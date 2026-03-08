# Chapter 8: Deployment
## Going Live on Vercel

---

### Why Deploy?

Your AI system runs locally on your machine. That works great when your computer is on. But what about when you close your laptop? When you travel? When your machine restarts?

Deployment means your AI system's web presence — your blog, your landing page, your API endpoints — lives on the internet, accessible 24/7, regardless of what your local machine is doing.

In this chapter, we'll deploy a professional web presence using Vercel, the platform behind some of the internet's fastest websites.

> **Note:** Your OpenClaw gateway still runs locally (or on a VPS). What we're deploying here is the web-facing portion: blog, landing pages, API endpoints for things like payment processing.

### Step 1: Create a Vercel Account

1. Go to vercel.com and sign up (free tier is generous)
2. Connect your GitHub account during signup
3. You'll get a free `.vercel.app` subdomain immediately

### Step 2: Install the Vercel CLI

```bash
npm install -g vercel
```

Authenticate:
```bash
vercel login
```

Follow the prompts to log in via your browser.

### Step 3: Build Your Project

If you have a web project (blog, landing page, dashboard), navigate to the project directory:

```bash
cd your-project-directory
vercel
```

Vercel automatically detects your framework (Astro, Next.js, etc.) and configures the build.

For your first deploy, accept the defaults:
- Link to existing project? No, create new
- Project name? Accept default or choose one
- Framework? Auto-detected
- Build settings? Accept defaults

### Step 4: Deploy to Production

```bash
vercel --prod
```

Vercel builds your project and deploys it. You'll get a URL like:
```
https://your-project.vercel.app
```

That's it. Your site is live on the internet, with:
- Global CDN distribution
- Automatic SSL (HTTPS)
- Serverless functions for API endpoints
- Zero infrastructure management

### Step 5: Connect a Custom Domain

If you have a custom domain:

1. In Vercel dashboard → your project → Settings → Domains
2. Type your domain name and click Add
3. Add the DNS records Vercel shows you to your domain registrar
4. Wait for DNS propagation (usually minutes with Cloudflare, up to 48 hours with others)

### Step 6: Environment Variables

For features that need API keys (like Stripe checkout), add environment variables in Vercel:

1. Dashboard → Project → Settings → Environment Variables
2. Add each key-value pair
3. Select which environments need the variable (Production, Preview, Development)
4. Redeploy for changes to take effect

### Step 7: Continuous Deployment

Connect your GitHub repository to Vercel for automatic deployments:

1. Dashboard → Project → Settings → Git
2. Connect your GitHub repository
3. Now every `git push` to `main` automatically triggers a new deployment

Your workflow becomes:
1. Make changes locally
2. `git add . && git commit -m "Update" && git push`
3. Vercel automatically builds and deploys
4. Live site updates in ~30 seconds

### Performance Optimization

Vercel + Astro gives you exceptional performance out of the box:

- **Static generation** — Pages are pre-built HTML, served instantly from CDN
- **Zero JavaScript by default** — Only loads JS where you explicitly need it
- **Image optimization** — Automatic compression and format selection
- **Edge caching** — Content served from the nearest data center to each visitor

Target: 95+ Lighthouse score on all pages.

### What You've Deployed

At the end of this chapter, you have:

✅ A live website accessible from anywhere in the world
✅ Automatic SSL/HTTPS security
✅ Global CDN for fast loading everywhere
✅ Continuous deployment from GitHub
✅ Environment variables for secure API integration
✅ A professional web presence for your AI automation brand

---

## Congratulations!

You've built a complete AI automation system:

🏗️ **Infrastructure** — OpenClaw gateway running with workspace configured
📱 **Command Interface** — Telegram or Discord connected for mobile access
🧠 **AI Engine** — Multiple models configured with smart routing
🔌 **APIs** — 5 services connected (search, markets, news, database, code)
💾 **Memory** — Persistent context that survives across sessions
⚡ **Automation** — Cron jobs running tasks on schedule
🌐 **Deployment** — Live web presence on Vercel

This is your foundation. Everything you build from here compounds on what you've already set up. New APIs add new capabilities. New cron jobs add new automations. New memory entries make your AI smarter.

**Want to go further?** The Business Edition covers:
- Multi-engine routing with automatic cost optimization
- Full 14-API toolchain with reusable helper functions
- Trading bot framework with Alpaca integration
- Advanced memory systems with active context management
- Custom skill development
- Email automation with Resend
- Stripe payment integration

Visit erronatus.com to upgrade.

---

*Appendices follow →*
