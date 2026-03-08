# Chapter 18: Web Scraping Engine
## Extract Data From Any Website

---

### Why Scraping Is the Ultimate Data Source

APIs are curated data feeds. Scraping is **raw access to the entire internet.**

Every business directory, every competitor's pricing page, every job board, every product listing, every social profile — it's all accessible HTML. With a scraping engine, your AI can:

- Monitor competitor prices daily
- Extract business listings from directories
- Track job postings for market signals
- Pull product data for market research
- Collect public contact information for outreach
- Monitor news sites for industry mentions

### The Scraping Architecture

```
┌────────────────────┐
│    Target URLs      │ ← Directory, search results, specific pages
├────────────────────┤
│    Fetch Engine     │ ← HTTP requests with headers, rotation
├────────────────────┤
│    Parser           │ ← HTML → structured data extraction
├────────────────────┤
│    AI Enrichment    │ ← Classify, score, clean the data
├────────────────────┤
│    Storage          │ ← Supabase, JSON files, CSV export
├────────────────────┤
│    Action           │ ← Feed into lead gen, email, monitoring
└────────────────────┘
```

### Building the Scraping Engine

Create `~/.openclaw/workspace/scripts/scraper.js`:

```javascript
// Web Scraping Engine
// Features: rate limiting, retry logic, user-agent rotation,
//           structured data extraction, error handling

const USER_AGENTS = [
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36...',
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36...',
  'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36...',
];

function randomUserAgent() {
  return USER_AGENTS[Math.floor(Math.random() * USER_AGENTS.length)];
}

async function fetchPage(url, options = {}) {
  const {
    retries = 3,
    delayMs = 1000,
    timeout = 10000,
  } = options;

  for (let attempt = 0; attempt < retries; attempt++) {
    try {
      // Respect rate limits
      if (attempt > 0) {
        await new Promise(r => setTimeout(r, delayMs * (attempt + 1)));
      }

      const response = await fetch(url, {
        headers: {
          'User-Agent': randomUserAgent(),
          'Accept': 'text/html,application/xhtml+xml',
          'Accept-Language': 'en-US,en;q=0.9',
        },
        signal: AbortSignal.timeout(timeout),
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }

      return await response.text();
    } catch (error) {
      if (attempt === retries - 1) throw error;
      console.log(`Retry ${attempt + 1}/${retries} for ${url}`);
    }
  }
}
```

### OpenClaw Browser Integration

For JavaScript-heavy sites that require rendering, use OpenClaw's built-in browser control:

```
You: Scrape the product listings from example-store.com/products
     Extract: name, price, rating, URL for each product
```

Your AI:
1. Opens the page in a headless browser
2. Waits for dynamic content to load
3. Takes a snapshot of the rendered DOM
4. Extracts structured data from the snapshot
5. Returns clean JSON or saves to Supabase

This handles:
- Single-page applications (React, Vue, Angular)
- Infinite scroll pages
- JavaScript-rendered content
- Pages requiring interaction (clicks, form fills)

### Extraction Patterns

**Pattern 1: List Pages (Directories, Search Results)**

```javascript
// Extract business listings from a directory
async function scrapeDirectory(url) {
  const html = await fetchPage(url);

  // AI parses the HTML and extracts structured data
  // Returns: [{ name, address, phone, website, category }]
}
```

**Pattern 2: Detail Pages (Individual Profiles)**

```javascript
// Extract full details from a business profile
async function scrapeProfile(url) {
  const html = await fetchPage(url);

  // AI extracts: description, contact info, social links,
  // hours, reviews, services, team members
}
```

**Pattern 3: Monitoring (Price Tracking, Change Detection)**

```javascript
// Check a page daily and alert on changes
async function monitorPage(url, selector) {
  const html = await fetchPage(url);
  const currentValue = extractValue(html, selector);
  const previousValue = await getPreviousValue(url);

  if (currentValue !== previousValue) {
    await alert(`Change detected on ${url}: ${previousValue} → ${currentValue}`);
    await saveValue(url, currentValue);
  }
}
```

### Anti-Detection Best Practices

1. **Rate limiting** — Never exceed 1 request per second to any single domain
2. **User-agent rotation** — Cycle through realistic browser user agents
3. **Request spacing** — Add random delays (1-5 seconds) between requests
4. **Respect robots.txt** — Check and honor robots.txt directives
5. **Session management** — Maintain cookies for sites that require sessions
6. **IP rotation** — Use proxy services for high-volume scraping
7. **Error handling** — Back off exponentially on rate limit errors (429)

### Legal and Ethical Guidelines

⚠️ **Important:** Web scraping legality varies by jurisdiction and website.

**Generally acceptable:**
- Scraping publicly available information
- Respecting robots.txt directives
- Rate limiting to avoid server impact
- Using data for analysis and research

**Avoid:**
- Scraping behind login walls without permission
- Ignoring robots.txt or terms of service
- Overwhelming servers with rapid requests
- Scraping personal/private data (GDPR, CCPA)
- Reselling scraped data without rights

When in doubt, check the site's terms of service and consult legal counsel for commercial use.

### Practical Scraping Workflows

**Workflow 1: Competitor Price Monitoring**
Cron schedule: Daily at 6 AM
→ Scrape competitor pricing pages
→ Compare to your prices
→ Alert on significant changes
→ Log to price history database

**Workflow 2: Directory Lead Extraction**
Cron schedule: Weekly
→ Scrape business directories for target industry
→ Extract name, email, website, phone
→ Score leads based on business size/relevance
→ Feed into lead generation pipeline

**Workflow 3: Content Monitoring**
Cron schedule: Every 4 hours
→ Scrape industry news sites
→ Identify mentions of your brand or competitors
→ Summarize findings
→ Alert on significant mentions

### What You've Built

✅ Web scraping engine with retry logic and rate limiting
✅ Browser-based scraping for JavaScript-heavy sites
✅ Three extraction patterns (list, detail, monitoring)
✅ Anti-detection measures
✅ Practical workflows for common business scenarios
✅ Legal and ethical framework for responsible scraping

---

*Next Chapter: Lead Generation →*
