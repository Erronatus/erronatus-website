import { b as createAstro, c as createComponent, a as renderTemplate, h as renderSlot, i as renderHead, u as unescapeHTML, d as addAttribute, m as maybeRenderHead } from './astro/server_CHmuSpaP.mjs';
import 'piccolore';
import 'clsx';
/* empty css                          */

var __freeze$1 = Object.freeze;
var __defProp$1 = Object.defineProperty;
var __template$1 = (cooked, raw) => __freeze$1(__defProp$1(cooked, "raw", { value: __freeze$1(cooked.slice()) }));
var _a$1;
const $$Astro = createAstro("https://erronatus.com");
const $$BaseLayout = createComponent(($$result, $$props, $$slots) => {
  const Astro2 = $$result.createAstro($$Astro, $$props, $$slots);
  Astro2.self = $$BaseLayout;
  const {
    title,
    description = "Build autonomous AI systems that execute, analyze, and scale. The Erronatus Blueprint teaches you AI automation with OpenClaw.",
    image = "/images/og-image.png",
    type = "website",
    noindex = false
  } = Astro2.props;
  const canonicalURL = new URL(Astro2.url.pathname, Astro2.site);
  const fullTitle = title === "Erronatus" ? title : `${title} \u2014 Erronatus`;
  return renderTemplate(_a$1 || (_a$1 = __template$1(['<html lang="en" class="dark"> <head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><meta name="generator"', "><!-- Primary Meta --><title>", '</title><meta name="description"', '><link rel="canonical"', ">", '<!-- Favicon --><link rel="icon" type="image/svg+xml" href="/favicon.svg"><!-- Font Preloading --><link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin><link rel="preload" href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600&display=swap" as="style"><link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&family=JetBrains+Mono:wght@400;500;600&display=swap"><!-- Open Graph --><meta property="og:type"', '><meta property="og:title"', '><meta property="og:description"', '><meta property="og:url"', '><meta property="og:image"', '><meta property="og:site_name" content="Erronatus"><!-- Twitter Card --><meta name="twitter:card" content="summary_large_image"><meta name="twitter:title"', '><meta name="twitter:description"', '><meta name="twitter:image"', '><!-- Structured Data --><script type="application/ld+json">', "<\/script>", '</head> <body class="min-h-screen antialiased"> <!-- Grain texture overlay --> <div class="grain-overlay" aria-hidden="true"></div> ', " <!-- Theme Toggle Script --> <script>\n      (function() {\n        const theme = localStorage.getItem('theme') || 'dark';\n        document.documentElement.classList.toggle('dark', theme === 'dark');\n        document.documentElement.classList.toggle('light', theme === 'light');\n      })();\n    <\/script> <!-- Scroll Reveal with stagger support --> <script>\n      document.addEventListener('DOMContentLoaded', () => {\n        const observer = new IntersectionObserver((entries) => {\n          entries.forEach(entry => {\n            if (entry.isIntersecting) {\n              entry.target.classList.add('visible');\n            }\n          });\n        }, { threshold: 0.08, rootMargin: '0px 0px -60px 0px' });\n\n        document.querySelectorAll('.reveal, .reveal-left, .reveal-right, .reveal-scale, .stagger-children').forEach(el => {\n          observer.observe(el);\n        });\n      });\n    <\/script> </body> </html> "])), addAttribute(Astro2.generator, "content"), fullTitle, addAttribute(description, "content"), addAttribute(canonicalURL, "href"), noindex && renderTemplate`<meta name="robots" content="noindex, nofollow">`, addAttribute(type, "content"), addAttribute(fullTitle, "content"), addAttribute(description, "content"), addAttribute(canonicalURL, "content"), addAttribute(new URL(image, Astro2.site), "content"), addAttribute(fullTitle, "content"), addAttribute(description, "content"), addAttribute(new URL(image, Astro2.site), "content"), unescapeHTML(JSON.stringify({
    "@context": "https://schema.org",
    "@type": "Organization",
    "name": "Erronatus",
    "url": "https://erronatus.com",
    "description": description,
    "logo": "https://erronatus.com/favicon.svg"
  })), renderHead(), renderSlot($$result, $$slots["default"]));
}, "C:/Users/jacks/.openclaw/workspace/projects/erronatus-website/src/layouts/BaseLayout.astro", void 0);

