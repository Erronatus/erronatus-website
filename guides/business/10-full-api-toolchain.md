# Chapter 10: The Full API Toolchain
## 14 Services, One Script

---

### From Individual APIs to a Unified Toolchain

In Chapter 5, you connected 5 APIs individually. That's fine for personal use. For business operations, you need a systematic approach — a single, reusable script that wraps every service into clean function calls.

This chapter gives you that script. We call it `api-tools.js` — a production-tested toolchain that we use daily.

### The Architecture

```
┌──────────────────────────────────────────┐
│           api-tools.js                   │
│                                          │
│  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │ Trading  │  │  Data    │  │  Infra │ │
│  │          │  │          │  │        │ │
│  │ Alpaca   │  │ AlphaV   │  │ Vercel │ │
│  │          │  │ NewsAPI  │  │ CF     │ │
│  │          │  │ Supabase │  │ GitHub │ │
│  └──────────┘  └──────────┘  └────────┘ │
│                                          │
│  ┌──────────┐  ┌──────────┐             │
│  │  Comms   │  │ Payments │             │
│  │          │  │          │             │
│  │ Resend   │  │ Stripe   │             │
│  │          │  │          │             │
│  └──────────┘  └──────────┘             │
│                                          │
│  All credentials loaded from .env        │
│  All functions export clean interfaces   │
└──────────────────────────────────────────┘
```

### Setting Up All 14 Services

Here's every API key you need, organized by category:

**Trading & Finance:**
```bash
ALPACA_API_KEY=your-paper-trading-key
ALPACA_SECRET_KEY=your-paper-secret-key
ALPACA_BASE_URL=https://paper-api.alpaca.markets
ALPHA_VANTAGE_KEY=your-key
```

**Social & Communication:**
```bash
X_API_KEY=your-twitter-api-key
X_API_SECRET=your-twitter-secret
X_ACCESS_TOKEN=your-access-token
X_ACCESS_SECRET=your-access-secret
X_BEARER_TOKEN=your-bearer-token
RESEND_API_KEY=re_your-resend-key
```

**Development & Deployment:**
```bash
GITHUB_TOKEN=github_pat_your-token
VERCEL_TOKEN=your-vercel-token
CLOUDFLARE_API_TOKEN=your-cf-token
CLOUDFLARE_ACCOUNT_ID=your-account-id
```

**Database & Services:**
```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
NEWSAPI_KEY=your-newsapi-key
```

**Payments:**
```bash
STRIPE_SECRET_KEY=sk_test_your-key
STRIPE_PUBLISHABLE_KEY=pk_test_your-key
```

**Search & AI:**
```bash
OPENROUTER_API_KEY=sk-or-v1-your-key
BRAVE_SEARCH_KEY=your-brave-key
```

### The api-tools.js Script

Create `~/.openclaw/workspace/scripts/api-tools.js`:

This ES module script:
1. Loads all credentials from `~/.openclaw/.env` automatically
2. Validates that required keys exist before making calls
3. Exports clean async functions for each service
4. Handles errors gracefully with descriptive messages

**Available Functions:**

```javascript
// Trading
alpaca_get_price(symbol)        // Latest stock price
alphavantage_rsi(symbol)        // RSI technical indicator

// News & Data
newsapi_headlines(count)        // Top business headlines

// Infrastructure
github_list_repos()             // List GitHub repositories
supabase_query(table, select)   // Query Supabase database
cloudflare_verify()             // Verify Cloudflare token
vercel_user()                   // Get Vercel account info

// Payments
stripe_balance()                // Check Stripe balance

// Email
resend_list_keys()              // List Resend API keys
```

**Usage in your AI's context:**

Your AI can call these functions directly:

```
You: What's the current price of AAPL?
AI: [Calls alpaca_get_price('AAPL')]
    AAPL is trading at $178.52 as of 2:30 PM ET.

You: Check my Stripe balance
AI: [Calls stripe_balance()]
    Stripe balance: $1,247.00 available, $89.00 pending.

You: Get the latest RSI for NVDA
AI: [Calls alphavantage_rsi('NVDA')]
    NVDA RSI (14-period, 5min): 45.2 — neutral territory.
```

### Building the Script

Here's the complete implementation pattern. Each function follows the same structure:

```javascript
import { readFileSync } from 'fs';
import { join } from 'path';

// Load .env
const envPath = join(process.env.HOME || process.env.USERPROFILE, '.openclaw', '.env');
const envVars = {};

const envContent = readFileSync(envPath, 'utf8');
envContent.split('\n').forEach(line => {
  line = line.trim();
  if (line && !line.startsWith('#')) {
    const eqIndex = line.indexOf('=');
    if (eqIndex > 0) {
      envVars[line.slice(0, eqIndex)] = line.slice(eqIndex + 1);
    }
  }
});

function requireKey(key, service) {
  if (!envVars[key]) throw new Error(`Missing ${service} key: ${key}`);
  return envVars[key];
}

// Example: Alpaca
export async function alpaca_get_price(symbol) {
  const API_KEY = requireKey('ALPACA_API_KEY', 'Alpaca');
  const SECRET = requireKey('ALPACA_SECRET_KEY', 'Alpaca');
  
  const response = await fetch(
    `https://data.alpaca.markets/v2/stocks/${symbol}/trades/latest`,
    {
      headers: {
        'APCA-API-KEY-ID': API_KEY,
        'APCA-API-SECRET-KEY': SECRET
      }
    }
  );
  
  const data = await response.json();
  return { symbol, price: data.trade.p, timestamp: data.trade.t };
}
```

The full script includes all 9+ functions with error handling, fallback logic, and clean return types. The complete, tested source code is included in the downloadable package.

### Testing the Toolchain

Run a comprehensive verification of all services:

```
You: Test all API connections and report status
AI: Running API verification...

✅ Alpaca Trading — Paper account active
✅ Alpha Vantage — AAPL RSI retrieved (42.8)
✅ NewsAPI — 5 headlines fetched
✅ GitHub — @YourUsername, 12 repos
✅ Supabase — Database responding
✅ Stripe — Balance API working ($0.00)
✅ Cloudflare — Token verified, active
✅ Vercel — Account accessible
✅ Resend — 1 API key found

9/9 services operational.
```

### What You've Built

At the end of this chapter, you have:

✅ A unified API toolchain script with 9 helper functions
✅ All 14 services configured and authenticated
✅ Clean function interfaces your AI calls directly
✅ Automatic credential loading from .env
✅ Error handling and descriptive failure messages
✅ A verification routine to test everything at once

This toolchain is the backbone of every automation you'll build. Trading bots call `alpaca_get_price()`. Morning briefings call `newsapi_headlines()`. Email automations call Resend. Everything routes through one tested, reliable script.

---

*Next Chapter: Trading Automation →*
