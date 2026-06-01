// T-24 + T-25: AI Embedding Pipeline + AI Suggestions Edge Function
// Actions: rebuild_profile_embedding, rebuild_job_embedding, rebuild_ai_suggestions
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
  suggestions?: AiSuggestionRow[];
}

interface AiSuggestionRow {
  job_id: string;
  score: number;
  reason: string | null;
  cached_at: string;
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
      case "rebuild_ai_suggestions": {
        return await handleRebuildAiSuggestions(supabaseClient, supabaseAdmin, geminiApiKey);
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

/* ─── Profile data helpers ─────────────────────────────────────────── */

interface ProfileData {
  profile: any;
  skills: any[] | null;
  experiences: any[] | null;
  educations: any[] | null;
  certificates: any[] | null;
}

async function fetchProfileData(supabaseAdmin: any, userId: string): Promise<ProfileData> {
  const [{ data: profile }, { data: skills }, { data: experiences }, { data: educations }, { data: certificates }] =
    await Promise.all([
      supabaseAdmin.from("profiles").select("headline, bio, location").eq("id", userId).single(),
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

/** Parse a pgvector embedding from Supabase into a number[].
 *  Supabase may return vectors as plain arrays, strings like "[1,2,3]",
 *  or Float32Array objects depending on the driver version.
 */
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
  // Float32Array or similar typed array
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

  // Rate limit: 1 suggestion rebuild / 5 minutes
  const rateOk = await checkRateLimit(supabaseAdmin, user.id, "ai_suggestions", 5, 1);
  if (!rateOk) {
    return jsonResponse({
      status: "rateLimited",
      message: "Vui lòng thử lại sau vài phút.",
      updatedAt: new Date().toISOString(),
    });
  }

  // Step 1: Ensure profile embedding exists / is up to date
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
    console.log("Profile embedding unchanged, reusing existing. dims:", profileEmbedding?.length);
  } else {
    // Need to rebuild profile embedding
    // Check profile embedding rate limit separately
    const profileRateOk = await checkRateLimit(supabaseAdmin, user.id, "profile_embedding", 5, 1);
    if (!profileRateOk) {
      // If profile embedding is rate-limited but we have an old one, use it
      if (existingProfileEmbedding?.embedding) {
        profileEmbedding = parseEmbedding(existingProfileEmbedding.embedding);
        console.log("Profile embedding rate limited, using existing embedding. dims:", profileEmbedding?.length);
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

  // Step 2: Fetch active job embeddings with job data
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

  // Step 3: Compute cosine similarity
  const scored = [];
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

  // Sort descending by score
  scored.sort((a, b) => b.score - a.score);

  // Take top 20
  const top20 = scored.slice(0, 20);
  const now = new Date().toISOString();

  // Step 4: Delete old suggestions for this seeker
  const { error: deleteError } = await supabaseAdmin
    .from("ai_suggestions")
    .delete()
    .eq("seeker_id", user.id);

  if (deleteError) {
    console.error("Delete old suggestions error:", deleteError);
    return jsonResponse({ status: "error", message: "Failed to clear old suggestions" }, 500);
  }

  // Step 5: Insert fresh suggestions
  const inserts = top20.map((item) => ({
    id: crypto.randomUUID(),
    seeker_id: user.id,
    job_id: item.row.job_id as string,
    score: item.score,
    reason: null,
    cached_at: now,
  }));

  console.log("Inserting", inserts.length, "ai_suggestions rows");

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

  // Step 6: Log the suggestion rebuild
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
