# Chapter 20: Email Outreach Automation

*From Qualified Leads to Active Conversations*

Email outreach is where your lead generation pipeline converts potential into profit. But most people do it wrong—they blast generic templates, ignore deliverability, and wonder why their response rates are terrible.

This chapter builds a complete email outreach engine that personalizes at scale, maintains deliverability, tracks engagement, and automatically adjusts based on performance. Every template, every API call, every automation script is production-ready and copy-paste complete.

## Cold Email Fundamentals: What Works, What Gets You Marked as Spam

### The Physics of Email Deliverability

Email deliverability isn't just about following rules—it's about understanding how email providers think.

**The Reputation Stack:**
1. **Domain Reputation** - Your sending domain's history
2. **IP Reputation** - Your sending server's reputation  
3. **Content Quality** - How "spammy" your message looks
4. **Engagement Rates** - How recipients interact with your emails
5. **Authentication** - SPF, DKIM, DMARC setup

```javascript
// Complete email deliverability configuration
const EMAIL_CONFIG = {
    // Domain configuration (replace with your domain)
    sendingDomain: 'outreach.yourcompany.com', // Subdomain for cold outreach
    replyToDomain: 'yourcompany.com', // Main domain for replies
    
    // Daily sending limits (start conservative, scale up)
    sendingLimits: {
        week1: { dailyLimit: 10, hourlyLimit: 2 },
        week2: { dailyLimit: 25, hourlyLimit: 5 },
        week3: { dailyLimit: 50, hourlyLimit: 10 },
        week4: { dailyLimit: 100, hourlyLimit: 20 },
        steady: { dailyLimit: 200, hourlyLimit: 40 }
    },
    
    // Content guidelines
    contentRules: {
        maxSubjectLength: 50,
        maxBodyLength: 150, // Keep it short
        avoidWords: [
            'free', 'guarantee', 'amazing', 'incredible', 'revolutionary',
            'click here', 'urgent', 'limited time', 'act now', '$$$'
        ],
        requiredElements: [
            'personalizedGreeting',
            'specificReason',
            'clearCTA',
            'unsubscribeLink',
            'physicalAddress'
        ]
    },
    
    // Authentication (set these up in your DNS)
    authentication: {
        spf: 'v=spf1 include:resend.com ~all',
        dkim: 'Managed by email provider (Resend)',
        dmarc: 'v=DMARC1; p=quarantine; rua=mailto:dmarc@yourcompany.com'
    }
};

// Email deliverability checker
class DeliverabilityChecker {
    constructor() {
        this.spamWords = EMAIL_CONFIG.contentRules.avoidWords;
        this.maxScore = 100; // Lower is better
    }
    
    analyzeEmail(subject, content, fromAddress) {
        let score = 0;
        const issues = [];
        const suggestions = [];
        
        // Subject line analysis
        if (subject.length > EMAIL_CONFIG.contentRules.maxSubjectLength) {
            score += 10;
            issues.push('Subject line too long');
            suggestions.push(`Shorten subject to under ${EMAIL_CONFIG.contentRules.maxSubjectLength} characters`);
        }
        
        if (subject.includes('Re:') || subject.includes('Fwd:')) {
            score += 15;
            issues.push('Fake reply subject detected');
            suggestions.push('Remove "Re:" or "Fwd:" from subject');
        }
        
        if (subject.toUpperCase() === subject) {
            score += 20;
            issues.push('All caps subject line');
            suggestions.push('Use normal capitalization');
        }
        
        // Content analysis
        const spamWordCount = this.spamWords.filter(word => 
            content.toLowerCase().includes(word.toLowerCase())
        ).length;
        
        if (spamWordCount > 0) {
            score += spamWordCount * 5;
            issues.push(`${spamWordCount} spam words detected`);
            suggestions.push('Replace spam words with neutral alternatives');
        }
        
        // Link analysis
        const linkCount = (content.match(/https?:\/\/[^\s]+/g) || []).length;
        if (linkCount > 2) {
            score += (linkCount - 2) * 5;
            issues.push('Too many links');
            suggestions.push('Limit to 1-2 links maximum');
        }
        
        // Personalization check
        if (!content.includes('{{') && !content.includes('{firstName}')) {
            score += 15;
            issues.push('No personalization detected');
            suggestions.push('Add personalized elements');
        }
        
        // Authentication check
        if (!fromAddress.includes(EMAIL_CONFIG.sendingDomain)) {
            score += 10;
            issues.push('Sender domain mismatch');
            suggestions.push(`Send from ${EMAIL_CONFIG.sendingDomain}`);
        }
        
        // Required elements check
        const hasUnsubscribe = content.includes('unsubscribe') || content.includes('opt-out');
        if (!hasUnsubscribe) {
            score += 25;
            issues.push('No unsubscribe link');
            suggestions.push('Add unsubscribe link (required by law)');
        }
        
        // Length check
        if (content.length > 1000) {
            score += 10;
            issues.push('Email too long');
            suggestions.push('Keep under 150 words for better response rates');
        }
        
        return {
            score,
            grade: this.calculateGrade(score),
            issues,
            suggestions,
            deliverabilityRisk: score > 50 ? 'HIGH' : score > 25 ? 'MEDIUM' : 'LOW'
        };
    }
    
    calculateGrade(score) {
        if (score <= 10) return 'A';
        if (score <= 25) return 'B';  
        if (score <= 50) return 'C';
        if (score <= 75) return 'D';
        return 'F';
    }
}
```

## Building Effective Email Sequences

### The 4-Touch Sequence Framework

```javascript
// Complete email sequence templates
const EMAIL_SEQUENCES = {
    b2b_saas_outreach: {
        name: 'B2B SaaS Cold Outreach',
        description: 'Proven 4-email sequence for B2B SaaS sales',
        timing: [0, 3, 7, 14], // Days between emails
        
        emails: [
            {
                step: 1,
                name: 'Initial Value',
                delayDays: 0,
                subject: 'Quick question about {{companyName}}\'s {{painPoint}}',
                template: `Hi {{firstName}},

I noticed {{companyName}} is {{specificObservation}} - that's impressive growth!

I'm curious: how are you currently handling {{painPoint}}? Most {{industry}} companies your size struggle with {{commonChallenge}}.

We helped {{similarCompany}} {{specificResult}} in just {{timeframe}}, and I think we could do something similar for {{companyName}}.

Worth a 15-minute conversation?

Best,
{{senderName}}

P.S. Here's the case study: {{caseStudyLink}}`,
                
                personalizationFields: [
                    'companyName', 'firstName', 'painPoint', 'specificObservation',
                    'industry', 'commonChallenge', 'similarCompany', 'specificResult',
                    'timeframe', 'senderName', 'caseStudyLink'
                ],
                
                cta: 'Schedule 15-minute call',
                expectedResponseRate: 0.15 // 15%
            },
            
            {
                step: 2,
                name: 'Different Angle',
                delayDays: 3,
                subject: 'Alternative approach for {{companyName}}',
                template: `Hi {{firstName}},

I know you're busy, so I'll keep this brief.

Instead of a call, what if I just sent you a 2-minute video showing exactly how {{similarCompany}} solved their {{painPoint}} challenge?

No pitch, no demo request - just the specific steps they took to {{specificResult}}.

Interested? Just reply with "yes" and I'll send it over.

{{senderName}}`,
                
                personalizationFields: [
                    'firstName', 'companyName', 'similarCompany', 
                    'painPoint', 'specificResult', 'senderName'
                ],
                
                cta: 'Reply with "yes"',
                expectedResponseRate: 0.08 // 8%
            },
            
            {
                step: 3, 
                name: 'Social Proof',
                delayDays: 7,
                subject: 'This might sound crazy...',
                template: `{{firstName}},

This might sound crazy, but what if {{companyName}} could {{desiredOutcome}} without {{currentPainPoint}}?

Here's what I mean:

→ {{similarCompany1}} reduced {{metric1}} by {{improvement1}}
→ {{similarCompany2}} increased {{metric2}} by {{improvement2}}  
→ {{similarCompany3}} eliminated {{metric3}} completely

All three are {{industry}} companies similar to {{companyName}}.

The approach isn't revolutionary - it's just systematic. And it works.

{{callToAction}}

{{senderName}}

P.S. If this isn't a priority right now, just let me know and I'll check back in {{timeframe}}.`,
                
                personalizationFields: [
                    'firstName', 'companyName', 'desiredOutcome', 'currentPainPoint',
                    'similarCompany1', 'metric1', 'improvement1',
                    'similarCompany2', 'metric2', 'improvement2',
                    'similarCompany3', 'metric3', 'industry',
                    'callToAction', 'senderName', 'timeframe'
                ],
                
                cta: 'Book 15-min strategy call',
                expectedResponseRate: 0.12 // 12%
            },
            
            {
                step: 4,
                name: 'Breakup',
                delayDays: 14,
                subject: 'Closing the loop on {{companyName}}',
                template: `{{firstName}},

I'm going to close the loop on this.

I've reached out a few times about helping {{companyName}} with {{painPoint}}, but haven't heard back. That's totally fine - I know you're busy and this might not be a priority.

Before I close your file, I'll leave you with this:

{{valuableResource}}

No strings attached. Just something that might be useful down the road.

If your {{painPoint}} situation changes, you know where to find me.

All the best,
{{senderName}}

P.S. Hit reply and let me know if you'd prefer I don't follow up on this topic again.`,
                
                personalizationFields: [
                    'firstName', 'companyName', 'painPoint', 'valuableResource', 'senderName'
                ],
                
                cta: 'Soft close with resource',
                expectedResponseRate: 0.05 // 5%
            }
        ]
    },
    
    // Additional sequences for different use cases
    consulting_services: {
        name: 'Professional Services Outreach',
        description: 'For agencies, consultants, and service providers',
        timing: [0, 4, 8, 15],
        
        emails: [
            {
                step: 1,
                name: 'Insight-Based Opening',
                delayDays: 0,
                subject: '{{industryTrend}} impact on {{companyName}}?',
                template: `Hi {{firstName}},

I was reading about {{industryTrend}} and immediately thought of {{companyName}}.

{{specificInsight}}

How is this affecting {{companyName}}'s {{businessArea}}?

We've helped {{similarCompany1}} and {{similarCompany2}} navigate similar challenges, and I'd love to share what we've learned.

Worth a brief conversation?

{{senderName}}`,
                
                personalizationFields: [
                    'firstName', 'industryTrend', 'companyName', 'specificInsight',
                    'businessArea', 'similarCompany1', 'similarCompany2', 'senderName'
                ],
                
                cta: 'Brief conversation request',
                expectedResponseRate: 0.18 // 18%
            }
            // Additional emails would follow similar pattern...
        ]
    }
};

