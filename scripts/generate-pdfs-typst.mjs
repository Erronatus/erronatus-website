import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const GUIDES = path.join(ROOT, 'guides');
const OUT = path.join(ROOT, 'dist-pdfs');
const FONTS = path.join(__dirname, 'fonts');

fs.mkdirSync(OUT, { recursive: true });

/* ────── Read chapters ────── */
function readChapters(dir) {
  const d = path.join(GUIDES, dir);
  if (!fs.existsSync(d)) return [];
  return fs.readdirSync(d)
    .filter(f => f.endsWith('.md') && !f.startsWith('00-') && f !== 'README.md')
    .sort()
    .map(f => ({ name: f, md: fs.readFileSync(path.join(d, f), 'utf-8') }));
}

function extractTitle(md) {
  const m = md.match(/^#\s+(.+)$/m);
  return m ? m[1] : '';
}
function extractSubtitle(md) {
  const m = md.match(/^##\s+(.+)$/m);
  return m ? m[1] : '';
}
function clean(t) { return t.replace(/^Chapter\s*\d+[:\s]*/i, ''); }

/* ────── Convert markdown to Typst via pandoc ────── */
function mdToTypst(mdContent) {
  // Write to temp file, run pandoc, read result
  const tmp = path.join(OUT, '_tmp_chapter.md');
  fs.writeFileSync(tmp, mdContent);
  try {
    const result = execSync(`pandoc "${tmp}" -f markdown-citations -t typst --wrap=none`, {
      encoding: 'utf-8',
      timeout: 30000,
    });
    return result;
  } catch (e) {
    console.error('  pandoc error:', e.stderr?.slice(0, 200));
    return mdContent; // fallback
  } finally {
    try { fs.unlinkSync(tmp); } catch {}
  }
}

/* ────── Build Typst document ────── */
function buildTypst(edition, dirs, label) {
  let chapters = [];
  dirs.forEach(d => chapters.push(...readChapters(d)));

  const accent = edition === 'enterprise' ? '"#d97706"' : '"#7c3aed"';
  const accentLight = edition === 'enterprise' ? '"#fef3c7"' : '"#ede9fe"';
  const accentDark = edition === 'enterprise' ? '"#92400e"' : '"#4c1d95"';

  // TOC entries
  const tocEntries = chapters.map((ch, i) => {
    const t = clean(extractTitle(ch.md));
    const num = String(i + 1).padStart(2, '0');
    return `  #grid(columns: (30pt, 1fr), gutter: 8pt,
    text(font: "JetBrains Mono", size: 8pt, weight: "medium", fill: rgb(${accent}))[${num}],
    text(size: 10pt, weight: "medium")[${t}],
  )
  #v(4pt)
  #line(length: 100%, stroke: 0.3pt + luma(240))`;
  }).join('\n');

  // Convert each chapter
  const chapterBlocks = chapters.map((ch, i) => {
    const t = clean(extractTitle(ch.md));
    const s = extractSubtitle(ch.md);
    const num = String(i + 1).padStart(2, '0');

    // Strip the first H1 and first H2 from markdown before converting
    // (we render them in the chapter opener)
    let mdClean = ch.md.replace(/^#\s+.+$/m, ''); // Remove first H1

    // Convert via pandoc
    const typstBody = mdToTypst(mdClean);

    return `
// ═══ Chapter ${num} ═══
#pagebreak()
#v(60pt)
#text(font: "JetBrains Mono", size: 9pt, weight: "medium", fill: rgb(${accent}), tracking: 1.5pt)[CHAPTER ${num}]
#v(12pt)
#text(size: 24pt, weight: "black", tracking: -0.5pt)[${t.replace(/[#\[\]]/g, c => '\\' + c)}]
${s ? `#v(6pt)\n#text(size: 11pt, fill: luma(120))[${s.replace(/[#\[\]]/g, c => '\\' + c)}]` : ''}
#v(10pt)
#rect(width: 80pt, height: 3pt, fill: gradient.linear(rgb(${accent}), white))
#v(20pt)

${typstBody}
`;
  }).join('\n');

  return `
// The Erronatus Blueprint — ${label}
// Generated via Pandoc + Typst

#set document(
  title: "The Erronatus Blueprint — ${label}",
  author: "Erronatus",
)

#set page(
  paper: "a4",
  margin: (top: 22mm, bottom: 24mm, left: 20mm, right: 20mm),
  footer: context {
    let pg = counter(page).get().first()
    if pg > 1 {
      grid(
        columns: (1fr, 1fr),
        text(size: 7pt, fill: luma(160), tracking: 0.5pt)[THE ERRONATUS BLUEPRINT],
        align(right, text(size: 7pt, fill: luma(160))[erronatus.com · #pg]),
      )
    }
  },
)

#set text(
  font: "Inter",
  size: 10pt,
  fill: rgb("#1a1a1f"),
  lang: "en",
)

#set par(leading: 0.75em, justify: true)

#set heading(numbering: none)
#show heading.where(level: 1): set text(size: 20pt, weight: "bold", fill: rgb("#09090b"))
#show heading.where(level: 1): it => { v(24pt); it; v(10pt) }
#show heading.where(level: 2): set text(size: 15pt, weight: "bold", fill: rgb("#18181b"))
#show heading.where(level: 2): it => { v(20pt); it; v(8pt) }
#show heading.where(level: 3): set text(size: 12pt, weight: "semibold", fill: rgb("#27272a"))
#show heading.where(level: 3): it => { v(14pt); it; v(6pt) }
#show heading.where(level: 4): set text(size: 10.5pt, weight: "semibold", fill: rgb("#3f3f46"))
#show heading.where(level: 4): it => { v(10pt); it; v(4pt) }

// Code blocks — dark bg with accent border
#show raw.where(block: true): it => block(
  fill: rgb("#18181b"),
  inset: (x: 16pt, y: 14pt),
  radius: 6pt,
  width: 100%,
  stroke: (left: 3pt + rgb(${accent})),
  text(font: "JetBrains Mono", size: 7.5pt, fill: rgb("#e4e4e7"), weight: "regular")[#it]
)

// Inline code
#show raw.where(block: false): it => box(
  fill: rgb(${accentLight}),
  inset: (x: 3pt, y: 1pt),
  radius: 2pt,
  text(font: "JetBrains Mono", size: 8.5pt, fill: rgb(${accentDark}), weight: "regular")[#it]
)

#show strong: set text(weight: "semibold", fill: rgb("#09090b"))
#show link: set text(fill: rgb("#3b82f6"))

#set list(indent: 16pt, body-indent: 6pt)
#set enum(indent: 16pt, body-indent: 6pt)

#set table(stroke: 0.5pt + luma(220), inset: 8pt)

// Pandoc compatibility
#let horizontalrule = line(length: 100%, stroke: 0.5pt + luma(200))

// ═══════════════════════════════════
// COVER PAGE
// ═══════════════════════════════════
#page(margin: 0pt, footer: none)[
  #rect(width: 100%, height: 100%, fill: rgb("#09090b"))[
    #place(center + horizon)[
      #block(width: 80%)[
        #align(center)[
          #rect(width: 56pt, height: 56pt, radius: 14pt,
            fill: gradient.linear(rgb("#3b82f6"), rgb(${accent}), angle: 135deg))[
            #place(center + horizon)[
              #text(size: 26pt, weight: "extrabold", fill: white, tracking: -0.5pt)[E]
            ]
          ]
          #v(40pt)
          #text(size: 40pt, weight: "extrabold", fill: rgb("#fafafa"), tracking: -1pt)[
            The Erronatus#linebreak()Blueprint
          ]
          #v(8pt)
          #text(size: 13pt, fill: luma(120), tracking: 0.3pt)[
            AI Automation with OpenClaw
          ]
          #v(40pt)
          #rect(
            radius: 50pt,
            stroke: 1.5pt + rgb(${accent}).transparentize(60%),
            inset: (x: 28pt, y: 8pt),
          )[
            #text(size: 8.5pt, weight: "bold", fill: rgb(${accent}), tracking: 2pt)[
              ${label.toUpperCase()}
            ]
          ]
        ]
      ]
    ]
    #place(bottom + center, dy: -40pt)[
      #text(size: 7.5pt, fill: luma(90), tracking: 0.3pt)[
        © 2026 Erronatus · erronatus.com · All rights reserved#linebreak()
        Do not redistribute without permission
      ]
    ]
  ]
]

