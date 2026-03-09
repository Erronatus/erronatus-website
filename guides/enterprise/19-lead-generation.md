# Chapter 19: Lead Generation Pipelines

*Building automated systems that find, qualify, and score prospects at scale*

---

## The Lead Generation Engine

Lead generation is the fuel of business growth. But most people do it wrong — manually scraping LinkedIn, sending generic messages, praying for responses. That's not a system. That's inefficiency wearing a business suit.

The Erronatus approach: **systematic, automated, scalable**. We build pipelines that work 24/7, finding qualified prospects while you sleep. This chapter covers the complete architecture: identify → scrape → qualify → enrich → score → store.

By the end, you'll have a production-ready lead generation system that can process thousands of prospects per month, automatically score them, and hand you a ranked list of your best opportunities.

## Pipeline Architecture Overview

```mermaid
graph LR
    A[Sources] → B[Scraper]
    B → C[Qualifier]
    C → D[Enricher]
    D → E[Scorer]
    E → F[Database]
    F → G[CRM/Outreach]
```

**Six stages, each automated:**

1. **Sources**: Industry directories, company databases, job boards
2. **Scraper**: Extract company data, contact info, metadata
3. **Qualifier**: Filter by ICP criteria (size, industry, funding)
4. **Enricher**: AI research, contact pattern discovery, tech stack detection
5. **Scorer**: Rank prospects by conversion probability
6. **Database**: Store in Supabase with full tracking

## Ideal Customer Profile (ICP) Framework

Before you build anything, define your ICP. Here's the framework:

### Company Characteristics

```javascript
const ICP_CRITERIA = {
  // Company size (employees)
  company_size: {
    min: 10,
    max: 500,
    ideal_range: [50, 200]
  },
  
  // Revenue (annual)
  revenue: {
    min: 1000000,
    max: 50000000,
    ideal_range: [5000000, 20000000]
  },
  
  // Industry verticals
  industries: [
    'Software',
    'SaaS',
    'E-commerce',
    'Marketing Agencies',
    'Consulting',
    'Financial Services'
  ],
  
  // Funding stage
  funding_stages: [
    'Series A',
    'Series B',
    'Growth',
    'Profitable'
  ],
  
  // Geographic focus
  locations: [
    'United States',
    'Canada',
    'United Kingdom',
    'Australia'
  ],
  
  // Technology stack (signals buying intent)
  tech_stack_indicators: [
    'HubSpot',
    'Salesforce',
    'Stripe',
    'Intercom',
    'Segment'
  ],
  
  // Pain point signals
  pain_signals: [
    'hiring rapidly',
    'scaling operations',
    'improving efficiency',
    'reducing costs',
    'automation needs'
  ]
};
```

### Contact Characteristics

```javascript
const CONTACT_ICP = {
  // Job titles (decision makers)
  titles: [
    'CEO',
    'CTO',
    'VP of Operations',
    'Head of Growth',
    'Director of Marketing',
    'Operations Manager'
  ],
  
  // Seniority levels
  seniority: ['Director', 'VP', 'Head', 'C-Level'],
  
  // Department
  departments: ['Operations', 'Marketing', 'Growth', 'Executive']
};
```

## Supabase Database Schema

Complete SQL schema for lead management:

