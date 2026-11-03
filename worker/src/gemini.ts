// Calls the Gemini API with a food photo and returns its parsed JSON answer.

const PROMPT = `You are "Khabo Ki?", a food safety and nutrition assistant for people in Bangladesh.
Look at the photo and judge ONLY what is visible.

Rules:
- If the photo does not show food or ingredients, set isFood=false and leave other lists empty.
- Judge freshness from visual signs only: mould, discolouration, slime, bruising, wilting,
  dull or cloudy fish eyes, grey gills, dry or cracked surfaces.
- Never claim to detect bacteria, microbes, chemicals or formalin. You may say a visual sign
  "may indicate" spoilage and suggest checking smell or texture.
- If unsure, use freshness "check_first" and a middle score. Safety beats confidence.
- safetyScore: 0-100, where 100 = clearly fresh and safe to cook/eat.
- Use local names where common (e.g. Rui fish, Hilsha/Ilish, Lau, Begun).
- budgetTip: one practical tip in Bangladeshi Taka (৳) context.
- Fill "en" in English and "bn" in natural Bangla with the same meaning.
- Keep every list item under 15 words. At most 5 items per list.`;

const TEXT_SCHEMA = {
  type: 'OBJECT',
  properties: {
    detected: { type: 'ARRAY', items: { type: 'STRING' } },
    risks: { type: 'ARRAY', items: { type: 'STRING' } },
    nutrition: { type: 'ARRAY', items: { type: 'STRING' } },
    portion: { type: 'STRING' },
    budgetTip: { type: 'STRING' },
  },
  required: ['detected', 'risks', 'nutrition', 'portion', 'budgetTip'],
};

const RESPONSE_SCHEMA = {
  type: 'OBJECT',
  properties: {
    isFood: { type: 'BOOLEAN' },
    freshness: { type: 'STRING', enum: ['fresh', 'check_first', 'spoiled', 'unknown'] },
    safetyScore: { type: 'INTEGER' },
    en: TEXT_SCHEMA,
    bn: TEXT_SCHEMA,
  },
  required: ['isFood', 'freshness', 'safetyScore', 'en', 'bn'],
};

export class UpstreamError extends Error {}

function toBase64(bytes: Uint8Array): string {
  let binary = '';
  const chunk = 0x8000;
  for (let i = 0; i < bytes.length; i += chunk) {
    binary += String.fromCharCode(...bytes.subarray(i, i + chunk));
  }
  return btoa(binary);
}

export async function analyzeWithGemini(
  bytes: Uint8Array,
  mimeType: string,
  apiKey: string,
  model: string,
  fetchFn: typeof fetch = fetch,
): Promise<unknown> {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`;
  const res = await fetchFn(url, {
    method: 'POST',
    // Key goes in a header, never in the URL, so it can't end up in logs.
    headers: { 'Content-Type': 'application/json', 'x-goog-api-key': apiKey },
    body: JSON.stringify({
      contents: [
        {
          role: 'user',
          parts: [{ text: PROMPT }, { inlineData: { mimeType, data: toBase64(bytes) } }],
        },
      ],
      generationConfig: {
        temperature: 0.2,
        responseMimeType: 'application/json',
        responseSchema: RESPONSE_SCHEMA,
      },
    }),
  });

  if (!res.ok) throw new UpstreamError(`Gemini returned ${res.status}`);
  const data = (await res.json()) as {
    candidates?: { content?: { parts?: { text?: string }[] } }[];
  };
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) throw new UpstreamError('Empty Gemini response');
  try {
    return JSON.parse(text);
  } catch {
    throw new UpstreamError('Gemini response was not JSON');
  }
}