// ═══════════════════════════════════
// TABLE OF CONTENTS
// ═══════════════════════════════════
#pagebreak()
#text(size: 9pt, weight: "semibold", fill: rgb(${accent}), tracking: 1.5pt)[${label.toUpperCase()}]
#v(4pt)
#text(size: 28pt, weight: "extrabold", tracking: -0.5pt)[Contents]
#v(24pt)

${tocEntries}

// ═══════════════════════════════════
// CHAPTERS
// ═══════════════════════════════════
${chapterBlocks}
`;
}

/* ────── Generate PDFs ────── */
const tiers = [
  { ed: 'personal', dirs: ['personal'], label: 'Personal Edition', file: 'erronatus-blueprint-personal' },
  { ed: 'business', dirs: ['personal', 'business'], label: 'Business Edition', file: 'erronatus-blueprint-business' },
  { ed: 'enterprise', dirs: ['personal', 'business', 'enterprise'], label: 'Enterprise Edition', file: 'erronatus-blueprint-enterprise' },
];

// Find typst binary
const typstPath = path.join(process.env.LOCALAPPDATA || '', 'Microsoft', 'WinGet', 'Links', 'typst.exe');
const typstCmd = fs.existsSync(typstPath) ? `"${typstPath}"` : 'typst';

for (const t of tiers) {
  console.log(`Generating ${t.label}...`);
  console.log('  Converting chapters via pandoc...');

  const typstSrc = buildTypst(t.ed, t.dirs, t.label);
  const srcFile = path.join(OUT, t.file + '.typ');
  const pdfFile = path.join(OUT, t.file + '.pdf');

  fs.writeFileSync(srcFile, typstSrc);

  try {
    console.log('  Compiling with Typst...');
    const stderr = execSync(`${typstCmd} compile "${srcFile}" "${pdfFile}" --font-path "${FONTS}" 2>&1`, {
      encoding: 'utf-8',
      timeout: 180000,
    });
    if (stderr.trim()) console.log('  warnings:', stderr.trim().slice(0, 300));
    const size = fs.statSync(pdfFile).size;
    console.log(`  ✓ ${t.file}.pdf (${Math.round(size / 1024)} KB)`);
  } catch (e) {
    const err = e.stderr?.toString() || e.stdout?.toString() || e.message;
    console.error(`  ✗ Failed:`, err.slice(0, 800));
  }
}

console.log('\nDone.');
