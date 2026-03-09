# Chapter 10: Full API Toolchain
## From 5 APIs to 14: Building Your Business Infrastructure

*The Personal Edition got you started with 5 essential APIs. The Business Edition scales you to 14 production-grade services that can run a real business. This isn't about collecting integrations — it's about building an infrastructure stack that generates revenue while you sleep.*

### Why This Matters

APIs are the nervous system of automated businesses. Each service you integrate multiplies your capabilities exponentially:
- 5 APIs = basic automation
- 10 APIs = sophisticated workflows  
- 14+ APIs = full business infrastructure

But here's the catch: most entrepreneurs fail at API integration because they treat it like a technical problem instead of a business architecture problem. You're not just connecting services — you're building the foundation that will handle millions in revenue.

By the end of this chapter, you'll have a bulletproof API foundation that can scale from your first customer to your first million.

## The Business Edition Stack

### Core 5 (Personal Edition Review)
- **OpenAI** - AI reasoning and content generation
- **Anthropic** - Advanced AI for complex tasks  
- **Telegram** - Real-time notifications and control
- **Supabase** - Database, auth, and file storage
- **GitHub** - Code management and deployment triggers

### Business 9 (New Additions)
- **Alpaca** - Paper trading and market data
- **Cloudflare** - CDN, DNS, and security
- **Vercel** - Hosting and serverless functions
- **Stripe** - Payment processing and billing
- **Resend** - Transactional email delivery
- **OpenRouter** - AI model aggregation and routing
- **Discord** - Community management and webhooks
- **Twilio** - SMS, voice, and WhatsApp messaging
- **Airtable** - Structured data and workflow management

Each API serves a specific business function. Miss one, and you'll hit a wall when scaling.

## Service-by-Service Setup

### 1. Alpaca - Paper Trading Engine

**Why you need it:** Real market data, paper trading, and financial alerts without risking real money.

