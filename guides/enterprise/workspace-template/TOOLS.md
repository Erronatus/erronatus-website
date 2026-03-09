# TOOLS.md - Local Configuration

This file contains your specific tool configurations and local setup details.

## API Keys and Credentials
Store actual keys in .env file - this is just for documentation

### Required Services
- **OpenClaw API Key:** Your AI automation platform key - Get at: https://app.openclaw.com/api-keys
- **Supabase:** Database URL and keys - Setup at: https://app.supabase.com
- **Resend/SendGrid:** Email delivery service - Get Resend key at: https://resend.com/api-keys

### Optional Integrations
- **Slack:** Webhook URLs for notifications - Create webhooks in your Slack workspace
- **Discord:** Bot tokens and channel IDs - Create bot at: https://discord.com/developers/applications
- **Twitter/X:** API credentials for social monitoring - Apply at: https://developer.twitter.com
- **LinkedIn:** API access for professional network automation - Apply at: https://developer.linkedin.com

## Database Configuration (Supabase Setup)

### Required Tables for Lead Generation
```sql
-- Copy-paste into Supabase SQL Editor
CREATE TABLE leads (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    first_name TEXT,
    last_name TEXT,
    company TEXT,
    job_title TEXT,
    phone TEXT,
    linkedin_url TEXT,
    website TEXT,
    lead_score INTEGER DEFAULT 0,
    status TEXT DEFAULT 'new',
    source TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE email_campaigns (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    subject_line TEXT NOT NULL,
    email_body TEXT NOT NULL,
    status TEXT DEFAULT 'draft',
    sent_count INTEGER DEFAULT 0,
    open_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    reply_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE email_sends (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    lead_id UUID REFERENCES leads(id),
    campaign_id UUID REFERENCES email_campaigns(id),
    sent_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    opened_at TIMESTAMP WITH TIME ZONE,
    clicked_at TIMESTAMP WITH TIME ZONE,
    replied_at TIMESTAMP WITH TIME ZONE,
    bounced_at TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'sent'
);

-- Indexes for performance
CREATE INDEX idx_leads_email ON leads(email);
CREATE INDEX idx_leads_status ON leads(status);
CREATE INDEX idx_leads_created_at ON leads(created_at);
CREATE INDEX idx_email_sends_lead_id ON email_sends(lead_id);
CREATE INDEX idx_email_sends_sent_at ON email_sends(sent_at);
```

### Email Infrastructure Setup

#### Resend Configuration (Recommended)
1. Sign up at https://resend.com
2. Verify your sending domain
3. Add these DNS records to your domain:
   ```
   Type: TXT
   Name: _dmarc
   Value: v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com

   Type: TXT  
   Name: @
   Value: v=spf1 include:resend.com ~all

   Type: CNAME
   Name: resend._domainkey
   Value: resend._domainkey.resend.com
   ```
4. Get your API key and add to .env file

#### Domain Authentication Checklist
- [ ] SPF record added and verified
- [ ] DKIM record added and verified  
- [ ] DMARC policy configured
- [ ] Domain verification completed
- [ ] Test email sent and received

## Local Development Environment

### Required Software
- **Node.js 18+:** Download from https://nodejs.org
- **Git:** Version control - https://git-scm.com
- **VS Code:** Recommended editor with extensions:
  - OpenClaw Extension (when available)
  - PostgreSQL extension for database queries
  - REST Client for API testing
  - GitLens for Git integration

### Development Tools
- **Database Client:** Choose one:
  - TablePlus (Mac/Windows) - https://tableplus.com
  - pgAdmin - https://www.pgadmin.org
  - DBeaver - https://dbeaver.io
- **API Testing:** 
  - Postman - https://www.postman.com
  - Insomnia - https://insomnia.rest
- **Terminal:** 
  - Windows Terminal (Windows) - Microsoft Store
  - iTerm2 (Mac) - https://iterm2.com

## Automation Workflow Configurations