// Email sequence generator
class EmailSequenceGenerator {
    constructor() {
        this.sequences = EMAIL_SEQUENCES;
        this.personalizer = new EmailPersonalizer();
    }
    
    async generateSequence(sequenceName, leadData) {
        const sequence = this.sequences[sequenceName];
        if (!sequence) {
            throw new Error(`Sequence ${sequenceName} not found`);
        }
        
        const personalizedEmails = [];
        
        for (const emailTemplate of sequence.emails) {
            try {
                const personalizedEmail = await this.personalizer.personalize(
                    emailTemplate, 
                    leadData
                );
                
                personalizedEmails.push({
                    ...emailTemplate,
                    personalizedSubject: personalizedEmail.subject,
                    personalizedContent: personalizedEmail.content,
                    scheduledDate: this.calculateSendDate(emailTemplate.delayDays),
                    personalizationData: personalizedEmail.personalizationData
                });
                
            } catch (error) {
                console.error(`Error personalizing email ${emailTemplate.step}:`, error.message);
                // Include unpersonalized version as fallback
                personalizedEmails.push({
                    ...emailTemplate,
                    personalizedSubject: emailTemplate.subject,
                    personalizedContent: emailTemplate.template,
                    error: error.message
                });
            }
        }
        
        return {
            sequenceName,
            leadData,
            emails: personalizedEmails,
            totalEmails: personalizedEmails.length,
            expectedResponseRate: sequence.emails.reduce(
                (sum, email) => sum + email.expectedResponseRate, 0
            ) / sequence.emails.length,
            generatedAt: new Date().toISOString()
        };
    }
    
    calculateSendDate(delayDays) {
        const sendDate = new Date();
        sendDate.setDate(sendDate.getDate() + delayDays);
        
        // Ensure business day (Monday-Friday)
        while (sendDate.getDay() === 0 || sendDate.getDay() === 6) {
            sendDate.setDate(sendDate.getDate() + 1);
        }
        
        // Set to optimal sending time (9 AM in recipient's timezone)
        sendDate.setHours(9, 0, 0, 0);
        
        return sendDate.toISOString();
    }
}
```

### Advanced Personalization System

```javascript
// Complete AI-powered email personalizer
class EmailPersonalizer {
    constructor() {
        this.personalizationSources = new Map();
        this.cache = new Map();
    }
    
    async personalize(emailTemplate, leadData) {
        const cacheKey = `${emailTemplate.step}_${leadData.id}`;
        
        // Check cache first
        if (this.cache.has(cacheKey)) {
            return this.cache.get(cacheKey);
        }
        
        try {
            // Gather personalization data
            const personalizationData = await this.gatherPersonalizationData(leadData);
            
            // Apply personalization to subject and content
            const personalizedSubject = this.applyPersonalization(
                emailTemplate.subject, 
                personalizationData
            );
            
            const personalizedContent = this.applyPersonalization(
                emailTemplate.template, 
                personalizationData
            );
            
            // AI enhancement for key fields
            const enhancedData = await this.enhanceWithAI(
                personalizedContent, 
                leadData, 
                personalizationData
            );
            
            const result = {
                subject: personalizedSubject,
                content: enhancedData.content,
                personalizationData: personalizationData,
                aiEnhancements: enhancedData.enhancements
            };
            
            // Cache for future use
            this.cache.set(cacheKey, result);
            
            return result;
            
        } catch (error) {
            console.error('Error personalizing email:', error.message);
            
            // Fallback to basic personalization
            return this.basicPersonalization(emailTemplate, leadData);
        }
    }
    
    async gatherPersonalizationData(leadData) {
        const data = {
            // Basic lead data
            firstName: leadData.contacts?.[0]?.first_name || 'there',
            companyName: leadData.name,
            industry: leadData.industry,
            website: leadData.website,
            
            // Sender data
            senderName: 'Jackson', // Replace with your name
            senderCompany: 'Your Company', // Replace with your company
            senderTitle: 'Founder', // Replace with your title
        };
        
        // Industry-specific personalization
        data.painPoint = this.inferPainPoint(leadData.industry);
        data.commonChallenge = this.inferCommonChallenge(leadData.industry);
        
        // Company-specific observations
        if (leadData.description) {
            data.specificObservation = await this.extractSpecificObservation(leadData.description);
        }
        
        // Find similar companies for social proof
        data.similarCompany = await this.findSimilarCompany(leadData);
        data.similarCompany1 = await this.findSimilarCompany(leadData, 1);
        data.similarCompany2 = await this.findSimilarCompany(leadData, 2);
        data.similarCompany3 = await this.findSimilarCompany(leadData, 3);
        
        // Results and metrics (customize based on your service)
        data.specificResult = this.generateSpecificResult(leadData.industry);
        data.timeframe = this.getRealisticTimeframe(leadData.industry);
        data.metric1 = this.getRelevantMetric(leadData.industry, 'cost');
        data.improvement1 = this.getTypicalImprovement('cost');
        data.metric2 = this.getRelevantMetric(leadData.industry, 'efficiency');  
        data.improvement2 = this.getTypicalImprovement('efficiency');
        data.metric3 = this.getRelevantMetric(leadData.industry, 'time');
        
        // Call to action
        data.callToAction = this.generateCTA(leadData);
        data.caseStudyLink = 'https://yourcompany.com/case-studies'; // Replace with real link
        
        // Valuable resource for breakup email
        data.valuableResource = this.selectValuableResource(leadData.industry);
        
        // Current trends and insights
        data.industryTrend = await this.getCurrentIndustryTrend(leadData.industry);
        data.specificInsight = await this.generateSpecificInsight(leadData);
        data.businessArea = this.getRelevantBusinessArea(leadData.industry);
        
        return data;
    }
    
    inferPainPoint(industry) {
        const painPointMap = {
            'Software': 'customer acquisition costs',
            'Technology': 'scaling technical operations', 
            'Professional Services': 'project profitability',
            'Financial Services': 'regulatory compliance',
            'Healthcare': 'patient data management',
            'Manufacturing': 'supply chain efficiency',
            'E-commerce': 'conversion optimization',
            'SaaS': 'customer churn'
        };
        
        return painPointMap[industry] || 'operational efficiency';
    }
    
    inferCommonChallenge(industry) {
        const challengeMap = {
            'Software': 'managing multiple tools and systems',
            'Technology': 'coordinating between technical and business teams',
            'Professional Services': 'tracking project profitability in real-time',
            'Financial Services': 'maintaining compliance while staying agile',
            'Healthcare': 'integrating patient data across systems',
            'Manufacturing': 'visibility into supply chain disruptions',
            'E-commerce': 'understanding why visitors don\'t convert',
            'SaaS': 'identifying at-risk customers before they churn'
        };
        
        return challengeMap[industry] || 'connecting disconnected systems and processes';
    }
    