**Account Setup:**
1. Go to [alpaca.markets](https://alpaca.markets)
2. Click "Get Started" → "Paper Trading"
3. Complete identity verification (required even for paper trading)
4. Verify email and phone number

**API Key Configuration:**
```bash
# In Alpaca dashboard, go to "Your API Keys"
# Generate new API key pair (keep secret!)

# Add to .env
ALPACA_API_KEY=your_api_key_here
ALPACA_SECRET_KEY=your_secret_key_here  
ALPACA_BASE_URL=https://paper-api.alpaca.markets
ALPACA_DATA_URL=https://data.alpaca.markets
```

**Test Connection:**
```javascript
// ~/.openclaw/workspace/scripts/test-alpaca.js
const axios = require('axios');

async function testAlpaca() {
    const headers = {
        'APCA-API-KEY-ID': process.env.ALPACA_API_KEY,
        'APCA-API-SECRET-KEY': process.env.ALPACA_SECRET_KEY
    };

    try {
        // Test account info
        const account = await axios.get('https://paper-api.alpaca.markets/v2/account', { headers });
        console.log('✅ Account Status:', account.data.status);
        console.log('💰 Buying Power:', account.data.buying_power);

        // Test market data
        const quote = await axios.get('https://data.alpaca.markets/v2/stocks/AAPL/quotes/latest', { headers });
        console.log('📈 AAPL Quote:', quote.data.quote);

        return true;
    } catch (error) {
        console.error('❌ Alpaca connection failed:', error.response?.data || error.message);
        return false;
    }
}

testAlpaca();
```

**Market Hours Understanding:**
```javascript
// Market hours helper
function getMarketStatus() {
    const now = new Date();
    const eastern = new Date(now.toLocaleString("en-US", {timeZone: "America/New_York"}));
    const hour = eastern.getHours();
    const day = eastern.getDay();
    
    // Weekend
    if (day === 0 || day === 6) return { open: false, reason: 'Weekend' };
    
    // Pre-market: 4:00 AM - 9:30 AM ET
    if (hour >= 4 && hour < 9 || (hour === 9 && eastern.getMinutes() < 30)) {
        return { open: 'pre-market', reason: 'Pre-market hours' };
    }
    
    // Market open: 9:30 AM - 4:00 PM ET
    if (hour >= 9 && hour < 16 || (hour === 9 && eastern.getMinutes() >= 30)) {
        return { open: true, reason: 'Market open' };
    }
    
    // After-hours: 4:00 PM - 8:00 PM ET
    if (hour >= 16 && hour < 20) {
        return { open: 'after-hours', reason: 'After-hours trading' };
    }
    
    return { open: false, reason: 'Market closed' };
}
```

### 2. Cloudflare - CDN and DNS Management

**Why you need it:** Fast global content delivery, DNS management, and DDoS protection for your business domains.

**Account Setup:**
1. Sign up at [cloudflare.com](https://cloudflare.com)
2. Add your domain (or buy one through Cloudflare)
3. Update nameservers at your registrar

**API Token Creation:**
1. Go to "My Profile" → "API Tokens"
2. "Create Token" → "Custom token"
3. Permissions needed:
   - Zone:DNS:Edit
   - Zone:Zone:Read
   - Zone:Analytics:Read

```bash
# Add to .env
CLOUDFLARE_API_TOKEN=your_api_token_here
CLOUDFLARE_ZONE_ID=your_zone_id_here
CLOUDFLARE_ACCOUNT_ID=your_account_id_here
```

**Test and Initial Setup:**
```javascript
// ~/.openclaw/workspace/scripts/test-cloudflare.js
const axios = require('axios');

class CloudflareManager {
    constructor() {
        this.token = process.env.CLOUDFLARE_API_TOKEN;
        this.zoneId = process.env.CLOUDFLARE_ZONE_ID;
        this.baseUrl = 'https://api.cloudflare.com/client/v4';
    }

    async testConnection() {
        try {
            const headers = { Authorization: `Bearer ${this.token}` };
            const response = await axios.get(`${this.baseUrl}/user/tokens/verify`, { headers });
            console.log('✅ Cloudflare token valid');
            return true;
        } catch (error) {
            console.error('❌ Cloudflare token invalid:', error.response?.data);
            return false;
        }
    }

    async createDNSRecord(name, type, content, ttl = 300) {
        const headers = { 
            Authorization: `Bearer ${this.token}`,
            'Content-Type': 'application/json'
        };

        const data = { name, type, content, ttl };

        try {
            const response = await axios.post(
                `${this.baseUrl}/zones/${this.zoneId}/dns_records`, 
                data, 
                { headers }
            );
            console.log(`✅ Created ${type} record: ${name} → ${content}`);
            return response.data.result;
        } catch (error) {
            console.error(`❌ Failed to create DNS record:`, error.response?.data);
            throw error;
        }
    }

    async listDNSRecords() {
        const headers = { Authorization: `Bearer ${this.token}` };
        const response = await axios.get(
            `${this.baseUrl}/zones/${this.zoneId}/dns_records`,
            { headers }
        );
        return response.data.result;
    }
}

// Test usage
async function setupCloudflare() {
    const cf = new CloudflareManager();
    
    if (await cf.testConnection()) {
        const records = await cf.listDNSRecords();
        console.log('📋 Current DNS records:', records.length);
        
        // Setup common business records
        await cf.createDNSRecord('api', 'CNAME', 'your-vercel-app.vercel.app');
        await cf.createDNSRecord('app', 'CNAME', 'your-vercel-app.vercel.app');
        await cf.createDNSRecord('mail', 'MX', 'mx.resend.com', 1, 10);
    }
}

module.exports = CloudflareManager;
```

### 3. Vercel - Hosting and Deployment

**Why you need it:** Serverless hosting, automatic deployments, and edge functions for your business applications.

**Account Setup:**
1. Sign up at [vercel.com](https://vercel.com)  
2. Connect your GitHub account
3. Import your first project

**CLI Installation and Setup:**
```bash
# Install Vercel CLI globally
npm install -g vercel

# Login and connect account
vercel login

# Link your project
cd ~/.openclaw/workspace/projects/your-business-app
vercel link

# Generate deployment token
vercel --token
```

**Project Configuration:**
```json
// vercel.json in your project root
{
  "version": 2,
  "builds": [
    {
      "src": "api/**/*.js",
      "use": "@vercel/node"
    },
    {
      "src": "public/**/*",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/api/(.*)",
      "dest": "/api/$1"
    },
    {
      "src": "/(.*)",
      "dest": "/public/$1"
    }
  ],
  "env": {
    "SUPABASE_URL": "@supabase_url",
    "SUPABASE_ANON_KEY": "@supabase_anon_key",
    "STRIPE_SECRET_KEY": "@stripe_secret_key"
  }
}
```

**Environment Variables:**
```bash
# Add to .env
VERCEL_TOKEN=your_deployment_token
VERCEL_PROJECT_ID=your_project_id  
VERCEL_TEAM_ID=your_team_id_if_applicable

# Set production secrets
vercel env add STRIPE_SECRET_KEY production
vercel env add SUPABASE_URL production  
vercel env add ANTHROPIC_API_KEY production
```

**Deployment Script:**
```javascript
// ~/.openclaw/workspace/scripts/deploy-to-vercel.js
const { exec } = require('child_process');
const fs = require('fs');

class VercelDeployer {
    constructor(projectPath) {
        this.projectPath = projectPath;
    }

    async deploy(production = false) {
        return new Promise((resolve, reject) => {
            const cmd = production ? 'vercel --prod' : 'vercel';
            
            exec(cmd, { cwd: this.projectPath }, (error, stdout, stderr) => {
                if (error) {
                    console.error('❌ Deployment failed:', error);
                    reject(error);
                } else {
                    const url = stdout.trim().split('\n').pop();
                    console.log('✅ Deployed successfully:', url);
                    resolve(url);
                }
            });
        });
    }

    async getDeployments() {
        return new Promise((resolve, reject) => {
            exec('vercel list', { cwd: this.projectPath }, (error, stdout) => {
                if (error) reject(error);
                else resolve(stdout);
            });
        });
    }
}

module.exports = VercelDeployer;
```

### 4. Stripe - Payment Processing

**Why you need it:** Accept payments, manage subscriptions, and handle billing for your digital products.

**Account Setup:**
1. Sign up at [stripe.com](https://stripe.com)
2. Complete business verification
3. Set up your first product

**API Keys:**
```bash
# Dashboard → Developers → API Keys
STRIPE_PUBLISHABLE_KEY=pk_test_...  # For frontend
STRIPE_SECRET_KEY=sk_test_...       # For backend (keep secret!)

# Webhooks
STRIPE_WEBHOOK_SECRET=whsec_...     # For webhook verification
```

**Test Your Integration:**
```javascript
// ~/.openclaw/workspace/scripts/test-stripe.js
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

async function testStripe() {
    try {
        // Test API connection
        const balance = await stripe.balance.retrieve();
        console.log('✅ Stripe connected. Available balance:', balance.available);

        // Create a test product
        const product = await stripe.products.create({
            name: 'Test Product',
            description: 'API integration test'
        });

        // Create a price for the product  
        const price = await stripe.prices.create({
            product: product.id,
            unit_amount: 2997, // $29.97
            currency: 'usd'
        });

        console.log('✅ Test product created:', product.id);
        console.log('✅ Test price created:', price.id);

        // Clean up test data
        await stripe.products.update(product.id, { active: false });
        
        return true;
    } catch (error) {
        console.error('❌ Stripe test failed:', error.message);
        return false;
    }
}

testStripe();
```

### 5. Resend - Transactional Email

**Why you need it:** Reliable email delivery with high deliverability rates for customer communications.

**Account Setup:**
1. Sign up at [resend.com](https://resend.com)
2. Verify your email address
3. Add and verify your domain

**Domain Verification Process:**
```bash
# DNS records to add in Cloudflare:

# SPF Record (TXT)
Name: @
Value: "v=spf1 include:_spf.resend.com ~all"

# DKIM Record (TXT) - Resend will provide exact values
Name: resend._domainkey
Value: "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQ..." # Provided by Resend

# DMARC Record (TXT)
Name: _dmarc  
Value: "v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com"

# MX Record (for receiving emails)
Name: @
Value: mx.resend.com
Priority: 10
```

**API Setup:**
```bash
# Add to .env
RESEND_API_KEY=re_...
RESEND_FROM_EMAIL=noreply@yourdomain.com
RESEND_FROM_NAME=Your Business Name
```

**Test Email Delivery:**
```javascript
// ~/.openclaw/workspace/scripts/test-resend.js
const { Resend } = require('resend');

class EmailManager {
    constructor() {
        this.resend = new Resend(process.env.RESEND_API_KEY);
        this.fromEmail = process.env.RESEND_FROM_EMAIL;
        this.fromName = process.env.RESEND_FROM_NAME;
    }

    async sendTestEmail(to) {
        try {
            const result = await this.resend.emails.send({
                from: `${this.fromName} <${this.fromEmail}>`,
                to: [to],
                subject: 'API Integration Test',
                html: `
                    <h1>Email Integration Working!</h1>
                    <p>Your Resend API is properly configured and working.</p>
                    <p>Sent at: ${new Date().toISOString()}</p>
                `
            });

            console.log('✅ Test email sent:', result.data.id);
            return result.data;
        } catch (error) {
            console.error('❌ Email send failed:', error);
            throw error;
        }
    }

    async getEmailStatus(emailId) {
        try {
            const email = await this.resend.emails.get(emailId);
            console.log(`📧 Email ${emailId} status:`, email.data.last_event);
            return email.data;
        } catch (error) {
            console.error('❌ Failed to get email status:', error);
            throw error;
        }
    }
}

// Test usage
async function testEmail() {
    const emailManager = new EmailManager();
    const result = await emailManager.sendTestEmail('your-test-email@gmail.com');
    
    // Check status after 30 seconds
    setTimeout(() => {
        emailManager.getEmailStatus(result.id);
    }, 30000);
}

module.exports = EmailManager;
```

### 6. OpenRouter - AI Model Aggregation

**Why you need it:** Access to 100+ AI models through one API, competitive pricing, and automatic fallbacks.

**Setup:**
1. Sign up at [openrouter.ai](https://openrouter.ai)
2. Add credit to your account
3. Generate API key

```bash
# Add to .env
OPENROUTER_API_KEY=sk-or-...
OPENROUTER_APP_NAME=YourApp
OPENROUTER_SITE_URL=https://yoursite.com
```

**Model Testing:**
```javascript
// ~/.openclaw/workspace/scripts/test-openrouter.js
const axios = require('axios');

class OpenRouterClient {
    constructor() {
        this.apiKey = process.env.OPENROUTER_API_KEY;
        this.baseUrl = 'https://openrouter.ai/api/v1';
        this.headers = {
            'Authorization': `Bearer ${this.apiKey}`,
            'HTTP-Referer': process.env.OPENROUTER_SITE_URL,
            'X-Title': process.env.OPENROUTER_APP_NAME,
            'Content-Type': 'application/json'
        };
    }

    async getModels() {
        const response = await axios.get(`${this.baseUrl}/models`, { headers: this.headers });
        return response.data.data;
    }

    async testModel(modelId = 'meta-llama/llama-3.1-8b-instruct:free') {
        try {
            const response = await axios.post(`${this.baseUrl}/chat/completions`, {
                model: modelId,
                messages: [
                    { role: 'user', content: 'Test message: respond with "API working!"' }
                ],
                max_tokens: 50
            }, { headers: this.headers });

            console.log(`✅ ${modelId} response:`, response.data.choices[0].message.content);
            return response.data;
        } catch (error) {
            console.error(`❌ ${modelId} failed:`, error.response?.data || error.message);
            throw error;
        }
    }

    async getBestPriceModel(task = 'general') {
        const models = await this.getModels();
        
        // Sort by price (input + output cost)
        const sortedModels = models
            .filter(m => m.pricing && m.pricing.prompt)
            .sort((a, b) => {
                const aCost = parseFloat(a.pricing.prompt) + parseFloat(a.pricing.completion);
                const bCost = parseFloat(b.pricing.prompt) + parseFloat(b.pricing.completion);
                return aCost - bCost;
            });

        console.log('💰 Cheapest models:');
        sortedModels.slice(0, 5).forEach(model => {
            const cost = parseFloat(model.pricing.prompt) + parseFloat(model.pricing.completion);
            console.log(`  ${model.id}: $${cost.toFixed(6)}/1M tokens`);
        });

        return sortedModels[0];
    }
}

// Test usage
async function testOpenRouter() {
    const client = new OpenRouterClient();
    
    // Test free model
    await client.testModel();
    
    // Find cheapest options
    await client.getBestPriceModel();
}

module.exports = OpenRouterClient;
```

## API Health Check System

Create a comprehensive monitoring system for all your APIs:

```javascript
// ~/.openclaw/workspace/scripts/api-health-monitor.js
const axios = require('axios');
const fs = require('fs');

class APIHealthMonitor {
    constructor() {
        this.services = {
            openai: {
                url: 'https://api.openai.com/v1/models',
                headers: { 'Authorization': `Bearer ${process.env.OPENAI_API_KEY}` },
                timeout: 10000
            },
            anthropic: {
                url: 'https://api.anthropic.com/v1/messages',
                headers: { 
                    'x-api-key': process.env.ANTHROPIC_API_KEY,
                    'anthropic-version': '2023-06-01'
                },
                method: 'POST',
                data: {
                    model: 'claude-3-haiku-20240307',
                    max_tokens: 10,
                    messages: [{ role: 'user', content: 'hi' }]
                },
                timeout: 15000
            },
            stripe: {
                url: 'https://api.stripe.com/v1/balance',
                headers: { 'Authorization': `Bearer ${process.env.STRIPE_SECRET_KEY}` },
                timeout: 5000
            },
            resend: {
                url: 'https://api.resend.com/domains',
                headers: { 'Authorization': `Bearer ${process.env.RESEND_API_KEY}` },
                timeout: 5000
            },
            supabase: {
                url: `${process.env.SUPABASE_URL}/rest/v1/`,
                headers: { 
                    'apikey': process.env.SUPABASE_ANON_KEY,
                    'Authorization': `Bearer ${process.env.SUPABASE_ANON_KEY}`
                },
                timeout: 5000
            },
            alpaca: {
                url: 'https://paper-api.alpaca.markets/v2/account',
                headers: {
                    'APCA-API-KEY-ID': process.env.ALPACA_API_KEY,
                    'APCA-API-SECRET-KEY': process.env.ALPACA_SECRET_KEY
                },
                timeout: 10000
            }
        };

        this.results = {};
        this.historyFile = `${process.env.HOME}/.openclaw/api-health-history.json`;
    }

    async checkService(name, config) {
        const startTime = Date.now();
        
        try {
            const response = await axios({
                method: config.method || 'GET',
                url: config.url,
                headers: config.headers,
                data: config.data,
                timeout: config.timeout
            });

            const responseTime = Date.now() - startTime;
            
            return {
                service: name,
                status: 'healthy',
                responseTime,
                statusCode: response.status,
                timestamp: new Date().toISOString()
            };
        } catch (error) {
            const responseTime = Date.now() - startTime;
            
            return {
                service: name,
                status: 'unhealthy',
                responseTime,
                error: error.message,
                statusCode: error.response?.status || 0,
                timestamp: new Date().toISOString()
            };
        }
    }

    async checkAllServices() {
        console.log('🔍 Checking API health...\n');
        
        const promises = Object.entries(this.services).map(([name, config]) =>
            this.checkService(name, config)
        );

        const results = await Promise.all(promises);
        
        // Display results
        results.forEach(result => {
            const statusIcon = result.status === 'healthy' ? '✅' : '❌';
            const responseTime = `${result.responseTime}ms`;
            
            console.log(`${statusIcon} ${result.service.padEnd(12)} ${responseTime.padStart(8)} ${result.statusCode}`);
            
            if (result.error) {
                console.log(`   Error: ${result.error}`);
            }
        });

        // Save to history
        this.saveToHistory(results);
        
        return results;
    }

    saveToHistory(results) {
        let history = [];
        
        if (fs.existsSync(this.historyFile)) {
            const data = fs.readFileSync(this.historyFile, 'utf8');
            history = JSON.parse(data);
        }

        history.push({
            timestamp: new Date().toISOString(),
            results
        });

        // Keep only last 100 entries
        if (history.length > 100) {
            history = history.slice(-100);
        }

        fs.writeFileSync(this.historyFile, JSON.stringify(history, null, 2));
    }

    async getServiceStats(serviceName, hours = 24) {
        if (!fs.existsSync(this.historyFile)) return null;

        const data = JSON.parse(fs.readFileSync(this.historyFile, 'utf8'));
        const cutoff = new Date(Date.now() - hours * 60 * 60 * 1000);

        const relevantEntries = data
            .filter(entry => new Date(entry.timestamp) > cutoff)
            .flatMap(entry => entry.results)
            .filter(result => result.service === serviceName);

        if (relevantEntries.length === 0) return null;

        const healthy = relevantEntries.filter(r => r.status === 'healthy').length;
        const total = relevantEntries.length;
        const uptime = (healthy / total * 100).toFixed(2);

        const responseTimes = relevantEntries
            .filter(r => r.status === 'healthy')
            .map(r => r.responseTime);

        const avgResponseTime = responseTimes.length > 0 
            ? Math.round(responseTimes.reduce((a, b) => a + b, 0) / responseTimes.length)
            : 0;

        return {
            service: serviceName,
            uptime: `${uptime}%`,
            avgResponseTime: `${avgResponseTime}ms`,
            totalChecks: total,
            healthyChecks: healthy
        };
    }
}

// CLI usage
if (require.main === module) {
    const monitor = new APIHealthMonitor();
    
    const command = process.argv[2];
    
    if (command === 'check') {
        monitor.checkAllServices();
    } else if (command === 'stats') {
        const service = process.argv[3];
        const hours = parseInt(process.argv[4]) || 24;
        
        if (service) {
            monitor.getServiceStats(service, hours).then(stats => {
                console.log(JSON.stringify(stats, null, 2));
            });
        } else {
            console.log('Usage: node api-health-monitor.js stats <service> [hours]');
        }
    } else {
        console.log('Usage: node api-health-monitor.js [check|stats]');
    }
}

module.exports = APIHealthMonitor;
```

## Rate Limiting and Retry Strategies

```javascript
// ~/.openclaw/workspace/scripts/api-rate-limiter.js
class APIRateLimiter {
    constructor() {
        this.limits = {
            openai: { rpm: 500, tpm: 30000 },
            anthropic: { rpm: 50, tpm: 40000 },
            stripe: { rpm: 100 },
            resend: { rpm: 10 }, // Free tier
            alpaca: { rpm: 200 }
        };
        
        this.usage = {};
        this.resetInterval = 60000; // Reset every minute
        
        // Reset counters every minute
        setInterval(() => this.resetCounters(), this.resetInterval);
    }

    resetCounters() {
        this.usage = {};
    }

    async checkLimit(service, tokens = 0) {
        const now = Date.now();
        const minute = Math.floor(now / this.resetInterval);
        
        if (!this.usage[service]) {
            this.usage[service] = { minute, requests: 0, tokens: 0 };
        }

        const usage = this.usage[service];
        
        // Reset if new minute
        if (usage.minute < minute) {
            usage.minute = minute;
            usage.requests = 0;
            usage.tokens = 0;
        }

        const limits = this.limits[service];
        
        // Check RPM limit
        if (usage.requests >= limits.rpm) {
            const waitTime = this.resetInterval - (now % this.resetInterval);
            throw new Error(`Rate limit exceeded for ${service}. Wait ${Math.ceil(waitTime/1000)}s`);
        }

        // Check TPM limit (if applicable)
        if (limits.tpm && usage.tokens + tokens > limits.tpm) {
            const waitTime = this.resetInterval - (now % this.resetInterval);
            throw new Error(`Token limit exceeded for ${service}. Wait ${Math.ceil(waitTime/1000)}s`);
        }

        // Update usage
        usage.requests++;
        usage.tokens += tokens;
    }

    async withRetry(fn, maxRetries = 3, baseDelay = 1000) {
        for (let attempt = 1; attempt <= maxRetries; attempt++) {
            try {
                return await fn();
            } catch (error) {
                if (attempt === maxRetries) throw error;

                // Exponential backoff with jitter
                const delay = baseDelay * Math.pow(2, attempt - 1) + Math.random() * 1000;
                
                console.log(`Attempt ${attempt} failed, retrying in ${Math.round(delay)}ms...`);
                await new Promise(resolve => setTimeout(resolve, delay));
            }
        }
    }
}

// Usage example
const rateLimiter = new APIRateLimiter();

async function safeAPICall(service, apiFunction, tokens = 0) {
    await rateLimiter.checkLimit(service, tokens);
    
    return rateLimiter.withRetry(async () => {
        return await apiFunction();
    });
}

module.exports = { APIRateLimiter, safeAPICall };
```

## API Key Security and Rotation

```bash
#!/bin/bash
# ~/.openclaw/workspace/scripts/rotate-api-keys.sh

echo "🔐 API Key Rotation Script"
echo "=========================="

# Backup current .env
cp ~/.openclaw/workspace/.env ~/.openclaw/workspace/.env.backup-$(date +%Y%m%d)

# Function to generate new API key placeholder
generate_placeholder() {
    echo "NEW_KEY_NEEDED_$(date +%s)"
}

# Check key expiration (if service provides it)
check_openai_key() {
    local key=$1
    curl -s -H "Authorization: Bearer $key" \
         "https://api.openai.com/v1/usage" \
    | jq -r '.error.message // "Valid"'
}

check_stripe_key() {
    local key=$1  
    curl -s -u "$key:" \
         "https://api.stripe.com/v1/balance" \
    | jq -r '.error.message // "Valid"'
}

# Rotation checklist
echo "📋 Manual rotation steps:"
echo "1. OpenAI: dashboard.openai.com → API Keys → Create new key"
echo "2. Anthropic: console.anthropic.com → API Keys → Create key"  
echo "3. Stripe: dashboard.stripe.com → Developers → API keys"
echo "4. Resend: resend.com → API Keys → Create API Key"
echo "5. Alpaca: alpaca.markets → API Keys → Generate new key"

# Test current keys
echo ""
echo "🧪 Testing current keys:"
node -e "require('./api-health-monitor.js'); new (require('./api-health-monitor.js'))().checkAllServices();"

# Remind about environment updates
echo ""
echo "⚠️  Remember to update:"
echo "- Vercel environment variables"
echo "- Docker containers"
echo "- CI/CD secrets"
echo "- Team member .env files"
```

## Pro Tips

**🔐 Security First:** Never commit API keys to git. Use environment variables and separate .env files for dev/staging/prod.

**🔄 Health Check Everything:** Set up monitoring before you need it. When revenue is flowing, downtime costs thousands per hour.

**📊 Rate Limit Proactively:** Don't wait to hit limits. Implement rate limiting that prevents errors instead of handling them.

**💰 Cost Monitoring:** Track API costs daily. A misconfigured loop can burn through thousands of dollars overnight.

**🔧 Graceful Degradation:** Build fallbacks. If Stripe is down, save the lead and process payment later.

## Troubleshooting

### Issue 1: Intermittent API Failures
**Symptoms:** APIs work sometimes, fail other times
**Diagnosis:** Rate limiting or network issues
**Fix:**
```javascript
// Add comprehensive error handling
async function robustAPICall(apiFunction) {
    const maxRetries = 3;
    const retryDelay = [1000, 2000, 4000]; // Exponential backoff
    
    for (let i = 0; i < maxRetries; i++) {
        try {
            return await apiFunction();
        } catch (error) {
            if (i === maxRetries - 1) throw error;
            
            console.log(`API call failed, retrying in ${retryDelay[i]}ms...`);
            await new Promise(resolve => setTimeout(resolve, retryDelay[i]));
        }
    }
}
```

### Issue 2: High API Costs
**Symptoms:** Unexpected large bills from API providers
**Diagnosis:** Inefficient usage or lack of rate limiting
**Fix:**
```javascript
// Implement cost tracking
class CostTracker {
    constructor() {
        this.costs = {
            openai: { input: 0.0015, output: 0.002 }, // per 1K tokens
            anthropic: { input: 0.0003, output: 0.0015 }
        };
    }
    
    estimateCost(service, inputTokens, outputTokens) {
        const rates = this.costs[service];
        return (inputTokens * rates.input + outputTokens * rates.output) / 1000;
    }
}
```

### Issue 3: Authentication Errors
**Symptoms:** 401/403 errors from API calls
**Diagnosis:** Invalid or expired API keys
**Fix:**
```bash
# Test each API key individually
node -e "console.log('Testing OpenAI...'); require('openai')('$OPENAI_API_KEY').models.list().then(r => console.log('✅ OpenAI OK')).catch(e => console.log('❌', e.message))"
```

### Issue 4: Webhook Delivery Failures  
**Symptoms:** Missing webhook events, duplicate processing
**Diagnosis:** Endpoint unreachable or not idempotent
**Fix:**
```javascript
// Webhook handler with idempotency
const processedEvents = new Set();

app.post('/webhook', (req, res) => {
    const eventId = req.body.id;
    
    if (processedEvents.has(eventId)) {
        return res.status(200).json({ received: true });
    }
    
    // Process event
    processEvent(req.body);
    processedEvents.add(eventId);
    
    res.status(200).json({ received: true });
});
```

### Issue 5: Environment Variable Confusion
**Symptoms:** Variables work locally but fail in production
**Diagnosis:** Different environment configurations
**Fix:**
```javascript
// Environment validator
function validateEnvironment() {
    const required = [
        'OPENAI_API_KEY',
        'ANTHROPIC_API_KEY', 
        'STRIPE_SECRET_KEY',
        'SUPABASE_URL',
        'RESEND_API_KEY'
    ];
    
    const missing = required.filter(key => !process.env[key]);
    
    if (missing.length > 0) {
        throw new Error(`Missing environment variables: ${missing.join(', ')}`);
    }
    
    console.log('✅ All required environment variables present');
}
```

Your API infrastructure is the nervous system of your automated business. Build it right once, and it'll scale with you from your first customer to your first million in revenue. Skimp on this foundation, and you'll spend months firefighting outages instead of growing your business.

The businesses that win with automation have bulletproof API infrastructure. This chapter gave you the blueprint. Now build it.