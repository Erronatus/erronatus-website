# Chapter 14: Email Automation
## Build Professional Email Systems That Actually Deliver

*Email marketing tools are expensive and generic. Transactional email services are powerful but developer-focused. This chapter bridges that gap — showing you how to build sophisticated email automation systems using Resend that rival $500/month enterprise platforms. We're not talking about newsletters. We're talking about email systems that drive revenue, nurture leads, and run your business automatically.*

### Why This Matters

Email is still the highest-ROI marketing channel, but most businesses either:
1. Overpay for cookie-cutter solutions that don't fit their needs
2. Under-invest and lose customers to poor email experiences
3. Get blocked by spam filters because they don't understand deliverability

When you build your own email automation system:
- You own the customer data and relationships
- You can create unique workflows competitors can't copy
- You pay for what you use, not arbitrary user limits
- You control deliverability and reputation

The businesses making serious money online have sophisticated email systems. This chapter shows you how to build yours.

## Resend Deep Dive: Architecture and Philosophy

### Why Resend Over Competitors

**Resend vs SendGrid:**
- Resend: Developer-first, modern API, better deliverability
- SendGrid: Legacy codebase, complex pricing, reputation issues

**Resend vs Mailgun:**
- Resend: Simpler setup, better documentation, EU compliance built-in
- Mailgun: More complex, harder to debug, pricing surprises

**Resend vs Amazon SES:**
- Resend: No AWS complexity, built-in DKIM/SPF, better support
- SES: Requires AWS knowledge, complex setup, bare-bones features

### Resend Architecture

```
Your Application
      ↓
 Resend API (https://api.resend.com)
      ↓
Email Service Providers (Gmail, Outlook, etc.)
      ↓
Your Recipients
```

Resend handles:
- SMTP routing and optimization
- Bounce and complaint handling
- Reputation management
- Deliverability monitoring
- EU GDPR compliance

You handle:
- Content creation
- Subscriber management
- Automation logic
- Analytics and reporting

## Complete Domain Verification Walkthrough

### Step 1: Add Your Domain to Resend

```bash
curl -X POST https://api.resend.com/domains \
  -H "Authorization: Bearer $RESEND_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "yourdomain.com",
    "region": "us-east-1"
  }'
```

Response:
```json
{
  "id": "d91cd9bd-1176-453e-8fc1-35364d380206",
  "name": "yourdomain.com",
  "status": "not_started",
  "created_at": "2024-01-15T09:51:30.632Z",
  "region": "us-east-1"
}
```

### Step 2: Get DNS Records

```bash
curl https://api.resend.com/domains/d91cd9bd-1176-453e-8fc1-35364d380206 \
  -H "Authorization: Bearer $RESEND_API_KEY"
```

### Step 3: Configure DNS in Cloudflare

Add these exact records to your Cloudflare DNS:

```javascript
// ~/.openclaw/workspace/scripts/setup-email-dns.js
const axios = require('axios');

class CloudflareEmailSetup {
    constructor() {
        this.apiToken = process.env.CLOUDFLARE_API_TOKEN;
        this.zoneId = process.env.CLOUDFLARE_ZONE_ID;
        this.baseUrl = 'https://api.cloudflare.com/client/v4';
        this.headers = {
            'Authorization': `Bearer ${this.apiToken}`,
            'Content-Type': 'application/json'
        };
    }

    async setupEmailDNS(domain, resendRecords) {
        console.log(`🔧 Setting up email DNS for ${domain}...`);
        
        // SPF Record
        await this.createDNSRecord({
            type: 'TXT',
            name: '@',
            content: 'v=spf1 include:_spf.resend.com ~all',
            comment: 'SPF record for Resend email authentication'
        });

        // DKIM Record (from Resend dashboard)
        await this.createDNSRecord({
            type: 'TXT',  
            name: 'resend._domainkey',
            content: resendRecords.dkim, // Get this from Resend API response
            comment: 'DKIM signature for Resend'
        });

        // DMARC Record
        await this.createDNSRecord({
            type: 'TXT',
            name: '_dmarc',
            content: 'v=DMARC1; p=quarantine; rua=mailto:dmarc-reports@yourdomain.com; ruf=mailto:dmarc-failures@yourdomain.com; sp=quarantine; adkim=r; aspf=r;',
            comment: 'DMARC policy for email authentication'
        });

        // MX Record for receiving emails (optional)
        await this.createDNSRecord({
            type: 'MX',
            name: '@',
            content: 'mx.resend.com',
            priority: 10,
            comment: 'MX record for Resend email receiving'
        });

        // Custom subdomain for sending (recommended)
        await this.createDNSRecord({
            type: 'TXT',
            name: 'mail',
            content: 'v=spf1 include:_spf.resend.com ~all',
            comment: 'SPF for mail subdomain'
        });

        console.log('✅ Email DNS setup complete');
        console.log('⏳ DNS propagation may take up to 24 hours');
    }

    async createDNSRecord(record) {
        try {
            const response = await axios.post(
                `${this.baseUrl}/zones/${this.zoneId}/dns_records`,
                record,
                { headers: this.headers }
            );

            if (response.data.success) {
                console.log(`✅ Created ${record.type} record: ${record.name}`);
                return response.data.result;
            } else {
                console.error(`❌ Failed to create ${record.type} record:`, response.data.errors);
                throw new Error('DNS record creation failed');
            }
        } catch (error) {
            console.error(`❌ DNS API error:`, error.response?.data || error.message);
            throw error;
        }
    }

    async verifyDNSRecords(domain) {
        console.log(`🔍 Verifying DNS records for ${domain}...`);
        
        const checks = [
            { name: 'SPF', type: 'TXT', record: '@' },
            { name: 'DKIM', type: 'TXT', record: 'resend._domainkey' },
            { name: 'DMARC', type: 'TXT', record: '_dmarc' }
        ];

        const results = {};

        for (const check of checks) {
            try {
                const response = await axios.get(
                    `${this.baseUrl}/zones/${this.zoneId}/dns_records`,
                    {
                        headers: this.headers,
                        params: {
                            type: check.type,
                            name: check.record === '@' ? domain : `${check.record}.${domain}`
                        }
                    }
                );

                results[check.name] = {
                    exists: response.data.result.length > 0,
                    content: response.data.result[0]?.content || null
                };

                console.log(`${results[check.name].exists ? '✅' : '❌'} ${check.name}: ${results[check.name].exists ? 'Found' : 'Missing'}`);
            } catch (error) {
                results[check.name] = { exists: false, error: error.message };
                console.log(`❌ ${check.name}: Error checking record`);
            }
        }

        return results;
    }
}

// Usage
if (require.main === module) {
    const setup = new CloudflareEmailSetup();
    
    // Example Resend DKIM record (get actual value from Resend API)
    const resendRecords = {
        dkim: 'p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4P4bVlbl8Z4LZjR4zJbZoR...'
    };
    
    setup.setupEmailDNS('yourdomain.com', resendRecords);
}

module.exports = CloudflareEmailSetup;
```

### Step 4: Verify Domain in Resend