var __freeze = Object.freeze;
var __defProp = Object.defineProperty;
var __template = (cooked, raw) => __freeze(__defProp(cooked, "raw", { value: __freeze(cooked.slice()) }));
var _a;
const $$Header = createComponent(($$result, $$props, $$slots) => {
  const navLinks = [
    { label: "Blueprint", href: "/#blueprint" },
    { label: "The System", href: "/#system" },
    { label: "Blog", href: "/blog" },
    { label: "About", href: "/#about" }
  ];
  return renderTemplate(_a || (_a = __template(["", '<header id="site-header" class="fixed top-0 left-0 right-0 z-50 transition-all duration-500" data-astro-cid-3ef6ksr2> <div class="mx-auto max-w-7xl section-padding" data-astro-cid-3ef6ksr2> <nav class="flex items-center justify-between h-20" data-astro-cid-3ef6ksr2> <!-- Logo --> <a href="/" class="flex items-center gap-3 group" data-astro-cid-3ef6ksr2> <div class="w-9 h-9 rounded-lg flex items-center justify-center bg-gradient-to-br from-accent-blue to-accent-purple transition-transform duration-300 group-hover:scale-110" data-astro-cid-3ef6ksr2> <span class="text-white font-extrabold text-lg" data-astro-cid-3ef6ksr2>E</span> </div> <span class="text-lg font-bold tracking-tight" style="color: var(--color-text);" data-astro-cid-3ef6ksr2>\nErronatus\n</span> </a> <!-- Desktop Nav --> <div class="hidden md:flex items-center gap-10" data-astro-cid-3ef6ksr2> ', ' </div> <!-- Right Side --> <div class="flex items-center gap-4" data-astro-cid-3ef6ksr2> <button id="theme-toggle" class="w-10 h-10 rounded-full flex items-center justify-center transition-all duration-300" style="border: 1px solid var(--color-border); color: var(--color-text-secondary);" aria-label="Toggle theme" data-astro-cid-3ef6ksr2> <svg class="w-4 h-4 dark-icon" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" data-astro-cid-3ef6ksr2> <path d="M12 3v1m0 16v1m9-9h-1M4 12H3m15.364 6.364l-.707-.707M6.343 6.343l-.707-.707m12.728 0l-.707.707M6.343 17.657l-.707.707M16 12a4 4 0 11-8 0 4 4 0 018 0z" data-astro-cid-3ef6ksr2></path> </svg> <svg class="w-4 h-4 light-icon hidden" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" data-astro-cid-3ef6ksr2> <path d="M20.354 15.354A9 9 0 018.646 3.646 9.003 9.003 0 0012 21a9.003 9.003 0 008.354-5.646z" data-astro-cid-3ef6ksr2></path> </svg> </button> <a href="/#blueprint" class="hidden sm:inline-flex items-center px-5 py-2.5 text-xs font-semibold tracking-widest uppercase rounded-full text-white transition-all duration-300 hover:-translate-y-0.5" style="background: var(--gradient-primary);" data-astro-cid-3ef6ksr2>\nGet The Blueprint\n</a> <!-- Mobile Menu Toggle --> <button id="mobile-toggle" class="md:hidden w-10 h-10 flex items-center justify-center" aria-label="Menu" data-astro-cid-3ef6ksr2> <div class="space-y-1.5" data-astro-cid-3ef6ksr2> <span class="block w-5 h-0.5 bg-current transition-all duration-300" style="color: var(--color-text);" data-astro-cid-3ef6ksr2></span> <span class="block w-5 h-0.5 bg-current transition-all duration-300" style="color: var(--color-text);" data-astro-cid-3ef6ksr2></span> </div> </button> </div> </nav> </div> <!-- Mobile Menu --> <div id="mobile-menu" class="md:hidden hidden absolute top-full left-0 right-0 glass-card border-t" style="border-color: var(--color-border);" data-astro-cid-3ef6ksr2> <div class="section-padding py-6 flex flex-col gap-4" data-astro-cid-3ef6ksr2> ', ` <a href="/#blueprint" class="btn-primary text-center mt-2" data-astro-cid-3ef6ksr2>
Get The Blueprint
</a> </div> </div> </header> <!-- Floating Email Bar --> <div id="floating-bar" class="fixed bottom-0 left-0 right-0 z-40 translate-y-full transition-transform duration-500" data-astro-cid-3ef6ksr2> <div class="glass-card border-t" style="border-color: var(--color-border);" data-astro-cid-3ef6ksr2> <div class="mx-auto max-w-4xl section-padding py-3 flex flex-col sm:flex-row items-center gap-3" data-astro-cid-3ef6ksr2> <p class="text-sm font-medium flex-1" style="color: var(--color-text-secondary);" data-astro-cid-3ef6ksr2>
Get the automation playbook. Join 1,000+ builders.
</p> <form class="flex gap-2 w-full sm:w-auto" onsubmit="return false;" data-astro-cid-3ef6ksr2> <input type="email" placeholder="you@company.com" class="flex-1 sm:w-64 px-4 py-2 rounded-full text-sm outline-none transition-all duration-300 focus:ring-2 focus:ring-accent-purple/50" style="background: var(--color-surface-2); border: 1px solid var(--color-border); color: var(--color-text);" data-astro-cid-3ef6ksr2> <button type="submit" class="px-5 py-2 rounded-full text-xs font-semibold uppercase tracking-wider text-white" style="background: var(--gradient-primary);" data-astro-cid-3ef6ksr2>
Subscribe
</button> </form> </div> </div> </div>  <script>
  // Header scroll effect
  let lastScroll = 0;
  const header = document.getElementById('site-header');
  const floatingBar = document.getElementById('floating-bar');

  window.addEventListener('scroll', () => {
    const scrollY = window.scrollY;

    // Header background
    if (scrollY > 50) {
      header.style.background = 'rgba(10, 10, 10, 0.8)';
      header.style.backdropFilter = 'blur(20px)';
      header.style.borderBottom = '1px solid rgba(255,255,255,0.05)';
    } else {
      header.style.background = 'transparent';
      header.style.backdropFilter = 'none';
      header.style.borderBottom = 'none';
    }

    // Floating bar after scrolling past hero
    if (scrollY > window.innerHeight) {
      floatingBar.style.transform = 'translateY(0)';
    } else {
      floatingBar.style.transform = 'translateY(100%)';
    }

    lastScroll = scrollY;
  });

  // Theme toggle
  document.getElementById('theme-toggle').addEventListener('click', () => {
    const html = document.documentElement;
    const isDark = html.classList.contains('dark');
    html.classList.toggle('dark', !isDark);
    html.classList.toggle('light', isDark);
    localStorage.setItem('theme', isDark ? 'light' : 'dark');
  });

  // Mobile menu
  document.getElementById('mobile-toggle').addEventListener('click', () => {
    document.getElementById('mobile-menu').classList.toggle('hidden');
  });
<\/script>`])), maybeRenderHead(), navLinks.map((link) => renderTemplate`<a${addAttribute(link.href, "href")} class="text-sm font-medium tracking-wide transition-colors duration-300 hover:text-white" style="color: var(--color-text-secondary);" data-astro-cid-3ef6ksr2> ${link.label} </a>`), navLinks.map((link) => renderTemplate`<a${addAttribute(link.href, "href")} class="text-base font-medium py-2 transition-colors duration-300" style="color: var(--color-text-secondary);" data-astro-cid-3ef6ksr2> ${link.label} </a>`));
}, "C:/Users/jacks/.openclaw/workspace/projects/erronatus-website/src/components/Header.astro", void 0);

