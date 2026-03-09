import puppeteer from 'puppeteer';
import { marked } from 'marked';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const GUIDES = path.join(ROOT, 'guides');
const OUT = path.join(ROOT, 'dist-pdfs');
const FONTS = path.join(__dirname, 'fonts');

/* ────── Font embedding ────── */
function fontB64(file) {
  const p = path.join(FONTS, file);
  if (!fs.existsSync(p)) { console.warn(`⚠ missing ${file}`); return ''; }
  return fs.readFileSync(p).toString('base64');
}

function fontFaces() {
  // Embed fonts via base64 AND reference system-installed versions as fallback.
  // Chromium uses the system font renderer for locally-installed fonts (crisper hinting).
  // We embed as backup for environments where fonts aren't installed.
  return [
    ['Inter', 'Inter-Regular.woff2', 400],
    ['Inter', 'Inter-Medium.woff2', 500],
    ['Inter', 'Inter-SemiBold.woff2', 600],
    ['Inter', 'Inter-Bold.woff2', 700],
    ['Inter', 'Inter-ExtraBold.woff2', 800],
    ['JetBrains Mono', 'JetBrainsMono-Regular.woff2', 400],
    ['JetBrains Mono', 'JetBrainsMono-Medium.woff2', 500],
  ].map(([fam, file, wt]) => {
    const b = fontB64(file);
    // Use local() first so system-installed fonts take priority (better hinting)
    const localName = file.replace('.woff2', '').replace(/-/g, ' ');
    const src = b
      ? `local('${localName}'), url(data:font/woff2;base64,${b}) format('woff2')`
      : `local('${localName}')`;
    return `@font-face{font-family:'${fam}';src:${src};font-weight:${wt};font-style:normal;font-display:block;}`;
  }).join('\n');
}

/* ────── Markdown helpers ────── */
function readChapters(dir) {
  const d = path.join(GUIDES, dir);
  if (!fs.existsSync(d)) return [];
  return fs.readdirSync(d)
    .filter(f => f.endsWith('.md') && !f.startsWith('00-') && f !== 'README.md')
    .sort()
    .map(f => ({ name: f, md: fs.readFileSync(path.join(d, f), 'utf-8') }));
}