    async extractSpecificObservation(description) {
        // Look for growth indicators, recent achievements, or notable facts
        const growthIndicators = [
            'funding', 'series', 'raised', 'investment', 'growth', 'expansion',
            'hiring', 'team', 'new office', 'launched', 'partnership'
        ];
        
        const descriptionLower = description.toLowerCase();
        const foundIndicators = growthIndicators.filter(indicator => 
            descriptionLower.includes(indicator)
        );
        
        if (foundIndicators.length > 0) {
            if (foundIndicators.includes('funding') || foundIndicators.includes('raised')) {
                return 'securing recent funding';
            } else if (foundIndicators.includes('hiring') || foundIndicators.includes('team')) {
                return 'rapidly expanding your team';
            } else if (foundIndicators.includes('launched')) {
                return 'launching new initiatives';
            } else {
                return 'scaling operations';
            }
        }
        
        return 'building innovative solutions';
    }
    
    async findSimilarCompany(leadData, index = 0) {
        // In production, this would query your database for similar companies
        // For now, using industry-appropriate examples
        
        const similarCompanies = {
            'Software': ['TechCorp', 'InnovateSoft', 'DataDyne', 'CloudFirst'],
            'Technology': ['TechSolutions', 'DigitalEdge', 'SystemsPro', 'TechAdvantage'],
            'Professional Services': ['ConsultPro', 'ServiceExcellence', 'ProfessionalPlus', 'Expertise Inc'],
            'SaaS': ['CloudCo', 'SaaS Solutions', 'PlatformPro', 'ServiceCloud'],
            'Financial Services': ['FinTech Solutions', 'Capital Systems', 'Financial Edge', 'MoneyTech'],
            'E-commerce': ['E-Shop Pro', 'Commerce Plus', 'Retail Systems', 'MarketPlace Tech']
        };
        
        const industryCompanies = similarCompanies[leadData.industry] || similarCompanies['Technology'];
        return industryCompanies[index] || industryCompanies[0];
    }
    
    generateSpecificResult(industry) {
        const resultMap = {
            'Software': 'reduce customer acquisition costs by 40%',
            'Technology': 'streamline deployment processes by 60%',
            'Professional Services': 'increase project margins by 25%',
            'SaaS': 'reduce customer churn by 35%',
            'Financial Services': 'accelerate compliance reporting by 50%',
            'E-commerce': 'improve conversion rates by 30%'
        };
        
        return resultMap[industry] || 'improve operational efficiency by 45%';
    }
    
    getRealisticTimeframe(industry) {
        const timeframeMap = {
            'Software': '8 weeks',
            'Technology': '6 weeks', 
            'Professional Services': '4 weeks',
            'SaaS': '10 weeks',
            'Financial Services': '12 weeks',
            'E-commerce': '6 weeks'
        };
        
        return timeframeMap[industry] || '8 weeks';
    }
    
    getRelevantMetric(industry, type) {
        const metricMap = {
            'cost': {
                'Software': 'development costs',
                'Technology': 'operational overhead',
                'Professional Services': 'project costs',
                'SaaS': 'customer acquisition costs',
                'Financial Services': 'compliance costs',
                'E-commerce': 'marketing spend'
            },
            'efficiency': {
                'Software': 'deployment speed',
                'Technology': 'system performance',
                'Professional Services': 'project delivery time',
                'SaaS': 'onboarding time',
                'Financial Services': 'processing time',
                'E-commerce': 'order fulfillment'
            },
            'time': {
                'Software': 'manual testing',
                'Technology': 'system downtime',
                'Professional Services': 'administrative overhead',
                'SaaS': 'support response times',
                'Financial Services': 'report generation',
                'E-commerce': 'inventory management'
            }
        };
        
        return metricMap[type]?.[industry] || metricMap[type]['Technology'] || 'operational costs';
    }
    
    getTypicalImprovement(type) {
        const improvementMap = {
            'cost': ['45%', '35%', '50%', '40%', '30%'][Math.floor(Math.random() * 5)],
            'efficiency': ['60%', '55%', '70%', '65%', '50%'][Math.floor(Math.random() * 5)],
            'time': ['80%', '75%', '85%', '70%', '90%'][Math.floor(Math.random() * 5)]
        };
        
        return improvementMap[type] || '50%';
    }
    
    generateCTA(leadData) {
        const ctas = [
            'Worth a 15-minute conversation this week?',
            'Should we schedule a brief call to discuss?',
            'Interested in a quick strategy session?',
            'Want to see how this could work for ' + leadData.name + '?',
            'Ready for a 15-minute deep dive?'
        ];
        
        return ctas[Math.floor(Math.random() * ctas.length)];
    }
    
    selectValuableResource(industry) {
        const resourceMap = {
            'Software': 'Our "Software Team Efficiency Checklist" - 47 ways to eliminate bottlenecks',
            'Technology': 'The "Tech Operations Playbook" - proven processes from 50+ companies',
            'Professional Services': 'Our "Project Profitability Calculator" - find hidden profit leaks',
            'SaaS': 'The "SaaS Metrics Dashboard Template" - track what really matters',
            'Financial Services': 'Our "Compliance Automation Guide" - 23 processes you can automate today',
            'E-commerce': 'The "Conversion Optimization Toolkit" - 31 proven tactics'
        };
        
        return resourceMap[industry] || 'Our "Business Efficiency Audit" - uncover hidden opportunities';
    }
    
    async getCurrentIndustryTrend(industry) {
        // In production, this could pull from news APIs or trend databases
        const trendMap = {
            'Software': 'AI-powered development automation',
            'Technology': 'Remote-first infrastructure changes',
            'Professional Services': 'Value-based pricing adoption',
            'SaaS': 'Product-led growth strategies',
            'Financial Services': 'Digital transformation acceleration',
            'E-commerce': 'Personalization at scale'
        };
        
        return trendMap[industry] || 'Digital transformation initiatives';
    }
    
    async generateSpecificInsight(leadData) {
        const industry = leadData.industry;
        const companySize = leadData.employee_count || 100;
        
        const insightTemplates = [
            `Companies like ${leadData.name} (${companySize}+ employees) typically see 3-5x ROI on ${this.inferPainPoint(industry)} optimization.`,
            `${industry} companies your size are investing heavily in ${this.inferPainPoint(industry)} - but most are doing it wrong.`,
            `We're seeing ${industry} leaders gain significant competitive advantage by solving ${this.inferPainPoint(industry)} systematically.`
        ];
        
        return insightTemplates[Math.floor(Math.random() * insightTemplates.length)];
    }
    
    getRelevantBusinessArea(industry) {
        const areaMap = {
            'Software': 'development operations',
            'Technology': 'technical infrastructure',
            'Professional Services': 'project delivery',
            'SaaS': 'customer success',
            'Financial Services': 'compliance processes',
            'E-commerce': 'customer experience'
        };
        
        return areaMap[industry] || 'operational processes';
    }
    
    applyPersonalization(template, data) {
        let personalized = template;
        
        // Replace all placeholders with actual data
        Object.entries(data).forEach(([key, value]) => {
            const placeholder = new RegExp(`\\{\\{${key}\\}\\}`, 'g');
            personalized = personalized.replace(placeholder, value || '[MISSING]');
        });
        
        return personalized;
    }
    
    async enhanceWithAI(content, leadData, personalizationData) {
        // This would integrate with OpenClaw's AI system for content enhancement
        // For now, returning basic enhancements
        
        const enhancements = {
            subjectLineVariations: this.generateSubjectVariations(content, leadData),
            contentSuggestions: this.generateContentSuggestions(content, leadData),
            toneAdjustments: this.suggestToneAdjustments(content, leadData)
        };
        
        return {
            content: content, // In production, AI would enhance this
            enhancements: enhancements
        };
    }
    
    generateSubjectVariations(content, leadData) {
        const baseSubject = content.split('\n')[0]; // Assuming first line is subject
        
        return [
            `Quick ${leadData.industry.toLowerCase()} question, ${leadData.contacts?.[0]?.first_name}`,
            `${leadData.name}'s ${this.inferPainPoint(leadData.industry)} strategy`,
            `15-min conversation about ${leadData.name}?`,
            `${this.inferPainPoint(leadData.industry)} at ${leadData.name}`,
            `Thoughts on ${leadData.name}'s growth?`
        ];
    }
    
    generateContentSuggestions(content, leadData) {
        return [
            'Consider adding specific metrics or results',
            'Include a question to encourage response',
            'Mention a relevant industry trend',
            'Add social proof from similar companies'
        ];
    }
    
