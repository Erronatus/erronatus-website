# Chapter 5: API Integration
## Connecting Your First 5 Services

---

### Why APIs Matter

Right now, your AI can think, communicate, and remember. But it can't *do* things in the real world. It can't check stock prices, send emails, query databases, or deploy websites.

APIs change that. Every API you connect is a new capability — a new hand your AI can use to interact with the outside world.

In this chapter, we'll connect 5 essential services that cover the most common automation needs:

1. **Brave Search** — Web search capability
2. **Alpha Vantage** — Financial market data
3. **NewsAPI** — Real-time news headlines
4. **Supabase** — Cloud database
5. **GitHub** — Code repository access

### How API Keys Work

Every external service requires authentication — proof that you're authorized to use it. This comes in the form of API keys: unique strings that identify your account.

API keys are stored in your `.env` file at `~/.openclaw/.env`:

```bash
# .env — API Keys and Secrets
# Never commit this file to git. Never share these keys.

OPENROUTER_API_KEY=sk-or-v1-your-key-here
BRAVE_SEARCH_KEY=your-brave-key-here
```

OpenClaw loads these automatically. Your AI can use them without ever seeing the raw keys.

> ⚠️ **Security Rules:**
> 1. Never commit `.env` to git (it's in `.gitignore` by default)
> 2. Never paste API keys in chat messages
> 3. Never share keys with anyone
> 4. Rotate keys immediately if you suspect a leak
> 5. Use the minimum permissions each key needs

### Service 1: Brave Search

**What it does:** Lets your AI search the web for real-time information.

**Get your key:**
1. Go to brave.com/search/api
2. Create a free account
3. Subscribe to the Free plan (2,000 queries/month)
4. Copy your API key

**Add to `.env`:**
```bash
BRAVE_SEARCH_KEY=BSAzrul5b7JTv7oFjLR9NbIrLpdtMy8
```

**Test it:**
Send to your AI: "Search the web for the latest AI news today"

Your AI will use the Brave Search API to find and summarize recent results. This is incredibly powerful — your AI now has access to real-time information that goes beyond its training data.

### Service 2: Alpha Vantage

**What it does:** Provides stock market data, technical indicators (RSI, MACD, moving averages), and financial metrics.

**Get your key:**
1. Go to alphavantage.co
2. Click "Get Your Free API Key"
3. Fill in the form and submit
4. Copy your key (free tier: 25 requests/day)

**Add to `.env`:**
```bash
ALPHA_VANTAGE_KEY=your-key-here
```

**Test it:**
Ask your AI: "What's the current RSI for AAPL?"

Your AI will call the Alpha Vantage API, retrieve the RSI indicator, and analyze whether the stock looks overbought (RSI > 70) or oversold (RSI < 30).

> **Note:** The free tier has a 25 calls/day limit. This is plenty for personal monitoring but will need an upgrade ($49.99/month) if you're running frequent automated checks.

### Service 3: NewsAPI

**What it does:** Aggregates news headlines from 80,000+ sources worldwide. Filter by country, category, keyword, or source.

**Get your key:**
1. Go to newsapi.org
2. Register for a free account
3. Copy your API key (free tier: 100 requests/day)

**Add to `.env`:**
```bash
NEWSAPI_KEY=your-key-here
```

**Test it:**
Ask your AI: "What are the top 5 business headlines right now?"

Your AI will pull live headlines from major news sources and present them with titles, sources, and brief descriptions.

### Service 4: Supabase

**What it does:** Provides a cloud PostgreSQL database with a REST API. Store data, run queries, and build data-driven automations.

**Get your key:**
1. Go to supabase.com and create a free account
2. Create a new project (choose a region close to you)
3. Go to Settings → API
4. Copy the Project URL and the `anon` (public) key

**Add to `.env`:**
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...your-key-here
```

**Test it:**
Ask your AI: "Check if the Supabase database is connected"

Your AI will ping the Supabase API and confirm the connection. Later, you can create tables to store automation logs, trade records, contact lists, or any structured data.

**Creating your first table:**
Ask your AI: "Create a Supabase table called 'automation_logs' with columns: id (auto), timestamp, task, result, status"

### Service 5: GitHub

**What it does:** Access your code repositories, create issues, check commits, and manage projects through the GitHub API.

**Get your key:**
1. Go to github.com → Settings → Developer Settings → Personal Access Tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Name it "OpenClaw" and select scopes: `repo`, `read:user`
4. Copy the token

**Add to `.env`:**
```bash
GITHUB_TOKEN=github_pat_your-token-here
```

**Test it:**
Ask your AI: "List my GitHub repositories"

### Verifying All Connections

Once all 5 services are configured, run a comprehensive test:

Send to your AI: "Test all API connections and report the status of each"

Your AI should report something like:

```
API Connection Status:
✅ Brave Search — Working (web search functional)
✅ Alpha Vantage — Working (RSI data retrieved)
✅ NewsAPI — Working (3 headlines fetched)
✅ Supabase — Working (database responding)
✅ GitHub — Working (repositories accessible)
```

### What You've Connected

At the end of this chapter, you have:

✅ Web search capability (Brave)
✅ Financial market data (Alpha Vantage)
✅ Real-time news aggregation (NewsAPI)
✅ Cloud database storage (Supabase)
✅ Code repository access (GitHub)

Your AI now has hands. It can search, analyze markets, read news, store data, and manage code. Each of these capabilities can be combined and automated — which is exactly what we'll do after building the memory system.

---

*Next Chapter: Memory Systems — Giving Your AI a Brain →*