```sql
-- Main leads table
CREATE TABLE leads (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  company_name text NOT NULL,
  website text,
  domain text, -- extracted from website
  email text,
  contact_name text,
  contact_title text,
  contact_email text,
  industry text,
  employee_count integer,
  revenue_range text,
  funding_stage text,
  location_country text,
  location_city text,
  score integer DEFAULT 0,
  status text DEFAULT 'new' CHECK (status IN ('new','qualified','contacted','replied','converted','dead')),
  source text NOT NULL, -- where we found them
  source_url text, -- specific page/listing
  notes text,
  pain_signals text[], -- array of detected pain points
  tech_stack text[], -- array of technologies used
  social_links jsonb DEFAULT '{}', -- LinkedIn, Twitter, etc
  enrichment_data jsonb DEFAULT '{}', -- AI research results
  last_activity timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enrichment activities log
CREATE TABLE lead_enrichments (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  lead_id uuid REFERENCES leads(id) ON DELETE CASCADE,
  enrichment_type text NOT NULL, -- 'company_research', 'contact_discovery', 'tech_stack'
  status text DEFAULT 'pending' CHECK (status IN ('pending','completed','failed')),
  input_data jsonb DEFAULT '{}',
  output_data jsonb DEFAULT '{}',
  error_message text,
  cost_usd decimal(10,4),
  model_used text,
  created_at timestamptz DEFAULT now(),
  completed_at timestamptz
);

-- Lead scoring components
CREATE TABLE lead_scores (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  lead_id uuid REFERENCES leads(id) ON DELETE CASCADE,
  score_type text NOT NULL, -- 'company_fit', 'contact_quality', 'intent_signals', 'total'
  score_value integer NOT NULL,
  score_reasoning text,
  factors jsonb DEFAULT '{}', -- breakdown of score components
  created_at timestamptz DEFAULT now()
);

-- Lead activities (touches, emails, calls)
CREATE TABLE lead_activities (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  lead_id uuid REFERENCES leads(id) ON DELETE CASCADE,
  activity_type text NOT NULL, -- 'scraped', 'enriched', 'contacted', 'replied', 'converted'
  channel text, -- 'email', 'linkedin', 'phone', 'website'
  subject text,
  message text,
  response text,
  metadata jsonb DEFAULT '{}',
  created_at timestamptz DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX idx_leads_status ON leads(status);
CREATE INDEX idx_leads_score ON leads(score DESC);
CREATE INDEX idx_leads_industry ON leads(industry);
CREATE INDEX idx_leads_employee_count ON leads(employee_count);
CREATE INDEX idx_leads_created_at ON leads(created_at);
CREATE INDEX idx_leads_domain ON leads(domain);
CREATE INDEX idx_lead_activities_lead_id ON lead_activities(lead_id);
CREATE INDEX idx_lead_activities_type ON lead_activities(activity_type);
CREATE INDEX idx_lead_enrichments_lead_id ON lead_enrichments(lead_id);

-- RLS policies (if using Supabase auth)
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_enrichments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE lead_activities ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to manage their leads
CREATE POLICY "Users can manage leads" ON leads
FOR ALL USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can manage enrichments" ON lead_enrichments
FOR ALL USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can manage scores" ON lead_scores
FOR ALL USING (auth.uid() IS NOT NULL);

CREATE POLICY "Users can manage activities" ON lead_activities
FOR ALL USING (auth.uid() IS NOT NULL);

-- Update trigger for leads
CREATE OR REPLACE FUNCTION update_lead_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_leads_timestamp
  BEFORE UPDATE ON leads
  FOR EACH ROW
  EXECUTE FUNCTION update_lead_timestamp();
```

## Source Identification Strategy

### High-Value Lead Sources

**1. Industry Directories**
```javascript
const LEAD_SOURCES = {
  directories: [
    {
      name: 'Crunchbase',
      url: 'https://www.crunchbase.com/',
      type: 'startup_database',
      filters: ['funding_stage', 'industry', 'employee_count'],
      cost: 'paid_api'
    },
    {
      name: 'AngelList',
      url: 'https://angel.co/',
      type: 'startup_jobs',
      filters: ['company_stage', 'role_type'],
      cost: 'free_scraping'
    },
    {
      name: 'Built In',
      url: 'https://builtin.com/',
      type: 'tech_companies',
      filters: ['location', 'industry', 'company_size'],
      cost: 'free_scraping'
    },
    {
      name: 'Inc 5000',
      url: 'https://www.inc.com/inc5000/',
      type: 'fast_growing',
      filters: ['revenue_growth', 'industry'],
      cost: 'free_scraping'
    }
  ],
  
  job_boards: [
    {
      name: 'LinkedIn Jobs',
      url: 'https://linkedin.com/jobs/',
      type: 'hiring_companies',
      signals: ['rapid_hiring', 'scaling_teams'],
      cost: 'scraping'
    },
    {
      name: 'Lever Jobs',
      url: 'https://jobs.lever.co/',
      type: 'tech_hiring',
      signals: ['operations_roles', 'automation_needs'],
      cost: 'free_scraping'
    }
  ]
};
```

**2. Web Scraping Implementation**

Here's a production-ready scraper using Playwright:

