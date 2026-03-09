import puppeteer from 'puppeteer';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUT = path.resolve(__dirname, '..', 'dist-pdfs');

const testHTML = `<!DOCTYPE html>
<html><head><style>
body { font-family: sans-serif; font-size: 11pt; line-height: 1.75; color: #1a1a1f; overflow-wrap: break-word; }
h2 { font-size: 16pt; font-weight: 700; margin-top: 24px; margin-bottom: 8px; }
ul { padding-left: 20px; }
li { margin-bottom: 6px; }
pre { background: #18181b; color: #e4e4e7; padding: 16px; border-radius: 8px; border-left: 3px solid #7c3aed; white-space: pre-wrap; overflow-wrap: break-word; font-family: monospace; font-size: 8pt; line-height: 1.6; }
code { background: #ede9fe; color: #4c1d95; padding: 1px 4px; border-radius: 3px; font-family: monospace; font-size: 9pt; }
</style></head><body>
<h2>Margin & Wrapping Test</h2>
<p>This paragraph tests that text wraps properly within the printable area. Every line should end naturally at the right margin without being cut off or truncated. This is a long sentence designed to test the full width of the printable area including how it handles overflow-wrap and word-break behavior across the entire page width.</p>

<h2>Bullet List Test</h2>
<ul>
<li><strong>Telegram for</strong> instant messaging and real-time notifications to your phone wherever you are in the world</li>
<li><strong>Discord for</strong> team communication and community building purposes across multiple servers and channels</li>
<li><strong>Email for</strong> formal communications and professional outreach campaigns that require deliverability tracking</li>
</ul>

<h2>Numbered List Test</h2>
<ol>
<li>Working memory: Real-time conversation context that your agent uses during the current session</li>
<li>Session memory: Short-term logs stored in daily markdown files in the memory directory</li>
<li>Long-term memory: Curated knowledge in MEMORY.md that persists across all sessions permanently</li>
</ol>

<h2>Code Block Test</h2>
<pre>export const POST: APIRoute = async ({ request }) => {
  const Stripe = (await import('stripe')).default;
  const stripe = new Stripe(import.meta.env.STRIPE_SECRET_KEY, { apiVersion: '2023-10-16' });
  
  const session = await stripe.checkout.sessions.create({
    line_items: [{ price: priceId, quantity: 1 }],
    mode: 'payment',
    success_url: 'https://www.erronatus.com/thank-you?session_id={CHECKOUT_SESSION_ID}',
    cancel_url: 'https://www.erronatus.com/#pricing',
  });

  return new Response(JSON.stringify({ url: session.url }), { status: 200 });
};</pre>

<h2>Inline Code Test</h2>
<p>Set <code>STRIPE_SECRET_KEY</code> in your environment. The webhook at <code>/api/webhook</code> handles <code>checkout.session.completed</code> events and sends a delivery email with a signed URL that expires in 7 days.</p>

<p style="border: 2px solid red; padding: 8px; margin-top: 24px;">If you can see this entire red border box without any clipping on any edge, margins are working correctly.</p>
</body></html>`;

async function test() {
  const browser = await puppeteer.launch({ headless: true, args: ['--no-sandbox'] });
  const page = await browser.newPage();
  
  await page.setContent(testHTML, { waitUntil: 'networkidle0' });
  
  const pdf = await page.pdf({
    format: 'A4',
    printBackground: true,
    preferCSSPageSize: false,
    margin: { top: '20mm', bottom: '20mm', left: '20mm', right: '20mm' },
  });
  
  const pdfPath = path.join(OUT, 'margin-test.pdf');
  fs.writeFileSync(pdfPath, pdf);
  console.log('Test PDF:', Math.round(pdf.length/1024), 'KB');
  
  // Now open this test PDF and screenshot it via Chrome PDF viewer
  const page2 = await browser.newPage();
  const fileUrl = 'file:///' + pdfPath.replace(/\\/g, '/');
  await page2.goto(fileUrl, { timeout: 10000 }).catch(() => {});
  await new Promise(r => setTimeout(r, 3000));
  await page2.screenshot({ path: path.join(OUT, 'margin-test-view.png') });
  console.log('Screenshot saved');
  
  await browser.close();
}

test().catch(console.error);
