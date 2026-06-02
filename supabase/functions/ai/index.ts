// T-24 + T-25 + T-26: AI Embedding Pipeline + AI Suggestions + Match Explanation
// Actions: rebuild_profile_embedding, rebuild_job_embedding, rebuild_ai_suggestions, explain_match
//
// Env vars required:
//   SUPABASE_URL
//   SUPABASE_ANON_KEY
//   SUPABASE_SERVICE_ROLE_KEY
//   GEMINI_API_KEY
// Env vars optional:
//   GEMINI_EMBEDDING_MODEL (default: gemini-embedding-001)
//   GEMINI_FLASH_MODEL (default: gemini-3.1-flash-lite)

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  action: string;
  jobId?: string;
  suggestionId?: string;
}

interface ApiResult {
  status: string;
  message: string;
  sourceHash?: string;
  updatedAt?: string;
  suggestions?: AiSuggestionRow[];
  suggestionId?: string;
  reason?: string;
  cached?: boolean;
}

interface AiSuggestionRow {
  job_id: string;
  score: number;
  reason: string | null;
  cached_at: string;
}

interface ProfileData {
  profile: any;
  skills: any[] | null;
  experiences: any[] | null;
  educations: any[] | null;
  certificates: any[] | null;
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

    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: {
        headers: { Authorization: req.headers.get("Authorization") || "" },
      },
    });

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
      case "rebuild_ai_suggestions": {
        return await handleRebuildAiSuggestions(supabaseClient, supabaseAdmin, geminiApiKey);
      }
      case "explain_match": {
        const suggestionId = body.suggestionId;
        if (!suggestionId) {
          return jsonResponse({ status: "error", message: "suggestionId is required" }, 400);
        }
        return await handleExplainMatch(supabaseClient, supabaseAdmin, geminiApiKey, suggestionId);
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

function jsonResponse(result: ApiResult, status = 200) {
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

/* ─── Gemini API helpers ───────────────────────────────────────────── */

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
  const embedding = json?.embedding?.values as number[];
  if (!embedding || embedding.length === 0) {
    throw new Error("Gemini returned empty embedding");
  }

  return embedding;
}

async function callGeminiFlash(apiKey: string, prompt: string): Promise<string> {
  const geminiFlashModel = Deno.env.get("GEMINI_FLASH_MODEL") || "gemini-3.1-flash-lite";
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${geminiFlashModel}:generateContent?key=${apiKey}`;

  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      contents: [
        {
          role: "user",
          parts: [{ text: prompt }],
        },
      ],
      generationConfig: {
        temperature: 0.4,
        maxOutputTokens: 350,
        responseMimeType: "application/json",
        thinkingConfig: {
          thinkingBudget: 0,
        },
      },
    }),
  });

  if (!response.ok) {
    const errText = await response.text();
    console.error("Gemini Flash API error:", response.status, errText);
    throw new Error(`Gemini Flash API error ${response.status}: ${errText}`);
  }

  const json = await response.json();
  const text = json?.candidates?.[0]?.content?.parts
    ?.map((part: { text?: string }) => part.text || "")
    .join("")
    .trim();

  if (!text) {
    throw new Error("Gemini Flash returned empty content");
  }

  return text;
}

/* ─── Profile data helpers ─────────────────────────────────────────── */

async function fetchProfileData(supabaseAdmin: any, userId: string): Promise<ProfileData> {
  const [{ data: profile }, { data: skills }, { data: experiences }, { data: educations }, { data: certificates }] =
    await Promise.all([
      supabaseAdmin.from("profiles").select("full_name, headline, bio, location").eq("id", userId).single(),
      supabaseAdmin.from("user_skills").select("level, skills(name)").eq("user_id", userId).order("skills(name)"),
      supabaseAdmin
        .from("work_experiences")
        .select("company, role, from_date, to_date, description, is_current")
        .eq("user_id", userId)
        .order("from_date", { ascending: false }),
      supabaseAdmin
        .from("educations")
        .select("school, degree, major, from_date, to_date")
        .eq("user_id", userId)
        .order("from_date", { ascending: false }),
      supabaseAdmin
        .from("certificates")
        .select("name, issuer, issued_at")
        .eq("user_id", userId)
        .order("issued_at", { ascending: false }),
    ]);

  return { profile, skills, experiences, educations, certificates };
}

function hasMeaningfulProfileData(data: ProfileData): boolean {
  return (
    (data.profile?.headline && (data.profile.headline as string).trim().length > 0) ||
    (data.profile?.bio && (data.profile.bio as string).trim().length > 0) ||
    (data.skills && data.skills.length > 0) ||
    (data.experiences && data.experiences.length > 0) ||
    (data.educations && data.educations.length > 0) ||
    (data.certificates && data.certificates.length > 0)
  );
}

function buildProfileSourceText(data: ProfileData): string {
  const { profile, skills, experiences, educations, certificates } = data;
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
      const duration = e.is_current ? `${e.from_date} to present` : `${e.from_date} to ${e.to_date || ""}`;
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

  const profileData = await fetchProfileData(supabaseAdmin, user.id);

  if (!hasMeaningfulProfileData(profileData)) {
    return jsonResponse({
      status: "missingData",
      message: "Hãy thêm headline, kỹ năng hoặc kinh nghiệm trước khi bật AI Match.",
    });
  }

  const sourceText = buildProfileSourceText(profileData);
  const sourceHash = await sha256Hex(sourceText);

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

  const rateOk = await checkRateLimit(supabaseAdmin, user.id, "profile_embedding", 5, 1);
  if (!rateOk) {
    return jsonResponse({
      status: "rateLimited",
      message: "Vui lòng thử lại sau vài phút.",
      sourceHash: existing?.source_hash,
      updatedAt: new Date().toISOString(),
    });
  }

  await insertRequestLog(supabaseAdmin, user.id, "profile_embedding");

  const embedding = await callGeminiEmbedding(geminiApiKey, sourceText);

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

/* ─── Job Embedding ────────────────────────────────────────────────── */

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

  const hasTitle = job.title && (job.title as string).trim().length > 0;
  const hasDescription = job.description && (job.description as string).trim().length > 0;
  const hasRequirements = job.requirements && (job.requirements as string).trim().length > 0;

  if (!hasTitle || (!hasDescription && !hasRequirements)) {
    return jsonResponse({
      status: "missingData",
      message: "Job post needs title and description/requirements to generate embedding.",
    });
  }

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

  const sourceText = buildJobSourceText(job, location, category, companyRow, requiredSkills);
  const sourceHash = await sha256Hex(sourceText);

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

/* ─── Cosine Similarity ────────────────────────────────────────────── */

function cosineSimilarity(a: number[], b: number[]): number {
  let dot = 0;
  let normA = 0;
  let normB = 0;
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  const denom = Math.sqrt(normA) * Math.sqrt(normB);
  if (denom === 0) return 0;
  return dot / denom;
}

function parseEmbedding(raw: any): number[] | null {
  if (!raw) return null;
  if (Array.isArray(raw)) {
    return raw.map((v) => Number(v)).filter((n) => !isNaN(n));
  }
  if (typeof raw === "string") {
    const cleaned = raw.trim().replace(/^\[|\]$/g, "");
    return cleaned
      .split(",")
      .map((s) => Number(s.trim()))
      .filter((n) => !isNaN(n));
  }
  if (raw.length !== undefined && typeof raw[Symbol.iterator] === "function") {
    return Array.from(raw as Iterable<number>)
      .map((v) => Number(v))
      .filter((n) => !isNaN(n));
  }
  return null;
}

/* ─── AI Suggestions ───────────────────────────────────────────────── */

async function handleRebuildAiSuggestions(
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
    return jsonResponse({ status: "error", message: "Only seekers can rebuild AI suggestions" }, 403);
  }

  const rateOk = await checkRateLimit(supabaseAdmin, user.id, "ai_suggestions", 5, 1);
  if (!rateOk) {
    return jsonResponse({
      status: "rateLimited",
      message: "Vui lòng thử lại sau vài phút.",
      updatedAt: new Date().toISOString(),
    });
  }

  const profileData = await fetchProfileData(supabaseAdmin, user.id);

  if (!hasMeaningfulProfileData(profileData)) {
    return jsonResponse({
      status: "missingData",
      message: "Hãy thêm headline, kỹ năng hoặc kinh nghiệm trước khi bật AI Match.",
    });
  }

  const sourceText = buildProfileSourceText(profileData);
  const sourceHash = await sha256Hex(sourceText);

  let profileEmbedding: number[] | null = null;

  const { data: existingProfileEmbedding } = await supabaseAdmin
    .from("profile_embeddings")
    .select("embedding, source_hash")
    .eq("user_id", user.id)
    .maybeSingle();

  if (existingProfileEmbedding && existingProfileEmbedding.source_hash === sourceHash) {
    profileEmbedding = parseEmbedding(existingProfileEmbedding.embedding);
  } else {
    const profileRateOk = await checkRateLimit(supabaseAdmin, user.id, "profile_embedding", 5, 1);
    if (!profileRateOk) {
      if (existingProfileEmbedding?.embedding) {
        profileEmbedding = parseEmbedding(existingProfileEmbedding.embedding);
      } else {
        return jsonResponse({
          status: "rateLimited",
          message: "Vui lòng thử lại sau vài phút.",
          updatedAt: new Date().toISOString(),
        });
      }
    } else {
      await insertRequestLog(supabaseAdmin, user.id, "profile_embedding");
      profileEmbedding = await callGeminiEmbedding(geminiApiKey, sourceText);

      const { error: profileUpsertError } = await supabaseAdmin
        .from("profile_embeddings")
        .upsert({
          user_id: user.id,
          embedding: profileEmbedding,
          source_hash: sourceHash,
          updated_at: new Date().toISOString(),
        });

      if (profileUpsertError) {
        console.error("Profile upsert error:", profileUpsertError);
        return jsonResponse({ status: "error", message: "Failed to save profile embedding" }, 500);
      }
    }
  }

  if (!profileEmbedding) {
    return jsonResponse({ status: "error", message: "Could not obtain profile embedding" }, 500);
  }

  const { data: jobRows, error: jobError } = await supabaseAdmin
    .from("job_embeddings")
    .select(`
      job_id,
      embedding,
      job_posts!inner(
        id,
        company_id,
        title,
        description,
        requirements,
        salary_min,
        salary_max,
        is_salary_visible,
        type,
        category_id,
        status,
        expires_at,
        created_at,
        updated_at,
        companies!inner(
          id,
          recruiter_id,
          name,
          logo_url,
          description,
          website,
          size,
          province,
          created_at,
          updated_at
        ),
        job_locations!inner(
          id,
          job_id,
          province,
          district,
          address,
          is_remote,
          created_at
        ),
        job_required_skills(
          job_id,
          skill_id,
          is_required,
          skills(name)
        ),
        job_categories(name)
      )
    `)
    .eq("job_posts.status", "active");

  if (jobError) {
    console.error("Job fetch error:", jobError);
    return jsonResponse({ status: "error", message: "Failed to fetch job embeddings" }, 500);
  }

  if (!jobRows || jobRows.length === 0) {
    return jsonResponse({
      status: "noJobEmbeddings",
      message: "Gợi ý đang được chuẩn bị. Một số Job Post cần được đồng bộ AI trước khi có Match Score.",
    });
  }

  const scored: Array<{ row: any; score: number }> = [];
  for (const row of jobRows) {
    const jobEmbedding = parseEmbedding(row.embedding);
    if (!jobEmbedding || jobEmbedding.length === 0) {
      console.log("Skipping job", row.job_id, "— no parseable embedding");
      continue;
    }

    const score = cosineSimilarity(profileEmbedding, jobEmbedding);
    if (isNaN(score) || !isFinite(score)) {
      console.log("Skipping job", row.job_id, "— NaN score");
      continue;
    }

    scored.push({ row, score });
  }

  if (scored.length === 0) {
    return jsonResponse({
      status: "noJobEmbeddings",
      message: "Gợi ý đang được chuẩn bị. Một số Job Post cần được đồng bộ AI trước khi có Match Score.",
    });
  }

  scored.sort((a, b) => b.score - a.score);
  const top20 = scored.slice(0, 20);
  const now = new Date().toISOString();

  const { error: deleteError } = await supabaseAdmin
    .from("ai_suggestions")
    .delete()
    .eq("seeker_id", user.id);

  if (deleteError) {
    console.error("Delete old suggestions error:", deleteError);
    return jsonResponse({ status: "error", message: "Failed to clear old suggestions" }, 500);
  }

  const inserts = top20.map((item) => ({
    id: crypto.randomUUID(),
    seeker_id: user.id,
    job_id: item.row.job_id as string,
    score: item.score,
    reason: null,
    cached_at: now,
  }));

  const { error: insertError } = await supabaseAdmin
    .from("ai_suggestions")
    .insert(inserts);

  if (insertError) {
    console.error("Insert suggestions error:", insertError);
    return jsonResponse({
      status: "error",
      message: `Failed to save suggestions: ${insertError.message || insertError.code || "unknown"}`,
    }, 500);
  }

  await insertRequestLog(supabaseAdmin, user.id, "ai_suggestions");

  const suggestions: AiSuggestionRow[] = top20.map((item) => ({
    job_id: item.row.job_id as string,
    score: item.score,
    reason: null,
    cached_at: now,
  }));

  return jsonResponse({
    status: "success",
    message: "AI đã cập nhật gợi ý việc làm.",
    suggestions,
    updatedAt: now,
  });
}

/* ─── Match Explanation ────────────────────────────────────────────── */

async function handleExplainMatch(
  supabaseClient: any,
  supabaseAdmin: any,
  geminiApiKey: string,
  suggestionId: string,
): Promise<Response> {
  const user = await getAuthUser(supabaseClient);
  if (!user) {
    return jsonResponse({ status: "error", message: "Unauthorized" }, 401);
  }

  const role = await getUserRole(supabaseAdmin, user.id);
  if (role !== "seeker") {
    return jsonResponse({ status: "error", message: "Only seekers can explain AI matches" }, 403);
  }

  const { data: suggestion, error: suggestionError } = await supabaseAdmin
    .from("ai_suggestions")
    .select("id, seeker_id, job_id, score, reason")
    .eq("id", suggestionId)
    .eq("seeker_id", user.id)
    .maybeSingle();

  if (suggestionError || !suggestion) {
    return jsonResponse({ status: "error", message: "AI Suggestion not found." }, 404);
  }

  const cachedReason = typeof suggestion.reason === "string" ? suggestion.reason.trim() : "";
  if (cachedReason.length > 0) {
    return jsonResponse({
      status: "success",
      message: "Match explanation loaded from cache.",
      suggestionId,
      reason: cachedReason,
      cached: true,
    });
  }

  const rateOk = await checkRateLimit(supabaseAdmin, user.id, "explain_match", 10, 3);
  if (!rateOk) {
    return jsonResponse({
      status: "rateLimited",
      message: "Bạn đã xem nhiều giải thích AI. Thử lại sau ít phút.",
      suggestionId,
    }, 429);
  }

  const profileData = await fetchProfileData(supabaseAdmin, user.id);
  const { data: jobContext, error: jobContextError } = await supabaseAdmin
    .from("job_posts")
    .select(`
      id,
      company_id,
      title,
      description,
      requirements,
      salary_min,
      salary_max,
      is_salary_visible,
      type,
      status,
      companies!inner(name),
      job_locations!inner(province, district, address, is_remote),
      job_required_skills(is_required, skills(name)),
      job_categories(name)
    `)
    .eq("id", suggestion.job_id)
    .eq("status", "active")
    .single();

  if (jobContextError || !jobContext) {
    return jsonResponse({ status: "error", message: "Job Post not found for AI explanation." }, 404);
  }

  await insertRequestLog(supabaseAdmin, user.id, "explain_match");

  const prompt = buildMatchExplanationPrompt({
    profileData,
    jobContext,
    matchScore: Number(suggestion.score ?? 0),
  });

  const rawText = await callGeminiFlash(geminiApiKey, prompt);
  const reason = formatMatchExplanation(rawText);

  if (!reason) {
    return jsonResponse({
      status: "error",
      message: "Không thể tạo giải thích AI từ phản hồi hiện tại.",
      suggestionId,
    }, 500);
  }

  const { data: updatedRows, error: updateError } = await supabaseAdmin
    .from("ai_suggestions")
    .update({ reason })
    .eq("id", suggestionId)
    .eq("seeker_id", user.id)
    .select("id, reason");

  if (updateError || !updatedRows || updatedRows.length === 0) {
    console.error("Update ai_suggestions.reason error:", updateError);
    return jsonResponse({
      status: "error",
      message: "Không thể lưu giải thích AI.",
      suggestionId,
    }, 500);
  }

  return jsonResponse({
    status: "success",
    message: "Match explanation generated.",
    suggestionId,
    reason,
    cached: false,
  });
}

function buildMatchExplanationPrompt({
  profileData,
  jobContext,
  matchScore,
}: {
  profileData: ProfileData;
  jobContext: any;
  matchScore: number;
}): string {
  const profile = profileData.profile ?? {};
  const userSkills = (profileData.skills ?? [])
    .map((item) => `- ${item.skills?.name || ""} (${item.level || "unknown"})`)
    .join("\n");
  const experiences = (profileData.experiences ?? [])
    .map((item) => {
      const duration = item.is_current ? `${item.from_date} - nay` : `${item.from_date} - ${item.to_date || ""}`;
      return `- ${item.role || ""} tại ${item.company || ""} (${duration})${item.description ? `: ${item.description}` : ""}`;
    })
    .join("\n");
  const educations = (profileData.educations ?? [])
    .map((item) => `- ${item.degree || ""} ${item.major ? `- ${item.major}` : ""} tại ${item.school || ""}`)
    .join("\n");
  const certificates = (profileData.certificates ?? [])
    .map((item) => `- ${item.name || ""}${item.issuer ? ` (${item.issuer})` : ""}`)
    .join("\n");

  const location = Array.isArray(jobContext.job_locations) ? jobContext.job_locations[0] : jobContext.job_locations;
  const company = jobContext.companies;
  const category = jobContext.job_categories;
  const requiredSkills = (jobContext.job_required_skills ?? [])
    .map((item: any) => `- ${item.skills?.name || ""} (${item.is_required ? "bắt buộc" : "ưu tiên"})`)
    .join("\n");

  return [
    "Bạn là AI của JobConnect.",
    "Nhiệm vụ: giải thích vì sao một Job Post có thể phù hợp với Seeker bằng tiếng Việt.",
    "Chỉ dùng dữ liệu được cung cấp. Không được bịa kỹ năng, kinh nghiệm, công ty, yêu cầu hoặc mức độ phù hợp.",
    "Giọng điệu phải được hiệu chỉnh theo Match Score:",
    "- >= 0.75: có thể dùng 'rất phù hợp'",
    "- 0.60 đến 0.74: dùng 'phù hợp'",
    "- 0.45 đến 0.59: dùng 'có tiềm năng phù hợp'",
    "- < 0.45: dùng 'có vài điểm liên quan'",
    "Không dùng lời lẽ tiêu cực hoặc khẳng định quá mức.",
    "Trả về JSON hợp lệ đúng schema sau:",
    '{"summary":"...","reasons":["...","...","..."],"missingSkills":["..."],"recommendation":"..."}',
    "Yêu cầu bắt buộc:",
    "- summary: đúng 1 câu kết luận ngắn",
    "- reasons: đúng 3 lý do, mỗi lý do ngắn, ưu tiên <= 25 từ",
    "- missingSkills: liệt kê ngắn nếu có, không bắt buộc",
    "- recommendation: 1 câu gợi ý nhẹ nhàng, có thể để chuỗi rỗng nếu không cần",
    "- Không thêm markdown, không thêm ```json, không thêm giải thích ngoài JSON",
    "",
    `Match Score: ${(matchScore * 100).toFixed(0)}%`,
    "",
    "=== PROFILE ===",
    `Full name: ${profile.full_name || ""}`,
    `Headline: ${profile.headline || ""}`,
    `Bio: ${profile.bio || ""}`,
    `Location: ${profile.location || ""}`,
    "User Skills:",
    userSkills || "- Không có dữ liệu",
    "Work Experiences:",
    experiences || "- Không có dữ liệu",
    "Educations:",
    educations || "- Không có dữ liệu",
    "Certificates:",
    certificates || "- Không có dữ liệu",
    "",
    "=== JOB POST ===",
    `Title: ${jobContext.title || ""}`,
    `Company: ${company?.name || ""}`,
    `Category: ${category?.name || ""}`,
    `Type: ${jobContext.type || ""}`,
    `Remote: ${location?.is_remote ? "Có" : "Không"}`,
    `Job Location: ${[location?.address, location?.district, location?.province].filter(Boolean).join(", ")}`,
    `Salary: ${jobContext.is_salary_visible ? `${jobContext.salary_min || ""}-${jobContext.salary_max || ""}` : "Ẩn"}`,
    `Description: ${jobContext.description || ""}`,
    `Requirements: ${jobContext.requirements || ""}`,
    "Required Skills:",
    requiredSkills || "- Không có dữ liệu",
  ].join("\n");
}