```javascript
// scraper.js
import { chromium } from 'playwright';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

class LeadScraper {
  constructor() {
    this.browser = null;
    this.page = null;
  }

  async initialize() {
    this.browser = await chromium.launch({
      headless: true,
      args: ['--no-sandbox', '--disable-setuid-sandbox']
    });
    this.page = await this.browser.newPage();
    
    // Randomize user agent
    await this.page.setUserAgent(
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    );
    
    // Add random delays
    await this.page.setDefaultTimeout(30000);
  }

  async scrapeBuiltIn(location = 'san-francisco', industry = 'software') {
    const url = `https://builtin.com/${location}/companies?industries=${industry}`;
    console.log(`Scraping Built In: ${url}`);
    
    await this.page.goto(url, { waitUntil: 'networkidle' });
    
    // Wait for company cards to load
    await this.page.waitForSelector('[data-testid="company-card"]');
    
    const companies = await this.page.evaluate(() => {
      const cards = document.querySelectorAll('[data-testid="company-card"]');
      return Array.from(cards).map(card => {
        const nameEl = card.querySelector('h2 a');
        const descEl = card.querySelector('.company-description');
        const sizeEl = card.querySelector('.company-size');
        const locationEl = card.querySelector('.company-location');
        const industryEl = card.querySelector('.company-industry');
        
        return {
          company_name: nameEl?.textContent?.trim(),
          website: this.extractDomainFromUrl(nameEl?.href),
          description: descEl?.textContent?.trim(),
          employee_count: this.parseEmployeeCount(sizeEl?.textContent),
          location_city: locationEl?.textContent?.trim(),
          industry: industryEl?.textContent?.trim(),
          source: 'builtin',
          source_url: window.location.href
        };
      });
    });
    
    return this.processCompanies(companies);
  }

  async scrapeIncorporatedList() {
    const url = 'https://www.inc.com/inc5000list/json/inc5000_2024.json';
    console.log('Scraping Inc 5000 list...');
    
    const response = await this.page.goto(url);
    const data = await response.json();
    
    const companies = data.map(company => ({
      company_name: company.company,
      website: this.cleanUrl(company.profile_url),
      industry: company.industry,
      location_city: company.city,
      location_country: 'United States',
      revenue_range: this.categorizeRevenue(company.revenue),
      employee_count: parseInt(company.workers) || null,
      source: 'inc5000',
      source_url: url,
      notes: `Inc 5000 Rank: ${company.rank}, Growth: ${company.growth}%`
    }));
    
    return this.processCompanies(companies);
  }

  async processCompanies(companies) {
    const processedLeads = [];
    
    for (const company of companies) {
      if (!company.company_name || !company.website) continue;
      
      // Skip if already exists
      const { data: existing } = await supabase
        .from('leads')
        .select('id')
        .eq('domain', this.extractDomain(company.website))
        .single();
      
      if (existing) continue;
      
      // Clean and enrich data
      const lead = {
        ...company,
        domain: this.extractDomain(company.website),
        status: 'new',
        created_at: new Date().toISOString()
      };
      
      // Insert into database
      const { error } = await supabase
        .from('leads')
        .insert([lead]);
      
      if (!error) {
        processedLeads.push(lead);
        
        // Log activity
        await this.logActivity(lead.id, 'scraped', {
          source: lead.source,
          url: lead.source_url
        });
      }
    }
    
    return processedLeads;
  }

  extractDomain(url) {
    if (!url) return null;
    try {
      return new URL(url.startsWith('http') ? url : `https://${url}`).hostname;
    } catch {
      return null;
    }
  }

  parseEmployeeCount(sizeText) {
    if (!sizeText) return null;
    const match = sizeText.match(/(\d+)-(\d+)/);
    if (match) {
      return Math.floor((parseInt(match[1]) + parseInt(match[2])) / 2);
    }
    const single = sizeText.match(/(\d+)/);
    return single ? parseInt(single[1]) : null;
  }

  categorizeRevenue(revenue) {
    const rev = parseInt(revenue);
    if (rev < 1000000) return 'Under $1M';
    if (rev < 5000000) return '$1M-$5M';
    if (rev < 25000000) return '$5M-$25M';
    if (rev < 100000000) return '$25M-$100M';
    return 'Over $100M';
  }

  async logActivity(leadId, activityType, metadata) {
    await supabase.from('lead_activities').insert([{
      lead_id: leadId,
      activity_type: activityType,
      metadata,
      created_at: new Date().toISOString()
    }]);
  }

  async close() {
    if (this.browser) {
      await this.browser.close();
    }
  }
}

