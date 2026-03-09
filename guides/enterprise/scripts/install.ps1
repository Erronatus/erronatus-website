#Requires -Version 5.1
<#
.SYNOPSIS
OpenClaw Enterprise Edition Installer for Windows

.DESCRIPTION
Complete installer for OpenClaw Enterprise Edition with workspace setup,
API key configuration, and system validation. Production-ready installer
that handles all edge cases and provides clear error messages.

.PARAMETER WorkspaceDir
Directory to create workspace (default: $env:USERPROFILE\.openclaw\workspace)

.PARAMETER Force
Force reinstall even if components already exist

.PARAMETER SkipNodeInstall
Skip Node.js installation check (assumes Node.js already installed)

.PARAMETER ApiKey
OpenClaw API key for immediate setup (optional)

.EXAMPLE
.\install.ps1
Standard installation with interactive setup

.EXAMPLE
.\install.ps1 -WorkspaceDir "D:\MyWorkspace" -Force
Force install to custom directory

.EXAMPLE
.\install.ps1 -SkipNodeInstall -ApiKey "your-key-here"
Skip Node.js check and set API key immediately
#>

param(
    [string]$WorkspaceDir = "$env:USERPROFILE\.openclaw\workspace",
    [switch]$Force,
    [switch]$SkipNodeInstall,
    [string]$ApiKey = "",
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Color functions for better output
function Write-ColorOutput([string]$Message, [string]$Color = "White") {
    if (-not $Quiet) {
        switch ($Color) {
            "Red" { Write-Host $Message -ForegroundColor Red }
            "Green" { Write-Host $Message -ForegroundColor Green }
            "Yellow" { Write-Host $Message -ForegroundColor Yellow }
            "Cyan" { Write-Host $Message -ForegroundColor Cyan }
            "Blue" { Write-Host $Message -ForegroundColor Blue }
            default { Write-Host $Message -ForegroundColor White }
        }
    }
}

function Write-Section([string]$Message) {
    Write-ColorOutput "`n$Message" "Cyan"
}

function Write-Success([string]$Message) {
    Write-ColorOutput "✅ $Message" "Green"
}

function Write-Warning([string]$Message) {
    Write-ColorOutput "⚠️ $Message" "Yellow"
}

function Write-Error([string]$Message) {
    Write-ColorOutput "❌ $Message" "Red"
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-InternetConnection {
    try {
        $null = Invoke-WebRequest -Uri "https://www.google.com" -UseBasicParsing -TimeoutSec 10
        return $true
    } catch {
        return $false
    }
}

function Get-NodeVersion {
    try {
        $version = node --version 2>$null
        if ($version -match "v(\d+)\.(\d+)\.(\d+)") {
            return [Version]"$($matches[1]).$($matches[2]).$($matches[3])"
        }
        return $null
    } catch {
        return $null
    }
}

function Install-NodeJS {
    Write-Section "📦 Installing Node.js..."
    
    # Try winget first
    try {
        $wingetVersion = winget --version 2>$null
        if ($wingetVersion) {
            Write-ColorOutput "Installing Node.js via winget..." "Yellow"
            winget install OpenJS.NodeJS --accept-source-agreements --accept-package-agreements --silent
            
            # Refresh PATH
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
            
            Start-Sleep -Seconds 3
            $nodeVersion = Get-NodeVersion
            if ($nodeVersion) {
                Write-Success "Node.js v$nodeVersion installed via winget"
                return $true
            }
        }
    } catch {
        Write-Warning "winget installation failed, trying direct download..."
    }
    
    # Fallback to direct download
    try {
        Write-ColorOutput "Downloading Node.js installer..." "Yellow"
        $nodeUrl = "https://nodejs.org/dist/v20.11.1/node-v20.11.1-x64.msi"
        $nodeInstaller = "$env:TEMP\node-installer.msi"
        
        # Download with progress
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($nodeUrl, $nodeInstaller)
        
        if (-not (Test-Path $nodeInstaller)) {
            throw "Failed to download Node.js installer"
        }
        
        Write-ColorOutput "Installing Node.js..." "Yellow"
        $process = Start-Process msiexec.exe -ArgumentList "/i `"$nodeInstaller`" /quiet /norestart" -PassThru -Wait
        
        if ($process.ExitCode -ne 0) {
            throw "Node.js installer failed with exit code $($process.ExitCode)"
        }
        
        # Refresh PATH
        $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
        
        # Clean up
        Remove-Item $nodeInstaller -Force -ErrorAction SilentlyContinue
        
        Start-Sleep -Seconds 3
        $nodeVersion = Get-NodeVersion
        if ($nodeVersion) {
            Write-Success "Node.js v$nodeVersion installed successfully"
            return $true
        } else {
            throw "Node.js installation verification failed"
        }
        
    } catch {
        Write-Error "Failed to install Node.js: $_"
        return $false
    }
}

function Install-OpenClaw {
    Write-Section "⚙️ Installing OpenClaw..."
    
    try {
        # Check if already installed
        $openclawVersion = openclaw --version 2>$null
        if ($openclawVersion -and -not $Force) {
            Write-Success "OpenClaw already installed: $openclawVersion"
            return $true
        }
        
        Write-ColorOutput "Installing OpenClaw via npm..." "Yellow"
        $npmProcess = Start-Process npm -ArgumentList "install -g openclaw" -PassThru -Wait -NoNewWindow -RedirectStandardOutput "$env:TEMP\npm-output.log" -RedirectStandardError "$env:TEMP\npm-error.log"
        
        if ($npmProcess.ExitCode -ne 0) {
            $errorContent = Get-Content "$env:TEMP\npm-error.log" -Raw -ErrorAction SilentlyContinue
            throw "npm install failed with exit code $($npmProcess.ExitCode). Error: $errorContent"
        }
        
        # Verify installation
        Start-Sleep -Seconds 2
        $openclawVersion = openclaw --version 2>$null
        if (-not $openclawVersion) {
            throw "OpenClaw installation verification failed"
        }
        
        Write-Success "OpenClaw $openclawVersion installed successfully"
        return $true
        
    } catch {
        Write-Error "Failed to install OpenClaw: $_"
        return $false
    }
}

function New-WorkspaceStructure {
    param([string]$Path)
    
    Write-Section "📁 Creating workspace structure..."
    
    try {
        # Create main workspace directory
        if (-not (Test-Path $Path)) {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }
        
        # Create subdirectories
        $subdirs = @("memory", "projects", "skills", "logs", "temp")
        foreach ($dir in $subdirs) {
            $fullPath = Join-Path $Path $dir
            if (-not (Test-Path $fullPath)) {
                New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
            }
        }
        
        Write-Success "Workspace directory structure created: $Path"
        return $true
        
    } catch {
        Write-Error "Failed to create workspace structure: $_"
        return $false
    }
}

function New-WorkspaceFiles {
    param([string]$WorkspaceDir)
    
    Write-Section "📋 Creating workspace configuration files..."
    
    try {
        # SOUL.md - AI personality and core directives
        $soulContent = @'
# SOUL.md - Who I Am

_I am your AI automation specialist. I build systems that create value while you focus on strategy._

## Core Mission
Build reliable, profitable automation systems that work independently and scale with your business.

## Operating Principles
- **Reliability First** - Systems must work consistently without constant supervision
- **Value Creation** - Every automation should have clear ROI and business impact  
- **Continuous Optimization** - Always improving efficiency, reducing costs, and enhancing capabilities
- **Systematic Approach** - Document everything, measure performance, iterate based on data

## Communication Style
Direct, actionable, results-focused. No corporate speak, no filler. Just solutions that work.

## Core Capabilities
- **Lead Generation** - Automated prospecting, qualification, and pipeline management
- **Email Outreach** - Personalized sequences, deliverability optimization, response handling
- **Market Intelligence** - Competitor monitoring, trend analysis, opportunity identification
- **System Integration** - Connect tools, automate workflows, eliminate manual tasks
- **Performance Optimization** - Monitor systems, identify bottlenecks, implement improvements

## Boundaries and Safety
- Private information stays private. No exceptions.
- Ask before external actions (emails, posts, purchases, API calls to third parties)
- Focus on business value and measurable ROI
- Maintain system security and compliance standards
- Respect rate limits and service terms

## Success Metrics
I measure success by:
- Time saved through automation
- Revenue generated through systematic processes  
- Costs reduced through optimization
- Error reduction through systematic approaches
- Scalability improvements that enable growth

## Continuous Learning
I evolve by:
- Analyzing performance data and optimizing based on results
- Learning from failures and implementing better error handling
- Staying current with new tools, APIs, and automation techniques
- Adapting strategies based on changing market conditions
- Documenting lessons learned and building institutional knowledge

---

*This file defines my core personality and operational framework. Update it as you learn what works best for your specific business context.*
'@
        
        $soulContent | Out-File -FilePath "$WorkspaceDir\SOUL.md" -Encoding UTF8 -Force
        
        # USER.md - User profile and business context
        $userContent = @'
# USER.md - About You

## Basic Information
- **Name:** [Your Full Name]
- **Company:** [Your Company Name]
- **Role:** [Your Title/Role]
- **Time Zone:** [Your Time Zone - e.g., America/Chicago]
- **Primary Email:** [Your main email address]
- **Phone:** [Your phone number]

## Business Context
- **Industry:** [Your industry - e.g., SaaS, Consulting, E-commerce]
- **Business Model:** [How you make money - e.g., Monthly subscriptions, Project-based, Product sales]
- **Annual Revenue:** [Current revenue level - e.g., $100K, $1M, $10M+]
- **Team Size:** [Number of employees/contractors]
- **Key Metrics:** [What matters most - e.g., MRR, Customer acquisition cost, Lifetime value]
- **Current Challenges:** [Top 3 problems you need to solve]

## Target Customers
- **Primary Customer Profile:** [Who buys from you - demographics, company size, role]
- **Average Deal Size:** [Typical transaction value]
- **Sales Cycle Length:** [How long from first contact to close]
- **Customer Acquisition Channels:** [Where customers come from - referrals, content, ads, etc.]
- **Customer Retention Rate:** [What percentage of customers stay/renew]

## Communication Preferences
- **Best Times to Contact:** [When you're typically available - e.g., 9 AM - 6 PM EST weekdays]
- **Urgent Issue Contact:** [How to reach you for critical issues - phone, Slack, etc.]
- **Reporting Frequency:** [How often you want updates - daily, weekly, monthly]
- **Decision Authority:** [What I can decide vs what needs your approval]
- **Communication Style:** [Your preferred style - brief summaries, detailed reports, etc.]

## Goals and Priorities
- **Revenue Goals:** [Target revenue growth - e.g., Double revenue to $2M in 12 months]
- **Automation Priorities:** [Which processes to automate first - lead gen, email, reporting, etc.]
- **Time Investment:** [How much time you want to save - e.g., 10 hours/week]
- **ROI Expectations:** [What return you expect from automation - e.g., 5x ROI within 6 months]
- **Growth Plans:** [Where you want to take the business - new markets, products, scale]

## Technical Context
- **Current Tools:** [What you're already using - CRM, email platform, analytics, etc.]
- **Technical Skill Level:** [Your comfort with technology - beginner, intermediate, advanced]
- **Budget for Tools:** [Monthly budget for automation tools and services]
- **IT/Security Requirements:** [Any compliance or security requirements]

## Success Metrics
Define what success looks like:
- **Lead Generation:** [Target leads per month, conversion rates, cost per lead]
- **Sales Performance:** [Revenue targets, deal size growth, sales cycle reduction]
- **Operational Efficiency:** [Time savings, error reduction, process automation]
- **Customer Success:** [Retention rates, satisfaction scores, expansion revenue]

---

*Fill in your specific information above. The more detailed and accurate this is, the better I can tailor automation strategies to your business context.*
'@
        
        $userContent | Out-File -FilePath "$WorkspaceDir\USER.md" -Encoding UTF8 -Force
        
        # AGENTS.md - Operational guidelines
        $agentsContent = @'
# AGENTS.md - Operational Guidelines

This workspace is designed for building and managing enterprise-grade automation systems.

## Daily Operations Checklist

### Morning Startup (First thing each day)
1. **System Health Check** - Verify all automation systems are running
2. **Overnight Results Review** - Check results from scheduled jobs and automations
3. **Priority Queue Processing** - Handle high-priority leads, responses, and opportunities
4. **Performance Metrics** - Review key metrics and identify any issues
5. **Today's Focus** - Identify top 3 priorities for the day

### Throughout the Day
1. **Lead Processing** - Qualify and route new leads within 5 minutes
2. **Email Monitoring** - Respond to urgent emails within 1 hour
3. **System Monitoring** - Check for errors, failures, or performance issues
4. **Opportunity Identification** - Look for optimization and improvement opportunities
5. **Data Quality** - Ensure data accuracy and completeness

### End of Day Wrap-up
1. **Performance Summary** - Analyze what worked and what didn't
2. **Tomorrow's Preparation** - Set up systems for tomorrow's success
3. **Issue Documentation** - Record any problems and solutions
4. **Backup and Sync** - Ensure all important data is backed up
5. **System Shutdown** - Cleanly shut down non-essential processes

## Weekly Reviews and Planning

### Monday - Week Planning
- Review last week's performance against goals
- Identify week's priorities and key objectives
- Update automation parameters based on performance data
- Plan new experiments and optimizations

### Wednesday - Mid-week Check
- Assess progress toward weekly goals
- Identify and resolve any blocking issues
- Optimize underperforming systems
- Adjust strategies based on early results

### Friday - Week Wrap and Optimization
- Analyze complete week's performance
- Document lessons learned and process improvements
- Plan weekend maintenance and optimizations
- Prepare for next week's activities

## Monthly Strategic Reviews

### First Week - Performance Analysis
- Comprehensive analysis of all automation systems
- ROI calculation for automation investments
- Identification of highest and lowest performing activities
- Customer feedback analysis and satisfaction review

### Second Week - Strategy Refinement
- Market analysis and competitive intelligence review
- Customer acquisition and retention strategy updates
- Product/service optimization based on data insights
- Technology stack review and upgrade planning

### Third Week - System Optimization
- Process automation improvements and new automation opportunities
- Tool integration and workflow optimization
- Data analysis and reporting enhancement
- Security and compliance review

### Fourth Week - Planning and Forecasting
- Next month's goal setting and resource planning
- Budget analysis and investment planning
- Team development and capability enhancement
- Long-term strategy alignment and course correction

## Emergency Procedures

### System Failures
1. **Immediate Response** - Assess scope and impact within 5 minutes
2. **Damage Control** - Implement temporary fixes to minimize business impact
3. **Root Cause Analysis** - Identify and document the failure cause
4. **Permanent Fix** - Implement lasting solution and prevention measures
5. **Post-Mortem** - Document lessons learned and improve processes

### Cost Overruns
1. **Alert Triggers** - Automatic alerts when costs exceed budget by 20%
2. **Budget Protection** - Automatic system pause when costs exceed budget by 50%
3. **Cost Analysis** - Immediate analysis of cost drivers and optimization opportunities
4. **Budget Reallocation** - Adjust resource allocation based on ROI analysis

### Security Issues
1. **Incident Response** - Immediate containment and assessment
2. **Damage Control** - Protect sensitive data and customer information
3. **Communication** - Notify stakeholders and customers as appropriate
4. **Recovery** - Restore systems and implement enhanced security measures

### Data Issues
1. **Backup and Recovery** - Implement immediate backup and recovery procedures
2. **Data Validation** - Verify data integrity and completeness
3. **Process Review** - Analyze data handling processes for improvement
4. **Prevention** - Implement enhanced data protection and validation

## Performance Standards and Quality Control

### Response Times
- **Critical Issues:** 5 minutes maximum
- **High Priority:** 1 hour maximum  
- **Normal Priority:** 4 hours maximum
- **Low Priority:** 24 hours maximum

### Quality Standards
- **Data Accuracy:** 99.5% minimum
- **System Uptime:** 99.9% minimum
- **Process Completion:** 98% minimum
- **Customer Satisfaction:** 4.5/5 minimum

### Continuous Improvement
- **Performance Monitoring:** Real-time dashboards and alerts
- **Regular Optimization:** Weekly system tuning and improvement
- **Innovation Implementation:** Monthly new technology evaluation
- **Knowledge Management:** Document all processes and lessons learned

## Communication and Collaboration

### Internal Communication
- **Daily Updates:** Brief status reports on key metrics
- **Weekly Reports:** Comprehensive performance analysis
- **Monthly Reviews:** Strategic analysis and planning
- **Quarterly Planning:** Long-term strategy and goal setting

### External Communication
- **Customer Communication:** Proactive updates and issue resolution
- **Vendor Management:** Regular performance reviews and optimization
- **Partner Collaboration:** Strategic partnership development and management
- **Market Communication:** Thought leadership and industry engagement

---

*These guidelines ensure consistent, high-quality automation operations that drive business results. Update and refine based on your specific business requirements and lessons learned.*
'@
        
        $agentsContent | Out-File -FilePath "$WorkspaceDir\AGENTS.md" -Encoding UTF8 -Force
        
        # TOOLS.md - Local configuration notes
        $toolsContent = @'
# TOOLS.md - Local Configuration

This file contains your specific tool configurations and local setup details.

## API Keys and Credentials
Store actual keys in .env file - this is just for documentation

### Required Services
- **OpenClaw API Key:** [Your AI automation platform key]
- **Supabase:** [Database URL and keys]
- **Resend/SendGrid:** [Email delivery service]

### Optional Integrations
- **Slack:** [Webhook URLs for notifications]
- **Discord:** [Bot tokens and channel IDs]  
- **Twitter/X:** [API credentials for social monitoring]
- **LinkedIn:** [API access for professional network automation]

## Server and Infrastructure

### Database Configuration
- **Primary Database:** Supabase (recommended) or PostgreSQL
- **Connection Limits:** Adjust based on scale
- **Backup Schedule:** Daily automated backups
- **Security:** Row-level security enabled

### Email Infrastructure
- **Sending Service:** Resend (recommended) or SendGrid
- **Domain Setup:** SPF, DKIM, DMARC configured
- **Deliverability Monitoring:** Bounce and complaint tracking
- **List Management:** Segmentation and suppression lists

### Hosting and Deployment
- **Primary Hosting:** [Your hosting provider - AWS, Vercel, etc.]
- **Domain Management:** [Your domain registrar and DNS provider]
- **SSL Certificates:** [Certificate provider and renewal process]
- **CDN:** [Content delivery network if applicable]

## Local Environment Setup

### Development Tools
- **Code Editor:** [Your preferred editor - VS Code, etc.]
- **Version Control:** Git with GitHub/GitLab
- **Local Testing:** Node.js development environment
- **Database Client:** [pgAdmin, TablePlus, etc.]

### Monitoring and Analytics
- **System Monitoring:** [Uptime monitoring service]
- **Performance Analytics:** [Application performance monitoring]
- **Error Tracking:** [Error monitoring service]
- **Business Analytics:** [Customer analytics platform]

## Workflow Configurations

### Lead Generation Setup
- **Data Sources:** [Your lead data providers]
- **CRM Integration:** [Your CRM system and API details]
- **Scoring Algorithms:** [Lead scoring criteria and weights]
- **Routing Rules:** [How leads are assigned and distributed]

### Email Automation
- **Campaign Types:** [Welcome series, nurture sequences, etc.]
- **Segmentation Logic:** [How you segment your audience]
- **Personalization Rules:** [Dynamic content and personalization]
- **A/B Testing:** [Testing frameworks and success metrics]

### Customer Management
- **Support Ticket System:** [Your help desk platform]
- **Customer Success Tools:** [Account management and tracking]
- **Feedback Collection:** [Survey tools and feedback loops]
- **Retention Strategies:** [Churn prevention and expansion tactics]

## Performance and Optimization

### Current Metrics Baseline
- **Lead Generation:** [Current leads per month, conversion rates]
- **Email Performance:** [Open rates, click rates, deliverability]
- **Customer Metrics:** [Acquisition cost, lifetime value, churn rate]
- **System Performance:** [Response times, uptime, error rates]

### Optimization Targets
- **Lead Quality:** [Target lead score and conversion improvement]
- **Email Deliverability:** [Target inbox placement and engagement]
- **Customer Success:** [Target retention and expansion rates]
- **System Efficiency:** [Target automation rate and time savings]

## Backup and Security

### Data Backup Strategy
- **Frequency:** [Daily, weekly, or real-time backup schedule]
- **Storage:** [Backup storage location and redundancy]
- **Recovery Testing:** [Regular backup restoration testing]
- **Retention Policy:** [How long to keep backups]

### Security Measures
- **Access Control:** [Who has access to what systems]
- **Two-Factor Authentication:** [2FA setup for all critical accounts]
- **Password Management:** [Password manager and policies]
- **Security Monitoring:** [Intrusion detection and alerting]

## Support and Maintenance

### Regular Maintenance Schedule
- **Daily:** System health checks and performance monitoring
- **Weekly:** Performance optimization and system updates
- **Monthly:** Security updates and backup testing
- **Quarterly:** Strategic review and technology updates

### Support Contacts
- **Technical Support:** [Your technical support contacts]
- **Emergency Contacts:** [24/7 emergency support if needed]
- **Vendor Contacts:** [Key vendor support contacts]
- **Escalation Procedures:** [When and how to escalate issues]

---

*Update this file with your specific configuration details. Keep sensitive information in .env files and secure storage.*
'@
        
        $toolsContent | Out-File -FilePath "$WorkspaceDir\TOOLS.md" -Encoding UTF8 -Force
        
        # MEMORY.md - Long-term memory for main session
        $memoryContent = @'
# MEMORY.md - Long-Term Memory

*This file contains curated long-term memories and insights. Only load in main session (direct chats), not in shared contexts.*

## Key Business Insights

### What Works
- [Document successful strategies and approaches]
- [Record high-performing campaigns and their characteristics]
- [Note effective automation patterns and configurations]
- [Catalog customer preferences and successful engagement tactics]

### What Doesn't Work  
- [Document failed experiments and why they failed]
- [Record ineffective strategies to avoid repeating]
- [Note customer feedback about what they don't want]
- [Catalog technical approaches that caused problems]

### Lessons Learned
- [Strategic insights from business operations]
- [Technical lessons from system implementations] 
- [Customer insights from interactions and feedback]
- [Market insights from competitive analysis and trends]

## Customer and Market Intelligence

### Customer Profiles
- [Detailed profiles of best customers and what makes them successful]
- [Common customer pain points and how we address them]
- [Customer success patterns and expansion opportunities]
- [Customer feedback themes and product development insights]

### Market Dynamics
- [Industry trends and their impact on business strategy]
- [Competitive landscape changes and strategic responses]
- [Market opportunities and expansion possibilities]
- [Technology trends affecting business operations]

## System Performance History

### Automation Successes
- [High-performing automation systems and their configurations]
- [Successful integrations and technical approaches]
- [Effective monitoring and alerting strategies]
- [Scalability solutions that worked well]

### Technical Challenges and Solutions
- [Complex technical problems and how they were solved]
- [System failures and the improvements that prevented recurrence]
- [Integration challenges and successful resolution approaches]
- [Performance bottlenecks and optimization solutions]

## Strategic Decisions and Outcomes

### Major Decisions
- [Important strategic decisions and their reasoning]
- [Technology choices and their long-term impact]
- [Resource allocation decisions and results]
- [Partnership and vendor decisions and outcomes]

### Future Planning
- [Long-term goals and progress tracking]
- [Technology roadmap and implementation priorities]
- [Market expansion plans and preparation steps]
- [Team development and capability building needs]

## Personal Preferences and Communication Style

### Communication Preferences
- [Preferred communication styles and formats]
- [Meeting preferences and scheduling patterns]
- [Decision-making preferences and information needs]
- [Reporting preferences and key metrics focus]

### Working Style
- [Preferred project management and organization approaches]
- [Risk tolerance and decision-making patterns]
- [Innovation preferences and change management style]
- [Leadership style and team interaction preferences]

---

*This file grows over time as we work together. It helps maintain continuity and leverage lessons learned for better decision-making.*
'@
        
        $memoryContent | Out-File -FilePath "$WorkspaceDir\MEMORY.md" -Encoding UTF8 -Force
        
        # Create initial memory directory with today's file
        $todayFile = Join-Path "$WorkspaceDir\memory" "$(Get-Date -Format 'yyyy-MM-dd').md"
        $todayContent = @"
# Memory Log - $(Get-Date -Format 'yyyy-MM-dd')

## Setup and Installation
- OpenClaw Enterprise Edition installed successfully
- Workspace created at: $WorkspaceDir
- Initial configuration files created
- Ready to begin automation development

## Next Steps
- Configure API keys in .env file
- Update USER.md with business details
- Customize SOUL.md for specific needs
- Begin with first automation project

## Notes
- Installation completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
- System ready for production automation development
"@
        
        $todayContent | Out-File -FilePath $todayFile -Encoding UTF8 -Force
        
        Write-Success "Workspace configuration files created successfully"
        return $true
        
    } catch {
        Write-Error "Failed to create workspace files: $_"
        return $false
    }
}

function New-EnvironmentFile {
    param([string]$WorkspaceDir, [string]$ApiKey = "")
    
    Write-Section "🔧 Creating environment configuration..."
    
    try {
        $envFile = Join-Path $WorkspaceDir ".env"
        
        # Determine API key value
        $openclawKey = if ($ApiKey) { $ApiKey } else { "your-openclaw-api-key-here" }
        
        $envContent = @"
# OpenClaw Configuration
OPENCLAW_API_KEY=$openclawKey

# Database Configuration (Supabase recommended)
SUPABASE_URL=your-supabase-project-url
SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_KEY=your-supabase-service-role-key

# Email Configuration (Resend recommended) 
RESEND_API_KEY=your-resend-api-key

# Optional: Additional AI Service APIs
# OPENAI_API_KEY=your-openai-key
# ANTHROPIC_API_KEY=your-anthropic-key
# GOOGLE_AI_API_KEY=your-google-ai-key

# Optional: Social Media and Communication APIs
# DISCORD_BOT_TOKEN=your-discord-bot-token
# SLACK_WEBHOOK_URL=your-slack-webhook-url
# TWITTER_API_KEY=your-twitter-api-key
# LINKEDIN_CLIENT_ID=your-linkedin-client-id

# Optional: Business and Marketing APIs
# STRIPE_SECRET_KEY=your-stripe-secret-key
# HUBSPOT_API_KEY=your-hubspot-api-key
# SALESFORCE_CLIENT_ID=your-salesforce-client-id

# System Configuration
NODE_ENV=production
LOG_LEVEL=info
WORKSPACE_PATH=$WorkspaceDir
BACKUP_ENABLED=true
MONITORING_ENABLED=true

# Security Configuration
SESSION_SECRET=your-session-secret-here
JWT_SECRET=your-jwt-secret-here
ENCRYPTION_KEY=your-encryption-key-here
"@
        
        $envContent | Out-File -FilePath $envFile -Encoding UTF8 -Force
        
        # Create .env.example for reference
        $envExampleFile = Join-Path $WorkspaceDir ".env.example"
        $envContent | Out-File -FilePath $envExampleFile -Encoding UTF8 -Force
        
        Write-Success "Environment configuration created: $envFile"
        return $true
        
    } catch {
        Write-Error "Failed to create environment file: $_"
        return $false
    }
}

function Test-OpenClawGateway {
    Write-Section "🧪 Testing OpenClaw Gateway..."
    
    try {
        $statusOutput = openclaw gateway status 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "OpenClaw Gateway is ready"
            return $true
        } else {
            Write-Warning "Gateway requires API key configuration"
            Write-ColorOutput "Complete API key setup and run: openclaw gateway start" "Yellow"
            return $false
        }
    } catch {
        Write-Warning "Gateway test requires API key configuration"
        Write-ColorOutput "Complete API key setup and run: openclaw gateway start" "Yellow"
        return $false
    }
}

function Show-ApiKeyInstructions {
    param([string]$EnvFile)
    
    Write-Section "🔑 API Key Configuration"
    Write-ColorOutput "Configure your API keys in the .env file:" "Yellow"
    Write-ColorOutput ""
    
    $apiKeys = @(
        @{Name="OpenClaw API Key"; Env="OPENCLAW_API_KEY"; Required=$true; Description="Your OpenClaw API key for AI automation"; Url="https://app.openclaw.com/api-keys"},
        @{Name="Supabase URL"; Env="SUPABASE_URL"; Required=$true; Description="Your Supabase project URL for data storage"; Url="https://app.supabase.com"},
        @{Name="Supabase Anon Key"; Env="SUPABASE_ANON_KEY"; Required=$true; Description="Your Supabase anonymous key"; Url="https://app.supabase.com"},
        @{Name="Resend API Key"; Env="RESEND_API_KEY"; Required=$false; Description="Email sending service (optional)"; Url="https://resend.com/api-keys"}
    )
    
    foreach ($key in $apiKeys) {
        Write-ColorOutput "$($key.Name):" "Green"
        Write-ColorOutput "  Description: $($key.Description)" "White"
        Write-ColorOutput "  Environment Variable: $($key.Env)" "White"
        Write-ColorOutput "  Get Key: $($key.Url)" "Cyan"
        
        if ($key.Required) {
            Write-ColorOutput "  Status: REQUIRED" "Red"
        } else {
            Write-ColorOutput "  Status: Optional" "Yellow"
        }
        Write-ColorOutput ""
    }
    
    Write-ColorOutput "To complete setup:" "Cyan"
    Write-ColorOutput "1. Edit $EnvFile" "White"
    Write-ColorOutput "2. Replace placeholder values with your actual API keys" "White" 
    Write-ColorOutput "3. Run: openclaw gateway start" "White"
    Write-ColorOutput "4. Test with: openclaw chat" "White"
}

function Show-CompletionSummary {
    param([string]$WorkspaceDir, [string]$EnvFile)
    
    Write-ColorOutput ""
    Write-ColorOutput "🎉 Installation Complete!" "Green"
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Green"
    Write-ColorOutput ""
    Write-ColorOutput "Workspace Location: $WorkspaceDir" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Next Steps:" "Yellow"
    Write-ColorOutput "1. Configure API keys in: $EnvFile" "White"
    Write-ColorOutput "2. Update your information in: $WorkspaceDir\USER.md" "White"
    Write-ColorOutput "3. Customize your AI persona in: $WorkspaceDir\SOUL.md" "White"
    Write-ColorOutput "4. Start the OpenClaw Gateway: openclaw gateway start" "White"
    Write-ColorOutput "5. Begin automating: openclaw chat" "White"
    Write-ColorOutput ""
    Write-ColorOutput "Documentation: https://docs.openclaw.com" "Cyan"
    Write-ColorOutput "Support: https://community.openclaw.com" "Cyan"
    Write-ColorOutput "Enterprise Guide: https://erronatus.com/enterprise" "Cyan"
    Write-ColorOutput ""
    Write-ColorOutput "Your AI automation journey begins now! 🚀" "Green"
}

# Main installation process
try {
    Write-ColorOutput "🚀 OpenClaw Enterprise Edition Installer" "Green"
    Write-ColorOutput "Installing complete automation and AI workflow system..." "Yellow"
    Write-ColorOutput ""
    
    # Check internet connection
    if (-not (Test-InternetConnection)) {
        Write-Error "Internet connection required for installation. Please check your connection and try again."
        exit 1
    }
    
    # Step 1: Check Administrator privileges for Node.js install
    if (-not $SkipNodeInstall -and -not (Test-Administrator)) {
        Write-Warning "Administrator privileges recommended for Node.js installation."
        $response = Read-Host "Continue without Node.js installation? (y/N)"
        if ($response -notmatch '^[Yy]') {
            Write-ColorOutput "Please run as Administrator or use -SkipNodeInstall flag." "Red"
            exit 1
        }
        $SkipNodeInstall = $true
    }
    
    # Step 2: Node.js installation
    if (-not $SkipNodeInstall) {
        Write-Section "📦 Step 1: Checking Node.js installation..."
        
        $nodeVersion = Get-NodeVersion
        if ($nodeVersion) {
            $requiredVersion = [Version]"18.0.0"
            if ($nodeVersion -ge $requiredVersion) {
                Write-Success "Node.js v$nodeVersion found"
            } else {
                Write-Warning "Node.js v$nodeVersion is too old. Required: v$requiredVersion+"
                if (-not (Install-NodeJS)) {
                    Write-Error "Node.js installation failed. Please install manually and retry with -SkipNodeInstall."
                    exit 1
                }
            }
        } else {
            Write-ColorOutput "Node.js not found. Installing..." "Yellow"
            if (-not (Install-NodeJS)) {
                Write-Error "Node.js installation failed. Please install manually and retry with -SkipNodeInstall."
                exit 1
            }
        }
    }
    
    # Step 3: OpenClaw installation
    if (-not (Install-OpenClaw)) {
        Write-Error "OpenClaw installation failed. Please check your npm configuration and try again."
        exit 1
    }
    
    # Step 4: Workspace setup
    if (Test-Path $WorkspaceDir) {
        if ($Force) {
            Write-ColorOutput "Removing existing workspace directory..." "Yellow"
            Remove-Item -Path $WorkspaceDir -Recurse -Force
        } else {
            Write-Warning "Workspace directory already exists: $WorkspaceDir"
            if (-not $Quiet) {
                $response = Read-Host "Overwrite existing workspace? (y/N)"
                if ($response -notmatch '^[Yy]') {
                    Write-Error "Installation cancelled."
                    exit 1
                }
            }
            Remove-Item -Path $WorkspaceDir -Recurse -Force
        }
    }
    
    if (-not (New-WorkspaceStructure -Path $WorkspaceDir)) {
        Write-Error "Failed to create workspace structure."
        exit 1
    }
    
    # Step 5: Create workspace files
    if (-not (New-WorkspaceFiles -WorkspaceDir $WorkspaceDir)) {
        Write-Error "Failed to create workspace configuration files."
        exit 1
    }
    
    # Step 6: Environment configuration
    $envFile = Join-Path $WorkspaceDir ".env"
    if (-not (New-EnvironmentFile -WorkspaceDir $WorkspaceDir -ApiKey $ApiKey)) {
        Write-Error "Failed to create environment configuration."
        exit 1
    }
    
    # Step 7: Gateway test (optional)
    Test-OpenClawGateway | Out-Null
    
    # Step 8: Show completion summary
    if (-not $Quiet) {
        Show-ApiKeyInstructions -EnvFile $envFile
        Show-CompletionSummary -WorkspaceDir $WorkspaceDir -EnvFile $envFile
    }
    
    # Return success code
    exit 0
    
} catch {
    Write-Error "Installation failed: $_"
    Write-ColorOutput "For support, visit: https://community.openclaw.com" "Red"
    exit 1
}