const $$Footer = createComponent(($$result, $$props, $$slots) => {
  const currentYear = (/* @__PURE__ */ new Date()).getFullYear();
  const links = {
    product: [
      { label: "The Blueprint", href: "/#blueprint" },
      { label: "Blog", href: "/blog" },
      { label: "Pricing", href: "/#blueprint" }
    ],
    legal: [
      { label: "Privacy Policy", href: "/privacy" },
      { label: "Terms of Service", href: "/terms" },
      { label: "Refund Policy", href: "/terms#4-refund-policy" }
    ],
    resources: [
      { label: "OpenClaw Docs", href: "https://docs.openclaw.ai" },
      { label: "GitHub", href: "https://github.com/openclaw/openclaw" },
      { label: "Community", href: "https://discord.com/invite/clawd" }
    ]
  };
  return renderTemplate`${maybeRenderHead()}<footer class="relative overflow-hidden" style="border-top: 1px solid var(--color-border);"> <div class="section-padding py-16 md:py-20"> <div class="mx-auto max-w-6xl"> <div class="grid grid-cols-2 md:grid-cols-4 gap-12 md:gap-8"> <!-- Brand --> <div class="col-span-2 md:col-span-1"> <a href="/" class="inline-flex items-center gap-2.5 mb-4"> <div class="w-8 h-8 rounded-lg flex items-center justify-center" style="background: var(--gradient-primary);"> <span class="text-white font-extrabold text-sm">E</span> </div> <span class="text-lg font-bold tracking-tight">Erronatus</span> </a> <p class="text-sm leading-relaxed mt-3 max-w-xs" style="color: var(--color-text-muted);">
Built with systems that build themselves.
</p> </div> <!-- Product --> <div> <h4 class="text-xs font-semibold tracking-[0.2em] uppercase mb-4" style="color: var(--color-text-muted);">Product</h4> <ul class="space-y-3"> ${links.product.map((link) => renderTemplate`<li> <a${addAttribute(link.href, "href")} class="text-sm transition-colors duration-200 hover:text-white" style="color: var(--color-text-secondary);"> ${link.label} </a> </li>`)} </ul> </div> <!-- Legal --> <div> <h4 class="text-xs font-semibold tracking-[0.2em] uppercase mb-4" style="color: var(--color-text-muted);">Legal</h4> <ul class="space-y-3"> ${links.legal.map((link) => renderTemplate`<li> <a${addAttribute(link.href, "href")} class="text-sm transition-colors duration-200 hover:text-white" style="color: var(--color-text-secondary);"> ${link.label} </a> </li>`)} </ul> </div> <!-- Resources --> <div> <h4 class="text-xs font-semibold tracking-[0.2em] uppercase mb-4" style="color: var(--color-text-muted);">Resources</h4> <ul class="space-y-3"> ${links.resources.map((link) => renderTemplate`<li> <a${addAttribute(link.href, "href")} class="text-sm transition-colors duration-200 hover:text-white" style="color: var(--color-text-secondary);"${addAttribute(link.href.startsWith("http") ? "_blank" : void 0, "target")}${addAttribute(link.href.startsWith("http") ? "noopener noreferrer" : void 0, "rel")}> ${link.label} </a> </li>`)} </ul> </div> </div> <!-- Bottom --> <div class="mt-16 pt-8 flex flex-col md:flex-row items-center justify-between gap-4" style="border-top: 1px solid var(--color-border);"> <p class="text-xs" style="color: var(--color-text-muted);">
&copy; ${currentYear} Erronatus. All rights reserved.
</p> <p class="text-xs" style="color: var(--color-text-muted);">
30-day money-back guarantee on all purchases.
</p> </div> </div> </div> </footer>`;
}, "C:/Users/jacks/.openclaw/workspace/projects/erronatus-website/src/components/Footer.astro", void 0);

export { $$BaseLayout as $, $$Header as a, $$Footer as b };