export default LeadScraper;
```

## AI-Powered Lead Enrichment

Once you have raw company data, AI enrichment adds the intelligence layer:

```javascript
// enricher.js
import OpenAI from 'openai';
import { createClient } from '@supabase/supabase-js';

const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

class LeadEnricher {
  constructor() {
    this.model = 'gpt-4o-mini'; // Cost-effective for enrichment
  }

  async enrichLead(leadId) {
    const { data: lead } = await supabase
      .from('leads')
      .select('*')
      .eq('id', leadId)
      .single();
    
    if (!lead) throw new Error('Lead not found');
    
    console.log(`Enriching lead: ${lead.company_name}`);
    
    // Create enrichment record
    const { data: enrichment } = await supabase
      .from('lead_enrichments')
      .insert([{
        lead_id: leadId,
        enrichment_type: 'full_company_research',
        status: 'pending',
        input_data: { company_name: lead.company_name, website: lead.website }
      }])
      .select()
      .single();

    try {
      // Research company
      const companyResearch = await this.researchCompany(lead);
      
      // Find contacts
      const contacts = await this.findContacts(lead);
      
      // Detect tech stack
      const techStack = await this.detectTechStack(lead.website);
      
      // Update lead with enriched data
      const enrichedData = {
        pain_signals: companyResearch.pain_signals,
        tech_stack: techStack.technologies,
        social_links: companyResearch.social_links,
        enrichment_data: {
          company_description: companyResearch.description,
          recent_news: companyResearch.news,
          growth_indicators: companyResearch.growth,
          contact_patterns: contacts.patterns,
          tech_stack_confidence: techStack.confidence
        },
        contact_email: contacts.primary_email,
        contact_name: contacts.primary_contact,
        contact_title: contacts.primary_title
      };

      await supabase
        .from('leads')
        .update(enrichedData)
        .eq('id', leadId);

      // Complete enrichment record
      await supabase
        .from('lead_enrichments')
        .update({
          status: 'completed',
          output_data: enrichedData,
          cost_usd: 0.05, // Estimated cost
          model_used: this.model,
          completed_at: new Date().toISOString()
        })
        .eq('id', enrichment.id);

      return enrichedData;
      
    } catch (error) {
      await supabase
        .from('lead_enrichments')
        .update({
          status: 'failed',
          error_message: error.message,
          completed_at: new Date().toISOString()
        })
        .eq('id', enrichment.id);
      
      throw error;
    }
  }

  async researchCompany(lead) {
    const prompt = `Research this company for B2B sales intelligence:
    
Company: ${lead.company_name}
Website: ${lead.website}
Industry: ${lead.industry}
Size: ${lead.employee_count} employees

Analyze and return JSON with:
1. pain_signals: Array of likely pain points (operations, scaling, efficiency, costs)
2. description: Brief company overview (2-3 sentences)
3. news: Recent developments, funding, growth indicators
4. growth: Growth stage assessment (startup, scaling, mature, declining)
5. social_links: LinkedIn, Twitter handles if findable

Focus on identifying automation and operational efficiency opportunities. Be specific and actionable.`;

    const completion = await openai.chat.completions.create({
      model: this.model,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.3
    });

    return JSON.parse(completion.choices[0].message.content);
  }

  async findContacts(lead) {
    const prompt = `Find contact information for this company:
    
Company: ${lead.company_name}
Website: ${lead.website}
Domain: ${lead.domain}

Based on common email patterns and the company name/domain, suggest:
1. primary_contact: Most likely decision maker name (if determinable)
2. primary_title: Most likely title (CEO, COO, VP Operations)
3. primary_email: Best guess email using common patterns
4. patterns: Array of likely email formats for this domain

Target roles: CEO, COO, VP/Director of Operations, Head of Growth

Return JSON format. Use common email patterns like:
- firstname@domain.com
- first.last@domain.com  
- f.lastname@domain.com
- firstname.lastname@domain.com

If company name suggests founder names, incorporate those.`;

    const completion = await openai.chat.completions.create({
      model: this.model,
      messages: [{ role: 'user', content: prompt }],
      temperature: 0.2
    });

    return JSON.parse(completion.choices[0].message.content);
  }