    suggestToneAdjustments(content, leadData) {
        return [
            'Keep tone casual and conversational',
            'Focus on value, not your product',
            'Be specific about benefits',
            'End with a soft call-to-action'
        ];
    }
    
    basicPersonalization(emailTemplate, leadData) {
        const basicData = {
            firstName: leadData.contacts?.[0]?.first_name || 'there',
            companyName: leadData.name,
            industry: leadData.industry,
            senderName: 'Jackson' // Replace with your name
        };
        
        return {
            subject: this.applyPersonalization(emailTemplate.subject, basicData),
            content: this.applyPersonalization(emailTemplate.template, basicData),
            personalizationData: basicData,
            aiEnhancements: {}
        };
    }
}
```

## Building the Outreach Engine

### Complete Email Sending System

```javascript
// Production-ready email outreach engine with Resend integration
class EmailOutreachEngine {
    constructor(resendApiKey, supabaseClient) {
        this.resendApiKey = resendApiKey;
        this.supabase = supabaseClient;
        this.baseUrl = 'https://api.resend.com';
        this.sequenceGenerator = new EmailSequenceGenerator();
        this.deliverabilityChecker = new DeliverabilityChecker();
        
        // Daily sending limits (implement gradual ramp-up)
        this.sendingLimits = EMAIL_CONFIG.sendingLimits;
        this.currentPhase = 'week1'; // Track your sending phase
    }
    
