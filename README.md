# Erronatus Website

A premium digital business platform for "The Erronatus Blueprint" — a guide to AI automation with OpenClaw.

Built with Astro, Tailwind CSS, and Stripe integration. Deploys to Vercel with perfect Lighthouse scores.

## Features

- **Modern Gallery Design**: Dark cinematic atmosphere with bold typography
- **Responsive Layout**: Mobile-first, perfect on all devices
- **SEO Optimized**: Meta tags, Open Graph, structured data, sitemap
- **Blog System**: Markdown/MDX posts with categories and tags
- **Stripe Integration**: Checkout for Personal ($47) and Business ($97) editions
- **Performance**: Targets 95+ Lighthouse score with CSS-only animations
- **Dark/Light Mode**: Toggle with system preference detection
- **Email Capture**: Multiple points with Resend integration ready

## Tech Stack

- **Astro 5** — Static site generation with SSR for API routes
- **Tailwind CSS** — Utility-first styling with custom design tokens
- **Stripe** — Payment processing with test mode configured
- **MDX** — Blog posts with React components support
- **Vercel** — Deployment platform with Edge Functions

## Project Structure

```
src/
├── components/          # Reusable UI components
├── content/            # Blog posts and collections
├── layouts/            # Base layout templates
├── pages/              # Routes and pages
│   ├── api/            # Server endpoints (Stripe checkout)
│   ├── blog/           # Blog index and individual posts
│   └── *.astro         # Static pages
├── styles/             # Global CSS and Tailwind imports
└── env.d.ts            # TypeScript environment definitions
```

## Getting Started

### 1. Clone and Install

```bash
git clone https://github.com/erronatus/erronatus-website
cd erronatus-website
npm install
```

### 2. Environment Variables

Copy `.env.example` to `.env` and fill in your Stripe keys:

```bash
cp .env.example .env
```

Required:
- `STRIPE_SECRET_KEY` — Stripe secret key (test mode: `sk_test_...`)
- `STRIPE_PUBLISHABLE_KEY` — Stripe publishable key (test mode: `pk_test_...`)
- `SITE_URL` — Your site URL (`http://localhost:4321` for dev)

Optional for production:
- `STRIPE_WEBHOOK_SECRET` — Webhook signing secret
- `RESEND_API_KEY` — For email automation
- `OPENROUTER_API_KEY` — For AI demo integrations

### 3. Development

```bash
npm run dev
```

Open [http://localhost:4321](http://localhost:4321)

### 4. Build for Production

```bash
npm run build
```

The build output goes to `dist/`.

### 5. Deploy to Vercel

The project is configured for zero-config Vercel deployment:

```bash
npm run build
vercel --prod
```

Or connect your GitHub repository in the Vercel dashboard.

## Stripe Integration

The checkout flow:

1. User clicks "Get The Blueprint"
2. Client calls `/api/checkout` with price ID and edition
3. Stripe creates a checkout session
4. User completes payment on Stripe's hosted page
5. Redirect to `/thank-you` with session ID

**Test cards** (Stripe test mode):
- Success: `4242 4242 4242 4242`
- Decline: `4000 0000 0000 0002`

## Blog System

Add new posts to `src/content/blog/` as markdown files:

```markdown
---
title: "Your Post Title"
excerpt: "Brief description"
date: "2026-03-08"
category: "Tutorials"
readTime: "5 min read"
author: "Erronatus"
tags: ["ai", "automation"]
---

Your content here...
```

Posts automatically appear in the blog index with filtering by category.

## Design System

### Colors

- **Background**: `#0a0a0a` (dark), `#fafafa` (light)
- **Surface**: `#111111`, `#1a1a1a`
- **Text**: `#ffffff`, `#a0a0a0`
- **Accents**: Gradient primary (`#3b82f6` → `#8b5cf6`)

### Typography

- **Sans**: Inter (Google Fonts)
- **Mono**: JetBrains Mono
- **Scale**: 4xl-9xl for headlines, base for body

### Animations

CSS-only animations:
- Gradient shifts
- Scroll-triggered reveals
- Floating elements
- Smooth transitions

## Performance Optimizations

- Astro's zero-JS by default
- CSS animations instead of JavaScript libraries
- Image optimization with Sharp
- Lazy loading for images
- Purged CSS via Tailwind
- Sitemap and robots.txt generation

## License

Copyright © 2026 Erronatus. All rights reserved.