  async detectTechStack(website) {
    if (!website) return { technologies: [], confidence: 'low' };
    
    try {
      // Simple tech stack detection via common indicators
      const response = await fetch(website);
      const html = await response.text();
      
      const technologies = [];
      const indicators = {
        'HubSpot': ['hubspot', 'hs-analytics', 'hsforms'],
        'Google Analytics': ['google-analytics', 'gtag', 'ga.js'],
        'Salesforce': ['salesforce', 'force.com'],
        'Stripe': ['stripe', 'js.stripe.com'],
        'Intercom': ['intercom', 'widget.intercom'],
        'Segment': ['segment.com', 'analytics.load'],
        'Shopify': ['shopify', 'cdn.shopify'],
        'WordPress': ['wp-content', 'wordpress'],
        'React': ['react', '__REACT_DEVTOOLS'],
        'Next.js': ['__NEXT_DATA__', '_next/static']
      };
      
      for (const [tech, patterns] of Object.entries(indicators)) {
        if (patterns.some(pattern => html.toLowerCase().includes(pattern.toLowerCase()))) {
          technologies.push(tech);
        }
      }
      
      return {
        technologies,
        confidence: technologies.length > 0 ? 'medium' : 'low'
      };
    } catch (error) {
      return { technologies: [], confidence: 'low' };
    }
  }

  async enrichBatch(leadIds) {
    const results = [];
    
    for (const leadId of leadIds) {
      try {
        const result = await this.enrichLead(leadId);
        results.push({ leadId, status: 'success', data: result });
        
        // Rate limiting
        await new Promise(resolve => setTimeout(resolve, 2000));
      } catch (error) {
        results.push({ leadId, status: 'error', error: error.message });
      }
    }
    
    return results;
  }
}

export default LeadEnricher;
```

## Lead Scoring System

Multi-factor scoring to rank prospects:

```javascript
// scorer.js
class LeadScorer {
  constructor() {
    this.weights = {
      company_fit: 0.40,    // How well they match ICP
      contact_quality: 0.25, // Contact info confidence
      intent_signals: 0.20,  // Buying intent indicators
      tech_fit: 0.15        // Technology stack alignment
    };
  }

  async scoreLead(leadId) {
    const { data: lead } = await supabase
      .from('leads')
      .select('*')
      .eq('id', leadId)
      .single();

    const scores = {
      company_fit: this.scoreCompanyFit(lead),
      contact_quality: this.scoreContactQuality(lead),
      intent_signals: this.scoreIntentSignals(lead),
      tech_fit: this.scoreTechFit(lead)
    };

    // Calculate weighted total
    const totalScore = Object.entries(scores).reduce((total, [factor, score]) => {
      return total + (score * this.weights[factor]);
    }, 0);

    // Store individual scores
    for (const [scoreType, scoreValue] of Object.entries(scores)) {
      await supabase.from('lead_scores').insert([{
        lead_id: leadId,
        score_type: scoreType,
        score_value: Math.round(scoreValue),
        score_reasoning: this.getScoreReasoning(scoreType, lead),
        factors: this.getScoreFactors(scoreType, lead)
      }]);
    }

    // Store total score
    await supabase.from('lead_scores').insert([{
      lead_id: leadId,
      score_type: 'total',
      score_value: Math.round(totalScore),
      score_reasoning: 'Weighted composite of all factors',
      factors: scores
    }]);

    // Update main lead record
    await supabase
      .from('leads')
      .update({ score: Math.round(totalScore) })
      .eq('id', leadId);

    return {
      total_score: Math.round(totalScore),
      breakdown: scores
    };
  }

  scoreCompanyFit(lead) {
    let score = 0;
    
    // Employee count (0-30 points)
    if (lead.employee_count >= 50 && lead.employee_count <= 200) {
      score += 30; // Ideal range
    } else if (lead.employee_count >= 10 && lead.employee_count <= 500) {
      score += 20; // Acceptable range
    } else {
      score += 5; // Outside target
    }
    
    // Industry match (0-25 points)
    const targetIndustries = ['Software', 'SaaS', 'E-commerce', 'Marketing Agencies'];
    if (targetIndustries.includes(lead.industry)) {
      score += 25;
    } else if (lead.industry) {
      score += 10; // Has industry data
    }
    
    // Location (0-15 points)
    const targetCountries = ['United States', 'Canada', 'United Kingdom'];
    if (targetCountries.includes(lead.location_country)) {
      score += 15;
    }
    
    // Growth indicators (0-30 points)
    if (lead.source === 'inc5000') score += 30; // Fast-growing company
    if (lead.notes?.includes('hiring')) score += 15;
    if (lead.notes?.includes('funding')) score += 15;
    
    return Math.min(score, 100);
  }

