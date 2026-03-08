# Chapter 19: Lead Generation
## Building Automated Prospect Pipelines

---

### The Lead Generation Machine

Most businesses generate leads manually — networking events, cold calls, LinkedIn browsing, referrals. This works, but it doesn't scale.

An automated lead generation pipeline discovers, qualifies, and delivers prospects to your inbox while you sleep. Your AI becomes a 24/7 business development representative.

### The Pipeline Architecture

```
DISCOVER → EXTRACT → ENRICH → SCORE → QUALIFY → DELIVER

1. Discover: Find potential leads from multiple sources
2. Extract: Pull contact information and company data
3. Enrich: Add context (company size, industry, tech stack)
4. Score: Rate lead quality 1-100
5. Qualify: Filter by your ideal customer profile
6. Deliver: Add to CRM, trigger outreach, or alert you
```

### Source 1: Business Directories

Scrape industry-specific directories for businesses matching your criteria:

```
You: Find 50 digital marketing agencies in Austin, TX
     using Google Maps and Yelp. Extract company name,
     website, phone, rating, and review count.
```

Your AI:
1. Searches Google Maps via web search for "digital marketing agencies Austin TX"
2. Extracts business listings with ratings and contact info
3. Cross-references with Yelp for additional data
4. Deduplicates and stores in Supabase

### Source 2: LinkedIn (Public Profiles)

Extract publicly available information from LinkedIn company pages:

```
You: Research the top 20 SaaS companies hiring AI engineers.
     Get company name, size, industry, and careers page URL.
```

Your AI searches the web for this information and compiles structured results.

### Source 3: Website Scraping

For specific niches, scrape industry platforms:

- **Product Hunt** — New startups launching daily
- **Crunchbase** (public profiles) — Funded companies
- **AngelList** — Startup ecosystem
- **G2/Capterra** — Software companies with review data
- **Industry-specific directories** — Trade associations, membership lists

### Source 4: Social Signals

Monitor social platforms for buying signals:

```
Cron: Every 6 hours, search Twitter/X for:
- "looking for a [your service]"
- "anyone recommend a [your category]"
- "switching from [competitor]"
- "frustrated with [pain point]"

Score each mention. Alert me on high-quality signals.
```

### The Enrichment Layer

Raw leads are just names and emails. Enriched leads are intelligence packages:

**Company enrichment:**
- Website → Extract: products, team size, tech stack, pricing model
- Social profiles → Employee count, growth rate, content themes
- Job postings → What they're hiring for reveals priorities and budget

**Contact enrichment:**
- Role and seniority level
- LinkedIn profile (public)
- Recent posts or content (engagement signals)
- Mutual connections or shared interests

Your AI performs this enrichment automatically using web search and scraping:

```
You: Enrich this lead: Acme Corp (acmecorp.com)

AI: Enrichment complete:
    Company: Acme Corp
    Industry: B2B SaaS
    Employees: 50-100 (based on LinkedIn)
    Funding: Series A, $8M (Crunchbase)
    Tech stack: React, AWS, Stripe (built with)
    Hiring: 3 engineering roles, 1 marketing (active)
    Pain signals: Recent post about "scaling challenges"
    Decision maker: Jane Smith, VP of Operations
    Score: 82/100 (strong fit)
```

### Lead Scoring Model

Create a scoring system that reflects your ideal customer:

```json
{
  "scoringWeights": {
    "companySize": {
      "1-10": 20,
      "11-50": 40,
      "51-200": 60,
      "201-500": 80,
      "500+": 100
    },
    "industry_fit": {
      "exact_match": 100,
      "adjacent": 60,
      "tangential": 30
    },
    "buying_signals": {
      "hiring_relevant_roles": 25,
      "recently_funded": 30,
      "pain_point_mentioned": 40,
      "competitor_frustration": 50
    },
    "engagement": {
      "website_visited": 15,
      "content_downloaded": 30,
      "email_opened": 20,
      "replied": 50
    }
  },
  "qualificationThreshold": 65,
  "highPriorityThreshold": 85
}
```

Leads scoring above 65 enter the pipeline. Above 85 get immediate attention.

### The Lead Database

Store everything in Supabase:

```sql
CREATE TABLE leads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_name TEXT NOT NULL,
  website TEXT,
  industry TEXT,
  employee_count TEXT,
  contact_name TEXT,
  contact_email TEXT,
  contact_title TEXT,
  score INTEGER DEFAULT 0,
  status TEXT DEFAULT 'new',
  source TEXT,
  enrichment JSONB,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_contacted TIMESTAMPTZ,
  next_action TEXT,
  next_action_date DATE
);
```

### Automated Pipeline Schedule

```
Daily 6:00 AM — Discover
  Scrape 3 directory sources for new businesses
  Search social media for buying signals
  Check job boards for relevant postings

Daily 8:00 AM — Enrich
  Enrich all new leads from yesterday
  Update scores based on new data

Daily 9:00 AM — Qualify
  Filter leads above threshold
  Prepare personalized outreach drafts
  Alert me with today's top 10 leads

Daily 10:00 AM — Deliver
  Send approved outreach emails
  Schedule follow-ups for non-responders
  Update lead statuses

Weekly Monday — Report
  Pipeline summary: new leads, contacted, responded, converted
  Source analysis: which channels produce best leads
  Score calibration: adjust weights based on conversion data
```

### What You've Built

✅ Multi-source lead discovery (directories, social, websites)
✅ Automated enrichment pipeline with AI analysis
✅ Configurable scoring model based on ideal customer profile
✅ Supabase-powered lead database
✅ Automated daily pipeline with scheduled extraction and enrichment
✅ Weekly performance analytics for pipeline optimization

---

*Next Chapter: Email Outreach →*