```bash
curl -X POST https://api.resend.com/domains/d91cd9bd-1176-453e-8fc1-35364d380206/verify \
  -H "Authorization: Bearer $RESEND_API_KEY"
```

## Understanding Email Authentication

### SPF (Sender Policy Framework)
**What it does:** Specifies which mail servers can send email for your domain
**Example:** `v=spf1 include:_spf.resend.com ~all`

Breakdown:
- `v=spf1` - SPF version 1
- `include:_spf.resend.com` - Include Resend's SPF record
- `~all` - Soft fail for other servers (recommended for testing)
- `−all` - Hard fail for other servers (use in production)

### DKIM (DomainKeys Identified Mail)
**What it does:** Cryptographically signs your emails to prove authenticity
**How it works:** 
1. Resend signs your emails with a private key
2. Your DNS publishes the matching public key
3. Recipients verify the signature matches

### DMARC (Domain-based Message Authentication)
**What it does:** Tells recipients what to do with emails that fail SPF/DKIM
**Policy options:**
- `p=none` - Monitor only (for testing)
- `p=quarantine` - Send suspicious emails to spam folder  
- `p=reject` - Block suspicious emails entirely

### Complete DNS Setup Script

```javascript
// ~/.openclaw/workspace/scripts/complete-email-setup.js
const axios = require('axios');
const dns = require('dns').promises;

class EmailSetup {
    constructor() {
        this.resendApiKey = process.env.RESEND_API_KEY;
        this.cloudflareToken = process.env.CLOUDFLARE_API_TOKEN;
        this.zoneId = process.env.CLOUDFLARE_ZONE_ID;
    }

    async setupEmailInfrastructure(domain) {
        try {
            console.log(`🚀 Starting email infrastructure setup for ${domain}`);
            
            // Step 1: Add domain to Resend
            const domainResult = await this.addDomainToResend(domain);
            console.log(`✅ Domain added to Resend: ${domainResult.id}`);
            
            // Step 2: Get required DNS records
            const dnsRecords = await this.getResendDNSRecords(domainResult.id);
            
            // Step 3: Create DNS records in Cloudflare
            await this.createCloudflareRecords(domain, dnsRecords);
            
            // Step 4: Wait for DNS propagation
            console.log('⏳ Waiting for DNS propagation...');
            await this.waitForDNSPropagation(domain);
            
            // Step 5: Verify domain in Resend
            await this.verifyResendDomain(domainResult.id);
            
            // Step 6: Send test email
            await this.sendTestEmail(domain);
            
            console.log('🎉 Email infrastructure setup complete!');
            
        } catch (error) {
            console.error('❌ Setup failed:', error.message);
            throw error;
        }
    }

    async addDomainToResend(domain) {
        const response = await axios.post('https://api.resend.com/domains', {
            name: domain,
            region: 'us-east-1'
        }, {
            headers: {
                'Authorization': `Bearer ${this.resendApiKey}`,
                'Content-Type': 'application/json'
            }
        });
        
        return response.data;
    }

    async getResendDNSRecords(domainId) {
        const response = await axios.get(`https://api.resend.com/domains/${domainId}`, {
            headers: {
                'Authorization': `Bearer ${this.resendApiKey}`
            }
        });
        
        return response.data.records;
    }

    async createCloudflareRecords(domain, records) {
        const cloudflareAPI = `https://api.cloudflare.com/client/v4/zones/${this.zoneId}/dns_records`;
        const headers = {
            'Authorization': `Bearer ${this.cloudflareToken}`,
            'Content-Type': 'application/json'
        };

        // Create all required records
        const recordsToCreate = [
            // SPF Record
            {
                type: 'TXT',
                name: domain,
                content: 'v=spf1 include:_spf.resend.com ~all'
            },
            // DKIM Record  
            {
                type: 'TXT',
                name: `resend._domainkey.${domain}`,
                content: records.find(r => r.record === 'DKIM')?.value
            },
            // DMARC Record
            {
                type: 'TXT', 
                name: `_dmarc.${domain}`,
                content: `v=DMARC1; p=quarantine; rua=mailto:dmarc@${domain}`
            },
            // Return-Path Record
            {
                type: 'CNAME',
                name: `resend.${domain}`,
                content: 'sendingdomains.resend.com'
            }
        ];

        for (const record of recordsToCreate) {
            if (record.content) {
                try {
                    await axios.post(cloudflareAPI, record, { headers });
                    console.log(`✅ Created ${record.type} record for ${record.name}`);
                } catch (error) {
                    console.error(`❌ Failed to create ${record.type} record:`, error.response?.data);
                }
            }
        }
    }

    async waitForDNSPropagation(domain, maxWait = 300000) {
        console.log('🔍 Checking DNS propagation...');
        const startTime = Date.now();
        
        while (Date.now() - startTime < maxWait) {
            try {
                const spfRecords = await dns.resolveTxt(domain);
                const hasSPF = spfRecords.some(record => 
                    record[0].includes('v=spf1') && record[0].includes('resend.com')
                );
                
                if (hasSPF) {
                    console.log('✅ SPF record propagated');
                    return true;
                }
                
                console.log('⏳ Still waiting for DNS propagation...');
                await new Promise(resolve => setTimeout(resolve, 30000));
                
            } catch (error) {
                console.log('⏳ DNS not ready yet, continuing to wait...');
                await new Promise(resolve => setTimeout(resolve, 30000));
            }
        }
        
        throw new Error('DNS propagation timeout');
    }

    async verifyResendDomain(domainId) {
        try {
            const response = await axios.post(`https://api.resend.com/domains/${domainId}/verify`, {}, {
                headers: {
                    'Authorization': `Bearer ${this.resendApiKey}`
                }
            });
            
            console.log('✅ Domain verified in Resend');
            return response.data;
        } catch (error) {
            console.error('❌ Domain verification failed:', error.response?.data);
            throw error;
        }
    }

    async sendTestEmail(domain) {
        try {
            const response = await axios.post('https://api.resend.com/emails', {
                from: `test@${domain}`,
                to: [process.env.TEST_EMAIL],
                subject: 'Email Infrastructure Test',
                html: `
                    <h1>🎉 Email Setup Successful!</h1>
                    <p>Your email infrastructure for <strong>${domain}</strong> is working correctly.</p>
                    <p>This test email was sent at ${new Date().toISOString()}.</p>
                    <hr>
                    <p style="color: #666; font-size: 12px;">
                        Powered by Resend • Configured with OpenClaw
                    </p>
                `
            }, {
                headers: {
                    'Authorization': `Bearer ${this.resendApiKey}`,
                    'Content-Type': 'application/json'
                }
            });
            
            console.log(`✅ Test email sent: ${response.data.id}`);
            return response.data;
        } catch (error) {
            console.error('❌ Test email failed:', error.response?.data);
            throw error;
        }
    }
}

// CLI usage
if (require.main === module) {
    const domain = process.argv[2];
    if (!domain) {
        console.error('Usage: node complete-email-setup.js yourdomain.com');
        process.exit(1);
    }
    
    const setup = new EmailSetup();
    setup.setupEmailInfrastructure(domain);
}