  scoreContactQuality(lead) {
    let score = 0;
    
    // Has contact name (20 points)
    if (lead.contact_name) score += 20;
    
    // Has contact email (30 points)
    if (lead.contact_email) score += 30;
    
    // Has contact title (20 points)  
    if (lead.contact_title) score += 20;
    
    // Title relevance (30 points)
    const decisionMakerTitles = ['CEO', 'COO', 'VP', 'Director', 'Head'];
    if (lead.contact_title && decisionMakerTitles.some(title => 
      lead.contact_title.includes(title))) {
      score += 30;
    }
    
    return Math.min(score, 100);
  }

  scoreIntentSignals(lead) {
    let score = 0;
    
    // Pain signals detected (40 points)
    if (lead.pain_signals?.length > 0) {
      score += Math.min(lead.pain_signals.length * 10, 40);
    }
    
    // Recent activity/news (20 points)
    if (lead.enrichment_data?.recent_news?.length > 0) {
      score += 20;
    }
    
    // Growth stage (40 points)
    const growthStage = lead.enrichment_data?.growth_indicators;
    if (growthStage === 'scaling') score += 40;
    else if (growthStage === 'startup') score += 25;
    else if (growthStage === 'mature') score += 10;
    
    return Math.min(score, 100);
  }

  scoreTechFit(lead) {
    let score = 0;
    
    // Has tech stack data (20 points)
    if (lead.tech_stack?.length > 0) score += 20;
    
    // Relevant technologies (80 points)
    const targetTech = ['HubSpot', 'Salesforce', 'Stripe', 'Segment', 'Intercom'];
    const matches = lead.tech_stack?.filter(tech => 
      targetTech.includes(tech)).length || 0;
    score += Math.min(matches * 20, 80);
    
    return Math.min(score, 100);
  }

  getScoreReasoning(scoreType, lead) {
    // Return human-readable explanation of score
    // Implementation depends on specific scoring logic
    return `Score calculated based on ${scoreType} factors`;
  }

  getScoreFactors(scoreType, lead) {
    // Return detailed breakdown of scoring factors
    return {};
  }
}
```

## Automated Pipeline Cron Job

Complete cron configuration for automated lead generation:

```json
{
  "name": "lead_generation_pipeline",
  "cron": "0 2 * * 1,3,5",
  "model": "gpt-4o-mini",
  "estimated_cost_per_run": 2.50,
  "description": "Full lead generation pipeline: scrape → enrich → score",
  "prompt": "Execute the complete lead generation pipeline:\n\n1. **Scrape New Leads** (Budget: 50 new leads)\n   - Built In tech companies (10 leads)\n   - Inc 5000 fast-growing companies (20 leads)\n   - AngelList hiring companies (20 leads)\n   \n2. **Enrich Unprocessed Leads**\n   - Get all leads where enrichment_data is null\n   - Run AI enrichment on up to 30 leads\n   - Focus on: pain signals, contact discovery, tech stack\n   \n3. **Score All Unscored Leads**\n   - Calculate scores for leads where score = 0\n   - Update lead scores in database\n   \n4. **Generate Pipeline Report**\n   - New leads added this week\n   - Top 10 highest scoring leads\n   - Enrichment success rate\n   - Source performance analysis\n   \n5. **Update Lead Statuses**\n   - Mark leads >90 days old as 'stale' if no activity\n   - Identify high-value leads ready for outreach\n   \nExecute each step in sequence. Report results and any errors. Include metrics: leads processed, enrichments completed, average score, top prospects ready for outreach.\n\nUse the LeadScraper, LeadEnricher, and LeadScorer classes. Store all results in Supabase.\n\nIf any step fails, continue with remaining steps but log the error.",
  "tags": ["lead-generation", "automation", "weekly"]
}
```

## Weekly Pipeline Reports

SQL queries for pipeline metrics:

```sql
-- Weekly pipeline performance report
WITH weekly_stats AS (
  SELECT 
    COUNT(*) as total_leads,
    COUNT(CASE WHEN created_at > NOW() - INTERVAL '7 days' THEN 1 END) as new_this_week,
    COUNT(CASE WHEN status = 'qualified' THEN 1 END) as qualified,
    COUNT(CASE WHEN status = 'contacted' THEN 1 END) as contacted,
    COUNT(CASE WHEN status = 'replied' THEN 1 END) as replied,
    COUNT(CASE WHEN status = 'converted' THEN 1 END) as converted,
    AVG(score) as avg_score,
    COUNT(CASE WHEN enrichment_data IS NOT NULL THEN 1 END) as enriched
  FROM leads
),
source_performance AS (
  SELECT 
    source,
    COUNT(*) as leads_count,
    AVG(score) as avg_score,
    COUNT(CASE WHEN status IN ('contacted', 'replied', 'converted') THEN 1 END) as engaged
  FROM leads 
  WHERE created_at > NOW() - INTERVAL '30 days'
  GROUP BY source
  ORDER BY avg_score DESC
),
top_prospects AS (
  SELECT 
    company_name,
    contact_name,
    contact_email,
    score,
    industry,
    employee_count,
    status
  FROM leads 
  WHERE score >= 80 
    AND status = 'new'
  ORDER BY score DESC
  LIMIT 10
)
SELECT 
  'Weekly Pipeline Report - ' || TO_CHAR(NOW(), 'YYYY-MM-DD') as report_title,
  json_build_object(
    'summary', row_to_json(weekly_stats.*),
    'source_performance', json_agg(DISTINCT source_performance.*),
    'top_prospects', json_agg(DISTINCT top_prospects.*)
  ) as report_data
