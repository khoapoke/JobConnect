// T-24: AI Embedding Pipeline Edge Function
// Actions: rebuild_profile_embedding, rebuild_job_embedding
//
// Env vars required:
//   SUPABASE_URL
//   SUPABASE_ANON_KEY
//   SUPABASE_SERVICE_ROLE_KEY
//   GEMINI_API_KEY
// Env vars optional:
//   GEMINI_EMBEDDING_MODEL (default: gemini-embedding-001)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  action: string;
  jobId?: string;
}

interface EmbeddingResult {
  status: string;
  message: string;
  sourceHash?: string;
  updatedAt?: string;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const supabaseServiceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const geminiApiKey = Deno.env.get("GEMINI_API_KEY");

    if (!supabaseUrl || !supabaseAnonKey || !supabaseServiceRoleKey) {
      return jsonResponse({
        status: "error",
        message: "Missing Supabase env vars. Check Edge Function secrets.",
      }, 500);
    }

    if (!geminiApiKey) {
      return jsonResponse({
        status: "error",
        message: "GEMINI_API_KEY env var is not set. Run: supabase secrets set GEMINI_API_KEY=your_key",
      }, 500);
    }

    const geminiModel = Deno.env.get("GEMINI_EMBEDDING_MODEL") || "gemini-embedding-001";

    // Client with caller JWT for auth checks
    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: { Authorization: req.headers.get("Authorization") || "" },
      },
    });

    // Admin client for DB ops (bypasses RLS)
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceRoleKey);

    const body: RequestBody = await req.json();
    const { action } = body;

    switch (action) {
      case "rebuild_profile_embedding": {
        return await handleRebuildProfileEmbedding(supabaseClient, supabaseAdmin, geminiApiKey);
      }
      case "rebuild_job_embedding": {
        const jobId = body.jobId;
        if (!jobId) {
          return jsonResponse({ status: "error", message: "jobId is required" }, 400);
        }
        return await handleRebuildJobEmbedding(supabaseClient, supabaseAdmin, geminiApiKey, jobId);
      }
      default: {
        return jsonResponse({ status: "error", message: `Unknown action: ${action}` }, 400);
      }
    }
  } catch (error: any) {
    console.error("Unhandled error:", error);
    return jsonResponse({ status: "error", message: error.message || "Internal server error" }, 500);
  }
});

function jsonResponse(result: EmbeddingResult, status = 200) {
  return new Response(JSON.stringify(result), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/* ─── Auth helpers ─────────────────────────────────────────────────── */

async function getAuthUser(supabaseClient: any) {
  const { data: { user }, error } = await supabaseClient.auth.getUser();
  if (error || !user) return null;
  return user;
}

async function getUserRole(supabaseAdmin: any, userId: string): Promise<string | null> {
  const { data, error } = await supabaseAdmin
    .from("profiles")
    .select("role")
    .eq("id", userId)
    .single();
  if (error || !data) return null;
  return data.role as string;
}

/* ─── Rate limiting ────────────────────────────────────────────────── */

async function checkRateLimit(
  supabaseAdmin: any,
  userId: string,
  requestType: string,
  windowMinutes: number,
  maxAttempts: number,
): Promise<boolean> {
  const { data, error } = await supabaseAdmin.rpc("check_ai_rate_limit", {
    p_user_id: userId,
    p_request_type: requestType,
    p_window_minutes: windowMinutes,
    p_max_attempts: maxAttempts,
  });

  if (error) {
    // Fallback if RPC doesn't exist: count manually
    const cutoff = new Date(Date.now() - windowMinutes * 60_000).toISOString();
    const { count } = await supabaseAdmin
      .from("ai_request_logs")
      .select("*", { count: "exact", head: true })
      .eq("user_id", userId)
      .eq("request_type", requestType)
      .gte("created_at", cutoff);

    return (count ?? 0) < maxAttempts;
  }

  return data === true;
}

async function insertRequestLog(supabaseAdmin: any, userId: string, requestType: string) {
  await supabaseAdmin.from("ai_request_logs").insert({
    user_id: userId,
    request_type: requestType,
  });
}

/* ─── Hash helper ──────────────────────────────────────────────────── */

async function sha256Hex(text: string): Promise<string> {
  const encoder = new TextEncoder();
  const data = encoder.encode(text);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, "0")).join("");
}