module.exports = EmailSetup;
```

## Building HTML Email Templates

### Responsive Base Template

```html
<!-- ~/.openclaw/workspace/templates/email-base.html -->
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>{{EMAIL_TITLE}}</title>
    <!--[if mso]>
    <noscript>
        <xml>
            <o:OfficeDocumentSettings>
                <o:PixelsPerInch>96</o:PixelsPerInch>
            </o:OfficeDocumentSettings>
        </xml>
    </noscript>
    <![endif]-->
    <style>
        /* Reset styles */
        body, table, td, a { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
        table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
        img { -ms-interpolation-mode: bicubic; }
        
        /* Remove blue links for iOS */
        a[x-apple-data-detectors] {
            color: inherit !important;
            text-decoration: none !important;
            font-size: inherit !important;
            font-family: inherit !important;
            font-weight: inherit !important;
            line-height: inherit !important;
        }
        
        /* Base styles */
        body {
            margin: 0;
            padding: 0;
            width: 100% !important;
            height: 100% !important;
            background-color: #f4f4f7;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
        }
        
        /* Dark mode support */
        @media (prefers-color-scheme: dark) {
            .email-body {
                background-color: #1a1a1a !important;
                color: #ffffff !important;
            }
            .email-container {
                background-color: #2d2d2d !important;
                color: #ffffff !important;
            }
            .header {
                background-color: #333333 !important;
            }
            .footer {
                background-color: #1a1a1a !important;
                color: #cccccc !important;
            }
        }
        
        /* Container */
        .email-container {
            max-width: 600px;
            margin: 0 auto;
            background-color: #ffffff;
        }
        
        /* Header */
        .header {
            background-color: #4f46e5;
            padding: 20px;
            text-align: center;
        }
        
        .header h1 {
            color: #ffffff;
            margin: 0;
            font-size: 24px;
            font-weight: 600;
        }
        
        /* Content */
        .content {
            padding: 40px 30px;
        }
        
        .content h2 {
            color: #1f2937;
            font-size: 20px;
            font-weight: 600;
            margin: 0 0 16px 0;
        }
        
        .content p {
            color: #4b5563;
            font-size: 16px;
            line-height: 1.6;
            margin: 0 0 16px 0;
        }
        
        /* Buttons */
        .button {
            display: inline-block;
            padding: 12px 24px;
            background-color: #4f46e5;
            color: #ffffff !important;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
            margin: 16px 0;
        }
        
        .button:hover {
            background-color: #4338ca;
        }
        
        /* Footer */
        .footer {
            background-color: #f9fafb;
            padding: 20px 30px;
            text-align: center;
            border-top: 1px solid #e5e7eb;
        }
        
        .footer p {
            color: #6b7280;
            font-size: 14px;
            margin: 0 0 8px 0;
        }
        
        .footer a {
            color: #4f46e5;
            text-decoration: none;
        }
        
        /* Responsive */
        @media screen and (max-width: 600px) {
            .email-container {
                width: 100% !important;
                max-width: none !important;
            }
            
            .content {
                padding: 30px 20px !important;
            }
            
            .header {
                padding: 20px 15px !important;
            }
            
            .footer {
                padding: 20px 15px !important;
            }
        }
    </style>
</head>
<body>
    <div class="email-body">
        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
            <tr>
                <td>
                    <div class="email-container">
                        <!-- Header -->
                        <div class="header">
                            <h1>{{COMPANY_NAME}}</h1>
                        </div>
                        
                        <!-- Content -->
                        <div class="content">
                            {{EMAIL_CONTENT}}
                        </div>
                        
                        <!-- Footer -->
                        <div class="footer">
                            <p>{{COMPANY_NAME}} • {{COMPANY_ADDRESS}}</p>
                            <p>
                                <a href="{{UNSUBSCRIBE_URL}}">Unsubscribe</a> | 
                                <a href="{{PREFERENCES_URL}}">Preferences</a> |
                                <a href="{{WEBSITE_URL}}">Website</a>
                            </p>
                            <p style="font-size: 12px; color: #9ca3af;">
                                This email was sent to {{RECIPIENT_EMAIL}}<br>
                                {{COMPANY_NAME}}, {{COMPANY_ADDRESS}}
                            </p>
                        </div>
                    </div>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>
```

### Template Processing System

```javascript
// ~/.openclaw/workspace/scripts/email-template-engine.js
const fs = require('fs');
const path = require('path');

class EmailTemplateEngine {
    constructor() {
        this.templatesDir = path.join(__dirname, '../templates');
        this.baseTemplate = this.loadTemplate('email-base.html');
    }

    loadTemplate(templateName) {
        const templatePath = path.join(this.templatesDir, templateName);
        
        if (!fs.existsSync(templatePath)) {
            throw new Error(`Template not found: ${templateName}`);
        }
        
        return fs.readFileSync(templatePath, 'utf8');
    }

    generateWelcomeEmail(userData, companyData) {
        const content = `
            <h2>Welcome to ${companyData.name}! 🎉</h2>
            <p>Hi ${userData.firstName},</p>
            <p>Thank you for joining ${companyData.name}! We're excited to have you as part of our community.</p>
            
            <p>Here's what you can expect:</p>
            <ul style="color: #4b5563; padding-left: 20px;">
                <li>Regular updates about new features and improvements</li>
                <li>Exclusive tips and insights from our team</li>
                <li>Early access to new products and services</li>
            </ul>
            
            <p>To get started, click the button below:</p>
            <a href="${companyData.onboardingUrl}" class="button">Get Started</a>
            
            <p>If you have any questions, just reply to this email. We're here to help!</p>
            
            <p>Best regards,<br>
            The ${companyData.name} Team</p>
        `;

        return this.processTemplate(content, {
            EMAIL_TITLE: `Welcome to ${companyData.name}`,
            COMPANY_NAME: companyData.name,
            EMAIL_CONTENT: content,
            COMPANY_ADDRESS: companyData.address,
            UNSUBSCRIBE_URL: companyData.unsubscribeUrl,
            PREFERENCES_URL: companyData.preferencesUrl,
            WEBSITE_URL: companyData.websiteUrl,
            RECIPIENT_EMAIL: userData.email
        });
    }

    generateReportEmail(reportData, recipientData, companyData) {
        const content = `
            <h2>${reportData.title}</h2>
            <p>Hi ${recipientData.firstName},</p>
            <p>Your ${reportData.period} report is ready. Here are the highlights:</p>
            
            <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
                <tr style="background-color: #f9fafb;">
                    <th style="padding: 12px; text-align: left; border-bottom: 1px solid #e5e7eb;">Metric</th>
                    <th style="padding: 12px; text-align: right; border-bottom: 1px solid #e5e7eb;">Value</th>
                    <th style="padding: 12px; text-align: right; border-bottom: 1px solid #e5e7eb;">Change</th>
                </tr>
                ${reportData.metrics.map(metric => `
                    <tr>
                        <td style="padding: 12px; border-bottom: 1px solid #f3f4f6;">${metric.name}</td>
                        <td style="padding: 12px; text-align: right; border-bottom: 1px solid #f3f4f6; font-weight: 600;">${metric.value}</td>
                        <td style="padding: 12px; text-align: right; border-bottom: 1px solid #f3f4f6; color: ${metric.change >= 0 ? '#10b981' : '#ef4444'};">
                            ${metric.change >= 0 ? '+' : ''}${metric.change}%
                        </td>
                    </tr>
                `).join('')}
            </table>
            
            ${reportData.insights ? `
                <h3 style="color: #1f2937; font-size: 18px; margin: 24px 0 12px 0;">Key Insights</h3>
                <ul style="color: #4b5563; padding-left: 20px;">
                    ${reportData.insights.map(insight => `<li style="margin-bottom: 8px;">${insight}</li>`).join('')}
                </ul>
            ` : ''}
            
            <a href="${reportData.fullReportUrl}" class="button">View Full Report</a>
            
            <p>Questions about your report? Just reply to this email.</p>
            
            <p>Best regards,<br>
            The ${companyData.name} Team</p>
        `;

        return this.processTemplate(content, {
            EMAIL_TITLE: reportData.title,
            COMPANY_NAME: companyData.name,
            EMAIL_CONTENT: content,
            COMPANY_ADDRESS: companyData.address,
            UNSUBSCRIBE_URL: companyData.unsubscribeUrl,
            PREFERENCES_URL: companyData.preferencesUrl,
            WEBSITE_URL: companyData.websiteUrl,
            RECIPIENT_EMAIL: recipientData.email
        });
    }

    generateTransactionEmail(transactionData, customerData, companyData) {
        const content = `
            <h2>Payment Confirmation 💳</h2>
            <p>Hi ${customerData.firstName},</p>
            <p>Thank you for your payment! Here are the details:</p>
            
            <div style="background-color: #f9fafb; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <h3 style="margin-top: 0; color: #1f2937;">Transaction Details</h3>
                <p style="margin: 8px 0;"><strong>Transaction ID:</strong> ${transactionData.id}</p>
                <p style="margin: 8px 0;"><strong>Amount:</strong> $${transactionData.amount}</p>
                <p style="margin: 8px 0;"><strong>Date:</strong> ${new Date(transactionData.date).toLocaleDateString()}</p>
                <p style="margin: 8px 0;"><strong>Payment Method:</strong> ${transactionData.paymentMethod}</p>
            </div>
            
            ${transactionData.items && transactionData.items.length > 0 ? `
                <h3 style="color: #1f2937;">Items Purchased</h3>
                <table style="width: 100%; border-collapse: collapse; margin: 20px 0;">
                    <tr style="background-color: #f9fafb;">
                        <th style="padding: 12px; text-align: left; border-bottom: 1px solid #e5e7eb;">Item</th>
                        <th style="padding: 12px; text-align: center; border-bottom: 1px solid #e5e7eb;">Qty</th>
                        <th style="padding: 12px; text-align: right; border-bottom: 1px solid #e5e7eb;">Price</th>
                    </tr>
                    ${transactionData.items.map(item => `
                        <tr>
                            <td style="padding: 12px; border-bottom: 1px solid #f3f4f6;">${item.name}</td>
                            <td style="padding: 12px; text-align: center; border-bottom: 1px solid #f3f4f6;">${item.quantity}</td>
                            <td style="padding: 12px; text-align: right; border-bottom: 1px solid #f3f4f6;">$${item.price}</td>
                        </tr>
                    `).join('')}
                </table>
            ` : ''}
            
            ${transactionData.downloadUrl ? `
                <a href="${transactionData.downloadUrl}" class="button">Download Your Purchase</a>
            ` : ''}
            
            <p>A receipt has been sent to your email for your records. If you have any questions about your purchase, please don't hesitate to contact us.</p>
            
            <p>Best regards,<br>
            The ${companyData.name} Team</p>
        `;

        return this.processTemplate(content, {
            EMAIL_TITLE: 'Payment Confirmation',
            COMPANY_NAME: companyData.name,
            EMAIL_CONTENT: content,
            COMPANY_ADDRESS: companyData.address,
            UNSUBSCRIBE_URL: companyData.unsubscribeUrl,
            PREFERENCES_URL: companyData.preferencesUrl,
            WEBSITE_URL: companyData.websiteUrl,
            RECIPIENT_EMAIL: customerData.email
        });
    }

    processTemplate(content, variables) {
        let processed = this.baseTemplate;
        
        // Replace all variables
        Object.entries(variables).forEach(([key, value]) => {
            const regex = new RegExp(`{{${key}}}`, 'g');
            processed = processed.replace(regex, value || '');
        });
        
        // Remove any remaining placeholders
        processed = processed.replace(/{{[^}]+}}/g, '');
        
        return processed;
    }

    // Test email rendering
    renderTestEmail() {
        const testData = {
            firstName: 'John',
            email: 'john@example.com'
        };
        
        const companyData = {
            name: 'Your Company',
            address: '123 Business St, City, State 12345',
            onboardingUrl: 'https://yourcompany.com/onboarding',
            unsubscribeUrl: 'https://yourcompany.com/unsubscribe',
            preferencesUrl: 'https://yourcompany.com/preferences',
            websiteUrl: 'https://yourcompany.com'
        };
        
        return this.generateWelcomeEmail(testData, companyData);
    }
}