FROM weekly_stats, source_performance, top_prospects;

-- Lead scoring distribution
SELECT 
  CASE 
    WHEN score >= 90 THEN 'A+ (90-100)'
    WHEN score >= 80 THEN 'A (80-89)'
    WHEN score >= 70 THEN 'B (70-79)'
    WHEN score >= 60 THEN 'C (60-69)'
    ELSE 'D (<60)'
  END as score_tier,
  COUNT(*) as lead_count,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM leads
WHERE score > 0
GROUP BY score_tier
ORDER BY MIN(score) DESC;

-- Enrichment success rates
SELECT 
  enrichment_type,
  COUNT(*) as total_attempts,
  COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful,
  ROUND(
    COUNT(CASE WHEN status = 'completed' THEN 1 END) * 100.0 / COUNT(*), 2
  ) as success_rate,
  AVG(cost_usd) as avg_cost,
  SUM(cost_usd) as total_cost
FROM lead_enrichments
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY enrichment_type;
```

## GDPR & CAN-SPAM Compliance

**Legal requirements for B2B outreach:**

```javascript
// compliance.js
class ComplianceManager {
  constructor() {
    this.gdprCountries = ['AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE'];
  }

  checkGDPRApplicability(lead) {
    const country = lead.location_country;
    const isEU = this.gdprCountries.includes(country);
    
    return {
      subject_to_gdpr: isEU,
      data_processing_basis: isEU ? 'legitimate_interest' : 'not_applicable',
      retention_period: isEU ? '2_years' : 'indefinite',
      opt_out_required: true,
      consent_required: false // B2B legitimate interest
    };
  }

  generateOptOutFooter(leadId) {
    const unsubscribeUrl = `${process.env.BASE_URL}/unsubscribe/${leadId}`;
    
    return `
    <div style="font-size: 12px; color: #666; margin-top: 20px; padding-top: 20px; border-top: 1px solid #eee;">
      <p>This email was sent to a business email address. If you no longer wish to receive these communications, you may <a href="${unsubscribeUrl}">unsubscribe here</a>.</p>
      <p>Your Company Name<br>
      123 Business St<br>
      City, State 12345<br>
      United States</p>
    </div>`;
  }

  async processOptOut(leadId) {
    await supabase
      .from('leads')
      .update({ 
        status: 'opted_out',
        notes: 'User requested opt-out on ' + new Date().toISOString()
      })
      .eq('id', leadId);
    
    // Log activity
    await supabase.from('lead_activities').insert([{
      lead_id: leadId,
      activity_type: 'opted_out',
      channel: 'email',
      message: 'Lead opted out of communications'
    }]);
  }
}
```

## Complete Implementation Example

Here's a working end-to-end example:

```javascript
// pipeline.js - Main pipeline orchestrator
import LeadScraper from './scraper.js';
import LeadEnricher from './enricher.js';
import LeadScorer from './scorer.js';
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY
);

class LeadGenerationPipeline {
  constructor() {
    this.scraper = new LeadScraper();
    this.enricher = new LeadEnricher();
    this.scorer = new LeadScorer();
  }

