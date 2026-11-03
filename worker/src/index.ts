// Khabo Ki? AI proxy. Keeps the Gemini key server-side and guards it with
// an app key, per-device and per-IP rate limits, and strict input/output checks.

import { analyzeWithGemini, UpstreamError } from './gemini';
import { detectImageType, isValidDeviceId, MAX_IMAGE_BYTES, sanitizeAnalysis } from './validate';

export interface RateLimiter {
  limit(options: { key: string }): Promise<{ success: boolean }>;
}

export interface Env {
  GEMINI_API_KEY: string;
  APP_KEY: string;
  GEMINI_MODEL: string;
  DEVICE_LIMITER: RateLimiter;
  IP_LIMITER: RateLimiter;
}

const SECURITY_HEADERS = {
  'Content-Type': 'application/json; charset=utf-8',
  'Cache-Control': 'no-store',
  'X-Content-Type-Options': 'nosniff',
  'X-Frame-Options': 'DENY',
  'Referrer-Policy': 'no-referrer',
  'Content-Security-Policy': "default-src 'none'; frame-ancestors 'none'",
  'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
};

function json(body: unknown, status = 200, extra: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...SECURITY_HEADERS, ...extra },
  });
}

const error = (status: number, code: string) => json({ error: code }, status);

/** Constant-time string comparison so the app key can't be guessed by timing. */
function safeEqual(a: string, b: string): boolean {
  const ea = new TextEncoder().encode(a);
  const eb = new TextEncoder().encode(b);
  let diff = ea.length ^ eb.length;
  for (let i = 0; i < Math.max(ea.length, eb.length); i++) {
    diff |= (ea[i] ?? 0) ^ (eb[i] ?? 0);
  }
  return diff === 0;
}

export async function handle(req: Request, env: Env, fetchFn: typeof fetch = fetch) {
  const url = new URL(req.url);

  if (url.pathname === '/health' && req.method === 'GET') return json({ ok: true });
  if (url.pathname !== '/analyze') return error(404, 'not_found');
  // The mobile app never sends CORS preflights; browsers get no CORS headers at all.
  if (req.method !== 'POST') return error(405, 'method_not_allowed');

  if (!env.APP_KEY || !env.GEMINI_API_KEY) return error(500, 'server_not_configured');
  if (!safeEqual(req.headers.get('X-App-Key') ?? '', env.APP_KEY)) {
    return error(401, 'unauthorized');
  }

  const deviceId = req.headers.get('X-Device-Id');
  if (!isValidDeviceId(deviceId)) return error(400, 'invalid_device');

  const ip = req.headers.get('CF-Connecting-IP') ?? 'unknown';
  const [byDevice, byIp] = await Promise.all([
    env.DEVICE_LIMITER.limit({ key: deviceId }),
    env.IP_LIMITER.limit({ key: ip }),
  ]);
  if (!byDevice.success || !byIp.success) {
    return json({ error: 'rate_limited' }, 429, { 'Retry-After': '60' });
  }

  const declared = Number(req.headers.get('Content-Length') ?? '0');
  if (declared > MAX_IMAGE_BYTES) return error(413, 'image_too_large');
  const bytes = new Uint8Array(await req.arrayBuffer());
  if (bytes.length === 0) return error(400, 'empty_body');
  if (bytes.length > MAX_IMAGE_BYTES) return error(413, 'image_too_large');

  const mimeType = detectImageType(bytes);
  if (!mimeType) return error(415, 'unsupported_image');

  try {
    const raw = await analyzeWithGemini(bytes, mimeType, env.GEMINI_API_KEY, env.GEMINI_MODEL, fetchFn);
    return json(sanitizeAnalysis(raw));
  } catch (e) {
    // Log only the error type — never the image, key or headers.
    console.error(e instanceof UpstreamError ? e.message : 'unexpected_error');
    return error(502, 'analysis_failed');
  }
}

export default {
  fetch: (req: Request, env: Env) => handle(req, env),
};