module.exports = EmailTemplateEngine;
```

## Email Automation Workflows

### 1. Daily Report Delivery

```javascript
// ~/.openclaw/workspace/scripts/daily-report-mailer.js
const { Resend } = require('resend');
const { createClient } = require('@supabase/supabase-js');
const EmailTemplateEngine = require('./email-template-engine');

class DailyReportMailer {
    constructor() {
        this.resend = new Resend(process.env.RESEND_API_KEY);
        this.supabase = createClient(
            process.env.SUPABASE_URL,
            process.env.SUPABASE_ANON_KEY
        );
        this.templateEngine = new EmailTemplateEngine();
    }

    async generateDailyMetrics() {
        const today = new Date();
        const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
        
        try {
            // Get revenue data
            const { data: transactions } = await this.supabase
                .from('transactions')
                .select('*')
                .gte('created_at', yesterday.toISOString())
                .lt('created_at', today.toISOString());

            // Get user signups
            const { data: signups } = await this.supabase
                .from('users')
                .select('*')
                .gte('created_at', yesterday.toISOString())
                .lt('created_at', today.toISOString());

            // Calculate metrics
            const dailyRevenue = transactions.reduce((sum, t) => sum + t.amount, 0);
            const dailySignups = signups.length;
            
            // Get previous day for comparison
            const dayBefore = new Date(yesterday.getTime() - 24 * 60 * 60 * 1000);
            
            const { data: prevTransactions } = await this.supabase
                .from('transactions')
                .select('*')
                .gte('created_at', dayBefore.toISOString())
                .lt('created_at', yesterday.toISOString());

            const { data: prevSignups } = await this.supabase
                .from('users')
                .select('*')
                .gte('created_at', dayBefore.toISOString())
                .lt('created_at', yesterday.toISOString());

            const prevRevenue = prevTransactions.reduce((sum, t) => sum + t.amount, 0);
            const prevSignupsCount = prevSignups.length;
            
            // Calculate changes
            const revenueChange = prevRevenue > 0 ? ((dailyRevenue - prevRevenue) / prevRevenue) * 100 : 0;
            const signupChange = prevSignupsCount > 0 ? ((dailySignups - prevSignupsCount) / prevSignupsCount) * 100 : 0;

            return {
                title: `Daily Report - ${yesterday.toLocaleDateString()}`,
                period: 'Daily',
                metrics: [
                    {
                        name: 'Revenue',
                        value: `$${dailyRevenue.toFixed(2)}`,
                        change: revenueChange.toFixed(1)
                    },
                    {
                        name: 'New Signups',
                        value: dailySignups.toString(),
                        change: signupChange.toFixed(1)
                    },
                    {
                        name: 'Transactions',
                        value: transactions.length.toString(),
                        change: prevTransactions.length > 0 ? 
                            (((transactions.length - prevTransactions.length) / prevTransactions.length) * 100).toFixed(1) : 
                            '0'
                    }
                ],
                insights: this.generateInsights({
                    dailyRevenue,
                    dailySignups,
                    revenueChange,
                    signupChange,
                    transactions: transactions.length
                }),
                fullReportUrl: `${process.env.WEBSITE_URL}/dashboard/reports`
            };
        } catch (error) {
            console.error('Failed to generate daily metrics:', error);
            throw error;
        }
    }

