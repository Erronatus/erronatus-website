import { mdToPdf } from 'md-to-pdf';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const GUIDES = path.join(ROOT, 'guides');
const OUT = path.join(ROOT, 'dist-pdfs');

// PDF styling
const css = `
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500&display=swap');

  :root {
    --blue: #3b82f6;
    --purple: #8b5cf6;
    --cyan: #06b6d4;
    --dark: #0a0a12;
    --text: #e0e0e8;
    --muted: #7a7a8a;
  }

  body {
    font-family: 'Inter', -apple-system, sans-serif;
    color: #1a1a2e;
    line-height: 1.7;
    font-size: 11pt;
    max-width: 100%;
  }

  h1 {
    font-size: 28pt;
    font-weight: 800;
    letter-spacing: -0.5px;
    margin-top: 2em;
    margin-bottom: 0.5em;
    color: #0a0a12;
    border-bottom: 3px solid #8b5cf6;
    padding-bottom: 0.3em;
    page-break-before: always;
  }

  h1:first-of-type {
    page-break-before: avoid;
  }

  h2 {
    font-size: 18pt;
    font-weight: 700;
    color: #1a1a2e;
    margin-top: 1.5em;
    margin-bottom: 0.5em;
  }

  h3 {
    font-size: 14pt;
    font-weight: 600;
    color: #2a2a3e;
    margin-top: 1.2em;
    margin-bottom: 0.4em;
  }

  h4 {
    font-size: 12pt;
    font-weight: 600;
    color: #3a3a4e;
  }

  p {
    margin-bottom: 0.8em;
  }

  code {
    font-family: 'JetBrains Mono', 'Fira Code', monospace;
    font-size: 9pt;
    background: #f0f0f5;
    padding: 2px 6px;
    border-radius: 4px;
    color: #8b5cf6;
  }

  pre {
    background: #0d0d14;
    color: #e0e0e8;
    padding: 16px 20px;
    border-radius: 8px;
    font-size: 9pt;
    line-height: 1.5;
    overflow-x: auto;
    margin: 1em 0;
    border-left: 3px solid #8b5cf6;
  }

  pre code {
    background: none;
    color: inherit;
    padding: 0;
  }

  blockquote {
    border-left: 3px solid #06b6d4;
    padding-left: 16px;
    margin: 1em 0;
    color: #4a4a5e;
    font-style: italic;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    margin: 1em 0;
    font-size: 10pt;
  }

  th {
    background: #f0f0f5;
    font-weight: 600;
    text-align: left;
    padding: 8px 12px;
    border-bottom: 2px solid #ddd;
  }

  td {
    padding: 8px 12px;
    border-bottom: 1px solid #eee;
  }

  ul, ol {
    padding-left: 1.5em;
    margin-bottom: 0.8em;
  }

  li {
    margin-bottom: 0.3em;
  }

  strong {
    color: #0a0a12;
  }

  a {
    color: #3b82f6;
    text-decoration: none;
  }

  hr {
    border: none;
    border-top: 1px solid #ddd;
    margin: 2em 0;
  }

  .cover-page {
    page-break-after: always;
    text-align: center;
    padding-top: 200px;
  }

  .cover-page h1 {
    font-size: 42pt;
    border: none;
    background: linear-gradient(135deg, #3b82f6, #8b5cf6);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    page-break-before: avoid;
  }

  .cover-page .subtitle {
    font-size: 16pt;
    color: #7a7a8a;
    margin-top: 0.5em;
  }

  .cover-page .edition {
    font-size: 12pt;
    font-weight: 700;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: #8b5cf6;
    margin-top: 2em;
  }

  .cover-page .copyright {
    font-size: 9pt;
    color: #aaa;
    margin-top: 4em;
  }

  .toc-page {
    page-break-after: always;
  }

  .toc-page h2 {
    font-size: 24pt;
    margin-bottom: 1em;
  }

  .toc-page ul {
    list-style: none;
    padding: 0;
  }

  .toc-page li {
    padding: 6px 0;
    border-bottom: 1px solid #f0f0f5;
    font-size: 11pt;
  }
`;

