import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.join(__dirname, '..', 'dist-pdfs');

// Load env
const envPath = path.join(process.env.HOME || process.env.USERPROFILE, '.openclaw', '.env');
const env = {};
fs.readFileSync(envPath, 'utf-8').split('\n').forEach(line => {
  const [k, ...v] = line.split('=');
  if (k && v.length) env[k.trim()] = v.join('=').trim();
});

const SUPABASE_URL = env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = env.SUPABASE_SERVICE_KEY;
const BUCKET = 'blueprints';

async function ensureBucket() {
  // Try creating bucket (idempotent)
  const res = await fetch(`${SUPABASE_URL}/storage/v1/bucket`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
      apikey: SUPABASE_SERVICE_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      id: BUCKET,
      name: BUCKET,
      public: false, // Private — use signed URLs only
    }),
  });
  const data = await res.json();
  if (res.ok) {
    console.log(`✓ Bucket "${BUCKET}" created`);
  } else if (data.message?.includes('already exists') || data.error === 'Duplicate') {
    console.log(`✓ Bucket "${BUCKET}" exists`);
  } else {
    console.log(`Bucket response:`, data);
  }
}

async function uploadFile(filePath, storagePath) {
  const fileBuffer = fs.readFileSync(filePath);
  
  const res = await fetch(`${SUPABASE_URL}/storage/v1/object/${BUCKET}/${storagePath}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
      apikey: SUPABASE_SERVICE_KEY,
      'Content-Type': 'application/pdf',
      'x-upsert': 'true',
    },
    body: fileBuffer,
  });

  const data = await res.json();
  if (res.ok) {
    const size = (fileBuffer.length / 1024).toFixed(0);
    console.log(`  ✓ Uploaded ${storagePath} (${size} KB)`);
  } else {
    console.error(`  ✗ Failed ${storagePath}:`, data);
  }
}

async function createSignedUrl(storagePath, expiresIn = 86400) {
  const res = await fetch(`${SUPABASE_URL}/storage/v1/object/sign/${BUCKET}/${storagePath}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
      apikey: SUPABASE_SERVICE_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ expiresIn }),
  });
  const data = await res.json();
  if (data.signedURL) {
    return `${SUPABASE_URL}/storage/v1${data.signedURL}`;
  }
  return null;
}

async function main() {
  await ensureBucket();

  const files = [
    'erronatus-blueprint-personal.pdf',
    'erronatus-blueprint-business.pdf',
    'erronatus-blueprint-enterprise.pdf',
  ];

  console.log('\nUploading PDFs to Supabase Storage...');
  for (const file of files) {
    await uploadFile(path.join(OUT, file), file);
  }

  console.log('\nTest signed URLs (24h expiry):');
  for (const file of files) {
    const url = await createSignedUrl(file, 86400);
    console.log(`  ${file}: ${url ? '✓' : '✗'}`);
  }

  console.log('\nDone. PDFs are in private bucket — accessible only via signed URLs.');
}

main().catch(console.error);