    generateInsights(metrics) {
        const insights = [];
        
        if (metrics.revenueChange > 20) {
            insights.push(`Revenue increased by ${metrics.revenueChange.toFixed(1)}% - great performance!`);
        } else if (metrics.revenueChange < -20) {
            insights.push(`Revenue decreased by ${Math.abs(metrics.revenueChange).toFixed(1)}% - investigate traffic sources`);
        }
        
        if (metrics.signupChange > 50) {
            insights.push(`Signups surge of ${metrics.signupChange.toFixed(1)}% - check what's driving growth`);
        }
        
        if (metrics.dailyRevenue > 1000) {
            insights.push('Daily revenue exceeded $1,000 - strong performance day');
        }
        
        if (metrics.transactions === 0) {
            insights.push('No transactions today - check payment processing and marketing');
        }
        
        return insights;
    }

    async sendDailyReport() {
        try {
            console.log('📊 Generating daily report...');
            
            // Generate report data
            const reportData = await this.generateDailyMetrics();
            
            // Get subscriber list
            const { data: subscribers } = await this.supabase
                .from('email_subscribers')
                .select('*')
                .eq('report_frequency', 'daily')
                .eq('active', true);

            console.log(`📧 Sending to ${subscribers.length} subscribers`);

            const results = [];
            
            // Send to each subscriber
            for (const subscriber of subscribers) {
                try {
                    const html = this.templateEngine.generateReportEmail(
                        reportData,
                        {
                            firstName: subscriber.first_name || 'there',
                            email: subscriber.email
                        },
                        {
                            name: process.env.COMPANY_NAME,
                            address: process.env.COMPANY_ADDRESS,
                            unsubscribeUrl: `${process.env.WEBSITE_URL}/unsubscribe?token=${subscriber.unsubscribe_token}`,
                            preferencesUrl: `${process.env.WEBSITE_URL}/preferences?token=${subscriber.preferences_token}`,
                            websiteUrl: process.env.WEBSITE_URL
                        }
                    );

                    const result = await this.resend.emails.send({
                        from: `${process.env.COMPANY_NAME} <reports@${process.env.DOMAIN}>`,
                        to: subscriber.email,
                        subject: reportData.title,
                        html: html
                    });

                    results.push({
                        email: subscriber.email,
                        success: true,
                        messageId: result.data.id
                    });

                    // Rate limiting
                    await new Promise(resolve => setTimeout(resolve, 200));

                } catch (error) {
                    console.error(`Failed to send to ${subscriber.email}:`, error.message);
                    results.push({
                        email: subscriber.email,
                        success: false,
                        error: error.message
                    });
                }
            }

            // Log results
            const successful = results.filter(r => r.success).length;
            console.log(`✅ Daily report sent to ${successful}/${subscribers.length} subscribers`);
            
            // Save delivery log
            await this.saveDeliveryLog('daily_report', reportData.title, results);
            
            return {
                reportData,
                deliveryResults: results,
                successCount: successful,
                totalSent: subscribers.length
            };

        } catch (error) {
            console.error('Daily report sending failed:', error);
            throw error;
        }
    }

    async saveDeliveryLog(campaignType, subject, results) {
        const { error } = await this.supabase
            .from('email_delivery_logs')
            .insert([{
                campaign_type: campaignType,
                subject: subject,
                recipients: results.length,
                delivered: results.filter(r => r.success).length,
                failed: results.filter(r => !r.success).length,
                sent_at: new Date().toISOString(),
                results: results
            }]);

        if (error) {
            console.error('Failed to save delivery log:', error);
        }
    }
}

// Cron job usage
if (require.main === module) {
    const mailer = new DailyReportMailer();
    mailer.sendDailyReport().then(result => {
        console.log(`Report sent to ${result.successCount} subscribers`);
        process.exit(0);
    }).catch(error => {
        console.error('Report failed:', error);
        process.exit(1);
    });
}

module.exports = DailyReportMailer;
```

### 2. Welcome Email Sequence

```javascript
// ~/.openclaw/workspace/scripts/welcome-sequence.js
const { Resend } = require('resend');
const { createClient } = require('@supabase/supabase-js');
const EmailTemplateEngine = require('./email-template-engine');

class WelcomeEmailSequence {
    constructor() {
        this.resend = new Resend(process.env.RESEND_API_KEY);
        this.supabase = createClient(
            process.env.SUPABASE_URL,
            process.env.SUPABASE_ANON_KEY
        );
        this.templateEngine = new EmailTemplateEngine();
        
        this.sequence = [
            { day: 0, type: 'welcome', subject: 'Welcome! Let\'s get you started 🎉' },
            { day: 1, type: 'setup', subject: 'Quick setup guide (5 minutes)' },
            { day: 3, type: 'tips', subject: 'Pro tips from our power users' },
            { day: 7, type: 'checkin', subject: 'How are things going?' },
            { day: 14, type: 'features', subject: 'Features you might have missed' }
        ];
    }

    async processWelcomeSequence() {
        console.log('📧 Processing welcome email sequence...');
        
        for (const step of this.sequence) {
            await this.sendSequenceStep(step);
        }
    }

