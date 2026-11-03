// Input checks for uploads and strict cleaning of the AI's JSON output.

export const MAX_IMAGE_BYTES = 2 * 1024 * 1024;

export type Freshness = 'fresh' | 'check_first' | 'spoiled' | 'unknown';

export interface LocalizedText {
  detected: string[];
  risks: string[];
  nutrition: string[];
  portion: string;
  budgetTip: string;
}

export interface Analysis {
  isFood: boolean;
  freshness: Freshness;
  safetyScore: number;
  en: LocalizedText;
  bn: LocalizedText;
}

/** Returns the image MIME type from its magic bytes, or null if not JPEG/PNG/WebP. */
export function detectImageType(bytes: Uint8Array): string | null {
  if (bytes.length < 12) return null;
  if (bytes[0] === 0xff && bytes[1] === 0xd8 && bytes[2] === 0xff) return 'image/jpeg';
  if (
    bytes[0] === 0x89 && bytes[1] === 0x50 && bytes[2] === 0x4e && bytes[3] === 0x47
  ) {
    return 'image/png';
  }
  const riff = String.fromCharCode(...bytes.subarray(0, 4));
  const webp = String.fromCharCode(...bytes.subarray(8, 12));
  if (riff === 'RIFF' && webp === 'WEBP') return 'image/webp';
  return null;
}

/** Device IDs are app-generated UUIDs; anything else is rejected. */
export function isValidDeviceId(id: string | null): id is string {
  return !!id && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(id);
}

/** Strips HTML tags, control characters and excess whitespace; caps length. */
export function cleanText(value: unknown, maxLen = 200): string {
  if (typeof value !== 'string') return '';
  return value
    .replace(/<[^>]*>/g, '')
    .replace(/[\u0000-\u001f\u007f]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, maxLen);
}

function cleanList(value: unknown, maxItems = 6): string[] {
  if (!Array.isArray(value)) return [];
  return value
    .map((v) => cleanText(v))
    .filter((v) => v.length > 0)
    .slice(0, maxItems);
}

function cleanLocalized(value: unknown): LocalizedText {
  const v = (value && typeof value === 'object' ? value : {}) as Record<string, unknown>;
  return {
    detected: cleanList(v.detected),
    risks: cleanList(v.risks),
    nutrition: cleanList(v.nutrition),
    portion: cleanText(v.portion),
    budgetTip: cleanText(v.budgetTip, 300),
  };
}

/** Turns untrusted model output into a safe, well-formed Analysis. */
export function sanitizeAnalysis(raw: unknown): Analysis {
  const r = (raw && typeof raw === 'object' ? raw : {}) as Record<string, unknown>;
  const freshness: Freshness = ['fresh', 'check_first', 'spoiled'].includes(
    r.freshness as string,
  )
    ? (r.freshness as Freshness)
    : 'unknown';
  const score = Number(r.safetyScore);
  return {
    isFood: r.isFood === true,
    freshness,
    safetyScore: Number.isFinite(score) ? Math.round(Math.min(100, Math.max(0, score))) : 0,
    en: cleanLocalized(r.en),
    bn: cleanLocalized(r.bn),
  };
}