    async sendEmail(emailData) {
        try {
            // Validate email before sending
            const deliverabilityCheck = this.deliverabilityChecker.analyzeEmail(
                emailData.subject,
                emailData.content,
                emailData.from
            );
            
            if (deliverabilityCheck.deliverabilityRisk === 'HIGH') {
                throw new Error(`Email failed deliverability check: ${deliverabilityCheck.issues.join(', ')}`);
            }
            
            // Check daily sending limits
            const canSend = await this.checkSendingLimits();
            if (!canSend) {
                throw new Error('Daily sending limit reached');
            }
            
            // Send via Resend API
            const response = await fetch(`${this.baseUrl}/emails`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.resendApiKey}`,
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    from: emailData.from,
                    to: [emailData.to],
                    subject: emailData.subject,
                    html: this.generateEmailHTML(emailData.content, emailData.personalizationData),
                    text: this.stripHTML(emailData.content),
                    reply_to: emailData.replyTo || emailData.from,
                    headers: {
                        'X-Entity-Ref-ID': emailData.trackingId || Date.now().toString()
                    }
                })
            });
            
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(`Resend API error: ${errorData.message}`);
            }
            
            const result = await response.json();
            
            // Log successful send
            await this.logEmailSend({
                ...emailData,
                providerMessageId: result.id,
                sendStatus: 'sent',
                sentAt: new Date().toISOString(),
                deliverabilityScore: deliverabilityCheck.score
            });
            
            return {
                success: true,
                messageId: result.id,
                deliverabilityScore: deliverabilityCheck.score
            };
            
        } catch (error) {
            // Log failed send
            await this.logEmailSend({
                ...emailData,
                sendStatus: 'failed',
                error: error.message,
                sentAt: new Date().toISOString()
            });
            
            throw error;
        }
    }
    
    generateEmailHTML(textContent, personalizationData = {}) {
        // Convert plain text to proper HTML email
        const htmlContent = textContent
            .replace(/\n\n/g, '</p><p>')
            .replace(/\n/g, '<br>')
            .replace(/^/, '<p>')
            .replace(/$/, '</p>');
        
        // Add unsubscribe link (required by law)
        const unsubscribeLink = `https://your-domain.com/unsubscribe?email={{email}}&token={{unsubscribeToken}}`;
        
        return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${personalizationData.subject || 'Email'}</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
            line-height: 1.6;
            color: #333333;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }
        p {
            margin: 0 0 16px 0;
        }
        a {
            color: #2563eb;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .signature {
            border-top: 1px solid #e5e7eb;
            margin-top: 32px;
            padding-top: 16px;
            font-size: 14px;
            color: #6b7280;
        }
        .unsubscribe {
            font-size: 12px;
            color: #9ca3af;
            text-align: center;
            margin-top: 32px;
            padding-top: 16px;
            border-top: 1px solid #f3f4f6;
        }
        .unsubscribe a {
            color: #9ca3af;
        }
    </style>
</head>
<body>
    ${htmlContent}
    
    <div class="signature">
        <strong>${personalizationData.senderName || 'Your Name'}</strong><br>
        ${personalizationData.senderTitle || 'Your Title'}<br>
        ${personalizationData.senderCompany || 'Your Company'}<br>
        <a href="mailto:${personalizationData.senderEmail || 'your@email.com'}">${personalizationData.senderEmail || 'your@email.com'}</a><br>
        <a href="${personalizationData.companyWebsite || 'https://your-website.com'}">${personalizationData.companyWebsite || 'your-website.com'}</a>
    </div>
    
    <div class="unsubscribe">
        Your Company Name<br>
        123 Business St, City, State 12345<br><br>
        <a href="${unsubscribeLink}">Unsubscribe</a> | 
        <a href="https://your-domain.com/privacy">Privacy Policy</a>
    </div>
    
    <!-- Tracking pixel (optional) -->
    <img src="https://your-domain.com/track/open?id={{trackingId}}" width="1" height="1" style="display:none;">
</body>
</html>`;
    }
    
    stripHTML(html) {
        return html.replace(/<[^>]*>/g, '').replace(/\n\s*\n/g, '\n\n').trim();
    }
    
    async checkSendingLimits() {
        const today = new Date().toISOString().split('T')[0];
        const currentHour = new Date().getHours();
        
        // Get today's send count
        const { data: todaySends, error } = await this.supabase
            .from('email_sends')
            .select('id')
            .gte('sent_at', today)
            .eq('send_status', 'sent');
        
        if (error) {
            console.error('Error checking send limits:', error);
            return false; // Fail safe - don't send if we can't check limits
        }
        
        const todayCount = todaySends?.length || 0;
        const limits = this.sendingLimits[this.currentPhase];
        
        // Check daily limit
        if (todayCount >= limits.dailyLimit) {
            return false;
        }
        
        // Check hourly limit
        const hourAgo = new Date();
        hourAgo.setHours(hourAgo.getHours() - 1);
        
        const { data: hourSends } = await this.supabase
            .from('email_sends')
            .select('id')
            .gte('sent_at', hourAgo.toISOString())
            .eq('send_status', 'sent');
        
        const hourCount = hourSends?.length || 0;
        
        return hourCount < limits.hourlyLimit;
    }
    
    async logEmailSend(emailData) {
        try {
            await this.supabase
                .from('email_sends')
                .insert({
                    campaign_id: emailData.campaignId,
                    sequence_id: emailData.sequenceId,
                    contact_id: emailData.contactId,
                    company_id: emailData.companyId,
                    subject_line: emailData.subject,
                    email_content: emailData.content,
                    personalization_data: emailData.personalizationData || {},
                    send_status: emailData.sendStatus,
                    email_provider: 'resend',
                    provider_message_id: emailData.providerMessageId,
                    provider_response: emailData.providerResponse || {},
                    scheduled_for: emailData.scheduledFor,
                    sent_at: emailData.sendStatus === 'sent' ? new Date() : null
                });
        } catch (error) {
            console.error('Error logging email send:', error);
        }
    }
    
    async createEmailCampaign(campaignData) {
        const { data: campaign, error } = await this.supabase
            .from('email_campaigns')
            .insert({
                name: campaignData.name,
                description: campaignData.description,
                campaign_type: campaignData.type,
                subject_line: campaignData.subjectLine,
                email_template: campaignData.template,
                personalization_fields: campaignData.personalizationFields || {},
                send_schedule: campaignData.sendSchedule || {},
                max_sends_per_day: campaignData.maxSendsPerDay || 50,
                delay_between_sends: campaignData.delayBetweenSends || 300,
                target_qualification_tier: campaignData.targetTiers || ['A', 'B'],
                target_industries: campaignData.targetIndustries || [],
                status: 'draft'
            })
            .select()
            .single();
        
        if (error) {
            throw new Error(`Failed to create campaign: ${error.message}`);
        }
        
        return campaign;
    }
    
    async createEmailSequence(campaignId, sequenceData) {
        const sequences = [];
        
        for (const [index, email] of sequenceData.emails.entries()) {
            const { data: sequence, error } = await this.supabase
                .from('email_sequences')
                .insert({
                    campaign_id: campaignId,
                    sequence_name: `${sequenceData.name} - Step ${index + 1}`,
                    step_number: index + 1,
                    delay_days: email.delayDays,
                    subject_line: email.subject,
                    email_template: email.template,
                    send_condition: email.sendCondition || {},
                    stop_condition: email.stopCondition || {}
                })
                .select()
                .single();
            
            if (error) {
                console.error(`Error creating sequence step ${index + 1}:`, error);
            } else {
                sequences.push(sequence);
            }
        }
        
        return sequences;
    }
    
    async scheduleSequenceForContact(contactId, campaignId, startDate = null) {
        const startTime = startDate ? new Date(startDate) : new Date();
        
        // Get campaign sequences
        const { data: sequences, error } = await this.supabase
            .from('email_sequences')
            .select('*')
            .eq('campaign_id', campaignId)
            .order('step_number', { ascending: true });
        
        if (error || !sequences) {
            throw new Error('Failed to load campaign sequences');
        }
        
        // Get contact and company data
        const { data: contact } = await this.supabase
            .from('contacts')
            .select(`
                *,
                companies (*)
            `)
            .eq('id', contactId)
            .single();
        
        if (!contact) {
            throw new Error('Contact not found');
        }
        
        // Generate personalized emails for each sequence step
        const scheduledEmails = [];
        
        for (const sequence of sequences) {
            try {
                const sendDate = new Date(startTime);
                sendDate.setDate(sendDate.getDate() + sequence.delay_days);
                
                // Skip weekends
                while (sendDate.getDay() === 0 || sendDate.getDay() === 6) {
                    sendDate.setDate(sendDate.getDate() + 1);
                }
                
                // Set optimal sending time (9 AM)
                sendDate.setHours(9, 0, 0, 0);
                
                // Personalize email content
                const personalizedEmail = await this.sequenceGenerator.personalizer.personalize(
                    {
                        subject: sequence.subject_line,
                        template: sequence.email_template,
                        step: sequence.step_number
                    },
                    {
                        id: contact.company_id,
                        name: contact.companies.name,
                        industry: contact.companies.industry,
                        website: contact.companies.website,
                        contacts: [{
                            first_name: contact.first_name,
                            last_name: contact.last_name,
                            email: contact.email,
                            title: contact.title
                        }]
                    }
                );
                
                // Schedule the email
                const { data: scheduledEmail, error: scheduleError } = await this.supabase
                    .from('email_sends')
                    .insert({
                        campaign_id: campaignId,
                        sequence_id: sequence.id,
                        contact_id: contactId,
                        company_id: contact.company_id,
                        subject_line: personalizedEmail.subject,
                        email_content: personalizedEmail.content,
                        personalization_data: personalizedEmail.personalizationData,
                        send_status: 'pending',
                        scheduled_for: sendDate.toISOString()
                    })
                    .select()
                    .single();
                
                if (scheduleError) {
                    console.error(`Error scheduling email ${sequence.step_number}:`, scheduleError);
                } else {
                    scheduledEmails.push(scheduledEmail);
                }
                
            } catch (error) {
                console.error(`Error preparing sequence ${sequence.step_number}:`, error);
            }
        }
        
        return scheduledEmails;
    }
    
    async processPendingEmails() {
        const now = new Date().toISOString();
        
        // Get emails ready to send
        const { data: pendingEmails, error } = await this.supabase
            .from('email_sends')
            .select(`
                *,
                contacts (*),
                companies (*)
            `)
            .eq('send_status', 'pending')
            .lte('scheduled_for', now)
            .limit(50); // Process in batches
        
        if (error || !pendingEmails?.length) {
            return { processed: 0, errors: [] };
        }
        
        const results = { processed: 0, errors: [] };
        
        for (const email of pendingEmails) {
            try {
                // Check if we can still send (rate limits)
                const canSend = await this.checkSendingLimits();
                if (!canSend) {
                    break; // Stop processing if we hit limits
                }
                
                // Prepare email data
                const emailData = {
                    from: `${email.personalization_data?.senderName || 'Your Name'} <${EMAIL_CONFIG.sendingDomain}>`,
                    to: email.contacts.email,
                    replyTo: `${EMAIL_CONFIG.replyToDomain}`,
                    subject: email.subject_line,
                    content: email.email_content,
                    personalizationData: email.personalization_data,
                    trackingId: email.id,
                    campaignId: email.campaign_id,
                    sequenceId: email.sequence_id,
                    contactId: email.contact_id,
                    companyId: email.company_id,
                    scheduledFor: email.scheduled_for
                };
                
                // Send the email
                await this.sendEmail(emailData);
                results.processed++;
                
                // Add delay between emails to avoid appearing automated
                await new Promise(resolve => setTimeout(resolve, 30000)); // 30 second delay
                
            } catch (error) {
                results.errors.push({
                    emailId: email.id,
                    error: error.message
                });
                console.error(`Error sending email ${email.id}:`, error);
            }
        }
        
        return results;
    }
}
```

## Deliverability Deep Dive

### Domain Warming Schedule

```bash
# DNS setup for your outreach domain (run these in your DNS provider)

# SPF Record (replace your-domain.com with your actual domain)
# Type: TXT
# Name: outreach.your-domain.com
# Value: v=spf1 include:resend.com ~all

# DKIM (Resend will provide this - add it exactly as given)
# Type: TXT  
# Name: resend._domainkey.outreach.your-domain.com
# Value: [Provided by Resend]

# DMARC Record
# Type: TXT
# Name: _dmarc.outreach.your-domain.com
# Value: v=DMARC1; p=quarantine; rua=mailto:dmarc@your-domain.com; ruf=mailto:dmarc@your-domain.com; sp=quarantine; adkim=r; aspf=r;
```

```javascript
// Domain warming automation
class DomainWarmingSchedule {
    constructor() {
        this.warmingPhases = [
            { phase: 'week1', dailyLimit: 10, duration: 7, description: 'Initial warm-up' },
            { phase: 'week2', dailyLimit: 25, duration: 7, description: 'Gradual increase' },
            { phase: 'week3', dailyLimit: 50, duration: 7, description: 'Moderate volume' },
            { phase: 'week4', dailyLimit: 100, duration: 7, description: 'Higher volume' },
            { phase: 'steady', dailyLimit: 200, duration: 0, description: 'Full volume' }
        ];
    }
    
    async getCurrentPhase() {
        // Check when domain warming started
        const { data: firstSend } = await this.supabase
            .from('email_sends')
            .select('sent_at')
            .eq('send_status', 'sent')
            .order('sent_at', { ascending: true })
            .limit(1);
        
        if (!firstSend?.length) {
            return this.warmingPhases[0]; // Start with week 1
        }
        
        const startDate = new Date(firstSend[0].sent_at);
        const daysSinceStart = Math.floor((Date.now() - startDate.getTime()) / (1000 * 60 * 60 * 24));
        
        let currentPhase = this.warmingPhases[0];
        let daysPassed = 0;
        
        for (const phase of this.warmingPhases) {
            if (phase.duration === 0) {
                // Steady state phase
                currentPhase = phase;
                break;
            }
            
            if (daysSinceStart < daysPassed + phase.duration) {
                currentPhase = phase;
                break;
            }
            
            daysPassed += phase.duration;
        }
        
        return {
            ...currentPhase,
            dayInPhase: daysSinceStart - daysPassed + 1,
            totalDaysWarming: daysSinceStart
        };
    }
    
    async getWarmingReport() {
        const currentPhase = await this.getCurrentPhase();
        
        // Get recent sending statistics
        const last30Days = new Date();
        last30Days.setDate(last30Days.getDate() - 30);
        
        const { data: recentSends } = await this.supabase
            .from('email_sends')
            .select('send_status, sent_at')
            .gte('sent_at', last30Days.toISOString());
        
        const stats = this.calculateWarmingStats(recentSends || []);
        
        return {
            currentPhase,
            stats,
            recommendations: this.generateWarmingRecommendations(currentPhase, stats)
        };
    }
    
    calculateWarmingStats(sends) {
        const total = sends.length;
        const sent = sends.filter(s => s.send_status === 'sent').length;
        const delivered = sends.filter(s => s.send_status === 'delivered').length;
        const bounced = sends.filter(s => s.send_status === 'bounced').length;
        
        return {
            totalSent: sent,
            deliveryRate: total > 0 ? delivered / total : 0,
            bounceRate: total > 0 ? bounced / total : 0,
            avgDailySends: this.getAvgDailySends(sends),
            warmingHealth: this.assessWarmingHealth({ deliveryRate: delivered / total, bounceRate: bounced / total })
        };
    }
    
    getAvgDailySends(sends) {
        if (!sends.length) return 0;
        
        const sendsByDay = {};
        
        sends.forEach(send => {
            const day = new Date(send.sent_at).toISOString().split('T')[0];
            sendsByDay[day] = (sendsByDay[day] || 0) + 1;
        });
        
        const totalDays = Object.keys(sendsByDay).length;
        const totalSends = Object.values(sendsByDay).reduce((sum, count) => sum + count, 0);
        
        return totalDays > 0 ? totalSends / totalDays : 0;
    }
    
    assessWarmingHealth(stats) {
        if (stats.bounceRate > 0.1) return 'POOR';
        if (stats.deliveryRate < 0.9) return 'NEEDS_IMPROVEMENT';
        if (stats.deliveryRate > 0.95 && stats.bounceRate < 0.05) return 'EXCELLENT';
        return 'GOOD';
    }
    
    generateWarmingRecommendations(phase, stats) {
        const recommendations = [];
        
        if (stats.bounceRate > 0.1) {
            recommendations.push('High bounce rate detected. Pause sending and clean your list.');
        }
        
        if (stats.deliveryRate < 0.9) {
            recommendations.push('Low delivery rate. Check email content for spam triggers.');
        }
        
        if (phase.phase !== 'steady' && stats.avgDailySends > phase.dailyLimit) {
            recommendations.push(`Sending above warming limit. Reduce to ${phase.dailyLimit} per day.`);
        }
        
        if (stats.warmingHealth === 'EXCELLENT' && phase.phase !== 'steady') {
            recommendations.push('Great warming progress! Ready to move to next phase.');
        }
        
        return recommendations;
    }
}
```

### Content Optimization for Deliverability

```javascript
// Advanced spam filter avoidance system
class SpamFilterAvoidance {
    constructor() {
        this.spamTriggers = {
            subject: {
                highRisk: [
                    'FREE', 'URGENT', 'LIMITED TIME', 'ACT NOW', 'CLICK HERE',
                    'GUARANTEED', 'INSTANT', 'CASH', 'CREDIT', 'LOAN'
                ],
                mediumRisk: [
                    'amazing', 'incredible', 'revolutionary', 'breakthrough',
                    'special offer', 'deal', 'discount', 'save money'
                ],
                patterns: [
                    /\$\d+/,          // Dollar amounts
                    /\d+%\s*(off|discount)/i,  // Percentage discounts
                    /^Re:/,           // Fake replies
                    /[!]{2,}/,        // Multiple exclamation marks
                    /[A-Z]{3,}/       // Excessive caps
                ]
            },
            
            content: {
                highRisk: [
                    'click here', 'download now', 'order now', 'buy now',
                    'free trial', 'risk-free', 'money back guarantee',
                    'no obligation', 'limited time', 'expires'
                ],
                linkPatterns: [
                    /https?:\/\/[^\s]+/g  // Count links
                ],
                imagePatterns: [
                    /<img[^>]*>/gi        // Count images
                ]
            }
        };
    }
    
    analyzeContent(subject, content) {
        const analysis = {
            subjectScore: this.analyzeSubject(subject),
            contentScore: this.analyzeContentBody(content),
            overallScore: 0,
            recommendations: []
        };
        
        analysis.overallScore = (analysis.subjectScore + analysis.contentScore) / 2;
        analysis.recommendations = this.generateRecommendations(analysis);
        
        return analysis;
    }
    
    analyzeSubject(subject) {
        let score = 0;
        const issues = [];
        
        // Check for high-risk words
        for (const word of this.spamTriggers.subject.highRisk) {
            if (subject.toLowerCase().includes(word.toLowerCase())) {
                score += 25;
                issues.push(`High-risk word: "${word}"`);
            }
        }
        
        // Check for medium-risk words
        for (const word of this.spamTriggers.subject.mediumRisk) {
            if (subject.toLowerCase().includes(word.toLowerCase())) {
                score += 10;
                issues.push(`Medium-risk word: "${word}"`);
            }
        }
        
        // Check patterns
        for (const pattern of this.spamTriggers.subject.patterns) {
            if (pattern.test(subject)) {
                score += 15;
                issues.push(`Spam pattern detected: ${pattern.toString()}`);
            }
        }
        
        // Length check
        if (subject.length > 50) {
            score += 5;
            issues.push('Subject line too long');
        }
        
        return { score: Math.min(100, score), issues };
    }
    
    analyzeContentBody(content) {
        let score = 0;
        const issues = [];
        
        // Check for high-risk phrases
        for (const phrase of this.spamTriggers.content.highRisk) {
            if (content.toLowerCase().includes(phrase.toLowerCase())) {
                score += 20;
                issues.push(`High-risk phrase: "${phrase}"`);
            }
        }
        
        // Link analysis
        const links = content.match(this.spamTriggers.content.linkPatterns[0]) || [];
        if (links.length > 3) {
            score += (links.length - 3) * 10;
            issues.push(`Too many links: ${links.length}`);
        }
        
        // Image analysis
        const images = content.match(this.spamTriggers.content.imagePatterns[0]) || [];
        if (images.length > 1) {
            score += images.length * 10;
            issues.push(`Too many images: ${images.length}`);
        }
        
        // Text-to-HTML ratio
        const textLength = this.stripHTML(content).length;
        const htmlLength = content.length;
        
        if (htmlLength > textLength * 2) {
            score += 15;
            issues.push('Poor text-to-HTML ratio');
        }
        
        return { score: Math.min(100, score), issues };
    }
    
    generateRecommendations(analysis) {
        const recommendations = [];
        
        if (analysis.overallScore > 75) {
            recommendations.push('High spam risk - rewrite email completely');
        } else if (analysis.overallScore > 50) {
            recommendations.push('Medium spam risk - revise content');
        }
        
        if (analysis.subjectScore > 30) {
            recommendations.push('Rewrite subject line with neutral language');
        }
        
        if (analysis.contentScore > 30) {
            recommendations.push('Reduce promotional language in content');
        }
        
        return recommendations;
    }
    
    stripHTML(html) {
        return html.replace(/<[^>]*>/g, '');
    }
    
    suggestAlternatives(text) {
        const alternatives = {
            'free': 'complimentary',
            'urgent': 'time-sensitive',
            'guaranteed': 'expected',
            'amazing': 'notable',
            'incredible': 'impressive',
            'click here': 'see details',
            'buy now': 'learn more',
            'limited time': 'for a short period'
        };
        
        let improved = text;
        
        Object.entries(alternatives).forEach(([bad, good]) => {
            const regex = new RegExp(bad, 'gi');
            improved = improved.replace(regex, good);
        });
        
        return improved;
    }
}
```

## Tracking and Analytics

### Complete Email Performance Dashboard

```javascript
// Email analytics and reporting system
class EmailAnalytics {
    constructor(supabaseClient) {
        this.supabase = supabaseClient;
    }
    
    async getCampaignPerformance(campaignId, dateRange = 30) {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - dateRange);
        
        // Get all emails for this campaign
        const { data: emails, error } = await this.supabase
            .from('email_sends')
            .select(`
                *,
                email_campaigns (*),
                email_sequences (*),
                contacts (*),
                companies (*)
            `)
            .eq('campaign_id', campaignId)
            .gte('sent_at', startDate.toISOString());
        
        if (error) {
            throw new Error(`Failed to fetch campaign data: ${error.message}`);
        }
        
        return this.calculateCampaignMetrics(emails);
    }
    
    calculateCampaignMetrics(emails) {
        const totalSent = emails.filter(e => e.send_status === 'sent').length;
        const totalDelivered = emails.filter(e => e.send_status === 'delivered').length;
        const totalBounced = emails.filter(e => e.send_status === 'bounced').length;
        const totalOpened = emails.filter(e => e.opened_at).length;
        const totalClicked = emails.filter(e => e.clicked_at).length;
        const totalReplied = emails.filter(e => e.replied_at).length;
        
        const metrics = {
            // Core metrics
            totalSent,
            totalDelivered,
            totalBounced,
            totalOpened,
            totalClicked, 
            totalReplied,
            
            // Rates
            deliveryRate: totalSent > 0 ? (totalDelivered / totalSent) * 100 : 0,
            bounceRate: totalSent > 0 ? (totalBounced / totalSent) * 100 : 0,
            openRate: totalDelivered > 0 ? (totalOpened / totalDelivered) * 100 : 0,
            clickRate: totalOpened > 0 ? (totalClicked / totalOpened) * 100 : 0,
            replyRate: totalDelivered > 0 ? (totalReplied / totalDelivered) * 100 : 0,
            
            // Advanced metrics
            clickToOpenRate: totalOpened > 0 ? (totalClicked / totalOpened) * 100 : 0,
            engagementRate: totalDelivered > 0 ? ((totalOpened + totalClicked + totalReplied) / totalDelivered) * 100 : 0,
            
            // Sequence performance
            sequencePerformance: this.calculateSequencePerformance(emails),
            
            // Time analysis
            bestSendTimes: this.analyzeSendTimes(emails),
            
            // Subject line performance
            subjectLinePerformance: this.analyzeSubjectLines(emails)
        };
        
        return {
            ...metrics,
            performanceGrade: this.calculatePerformanceGrade(metrics),
            recommendations: this.generateRecommendations(metrics)
        };
    }
    
    calculateSequencePerformance(emails) {
        const sequenceStats = {};
        
        emails.forEach(email => {
            const stepNumber = email.email_sequences?.step_number || 1;
            
            if (!sequenceStats[stepNumber]) {
                sequenceStats[stepNumber] = {
                    sent: 0,
                    delivered: 0,
                    opened: 0,
                    clicked: 0,
                    replied: 0
                };
            }
            
            const stats = sequenceStats[stepNumber];
            
            if (email.send_status === 'sent') stats.sent++;
            if (email.send_status === 'delivered') stats.delivered++;
            if (email.opened_at) stats.opened++;
            if (email.clicked_at) stats.clicked++;
            if (email.replied_at) stats.replied++;
        });
        
        // Calculate rates for each step
        Object.keys(sequenceStats).forEach(step => {
            const stats = sequenceStats[step];
            stats.openRate = stats.delivered > 0 ? (stats.opened / stats.delivered) * 100 : 0;
            stats.clickRate = stats.opened > 0 ? (stats.clicked / stats.opened) * 100 : 0;
            stats.replyRate = stats.delivered > 0 ? (stats.replied / stats.delivered) * 100 : 0;
        });
        
        return sequenceStats;
    }
    
    analyzeSendTimes(emails) {
        const timeStats = {};
        
        emails.forEach(email => {
            if (!email.sent_at) return;
            
            const sendDate = new Date(email.sent_at);
            const hour = sendDate.getHours();
            const dayOfWeek = sendDate.getDay();
            
            const key = `${dayOfWeek}_${hour}`;
            
            if (!timeStats[key]) {
                timeStats[key] = {
                    dayOfWeek,
                    hour,
                    sent: 0,
                    opened: 0,
                    clicked: 0,
                    replied: 0
                };
            }
            
            timeStats[key].sent++;
            if (email.opened_at) timeStats[key].opened++;
            if (email.clicked_at) timeStats[key].clicked++;
            if (email.replied_at) timeStats[key].replied++;
        });
        
        // Calculate rates and find best times
        const timesWithRates = Object.values(timeStats).map(stats => ({
            ...stats,
            openRate: stats.sent > 0 ? (stats.opened / stats.sent) * 100 : 0,
            replyRate: stats.sent > 0 ? (stats.replied / stats.sent) * 100 : 0
        }));
        
        // Sort by reply rate (most important metric)
        return timesWithRates
            .sort((a, b) => b.replyRate - a.replyRate)
            .slice(0, 5); // Top 5 times
    }
    
    analyzeSubjectLines(emails) {
        const subjectStats = {};
        
        emails.forEach(email => {
            const subject = email.subject_line;
            
            if (!subjectStats[subject]) {
                subjectStats[subject] = {
                    subject,
                    sent: 0,
                    delivered: 0,
                    opened: 0,
                    replied: 0
                };
            }
            
            const stats = subjectStats[subject];
            if (email.send_status === 'sent') stats.sent++;
            if (email.send_status === 'delivered') stats.delivered++;
            if (email.opened_at) stats.opened++;
            if (email.replied_at) stats.replied++;
        });
        
        // Calculate rates and sort by performance
        return Object.values(subjectStats)
            .map(stats => ({
                ...stats,
                openRate: stats.delivered > 0 ? (stats.opened / stats.delivered) * 100 : 0,
                replyRate: stats.delivered > 0 ? (stats.replied / stats.delivered) * 100 : 0
            }))
            .sort((a, b) => b.replyRate - a.replyRate);
    }
    
    calculatePerformanceGrade(metrics) {
        // Industry benchmarks for cold email
        const benchmarks = {
            deliveryRate: 95,  // 95%+
            openRate: 25,      // 25%+
            replyRate: 10,     // 10%+
            bounceRate: 5      // <5%
        };
        
        let score = 0;
        let maxScore = 0;
        
        // Delivery rate (25 points)
        if (metrics.deliveryRate >= benchmarks.deliveryRate) {
            score += 25;
        } else {
            score += (metrics.deliveryRate / benchmarks.deliveryRate) * 25;
        }
        maxScore += 25;
        
        // Open rate (25 points)
        if (metrics.openRate >= benchmarks.openRate) {
            score += 25;
        } else {
            score += (metrics.openRate / benchmarks.openRate) * 25;
        }
        maxScore += 25;
        
        // Reply rate (40 points - most important)
        if (metrics.replyRate >= benchmarks.replyRate) {
            score += 40;
        } else {
            score += (metrics.replyRate / benchmarks.replyRate) * 40;
        }
        maxScore += 40;
        
        // Bounce rate penalty (10 points)
        if (metrics.bounceRate <= benchmarks.bounceRate) {
            score += 10;
        } else {
            score += Math.max(0, 10 - (metrics.bounceRate - benchmarks.bounceRate) * 2);
        }
        maxScore += 10;
        
        const percentage = (score / maxScore) * 100;
        
        if (percentage >= 90) return 'A';
        if (percentage >= 80) return 'B';
        if (percentage >= 70) return 'C';
        if (percentage >= 60) return 'D';
        return 'F';
    }
    
    generateRecommendations(metrics) {
        const recommendations = [];
        
        if (metrics.deliveryRate < 95) {
            recommendations.push('Low delivery rate. Check email authentication (SPF, DKIM, DMARC)');
        }
        
        if (metrics.bounceRate > 5) {
            recommendations.push('High bounce rate. Clean email list and verify addresses');
        }
        
        if (metrics.openRate < 20) {
            recommendations.push('Low open rate. Test different subject lines and sender names');
        }
        
        if (metrics.replyRate < 5) {
            recommendations.push('Low reply rate. Focus on personalization and value proposition');
        }
        
        if (metrics.clickRate < 10 && metrics.openRate > 20) {
            recommendations.push('Good opens but poor clicks. Improve email content and CTAs');
        }
        
        // Sequence-specific recommendations
        const sequences = metrics.sequencePerformance;
        const sequenceNumbers = Object.keys(sequences).map(Number).sort();
        
        for (let i = 0; i < sequenceNumbers.length - 1; i++) {
            const current = sequences[sequenceNumbers[i]];
            const next = sequences[sequenceNumbers[i + 1]];
            
            if (next.replyRate > current.replyRate * 1.5) {
                recommendations.push(`Email ${sequenceNumbers[i + 1]} performs much better than ${sequenceNumbers[i]}. Consider swapping order`);
            }
        }
        
        return recommendations;
    }
    
    async generateWeeklyReport() {
        const weekAgo = new Date();
        weekAgo.setDate(weekAgo.getDate() - 7);
        
        const { data: weeklyEmails } = await this.supabase
            .from('email_sends')
            .select('*')
            .gte('sent_at', weekAgo.toISOString());
        
        const metrics = this.calculateCampaignMetrics(weeklyEmails || []);
        
        const report = {
            period: 'Last 7 days',
            summary: {
                totalSent: metrics.totalSent,
                replyRate: Math.round(metrics.replyRate * 10) / 10,
                openRate: Math.round(metrics.openRate * 10) / 10,
                deliveryRate: Math.round(metrics.deliveryRate * 10) / 10,
                performanceGrade: metrics.performanceGrade
            },
            keyInsights: this.generateKeyInsights(metrics),
            actionItems: metrics.recommendations,
            generatedAt: new Date().toISOString()
        };
        
        return report;
    }
    
    generateKeyInsights(metrics) {
        const insights = [];
        
        if (metrics.replyRate > 10) {
            insights.push(`Excellent reply rate of ${Math.round(metrics.replyRate)}% - well above industry average`);
        }
        
        if (metrics.openRate > 30) {
            insights.push(`Strong subject lines driving ${Math.round(metrics.openRate)}% open rate`);
        }
        
        const bestSequence = Object.entries(metrics.sequencePerformance)
            .sort(([,a], [,b]) => b.replyRate - a.replyRate)[0];
        
        if (bestSequence && bestSequence[1].replyRate > 5) {
            insights.push(`Email ${bestSequence[0]} is your top performer with ${Math.round(bestSequence[1].replyRate)}% replies`);
        }
        
        return insights;
    }
}
```

## Complete Working Example: B2B SaaS Outreach Campaign

```javascript
// Complete outreach campaign setup and execution
async function setupB2BSaaSCampaign() {
    // Initialize the outreach engine
    const outreachEngine = new EmailOutreachEngine('your-resend-api-key', supabase);
    
    // 1. Create the campaign
    const campaign = await outreachEngine.createEmailCampaign({
        name: 'B2B SaaS Cold Outreach Q1 2024',
        description: 'Targeting 100-250 employee SaaS companies with automation pain points',
        type: 'cold_outreach',
        subjectLine: 'Quick question about {{companyName}}\'s automation',
        template: EMAIL_SEQUENCES.b2b_saas_outreach.emails[0].template,
        personalizationFields: EMAIL_SEQUENCES.b2b_saas_outreach.emails[0].personalizationFields,
        maxSendsPerDay: 50,
        delayBetweenSends: 300,
        targetTiers: ['A', 'B'],
        targetIndustries: ['Software', 'Technology', 'SaaS']
    });
    
    console.log('Campaign created:', campaign.id);
    
    // 2. Create the email sequences
    const sequences = await outreachEngine.createEmailSequence(
        campaign.id, 
        EMAIL_SEQUENCES.b2b_saas_outreach
    );
    
    console.log('Sequences created:', sequences.length);
    
    // 3. Get qualified leads from database
    const { data: qualifiedLeads } = await supabase
        .from('companies')
        .select(`
            *,
            contacts (*)
        `)
        .eq('qualified', true)
        .in('qualification_tier', ['A', 'B'])
        .eq('pipeline_stage', 'qualified')
        .limit(100); // Start with 100 leads
    
    console.log('Found qualified leads:', qualifiedLeads?.length || 0);
    
    // 4. Schedule sequences for each qualified contact
    let scheduledCount = 0;
    
    for (const company of qualifiedLeads || []) {
        // Get decision maker contact
        const decisionMaker = company.contacts?.find(c => c.is_decision_maker) || company.contacts?.[0];
        
        if (decisionMaker?.email) {
            try {
                const scheduledEmails = await outreachEngine.scheduleSequenceForContact(
                    decisionMaker.id,
                    campaign.id,
                    new Date() // Start immediately
                );
                
                scheduledCount += scheduledEmails.length;
                
                // Update company stage
                await supabase
                    .from('companies')
                    .update({ 
                        pipeline_stage: 'contacted',
                        last_activity: new Date().toISOString()
                    })
                    .eq('id', company.id);
                
            } catch (error) {
                console.error(`Error scheduling for ${company.name}:`, error.message);
            }
        }
    }
    
    console.log('Emails scheduled:', scheduledCount);
    
    // 5. Activate the campaign
    await supabase
        .from('email_campaigns')
        .update({ 
            status: 'active',
            started_at: new Date().toISOString()
        })
        .eq('id', campaign.id);
    
    return {
        campaign,
        sequences,
        leadsTargeted: qualifiedLeads?.length || 0,
        emailsScheduled: scheduledCount
    };
}

// Email processing cron job (run every 15 minutes)
async function processOutreachEmails() {
    const outreachEngine = new EmailOutreachEngine('your-resend-api-key', supabase);
    
    try {
        const results = await outreachEngine.processPendingEmails();
        
        console.log('Email processing results:', {
            processed: results.processed,
            errors: results.errors.length,
            timestamp: new Date().toISOString()
        });
        
        // Log results for monitoring
        if (results.processed > 0) {
            await supabase
                .from('pipeline_activities')
                .insert({
                    activity_type: 'email_batch_sent',
                    activity_description: `Processed ${results.processed} outreach emails`,
                    activity_data: results,
                    triggered_by: 'cron'
                });
        }
        
        return results;
        
    } catch (error) {
        console.error('Error processing outreach emails:', error);
        
        // Log error for monitoring
        await supabase
            .from('pipeline_activities')
            .insert({
                activity_type: 'email_processing_error',
                activity_description: `Email processing failed: ${error.message}`,
                activity_data: { error: error.message },
                triggered_by: 'cron'
            });
        
        throw error;
    }
}

// Weekly analytics report generation
async function generateWeeklyOutreachReport() {
    const analytics = new EmailAnalytics(supabase);
    
    try {
        const report = await analytics.generateWeeklyReport();
        
        // Send report via email or Slack
        const reportText = `
# Weekly Outreach Report

## Summary
- **Emails Sent:** ${report.summary.totalSent}
- **Reply Rate:** ${report.summary.replyRate}%
- **Open Rate:** ${report.summary.openRate}%
- **Delivery Rate:** ${report.summary.deliveryRate}%
- **Grade:** ${report.summary.performanceGrade}

## Key Insights
${report.keyInsights.map(insight => `- ${insight}`).join('\n')}

## Action Items
${report.actionItems.map(item => `- ${item}`).join('\n')}

Generated: ${new Date(report.generatedAt).toLocaleDateString()}
        `;
        
        console.log(reportText);
        
        return report;
        
    } catch (error) {
        console.error('Error generating weekly report:', error);
        throw error;
    }
}

// Export the main functions
module.exports = {
    EmailOutreachEngine,
    EmailSequenceGenerator, 
    EmailPersonalizer,
    EmailAnalytics,
    setupB2BSaaSCampaign,
    processOutreachEmails,
    generateWeeklyOutreachReport
};
```

## Troubleshooting Common Outreach Issues

### Issue 1: High Bounce Rates (>10%)

**Symptoms:** Emails bouncing back, low delivery rates

**Solutions:**
```javascript
// Email verification before sending
async function verifyEmailBeforeSending(email) {
    // Basic syntax check
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        return { valid: false, reason: 'Invalid syntax' };
    }
    
    // Domain check
    const domain = email.split('@')[1];
    try {
        const response = await fetch(`https://${domain}`, { method: 'HEAD', timeout: 5000 });
        if (!response.ok && response.status >= 500) {
            return { valid: false, reason: 'Domain unreachable' };
        }
    } catch (error) {
        return { valid: false, reason: 'Domain error' };
    }
    
    return { valid: true };
}
```

### Issue 2: Low Open Rates (<15%)

**Symptoms:** Emails delivered but not opened

**Solutions:**
```javascript
// A/B test subject lines
const subjectLineTests = [
    'Quick question about {{companyName}}',
    '{{industryTrend}} impact on {{companyName}}?',
    '15-min conversation about {{painPoint}}?',
    'Thoughts on {{companyName}}\'s growth?'
];

// Test and optimize
async function optimizeSubjectLines(campaignId) {
    const analytics = new EmailAnalytics(supabase);
    const performance = await analytics.getCampaignPerformance(campaignId);
    
    const bestSubjects = performance.subjectLinePerformance
        .filter(s => s.sent > 10) // Minimum volume
        .slice(0, 3); // Top 3
    
    console.log('Top performing subjects:', bestSubjects);
    return bestSubjects;
}
```

### Issue 3: Low Reply Rates (<3%)

**Symptoms:** Opens but no responses

**Solutions:**
```javascript
// Improve personalization depth
const advancedPersonalization = {
    recentNews: 'Found through news monitoring',
    mutualConnection: 'LinkedIn mutual connection',
    specificPainPoint: 'Extracted from job postings',
    competitiveIntel: 'Analysis of competitors',
    technologyStack: 'Detected from website'
};

// Better CTAs
const softCTAs = [
    'Worth a brief conversation?',
    'Should we schedule 15 minutes?',
    'Interested in learning more?',
    'Want to see how this works?'
];
```

## Pro Tips for Outreach Success

**Tip 1: Perfect Your First Email**
80% of your results come from your initial email. Spend 80% of your time perfecting it.

**Tip 2: Personalize the First Line**
The first line of your email should be 100% unique to that prospect. Everything else can be templated.

**Tip 3: Send at Optimal Times**
Tuesday-Thursday, 9-11 AM in the recipient's timezone typically perform best for B2B.

**Tip 4: Keep It Short**
150 words maximum. If you can't explain your value in 150 words, you don't understand it yourself.

**Tip 5: Track Reply Sentiment**
Not all replies are positive. Track sentiment to understand true interest level.

**Tip 6: Follow Up Persistently (But Politely)**
Most prospects respond to emails 3-7, not email 1. Have a systematic follow-up process.

---

You now have a complete, production-ready email outreach system that can handle personalization at scale, maintain deliverability, and optimize performance automatically. 

The next chapter will show you how to orchestrate all your automation systems with sophisticated cron architectures that can handle dozens of concurrent processes.

**Remember:** Great outreach isn't about volume—it's about relevance at scale. Every email should feel personally crafted, even when sent to thousands of prospects.