function title(md) { const m = md.match(/^#\s+(.+)$/m); return m ? m[1] : ''; }
function subtitle(md) { const m = md.match(/^##\s+(.+)$/m); return m ? m[1] : ''; }
function clean(t) { return t.replace(/^Chapter\s*\d+[:\s]*/i, ''); }

/* ────── HTML builder ────── */
function buildHTML(edition, dirs, label) {
  let chapters = [];
  dirs.forEach(d => chapters.push(...readChapters(d)));

  const accent = edition === 'enterprise' ? '#d97706' : '#7c3aed';
  const accentRGB = edition === 'enterprise' ? '217,119,6' : '124,58,237';
  const accentLight = edition === 'enterprise' ? '#fef3c7' : '#ede9fe';
  const accentDark = edition === 'enterprise' ? '#92400e' : '#4c1d95';

  const tocItems = chapters.map((ch, i) =>
    `<div class="toc-row"><span class="toc-n">${String(i+1).padStart(2,'0')}</span><span class="toc-t">${clean(title(ch.md))}</span></div>`
  ).join('\n');

  const chapterBlocks = chapters.map((ch, i) => {
    const t = clean(title(ch.md));
    const s = subtitle(ch.md);
    const html = marked.parse(ch.md, { gfm: true, breaks: false });
    return `
<div class="ch-open">
  <div class="ch-label">Chapter ${String(i+1).padStart(2,'0')}</div>
  <div class="ch-title">${t}</div>
  ${s ? `<div class="ch-sub">${s}</div>` : ''}
  <div class="ch-bar"></div>
</div>
<div class="ch-body">${html}</div>`;
  }).join('\n');

  return `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">
<style>
${fontFaces()}

/* === RESET === */
*,*::before,*::after{margin:0;padding:0;box-sizing:border-box}
html{-webkit-print-color-adjust:exact;print-color-adjust:exact}

body{
  font-family:'Inter','Segoe UI',system-ui,-apple-system,sans-serif;
  color:#1a1a1f;
  font-size:10pt;
  line-height:1.75;
  font-weight:400;
  /* CRITICAL: force all text to wrap within container */
  overflow-wrap:break-word;
  word-wrap:break-word;
  word-break:normal;
  max-width:100%;
}

/* === COVER — lives within printable area, no bleed tricks === */
.cover-page{
  page-break-after:always;
  background:#09090b;
  border-radius:0;
  padding:60px 40px;
  min-height:253mm; /* 297mm minus top+bottom Puppeteer margins */
  display:flex;
  flex-direction:column;
  justify-content:center;
  align-items:center;
  text-align:center;
  position:relative;
}
.cover-page *{color:#fafafa}
.cover-glow{
  position:absolute;inset:0;pointer-events:none;
  background:
    radial-gradient(ellipse at 30% 20%,rgba(${accentRGB},0.12) 0%,transparent 50%),
    radial-gradient(ellipse at 70% 80%,rgba(59,130,246,0.08) 0%,transparent 50%);
}
.cover-inner{position:relative;z-index:1}
.cover-logo{
  width:60px;height:60px;border-radius:15px;
  background:linear-gradient(135deg,#3b82f6,${accent});
  display:flex;align-items:center;justify-content:center;
  margin:0 auto 48px;
}
.cover-logo span{font-size:28pt;font-weight:800;letter-spacing:-0.02em}
.cover-h1{font-size:40pt;font-weight:800;letter-spacing:-0.035em;line-height:1.1;margin-bottom:12px}
.cover-sub{font-size:13pt;color:#a1a1aa;font-weight:400;letter-spacing:0.03em;margin-bottom:48px}
.cover-badge{
  font-size:8.5pt;font-weight:700;letter-spacing:0.22em;text-transform:uppercase;
  color:${accent};padding:10px 36px;
  border:1.5px solid rgba(${accentRGB},0.4);border-radius:100px;display:inline-block;
}
.cover-copy{
  position:absolute;bottom:40px;left:0;right:0;
  font-size:7.5pt;color:#52525b;line-height:1.8;text-align:center;
}

/* === TOC === */
.toc-page{page-break-after:always;padding-top:20px}
.toc-page h2{font-size:28pt;font-weight:800;color:#09090b;letter-spacing:-0.03em;margin-bottom:6px}
.toc-label{font-size:9pt;color:${accent};font-weight:600;letter-spacing:0.15em;text-transform:uppercase;margin-bottom:28px;display:block}
.toc-row{display:flex;align-items:baseline;gap:14px;padding:9px 0;border-bottom:1px solid #f0f0f2}
.toc-row:last-child{border-bottom:none}
.toc-n{font-family:'JetBrains Mono','Consolas',monospace;font-size:8.5pt;font-weight:500;color:${accent};flex-shrink:0;min-width:22px}
.toc-t{font-size:10pt;font-weight:500;color:#27272a}

/* === CHAPTER OPENER === */
.ch-open{
  page-break-before:always;
  page-break-after:avoid;
  page-break-inside:avoid;
  padding-top:60px;
  padding-bottom:16px;
}
.ch-label{font-family:'JetBrains Mono','Consolas',monospace;font-size:9pt;font-weight:500;color:${accent};letter-spacing:0.15em;text-transform:uppercase;margin-bottom:12px}
.ch-title{font-size:26pt;font-weight:800;color:#09090b;letter-spacing:-0.025em;line-height:1.15;margin-bottom:8px}
.ch-sub{font-size:11pt;color:#71717a;font-weight:400;line-height:1.5;margin-bottom:12px}
.ch-bar{height:3px;width:80px;background:linear-gradient(90deg,${accent},transparent)}

/* === CHAPTER BODY === */
.ch-body{padding-top:8px}

/* Hide the first H1 — already shown in opener */
.ch-body>h1:first-child{display:none}

.ch-body h1{font-size:20pt;font-weight:800;color:#09090b;margin-top:28px;margin-bottom:10px;page-break-after:avoid}
.ch-body h2{font-size:14pt;font-weight:700;color:#18181b;margin-top:26px;margin-bottom:8px;line-height:1.3;page-break-after:avoid}
.ch-body h3{font-size:11.5pt;font-weight:600;color:#27272a;margin-top:20px;margin-bottom:6px;page-break-after:avoid}
.ch-body h4{font-size:10pt;font-weight:600;color:#3f3f46;margin-top:14px;margin-bottom:5px;page-break-after:avoid}

.ch-body p{margin-bottom:9px;orphans:3;widows:3}
.ch-body strong{font-weight:600;color:#09090b}
.ch-body em{font-style:italic}
.ch-body a{color:#3b82f6;text-decoration:none}

/* Inline code */
.ch-body code{
  font-family:'JetBrains Mono','Consolas','Courier New',monospace;
  font-size:8.5pt;font-weight:400;
  background:${accentLight};color:${accentDark};
  padding:1px 4px;border-radius:3px;
}

/* Code blocks */
.ch-body pre{
  background:#18181b;color:#e4e4e7;
  padding:14px 18px;border-radius:8px;
  font-family:'JetBrains Mono','Consolas','Courier New',monospace;
  font-size:7.5pt;font-weight:400;line-height:1.6;
  margin:12px 0 16px;
  border-left:3px solid ${accent};
  /* WRAP — never clip */
  white-space:pre-wrap;
  overflow-wrap:break-word;
  word-wrap:break-word;
  word-break:normal;
  overflow:hidden;
  max-width:100%;
}
.ch-body pre code{background:none;color:inherit;padding:0;font-size:inherit;border-radius:0}

/* Blockquotes */
.ch-body blockquote{
  border-left:3px solid #06b6d4;padding:10px 14px;margin:12px 0;
  background:#f0fdfa;border-radius:0 6px 6px 0;
}
.ch-body blockquote p{color:#374151;font-size:9.5pt;margin-bottom:3px}
.ch-body blockquote p:last-child{margin-bottom:0}

/* Tables */
.ch-body table{width:100%;border-collapse:collapse;margin:12px 0;font-size:8.5pt;table-layout:fixed}
.ch-body th{background:#f9fafb;font-weight:600;text-align:left;padding:7px 8px;border-bottom:2px solid #e5e7eb;color:#18181b;font-size:7.5pt;text-transform:uppercase;letter-spacing:0.06em}
.ch-body td{padding:6px 8px;border-bottom:1px solid #f4f4f5;color:#3f3f46;overflow-wrap:break-word}
.ch-body tr:last-child td{border-bottom:none}

/* Lists */
.ch-body ul,.ch-body ol{padding-left:20px;margin:5px 0 12px}
.ch-body li{margin-bottom:4px;line-height:1.65}
.ch-body li>ul,.ch-body li>ol{margin-top:3px;margin-bottom:3px}

/* HR */
.ch-body hr{border:none;height:1px;background:linear-gradient(to right,transparent,#e5e7eb,transparent);margin:24px 0}

</style></head><body>

<div class="cover-page">
  <div class="cover-glow"></div>
  <div class="cover-inner">
    <div class="cover-logo"><span>E</span></div>
    <div class="cover-h1">The Erronatus<br>Blueprint</div>
    <div class="cover-sub">AI Automation with OpenClaw</div>
    <div class="cover-badge">${label}</div>
  </div>
  <div class="cover-copy">© 2026 Erronatus · erronatus.com · All rights reserved<br>Do not redistribute without permission</div>
</div>

<div class="toc-page">
  <div class="toc-label">${label}</div>
  <h2>Contents</h2>
  ${tocItems}
</div>

${chapterBlocks}

</body></html>`;
}

/* ────── PDF generation ────── */
async function generate() {
  fs.mkdirSync(OUT, { recursive: true });

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const tiers = [
    { ed: 'personal',   dirs: ['personal'],                        label: 'Personal Edition',   file: 'erronatus-blueprint-personal.pdf' },
    { ed: 'business',   dirs: ['personal', 'business'],            label: 'Business Edition',   file: 'erronatus-blueprint-business.pdf' },
    { ed: 'enterprise', dirs: ['personal', 'business', 'enterprise'], label: 'Enterprise Edition', file: 'erronatus-blueprint-enterprise.pdf' },
  ];

  for (const t of tiers) {
    console.log(`Generating ${t.label}...`);
    const html = buildHTML(t.ed, t.dirs, t.label);
    fs.writeFileSync(path.join(OUT, t.file.replace('.pdf', '.html')), html);

    const page = await browser.newPage();
    await page.setContent(html, { waitUntil: 'networkidle0', timeout: 60000 });

    // Wait for fonts
    await page.evaluate(async () => {
      await document.fonts.ready;
      for (const f of document.fonts) {
        if (f.status !== 'loaded') await f.load().catch(() => {});
      }
    });
    await new Promise(r => setTimeout(r, 2000));

    const pdf = await page.pdf({
      format: 'A4',
      printBackground: true,
      preferCSSPageSize: false, // Use Puppeteer margins, not CSS
      displayHeaderFooter: true,
      headerTemplate: '<span style="font-size:1px"></span>',
      footerTemplate: `<div style="width:100%;font-size:7pt;color:#a1a1aa;padding:0 20mm;display:flex;justify-content:space-between;font-family:system-ui,sans-serif;"><span>THE ERRONATUS BLUEPRINT</span><span>erronatus.com · <span class="pageNumber"></span></span></div>`,
      margin: { top: '20mm', bottom: '20mm', left: '20mm', right: '20mm' },
    });

    fs.writeFileSync(path.join(OUT, t.file), pdf);
    const kb = (pdf.length / 1024).toFixed(0);
    const pages = (pdf.toString('latin1').match(/\/Type\s*\/Page[^s]/g) || []).length;
    console.log(`  ✓ ${t.file} (${kb} KB, ~${pages} pages)`);
    await page.close();
  }

  await browser.close();
  console.log('\\nDone.');
}

generate().catch(e => { console.error('FATAL:', e); process.exit(1); });