### Lead Generation Pipeline
```javascript
// Example lead scoring configuration
const LEAD_SCORING_RULES = {
    email_domain: {
        'gmail.com': -10,      // Consumer emails
        'yahoo.com': -10,
        'company.com': 20,     // Business emails get bonus
    },
    job_title: {
        'ceo': 50,
        'founder': 50,
        'director': 30,
        'manager': 20,
        'intern': -20
    },
    company_size: {
        'enterprise': 40,      // 1000+ employees
        'mid-market': 30,      // 100-999 employees  
        'small-business': 20,  // 10-99 employees
        'startup': 10          // <10 employees
    }
};
```

### Email Campaign Templates
Create in your email platform or store in database:

#### Welcome Series Template
```html
Subject: Welcome to [Company Name], [First Name]!

Hi [First Name],

Welcome aboard! You've just joined [Number] other professionals who are [Value Proposition].

Here's what happens next:

1. **Today**: You'll receive our getting started guide
2. **Day 3**: Tips for [Specific Benefit]  
3. **Day 7**: Case study showing [Specific Result]

Questions? Just reply to this email.

Best regards,
[Your Name]
[Your Title]
[Company Name]
```

#### Re-engagement Template  
```html
Subject: We miss you, [First Name]

Hi [First Name],

I noticed you haven't opened our emails lately. 

That's okay - inboxes get crowded.

But if you're still interested in [Value Proposition], 
I have something special for you:

[Specific Offer/Resource]

Want it? Just reply with "YES"

Not interested? You can unsubscribe below.

[Your Name]
```

## Monitoring and Analytics

### Key Performance Indicators (KPIs)
Track these metrics in your dashboard:

```javascript
const BUSINESS_METRICS = {
    lead_generation: {
        leads_per_day: { target: 50, current: 0 },
        conversion_rate: { target: 0.15, current: 0 }, // 15%
        cost_per_lead: { target: 5.00, current: 0 },
        lead_quality_score: { target: 70, current: 0 }
    },
    email_marketing: {
        open_rate: { target: 0.25, current: 0 }, // 25%
        click_rate: { target: 0.05, current: 0 }, // 5%
        reply_rate: { target: 0.02, current: 0 }, // 2%
        deliverability: { target: 0.98, current: 0 } // 98%
    },
    business_impact: {
        monthly_recurring_revenue: { target: 10000, current: 0 },
        customer_acquisition_cost: { target: 100, current: 0 },
        customer_lifetime_value: { target: 1000, current: 0 },
        time_saved_per_week: { target: 20, current: 0 } // hours
    }
};
```

### Monitoring Stack
- **Uptime Monitoring:** UptimeRobot or Pingdom
- **Error Tracking:** Sentry or LogRocket
- **Analytics:** Google Analytics 4 or Mixpanel
- **Email Deliverability:** Mail-tester.com for testing

## Security and Compliance

### Security Checklist
- [ ] Two-factor authentication enabled on all accounts
- [ ] Strong, unique passwords in password manager
- [ ] API keys stored in environment variables, not code
- [ ] Database has row-level security enabled
- [ ] Regular backups scheduled and tested
- [ ] SSL certificates installed and auto-renewing

### Data Privacy Compliance
- [ ] Privacy policy includes data collection disclosure
- [ ] Unsubscribe links in all marketing emails
- [ ] Data retention policy defined and implemented
- [ ] GDPR/CCPA compliance if applicable to your business
- [ ] Lead consent tracking implemented

## Backup and Recovery

### Automated Backup Strategy
```sql
-- Schedule in your database (modify for your needs)
SELECT cron.schedule('backup-leads', '0 2 * * *', 
    'pg_dump -h localhost -U postgres -d your_db -t leads -f /backups/leads_$(date +%Y%m%d).sql'
);
```

### Recovery Testing
- Monthly backup restoration test
- Documentation of recovery procedures
- Contact list for emergency support
- Rollback procedures for failed deployments

---

*This file should be customized with your specific configurations. Keep sensitive information in .env files and secure storage.*