    async sendSequenceStep(step) {
        try {
            // Calculate target date (users who signed up N days ago)
            const targetDate = new Date();
            targetDate.setDate(targetDate.getDate() - step.day);
            targetDate.setHours(0, 0, 0, 0);
            
            const nextDay = new Date(targetDate);
            nextDay.setDate(nextDay.getDate() + 1);

            // Find users who should receive this email
            const { data: users } = await this.supabase
                .from('users')
                .select('*')
                .gte('created_at', targetDate.toISOString())
                .lt('created_at', nextDay.toISOString())
                .eq('email_verified', true);

            console.log(`📤 Sending "${step.type}" emails to ${users.length} users (Day ${step.day})`);

            for (const user of users) {
                // Check if this email was already sent
                const { data: sentEmails } = await this.supabase
                    .from('welcome_sequence_log')
                    .select('*')
                    .eq('user_id', user.id)
                    .eq('sequence_step', step.type);

                if (sentEmails.length > 0) {
                    console.log(`⏭️  Skipping ${step.type} for ${user.email} - already sent`);
                    continue;
                }

                const html = await this.generateSequenceEmail(step, user);
                
                try {
                    const result = await this.resend.emails.send({
                        from: `${process.env.COMPANY_NAME} <hello@${process.env.DOMAIN}>`,
                        to: user.email,
                        subject: step.subject,
                        html: html
                    });

                    // Log successful send
                    await this.supabase
                        .from('welcome_sequence_log')
                        .insert([{
                            user_id: user.id,
                            user_email: user.email,
                            sequence_step: step.type,
                            sequence_day: step.day,
                            sent_at: new Date().toISOString(),
                            message_id: result.data.id
                        }]);

                    console.log(`✅ Sent ${step.type} email to ${user.email}`);
                    
                    // Rate limiting
                    await new Promise(resolve => setTimeout(resolve, 300));

                } catch (error) {
                    console.error(`❌ Failed to send ${step.type} email to ${user.email}:`, error.message);
                }
            }

        } catch (error) {
            console.error(`Failed to process ${step.type} step:`, error);
        }
    }

    async generateSequenceEmail(step, user) {
        const companyData = {
            name: process.env.COMPANY_NAME,
            address: process.env.COMPANY_ADDRESS,
            unsubscribeUrl: `${process.env.WEBSITE_URL}/unsubscribe?email=${encodeURIComponent(user.email)}`,
            preferencesUrl: `${process.env.WEBSITE_URL}/preferences?email=${encodeURIComponent(user.email)}`,
            websiteUrl: process.env.WEBSITE_URL
        };

        switch (step.type) {
            case 'welcome':
                return this.templateEngine.generateWelcomeEmail(
                    { firstName: user.first_name, email: user.email },
                    { ...companyData, onboardingUrl: `${process.env.WEBSITE_URL}/onboarding` }
                );

            case 'setup':
                return this.generateSetupEmail(user, companyData);

            case 'tips':
                return this.generateTipsEmail(user, companyData);

            case 'checkin':
                return this.generateCheckinEmail(user, companyData);

            case 'features':
                return this.generateFeaturesEmail(user, companyData);

            default:
                throw new Error(`Unknown sequence type: ${step.type}`);
        }
    }

    generateSetupEmail(user, companyData) {
        const content = `
            <h2>Ready to set up your account? 🛠️</h2>
            <p>Hi ${user.first_name || 'there'},</p>
            <p>Let's get your account fully configured! This quick 5-minute setup will unlock all features:</p>
            
            <div style="background-color: #f0f9ff; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #3b82f6;">
                <h3 style="margin-top: 0; color: #1e40af;">Setup Checklist</h3>
                <ul style="margin: 0; padding-left: 20px;">
                    <li>Complete your profile</li>
                    <li>Connect your first data source</li>
                    <li>Set up your preferences</li>
                    <li>Configure notifications</li>
                </ul>
            </div>
            
            <a href="${process.env.WEBSITE_URL}/setup?user=${user.id}" class="button">Start 5-Minute Setup</a>
            
            <p>Need help? Just reply to this email and we'll guide you through it personally.</p>
            
            <p>Best,<br>
            The ${companyData.name} Team</p>
        `;

        return this.templateEngine.processTemplate(content, {
            EMAIL_TITLE: 'Complete Your Setup',
            COMPANY_NAME: companyData.name,
            EMAIL_CONTENT: content,
            COMPANY_ADDRESS: companyData.address,
            UNSUBSCRIBE_URL: companyData.unsubscribeUrl,
            PREFERENCES_URL: companyData.preferencesUrl,
            WEBSITE_URL: companyData.websiteUrl,
            RECIPIENT_EMAIL: user.email
        });
    }

    generateTipsEmail(user, companyData) {
        const content = `
            <h2>Pro tips from our power users 💡</h2>
            <p>Hi ${user.first_name || 'there'},</p>
            <p>Our most successful users shared these game-changing tips:</p>
            
            <div style="margin: 30px 0;">
                <div style="border-left: 4px solid #10b981; padding-left: 20px; margin-bottom: 25px;">
                    <h3 style="color: #065f46; margin: 0 0 8px 0;">💚 Tip #1: Start Small</h3>
                    <p style="margin: 0; color: #374151;">"Don't try to automate everything at once. Pick one workflow and master it first." - Sarah K.</p>
                </div>
                
                <div style="border-left: 4px solid #3b82f6; padding-left: 20px; margin-bottom: 25px;">
                    <h3 style="color: #1e40af; margin: 0 0 8px 0;">🔵 Tip #2: Monitor Daily</h3>
                    <p style="margin: 0; color: #374151;">"I check my automation dashboard every morning with coffee. Catches issues early." - Mike R.</p>
                </div>
                
                <div style="border-left: 4px solid #f59e0b; padding-left: 20px; margin-bottom: 25px;">
                    <h3 style="color: #92400e; margin: 0 0 8px 0;">🟡 Tip #3: Document Everything</h3>
                    <p style="margin: 0; color: #374151;">"Write down why you set up each automation. You'll thank yourself later." - Lisa T.</p>
                </div>
            </div>
            
            <a href="${process.env.WEBSITE_URL}/best-practices" class="button">See All Best Practices</a>
            
            <p>What's your biggest automation challenge? Just reply and tell us - we read every response!</p>
            
            <p>Cheers,<br>
            The ${companyData.name} Team</p>
        `;

        return this.templateEngine.processTemplate(content, {
            EMAIL_TITLE: 'Pro Tips Inside',
            COMPANY_NAME: companyData.name,
            EMAIL_CONTENT: content,
            COMPANY_ADDRESS: companyData.address,
            UNSUBSCRIBE_URL: companyData.unsubscribeUrl,
            PREFERENCES_URL: companyData.preferencesUrl,
            WEBSITE_URL: companyData.websiteUrl,
            RECIPIENT_EMAIL: user.email
        });
    }