  async runFullPipeline() {
    console.log('🚀 Starting lead generation pipeline...');
    const startTime = Date.now();
    const results = {
      scraped: 0,
      enriched: 0,
      scored: 0,
      errors: []
    };

    try {
      // Step 1: Scrape new leads
      console.log('📊 Scraping new leads...');
      await this.scraper.initialize();
      
      const builtInLeads = await this.scraper.scrapeBuiltIn('san-francisco', 'software');
      const inc5000Leads = await this.scraper.scrapeIncorporatedList();
      
      results.scraped = builtInLeads.length + inc5000Leads.length;
      console.log(`✅ Scraped ${results.scraped} new leads`);

      await this.scraper.close();

      // Step 2: Enrich unprocessed leads
      console.log('🔍 Enriching leads...');
      const { data: unenrichedLeads } = await supabase
        .from('leads')
        .select('id')
        .is('enrichment_data', null)
        .limit(30);

      if (unenrichedLeads?.length > 0) {
        const enrichResults = await this.enricher.enrichBatch(
          unenrichedLeads.map(l => l.id)
        );
        results.enriched = enrichResults.filter(r => r.status === 'success').length;
      }
      console.log(`✅ Enriched ${results.enriched} leads`);

      // Step 3: Score unscored leads
      console.log('🎯 Scoring leads...');
      const { data: unscoredLeads } = await supabase
        .from('leads')
        .select('id')
        .eq('score', 0)
        .limit(50);

      if (unscoredLeads?.length > 0) {
        for (const lead of unscoredLeads) {
          try {
            await this.scorer.scoreLead(lead.id);
            results.scored++;
          } catch (error) {
            results.errors.push(`Scoring error for lead ${lead.id}: ${error.message}`);
          }
        }
      }
      console.log(`✅ Scored ${results.scored} leads`);

      // Step 4: Generate report
      const report = await this.generateReport();
      console.log('📈 Pipeline Report Generated');

      const duration = (Date.now() - startTime) / 1000;
      console.log(`✅ Pipeline completed in ${duration}s`);

      return {
        ...results,
        duration,
        report
      };

    } catch (error) {
      console.error('❌ Pipeline error:', error);
      results.errors.push(error.message);
      return results;
    }
  }

  async generateReport() {
    const { data: stats } = await supabase.rpc('get_pipeline_stats');
    
    return {
      generated_at: new Date().toISOString(),
      total_leads: stats?.total_leads || 0,
      qualified_leads: stats?.qualified || 0,
      average_score: Math.round(stats?.avg_score || 0),
      top_prospects: await this.getTopProspects()
    };
  }

  async getTopProspects() {
    const { data } = await supabase
      .from('leads')
      .select('company_name, contact_name, score, industry')
      .eq('status', 'new')
      .gte('score', 80)
      .order('score', { ascending: false })
      .limit(10);
    
    return data || [];
  }
}

// Usage
const pipeline = new LeadGenerationPipeline();
pipeline.runFullPipeline()
  .then(results => console.log('Pipeline Results:', results))
  .catch(error => console.error('Pipeline Failed:', error));
```

## Production Deployment

**Environment Configuration:**

```bash
# .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-role-key
OPENAI_API_KEY=your-openai-key
BASE_URL=https://yourdomain.com

# Scraping limits
MAX_LEADS_PER_RUN=50
ENRICHMENT_BATCH_SIZE=30
SCORE_BATCH_SIZE=50

# Compliance
COMPANY_NAME="Your Company Name"
COMPANY_ADDRESS="123 Business St, City, State 12345"
```

**Docker Deployment:**

```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install

COPY . .

# Run pipeline
CMD ["node", "pipeline.js"]
```

## Key Takeaways

1. **Systems Over Manual Work**: Automate everything from scraping to scoring
2. **Quality Over Quantity**: Better to have 100 qualified leads than 1000 junk contacts
3. **Data-Driven Decisions**: Use scoring and analytics to focus efforts
4. **Compliance First**: Build legal requirements into the system from day one
5. **Continuous Improvement**: Monitor performance, optimize scoring, update sources

This pipeline processes thousands of prospects monthly while you focus on closing deals. The initial setup investment pays dividends in qualified pipeline and time savings.

Next chapter: We'll build the email outreach system to convert these leads into conversations.