/* ─── Gemini embedding ─────────────────────────────────────────────── */

async function callGeminiEmbedding(apiKey: string, text: string): Promise<number[]> {
  const geminiModel = Deno.env.get("GEMINI_EMBEDDING_MODEL") || "gemini-embedding-001";
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:embedContent?key=${apiKey}`;

  const requestBody = {
    content: {
      parts: [{ text }],
    },
    taskType: "SEMANTIC_SIMILARITY",
    outputDimensionality: 768,
  };

  console.log("Calling Gemini embedding API with text length:", text.length);

  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(requestBody),
  });

  if (!response.ok) {
    const errText = await response.text();
    console.error("Gemini API error:", response.status, errText);
    throw new Error(`Gemini API error ${response.status}: ${errText}`);
  }

  const json = await response.json();
  console.log("Gemini response keys:", Object.keys(json));

  const embedding = json?.embedding?.values as number[];
  if (!embedding || embedding.length === 0) {
    throw new Error("Gemini returned empty embedding");
  }
  console.log("Embedding generated, dimensions:", embedding.length);
  return embedding;
}

/* ─── Profile Embedding ────────────────────────────────────────────── */

async function handleRebuildProfileEmbedding(
  supabaseClient: any,
  supabaseAdmin: any,
  geminiApiKey: string,
): Promise<Response> {
  const user = await getAuthUser(supabaseClient);
  if (!user) {
    return jsonResponse({ status: "error", message: "Unauthorized" }, 401);
  }

  const role = await getUserRole(supabaseAdmin, user.id);
  if (role !== "seeker") {
    return jsonResponse({ status: "error", message: "Only seekers can rebuild profile embedding" }, 403);
  }

  // Fetch profile data
  const { data: profile } = await supabaseAdmin
    .from("profiles")
    .select("headline, bio, location")
    .eq("id", user.id)
    .single();

  const { data: skills } = await supabaseAdmin
    .from("user_skills")
    .select("level, skills(name)")
    .eq("user_id", user.id)
    .order("skills(name)");

  const { data: experiences } = await supabaseAdmin
    .from("work_experiences")
    .select("company, role, from_date, to_date, description, is_current")
    .eq("user_id", user.id)
    .order("from_date", { ascending: false });

  const { data: educations } = await supabaseAdmin
    .from("educations")
    .select("school, degree, major, from_date, to_date")
    .eq("user_id", user.id)
    .order("from_date", { ascending: false });

  const { data: certificates } = await supabaseAdmin
    .from("certificates")
    .select("name, issuer, issued_at")
    .eq("user_id", user.id)
    .order("issued_at", { ascending: false });

  // Missing-data check
  const hasMeaningfulData =
    (profile?.headline && (profile.headline as string).trim().length > 0) ||
    (profile?.bio && (profile.bio as string).trim().length > 0) ||
    (skills && skills.length > 0) ||
    (experiences && experiences.length > 0) ||
    (educations && educations.length > 0) ||
    (certificates && certificates.length > 0);

  if (!hasMeaningfulData) {
    return jsonResponse({
      status: "missingData",
      message: "Hãy thêm headline, kỹ năng hoặc kinh nghiệm trước khi bật AI Match.",
    });
  }

  // Build canonical source text
  const sourceText = buildProfileSourceText(profile, skills, experiences, educations, certificates);
  const sourceHash = await sha256Hex(sourceText);

  // Check existing hash
  const { data: existing } = await supabaseAdmin
    .from("profile_embeddings")
    .select("source_hash")
    .eq("user_id", user.id)
    .maybeSingle();

  if (existing && existing.source_hash === sourceHash) {
    return jsonResponse({
      status: "unchanged",
      message: "AI Match đã sẵn sàng.",
      sourceHash,
      updatedAt: new Date().toISOString(),
    });
  }

  // Rate limit: 1 attempt / 5 minutes
  const rateOk = await checkRateLimit(supabaseAdmin, user.id, "profile_embedding", 5, 1);
  if (!rateOk) {
    return jsonResponse({
      status: "rateLimited",
      message: "Vui lòng thử lại sau vài phút.",
      sourceHash: existing?.source_hash,
      updatedAt: new Date().toISOString(),
    });
  }

  // Log attempt before calling Gemini
  await insertRequestLog(supabaseAdmin, user.id, "profile_embedding");

  // Call Gemini
  const embedding = await callGeminiEmbedding(geminiApiKey, sourceText);

  // Upsert
  const { error: upsertError } = await supabaseAdmin
    .from("profile_embeddings")
    .upsert({
      user_id: user.id,
      embedding,
      source_hash: sourceHash,
      updated_at: new Date().toISOString(),
    });

  if (upsertError) {
    console.error("Upsert error:", upsertError);
    return jsonResponse({ status: "error", message: "Failed to save embedding" }, 500);
  }

  return jsonResponse({
    status: "generated",
    message: "AI đã cập nhật Profile Embedding.",
    sourceHash,
    updatedAt: new Date().toISOString(),
  });
}

function buildProfileSourceText(
  profile: any,
  skills: any[] | null,
  experiences: any[] | null,
  educations: any[] | null,
  certificates: any[] | null,
): string {
  const parts: string[] = [];

  if (profile?.headline) parts.push(`Headline: ${profile.headline}`);
  if (profile?.bio) parts.push(`Bio: ${profile.bio}`);
  if (profile?.location) parts.push(`Location: ${profile.location}`);

  if (skills && skills.length > 0) {
    parts.push("Skills:");
    for (const s of skills) {
      const name = s.skills?.name || "";
      parts.push(`- ${name} (${s.level})`);
    }
  }

  if (experiences && experiences.length > 0) {
    parts.push("Work Experience:");
    for (const e of experiences) {
      const duration = e.is_current
        ? `${e.from_date} to present`
        : `${e.from_date} to ${e.to_date || ""}`;
      parts.push(`- ${e.role} at ${e.company} (${duration})`);
      if (e.description) parts.push(`  ${e.description}`);
    }
  }

  if (educations && educations.length > 0) {
    parts.push("Education:");
    for (const edu of educations) {
      const degree = [edu.degree, edu.major].filter(Boolean).join(" in ");
      const duration = `${edu.from_date} to ${edu.to_date || ""}`;
      parts.push(`- ${degree} at ${edu.school} (${duration})`);
    }
  }

  if (certificates && certificates.length > 0) {
    parts.push("Certificates:");
    for (const cert of certificates) {
      parts.push(`- ${cert.name} issued by ${cert.issuer || "unknown"} (${cert.issued_at || ""})`);
    }
  }

  return parts.join("\n");
}

/* ─── Job Embedding ──────────────────────────────────────────────────── */

async function handleRebuildJobEmbedding(
  supabaseClient: any,
  supabaseAdmin: any,
  geminiApiKey: string,
  jobId: string,
): Promise<Response> {
  const user = await getAuthUser(supabaseClient);
  if (!user) {
    return jsonResponse({ status: "error", message: "Unauthorized" }, 401);
  }

  const role = await getUserRole(supabaseAdmin, user.id);
  if (role !== "recruiter") {
    return jsonResponse({ status: "error", message: "Only recruiters can rebuild job embedding" }, 403);
  }

  // Verify job belongs to recruiter's company
  const { data: company } = await supabaseAdmin
    .from("companies")
    .select("id")
    .eq("recruiter_id", user.id)
    .single();

  if (!company) {
    return jsonResponse({ status: "error", message: "Recruiter has no company" }, 403);
  }

  const { data: job } = await supabaseAdmin
    .from("job_posts")
    .select("company_id, status, title, description, requirements, salary_min, salary_max, type, category_id")
    .eq("id", jobId)
    .single();

  if (!job) {
    return jsonResponse({ status: "error", message: "Job not found" }, 404);
  }

  if (job.company_id !== company.id) {
    return jsonResponse({ status: "error", message: "Job does not belong to your company" }, 403);
  }

  if (job.status !== "active") {
    return jsonResponse({ status: "missingData", message: "Job must be active to generate embedding" });
  }

  // Missing data check
  const hasTitle = job.title && (job.title as string).trim().length > 0;
  const hasDescription = job.description && (job.description as string).trim().length > 0;
  const hasRequirements = job.requirements && (job.requirements as string).trim().length > 0;

  if (!hasTitle || (!hasDescription && !hasRequirements)) {
    return jsonResponse({
      status: "missingData",
      message: "Job post needs title and description/requirements to generate embedding.",
    });
  }

  // Fetch related data
  const { data: location } = await supabaseAdmin
    .from("job_locations")
    .select("province, district, address, is_remote")
    .eq("job_id", jobId)
    .maybeSingle();

  const { data: category } = await supabaseAdmin
    .from("job_categories")
    .select("name")
    .eq("id", job.category_id)
    .maybeSingle();

  const { data: companyRow } = await supabaseAdmin
    .from("companies")
    .select("name")
    .eq("id", job.company_id)
    .single();

  const { data: requiredSkills } = await supabaseAdmin
    .from("job_required_skills")
    .select("is_required, skills(name)")
    .eq("job_id", jobId)
    .order("skills(name)");

  // Build source text
  const sourceText = buildJobSourceText(job, location, category, companyRow, requiredSkills);
  const sourceHash = await sha256Hex(sourceText);

  // Check existing hash
  const { data: existing } = await supabaseAdmin
    .from("job_embeddings")
    .select("source_hash")
    .eq("job_id", jobId)
    .maybeSingle();

  if (existing && existing.source_hash === sourceHash) {
    return jsonResponse({
      status: "unchanged",
      message: "Job embedding is up to date.",
      sourceHash,
      updatedAt: new Date().toISOString(),
    });
  }

  // Rate limit: 1 attempt / 1 minute for recruiters
  const rateOk = await checkRateLimit(supabaseAdmin, user.id, "job_embedding", 1, 1);
  if (!rateOk) {
    return jsonResponse({
      status: "rateLimited",
      message: "Vui lòng thử lại sau vài phút.",
      sourceHash: existing?.source_hash,
      updatedAt: new Date().toISOString(),
    });
  }

  await insertRequestLog(supabaseAdmin, user.id, "job_embedding");

  const embedding = await callGeminiEmbedding(geminiApiKey, sourceText);

  const { error: upsertError } = await supabaseAdmin
    .from("job_embeddings")
    .upsert({
      job_id: jobId,
      embedding,
      source_hash: sourceHash,
      updated_at: new Date().toISOString(),
    });

  if (upsertError) {
    console.error("Upsert error:", upsertError);
    return jsonResponse({ status: "error", message: "Failed to save embedding" }, 500);
  }

  return jsonResponse({
    status: "generated",
    message: "Job embedding generated successfully.",
    sourceHash,
    updatedAt: new Date().toISOString(),
  });
}

function buildJobSourceText(
  job: any,
  location: any,
  category: any,
  company: any,
  skills: any[] | null,
): string {
  const parts: string[] = [];

  parts.push(`Title: ${job.title || ""}`);
  if (company?.name) parts.push(`Company: ${company.name}`);
  if (category?.name) parts.push(`Category: ${category.name}`);
  if (job.type) parts.push(`Type: ${job.type}`);
  if (job.salary_min != null || job.salary_max != null) {
    const min = job.salary_min ?? "";
    const max = job.salary_max ?? "";
    parts.push(`Salary: ${min}-${max}`);
  }

  if (location) {
    const locParts = [location.province, location.district, location.address].filter(Boolean);
    const locText = locParts.join(", ");
    const remoteText = location.is_remote ? " (Remote available)" : "";
    parts.push(`Location: ${locText}${remoteText}`);
  }

  if (job.description) parts.push(`Description: ${job.description}`);
  if (job.requirements) parts.push(`Requirements: ${job.requirements}`);

  if (skills && skills.length > 0) {
    parts.push("Required Skills:");
    for (const s of skills) {
      const name = s.skills?.name || "";
      const required = s.is_required ? "required" : "preferred";
      parts.push(`- ${name} (${required})`);
    }
  }

  return parts.join("\n");
}