    generateCheckinEmail(user, companyData) {
        const content = `
            <h2>How's your first week going? 🤔</h2>
            <p>Hi ${user.first_name || 'there'},</p>
            <p>It's been a week since you joined ${companyData.name}! I'm curious - how's your experience so far?</p>
            
            <p>Quick question: <strong>What's the biggest challenge you're trying to solve right now?</strong></p>
            
            <div style="background-color: #fef3c7; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <p style="margin: 0; color: #92400e;"><strong>💡 Just reply to this email</strong> - I read every response personally and often have specific suggestions that can save you hours.</p>
            </div>
            
            <p>Some common things people tell me at this stage:</p>
            <ul style="padding-left: 20px; color: #4b5563;">
                <li>"I'm not sure which automation to build first"</li>
                <li>"I'm getting stuck on the technical setup"</li>
                <li>"I want to automate X but don't know if it's possible"</li>
            </ul>
            
            <p>Whatever it is, I'm here to help. This is exactly why we built ${companyData.name} - to make automation accessible to everyone.</p>
            
            <a href="${process.env.WEBSITE_URL}/help" class="button">Get Personal Help</a>
            
            <p>Looking forward to your reply!</p>
            
            <p>Best,<br>
            [Your Name]<br>
            Founder, ${companyData.name}</p>
        `;

        return this.templateEngine.processTemplate(content, {
            EMAIL_TITLE: 'Quick check-in',
            COMPANY_NAME: companyData.name,
            EMAIL_CONTENT: content,
            COMPANY_ADDRESS: companyData.address,
            UNSUBSCRIBE_URL: companyData.unsubscribeUrl,
            PREFERENCES_URL: companyData.preferencesUrl,
            WEBSITE_URL: companyData.websiteUrl,
            RECIPIENT_EMAIL: user.email
        });
    }

    generateFeaturesEmail(user, companyData) {
        const content = `
            <h2>Features you might have missed 🔍</h2>
            <p>Hi ${user.first_name || 'there'},</p>
            <p>You've been exploring ${companyData.name} for two weeks now. Here are some powerful features that often fly under the radar:</p>
            
            <div style="margin: 30px 0;">
                <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; margin-bottom: 20px;">
                    <h3 style="color: #1e293b; margin: 0 0 12px 0;">🔄 Conditional Logic</h3>
                    <p style="margin: 0 0 12px 0; color: #475569;">Create smart automations that adapt based on data conditions. Perfect for handling different scenarios automatically.</p>
                    <a href="${process.env.WEBSITE_URL}/features/conditional-logic" style="color: #3b82f6; text-decoration: none; font-weight: 500;">Learn more →</a>
                </div>
                
                <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; margin-bottom: 20px;">
                    <h3 style="color: #1e293b; margin: 0 0 12px 0;">📊 Custom Dashboards</h3>
                    <p style="margin: 0 0 12px 0; color: #475569;">Build personalized dashboards that show exactly what matters to your business. No coding required.</p>
                    <a href="${process.env.WEBSITE_URL}/features/dashboards" style="color: #3b82f6; text-decoration: none; font-weight: 500;">Learn more →</a>
                </div>
                
                <div style="background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 20px; margin-bottom: 20px;">
                    <h3 style="color: #1e293b; margin: 0 0 12px 0;">🚨 Smart Alerts</h3>
                    <p style="margin: 0 0 12px 0; color: #475569;">Get notified only when something actually needs your attention. Reduce noise, increase focus.</p>
                    <a href="${process.env.WEBSITE_URL}/features/smart-alerts" style="color: #3b82f6; text-decoration: none; font-weight: 500;">Learn more →</a>
                </div>
            </div>
            
            <a href="${process.env.WEBSITE_URL}/features/all" class="button">Explore All Features</a>
            
            <p>Questions about any of these? Just reply - I love talking about automation possibilities!</p>
            
            <p>Best,<br>
            The ${companyData.name} Team</p>
        `;

        return this.templateEngine.processTemplate(content, {
            EMAIL_TITLE: 'Hidden Features Revealed',
            COMPANY_NAME: companyData.name,
            EMAIL_CONTENT: content,
            COMPANY_ADDRESS: companyData.address,
            UNSUBSCRIBE_URL: companyData.unsubscribeUrl,
            PREFERENCES_URL: companyData.preferencesUrl,
            WEBSITE_URL: companyData.websiteUrl,
            RECIPIENT_EMAIL: user.email
        });
    }
}

// Cron job usage
if (require.main === module) {
    const sequence = new WelcomeEmailSequence();
    sequence.processWelcomeSequence().then(() => {
        console.log('Welcome sequence processing complete');
        process.exit(0);
    }).catch(error => {
        console.error('Welcome sequence failed:', error);
        process.exit(1);
    });
}

module.exports = WelcomeEmailSequence;
```

## Deliverability Optimization

### Email Health Monitoring

```javascript
// ~/.openclaw/workspace/scripts/email-health-monitor.js
const { Resend } = require('resend');
const { createClient } = require('@supabase/supabase-js');

class EmailHealthMonitor {
    constructor() {
        this.resend = new Resend(process.env.RESEND_API_KEY);
        this.supabase = createClient(
            process.env.SUPABASE_URL,
            process.env.SUPABASE_ANON_KEY
        );
    }

    async checkDomainHealth() {
        try {
            console.log('🔍 Checking email domain health...');
            
            // Get domain status from Resend
            const domains = await this.resend.domains.list();
            
            const healthReport = {
                timestamp: new Date().toISOString(),
                domains: [],
                overallHealth: 'good',
                issues: [],
                recommendations: []
            };

            for (const domain of domains.data) {
                const domainDetail = await this.resend.domains.get(domain.id);
                
                const domainHealth = {
                    name: domain.name,
                    status: domain.status,
                    region: domain.region,
                    records: domainDetail.records || [],
                    dnsHealth: this.checkDNSHealth(domainDetail.records),
                    createdAt: domain.created_at
                };

                if (domain.status !== 'verified') {
                    healthReport.issues.push(`Domain ${domain.name} is not verified`);
                    healthReport.overallHealth = 'warning';
                }

                healthReport.domains.push(domainHealth);
            }

            // Check recent delivery metrics
            const deliveryMetrics = await this.getDeliveryMetrics(7); // Last 7 days
            healthReport.deliveryMetrics = deliveryMetrics;

            // Analyze bounce rates
            if (deliveryMetrics.bounceRate > 5) {
                healthReport.issues.push(`High bounce rate: ${deliveryMetrics.bounceRate}%`);
                healthReport.overallHealth = 'critical';
                healthReport.recommendations.push('Clean your email list - remove hard bounces');
            }

            // Analyze complaint rates
            if (deliveryMetrics.complaintRate > 0.1) {
                healthReport.issues.push(`High complaint rate: ${deliveryMetrics.complaintRate}%`);
                healthReport.overallHealth = 'warning';
                healthReport.recommendations.push('Review email content and unsubscribe process');
            }

            // Save health report
            await this.saveHealthReport(healthReport);
            
            console.log(`📊 Domain health: ${healthReport.overallHealth}`);
            if (healthReport.issues.length > 0) {
                console.log('⚠️  Issues found:', healthReport.issues);
            }

            return healthReport;

        } catch (error) {
            console.error('Failed to check domain health:', error);
            throw error;
        }
    }

    checkDNSHealth(records) {
        const health = {
            spf: false,
            dkim: false,
            dmarc: false,
            mx: false
        };

        records.forEach(record => {
            switch (record.record) {
                case 'SPF':
                    health.spf = record.status === 'verified';
                    break;
                case 'DKIM':
                    health.dkim = record.status === 'verified';
                    break;
                case 'DMARC':
                    health.dmarc = record.status === 'verified';
                    break;
                case 'MX':
                    health.mx = record.status === 'verified';
                    break;
            }
        });

        return health;
    }