const pdfOptions = {
  launch_options: { headless: true, args: ['--no-sandbox'] },
  pdf_options: {
    format: 'A4',
    margin: { top: '60px', bottom: '60px', left: '50px', right: '50px' },
    printBackground: true,
    displayHeaderFooter: true,
    headerTemplate: `
      <div style="width:100%;font-size:8pt;color:#aaa;padding:0 40px;font-family:sans-serif;">
        <span>The Erronatus Blueprint</span>
      </div>`,
    footerTemplate: `
      <div style="width:100%;font-size:8pt;color:#aaa;padding:0 40px;font-family:sans-serif;display:flex;justify-content:space-between;">
        <span>erronatus.com</span>
        <span>Page <span class="pageNumber"></span></span>
      </div>`,
  },
  stylesheet: [],
  css,
};

// Read and combine chapters
function readChapters(dir) {
  const files = fs.readdirSync(dir)
    .filter(f => f.endsWith('.md'))
    .sort();
  return files.map(f => ({
    name: f,
    content: fs.readFileSync(path.join(dir, f), 'utf-8'),
  }));
}

function buildToc(chapters) {
  const items = [];
  for (const ch of chapters) {
    // Extract first H1 from content
    const match = ch.content.match(/^#\s+(.+)$/m);
    if (match && !ch.name.includes('cover')) {
      items.push(match[1]);
    }
  }
  return items;
}

function buildPdf(edition, dirs, label) {
  let chapters = [];
  for (const dir of dirs) {
    const dirPath = path.join(GUIDES, dir);
    if (fs.existsSync(dirPath)) {
      chapters = chapters.concat(readChapters(dirPath));
    }
  }

  // Build cover
  const cover = `<div class="cover-page">

# The Erronatus Blueprint

<div class="subtitle">AI Automation with OpenClaw</div>

<div class="edition">${label}</div>

<div class="copyright">© 2026 Erronatus · erronatus.com<br/>All rights reserved. Do not redistribute.</div>

</div>`;

  // Build TOC
  const tocItems = buildToc(chapters);
  const toc = `<div class="toc-page">

## Table of Contents

${tocItems.map((t, i) => `${i + 1}. ${t}`).join('\n')}

</div>`;

  // Combine all content (skip cover.md files since we have custom cover)
  const body = chapters
    .filter(ch => !ch.name.includes('cover'))
    .map(ch => ch.content)
    .join('\n\n---\n\n');

  return `${cover}\n\n${toc}\n\n${body}`;
}

async function generate() {
  fs.mkdirSync(OUT, { recursive: true });

  const tiers = [
    {
      edition: 'personal',
      dirs: ['personal'],
      label: 'Personal Edition',
      file: 'erronatus-blueprint-personal.pdf',
    },
    {
      edition: 'business',
      dirs: ['personal', 'business'],
      label: 'Business Edition',
      file: 'erronatus-blueprint-business.pdf',
    },
    {
      edition: 'enterprise',
      dirs: ['personal', 'business', 'enterprise'],
      label: 'Enterprise Edition',
      file: 'erronatus-blueprint-enterprise.pdf',
    },
  ];

  for (const tier of tiers) {
    console.log(`Generating ${tier.label}...`);
    const markdown = buildPdf(tier.edition, tier.dirs, tier.label);

    const result = await mdToPdf(
      { content: markdown },
      pdfOptions
    );

    if (result && result.content) {
      const outPath = path.join(OUT, tier.file);
      fs.writeFileSync(outPath, result.content);
      const size = (result.content.length / 1024).toFixed(0);
      console.log(`  ✓ ${tier.file} (${size} KB)`);
    } else {
      console.error(`  ✗ Failed to generate ${tier.file}`);
    }
  }

  console.log('\nAll PDFs generated in dist-pdfs/');
}

generate().catch(console.error);
