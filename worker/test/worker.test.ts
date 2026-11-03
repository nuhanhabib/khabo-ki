import { describe, expect, it, vi } from 'vitest';

import { handle, type Env } from '../src/index';
import { cleanText, detectImageType, sanitizeAnalysis } from '../src/validate';

const JPEG: Uint8Array<ArrayBuffer> = new Uint8Array([0xff, 0xd8, 0xff, 0xe0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3]);
const DEVICE = '123e4567-e89b-42d3-a456-426614174000';

function env(overrides: Partial<Env> = {}): Env {
  const allow = { limit: async () => ({ success: true }) };
  return {
    GEMINI_API_KEY: 'test-gemini-key',
    APP_KEY: 'test-app-key',
    GEMINI_MODEL: 'test-model',
    DEVICE_LIMITER: allow,
    IP_LIMITER: allow,
    ...overrides,
  };
}

function request(opts: { body?: Uint8Array<ArrayBuffer>; headers?: Record<string, string>; method?: string; path?: string } = {}) {
  return new Request(`https://w.test${opts.path ?? '/analyze'}`, {
    method: opts.method ?? 'POST',
    body: opts.method === 'GET' ? undefined : (opts.body ?? JPEG),
    headers: { 'X-App-Key': 'test-app-key', 'X-Device-Id': DEVICE, ...opts.headers },
  });
}

function geminiReply(payload: unknown) {
  return vi.fn(async () =>
    new Response(
      JSON.stringify({ candidates: [{ content: { parts: [{ text: JSON.stringify(payload) }] } }] }),
      { status: 200 },
    ),
  );
}

describe('request checks', () => {
  it('rejects a wrong app key', async () => {
    const res = await handle(request({ headers: { 'X-App-Key': 'nope' } }), env());
    expect(res.status).toBe(401);
  });

  it('rejects a bad device id', async () => {
    const res = await handle(request({ headers: { 'X-Device-Id': 'x' } }), env());
    expect(res.status).toBe(400);
  });

  it('rejects non-image uploads', async () => {
    const res = await handle(request({ body: new TextEncoder().encode('<script>alert(1)</script>') }), env());
    expect(res.status).toBe(415);
  });

  it('rejects images over 2 MB', async () => {
    const big = new Uint8Array(2 * 1024 * 1024 + 1);
    big.set(JPEG);
    const res = await handle(request({ body: big }), env());
    expect(res.status).toBe(413);
  });

  it('rate limits', async () => {
    const deny = { limit: async () => ({ success: false }) };
    const res = await handle(request(), env({ DEVICE_LIMITER: deny }));
    expect(res.status).toBe(429);
  });

  it('refuses GET and preflight on /analyze and sends no CORS headers', async () => {
    const res = await handle(request({ method: 'OPTIONS' }), env());
    expect(res.status).toBe(405);
    expect(res.headers.get('Access-Control-Allow-Origin')).toBeNull();
  });

  it('fails closed when secrets are missing', async () => {
    const res = await handle(request(), env({ APP_KEY: '' }));
    expect(res.status).toBe(500);
  });
});

describe('analysis', () => {
  it('returns sanitized results with security headers and keeps the key out of the URL', async () => {
    const fetchFn = geminiReply({
      isFood: true,
      freshness: 'fresh',
      safetyScore: 140,
      en: { detected: ['<b>Tomato</b>'], risks: [], nutrition: ['Vitamin C'], portion: '1', budgetTip: 'Cheap' },
      bn: { detected: ['টমেটো'], risks: [], nutrition: [], portion: '১', budgetTip: 'সস্তা' },
    });
    const res = await handle(request(), env(), fetchFn as unknown as typeof fetch);
    expect(res.status).toBe(200);
    expect(res.headers.get('X-Content-Type-Options')).toBe('nosniff');
    const body = (await res.json()) as ReturnType<typeof sanitizeAnalysis>;
    expect(body.safetyScore).toBe(100);
    expect(body.en.detected).toEqual(['Tomato']);
    expect(body.bn.detected).toEqual(['টমেটো']);

    const [url, init] = fetchFn.mock.calls[0] as unknown as [string, RequestInit];
    expect(url).not.toContain('test-gemini-key');
    expect((init.headers as Record<string, string>)['x-goog-api-key']).toBe('test-gemini-key');
  });

  it('returns 502 without leaking details when Gemini fails', async () => {
    const fetchFn = vi.fn(async () => new Response('quota', { status: 429 }));
    const res = await handle(request(), env(), fetchFn as unknown as typeof fetch);
    expect(res.status).toBe(502);
    expect(await res.json()).toEqual({ error: 'analysis_failed' });
  });
});

describe('validators', () => {
  it('detects image types by magic bytes', () => {
    expect(detectImageType(JPEG)).toBe('image/jpeg');
    expect(detectImageType(new Uint8Array(12))).toBeNull();
  });

  it('cleans text', () => {
    expect(cleanText('<img src=x onerror=1>Fish\n\n ok')).toBe('Fish ok');
    expect(cleanText(42)).toBe('');
    expect(cleanText('a'.repeat(500)).length).toBe(200);
  });

  it('defaults unknown freshness and non-food', () => {
    const a = sanitizeAnalysis({ freshness: 'yummy', safetyScore: 'x' });
    expect(a.freshness).toBe('unknown');
    expect(a.safetyScore).toBe(0);
    expect(a.isFood).toBe(false);
  });
});