    async getDeliveryMetrics(days = 7) {
        try {
            const startDate = new Date();
            startDate.setDate(startDate.getDate() - days);

            const { data: deliveryLogs } = await this.supabase
                .from('email_delivery_logs')
                .select('*')
                .gte('sent_at', startDate.toISOString());

            const totalSent = deliveryLogs.reduce((sum, log) => sum + log.recipients, 0);
            const totalDelivered = deliveryLogs.reduce((sum, log) => sum + log.delivered, 0);
            const totalBounced = deliveryLogs.reduce((sum, log) => sum + (log.bounced || 0), 0);
            const totalComplaints = deliveryLogs.reduce((sum, log) => sum + (log.complaints || 0), 0);

            return {
                totalSent,
                totalDelivered,
                totalBounced,
                totalComplaints,
                deliveryRate: totalSent > 0 ? ((totalDelivered / totalSent) * 100).toFixed(2) : 0,
                bounceRate: totalSent > 0 ? ((totalBounced / totalSent) * 100).toFixed(2) : 0,
                complaintRate: totalSent > 0 ? ((totalComplaints / totalSent) * 100).toFixed(2) : 0,
                period: `${days} days`
            };

        } catch (error) {
            console.error('Failed to get delivery metrics:', error);
            return {
                totalSent: 0,
                deliveryRate: 0,
                bounceRate: 0,
                complaintRate: 0,
                period: `${days} days`
            };
        }
    }

    async saveHealthReport(report) {
        try {
            const { error } = await this.supabase
                .from('email_health_reports')
                .insert([{
                    timestamp: report.timestamp,
                    overall_health: report.overallHealth,
                    issues: report.issues,
                    recommendations: report.recommendations,
                    domain_count: report.domains.length,
                    delivery_metrics: report.deliveryMetrics,
                    full_report: report
                }]);

            if (error) throw error;
        } catch (error) {
            console.error('Failed to save health report:', error);
        }
    }

    async cleanBounces() {
        console.log('🧹 Cleaning bounced emails...');
        
        try {
            // Get bounced emails from delivery logs
            const { data: bouncedLogs } = await this.supabase
                .from('email_delivery_logs')
                .select('results')
                .not('results', 'is', null);

            const bouncedEmails = new Set();
            
            bouncedLogs.forEach(log => {
                if (log.results) {
                    log.results.forEach(result => {
                        if (!result.success && result.error && 
                            (result.error.includes('bounce') || result.error.includes('invalid'))) {
                            bouncedEmails.add(result.email);
                        }
                    });
                }
            });

            if (bouncedEmails.size > 0) {
                // Mark emails as bounced in subscribers table
                const emailArray = Array.from(bouncedEmails);
                
                const { error } = await this.supabase
                    .from('email_subscribers')
                    .update({ 
                        active: false, 
                        bounce_status: 'hard',
                        deactivated_at: new Date().toISOString(),
                        deactivation_reason: 'email_bounce'
                    })
                    .in('email', emailArray);

                if (error) throw error;

                console.log(`✅ Deactivated ${bouncedEmails.size} bounced email addresses`);
            } else {
                console.log('✅ No bounced emails found');
            }

        } catch (error) {
            console.error('Failed to clean bounces:', error);
        }
    }
}

module.exports = EmailHealthMonitor;
```

## Pro Tips

**📧 Subject Line Science:** A/B test subject lines. Personalization increases open rates by 26%, but avoid spam triggers like "FREE" or excessive punctuation.

**📱 Mobile-First Design:** 60% of emails are opened on mobile. Design for mobile first, desktop second. Single column layouts work best.

**🎯 List Segmentation:** Generic broadcasts perform poorly. Segment by user behavior, preferences, purchase history, and engagement level.

**⏰ Timing Optimization:** Send times matter. B2B: Tuesday-Thursday, 10am-2pm. B2C: Weekend mornings often work better.

**🔄 Automation Testing:** Always test your sequences end-to-end before launching. Send test emails to yourself and verify all links work.

## Troubleshooting

### Issue 1: Low Deliverability Rates
**Symptoms:** Emails going to spam, low open rates
**Diagnosis:** DNS authentication issues or reputation problems
**Fix:**
```bash
# Check DNS records
dig TXT yourdomain.com
dig TXT resend._domainkey.yourdomain.com  
dig TXT _dmarc.yourdomain.com

# Test email authentication
node -e "
const EmailHealthMonitor = require('./email-health-monitor');
const monitor = new EmailHealthMonitor();
monitor.checkDomainHealth().then(console.log);
"
```

### Issue 2: High Bounce Rates
**Symptoms:** Many emails failing to deliver
**Diagnosis:** Invalid email addresses in database
**Fix:**
```javascript
// Email validation before sending
function isValidEmail(email) {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email);
}

// Clean list before sending
const validEmails = subscribers.filter(sub => isValidEmail(sub.email));
```

### Issue 3: Template Rendering Issues
**Symptoms:** Emails display incorrectly in different clients
**Diagnosis:** CSS compatibility or HTML structure problems
**Fix:**
```html
<!-- Use table-based layouts for maximum compatibility -->
<table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
    <tr>
        <td style="padding: 20px;">
            <!-- Content here -->
        </td>
    </tr>
</table>

<!-- Inline CSS for better compatibility -->
<p style="color: #333333; font-size: 16px; line-height: 1.6; margin: 0 0 16px 0;">
    Your content
</p>
```

### Issue 4: API Rate Limiting
**Symptoms:** Some emails fail to send during bulk campaigns
**Diagnosis:** Hitting Resend's rate limits
**Fix:**
```javascript
// Add proper rate limiting
async function sendWithRateLimit(emails, rateLimit = 14) { // Resend limit: 14/sec
    const delay = 1000 / rateLimit;
    
    for (const email of emails) {
        await sendEmail(email);
        await new Promise(resolve => setTimeout(resolve, delay));
    }
}
```

### Issue 5: Unsubscribe Not Working
**Symptoms:** Users complain they can't unsubscribe
**Diagnosis:** Unsubscribe links broken or process complicated
**Fix:**
```javascript
// Simple one-click unsubscribe
app.get('/unsubscribe/:token', async (req, res) => {
    try {
        const { error } = await supabase
            .from('email_subscribers')
            .update({ 
                active: false,
                unsubscribed_at: new Date().toISOString()
            })
            .eq('unsubscribe_token', req.params.token);

        if (error) throw error;
        
        res.send('You have been successfully unsubscribed.');
    } catch (error) {
        res.status(500).send('Error processing unsubscribe request.');
    }
});
```

Email automation done right is a revenue machine that works 24/7. It nurtures leads, converts prospects, and retains customers without human intervention. Build these systems once, and they'll pay dividends for years.

The businesses dominating their markets have email systems that feel personal at scale. This chapter gave you the blueprint to build yours. Now implement it and watch your conversion rates soar.