function formatMatchExplanation(rawText: string): string | null {
  const trimmed = rawText.trim();
  if (!trimmed) return null;

  const parsed = parseGeminiExplanationJson(trimmed) ?? parseGeminiExplanationJson(stripJsonFence(trimmed));
  if (parsed) {
    const formatted = formatStructuredExplanation(parsed);
    if (formatted) return formatted;
  }

  if (isReadableText(trimmed)) {
    return trimmed;
  }

  return null;
}

function parseGeminiExplanationJson(text: string): any | null {
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

function stripJsonFence(text: string): string {
  return text.replace(/^```json\s*/i, "").replace(/^```\s*/i, "").replace(/```$/i, "").trim();
}

function formatStructuredExplanation(payload: any): string | null {
  const summary = typeof payload?.summary === "string" ? payload.summary.trim() : "";
  const reasons = Array.isArray(payload?.reasons)
    ? payload.reasons.map((item: unknown) => String(item).trim()).filter(Boolean).slice(0, 3)
    : [];
  const recommendation = typeof payload?.recommendation === "string"
    ? payload.recommendation.trim()
    : "";

  if (!summary && reasons.length === 0 && !recommendation) {
    return null;
  }

  const lines: string[] = [];
  if (summary) lines.push(summary);
  if (reasons.length > 0) {
    lines.push("");
    reasons.forEach((reason, index) => lines.push(`${index + 1}. ${reason}`));
  }
  if (recommendation) {
    lines.push("");
    lines.push(`Gợi ý tiếp theo: ${recommendation}`);
  }

  return lines.join("\n").trim();
}

function isReadableText(text: string): boolean {
  return text.replace(/\s+/g, " ").trim().length >= 20;
}
