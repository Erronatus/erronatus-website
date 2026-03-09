#!/bin/bash
set -e

# OpenClaw Enterprise Edition Installer for macOS/Linux
# Production-ready installer with comprehensive error handling

# Configuration
DEFAULT_WORKSPACE_DIR="${HOME}/.openclaw/workspace"
WORKSPACE_DIR="$DEFAULT_WORKSPACE_DIR"
FORCE=false
SKIP_NODE=false
API_KEY=""
QUIET=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Logging functions
log() {
    if [ "$QUIET" != "true" ]; then
        echo -e "${WHITE}$1${NC}"
    fi
}

log_section() {
    if [ "$QUIET" != "true" ]; then
        echo ""
        echo -e "${CYAN}$1${NC}"
    fi
}

log_success() {
    if [ "$QUIET" != "true" ]; then
        echo -e "${GREEN}✅ $1${NC}"
    fi
}

log_warning() {
    if [ "$QUIET" != "true" ]; then
        echo -e "${YELLOW}⚠️ $1${NC}"
    fi
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

log_info() {
    if [ "$QUIET" != "true" ]; then
        echo -e "${BLUE}ℹ️ $1${NC}"
    fi
}

# Help function
show_help() {
    cat << EOF
OpenClaw Enterprise Edition Installer

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --workspace-dir DIR     Set workspace directory (default: ~/.openclaw/workspace)
    --force                Force reinstall even if components exist
    --skip-node-install    Skip Node.js installation check
    --api-key KEY          OpenClaw API key for immediate setup
    --quiet                Suppress non-error output
    -h, --help             Show this help message

EXAMPLES:
    $0                                    # Standard installation
    $0 --workspace-dir ~/my-workspace     # Custom workspace directory
    $0 --force --api-key "your-key"       # Force reinstall with API key
    $0 --skip-node-install --quiet        # Skip Node.js check, quiet mode

REQUIREMENTS:
    - macOS 10.15+ or Linux (Ubuntu 18.04+, CentOS 7+, Debian 9+)
    - Internet connection for downloads
    - curl or wget for downloading packages
    - sudo access for package installation

For support: https://community.openclaw.com
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --workspace-dir)
            WORKSPACE_DIR="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --skip-node-install)
            SKIP_NODE=true
            shift
            ;;
        --api-key)
            API_KEY="$2"
            shift 2
            ;;
        --quiet)
            QUIET=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# System detection
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get >/dev/null 2>&1; then
            echo "ubuntu"
        elif command -v yum >/dev/null 2>&1; then
            echo "centos"
        elif command -v dnf >/dev/null 2>&1; then
            echo "fedora"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Internet connectivity check
check_internet() {
    if command -v curl >/dev/null 2>&1; then
        if curl -s --connect-timeout 10 https://www.google.com >/dev/null; then
            return 0
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q --spider --timeout=10 https://www.google.com; then
            return 0
        fi
    fi
    return 1
}

# Node.js version check
get_node_version() {
    if command -v node >/dev/null 2>&1; then
        local version=$(node --version 2>/dev/null | sed 's/v//')
        echo "$version"
    else
        echo ""
    fi
}

# Version comparison
version_ge() {
    [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]
}

# Package manager detection
get_package_manager() {
    local os=$(detect_os)
    case $os in
        "macos")
            if command -v brew >/dev/null 2>&1; then
                echo "brew"
            else
                echo "homebrew_needed"
            fi
            ;;
        "ubuntu")
            echo "apt"
            ;;
        "centos")
            echo "yum"
            ;;
        "fedora")
            echo "dnf"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Install Node.js
install_nodejs() {
    log_section "📦 Installing Node.js..."
    
    local os=$(detect_os)
    local package_manager=$(get_package_manager)
    
    case $package_manager in
        "brew")
            log "Installing Node.js via Homebrew..."
            if brew install node; then
                log_success "Node.js installed via Homebrew"
                return 0
            else
                log_error "Failed to install Node.js via Homebrew"
                return 1
            fi
            ;;
        "homebrew_needed")
            log "Installing Homebrew first..."
            if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
                log_success "Homebrew installed"
                # Add Homebrew to PATH for this session
                if [[ -f "/opt/homebrew/bin/brew" ]]; then
                    export PATH="/opt/homebrew/bin:$PATH"
                elif [[ -f "/usr/local/bin/brew" ]]; then
                    export PATH="/usr/local/bin:$PATH"
                fi
                
                if brew install node; then
                    log_success "Node.js installed via Homebrew"
                    return 0
                else
                    log_error "Failed to install Node.js after Homebrew installation"
                    return 1
                fi
            else
                log_error "Failed to install Homebrew"
                return 1
            fi
            ;;
        "apt")
            log "Installing Node.js via NodeSource repository..."
            if curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - && \
               sudo apt-get install -y nodejs; then
                log_success "Node.js installed via apt"
                return 0
            else
                log_error "Failed to install Node.js via apt"
                return 1
            fi
            ;;
        "yum")
            log "Installing Node.js via NodeSource repository..."
            if curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash - && \
               sudo yum install -y nodejs; then
                log_success "Node.js installed via yum"
                return 0
            else
                log_error "Failed to install Node.js via yum"
                return 1
            fi
            ;;
        "dnf")
            log "Installing Node.js via NodeSource repository..."
            if curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash - && \
               sudo dnf install -y nodejs; then
                log_success "Node.js installed via dnf"
                return 0
            else
                log_error "Failed to install Node.js via dnf"
                return 1
            fi
            ;;
        *)
            log_error "Unsupported package manager. Please install Node.js manually."
            return 1
            ;;
    esac
}

# Install OpenClaw
install_openclaw() {
    log_section "⚙️ Installing OpenClaw..."
    
    # Check if already installed
    if command -v openclaw >/dev/null 2>&1 && [ "$FORCE" != "true" ]; then
        local version=$(openclaw --version 2>/dev/null || echo "unknown")
        log_success "OpenClaw already installed: $version"
        return 0
    fi
    
    log "Installing OpenClaw via npm..."
    if npm install -g openclaw; then
        # Verify installation
        sleep 2
        if command -v openclaw >/dev/null 2>&1; then
            local version=$(openclaw --version 2>/dev/null || echo "installed")
            log_success "OpenClaw $version installed successfully"
            return 0
        else
            log_error "OpenClaw installation verification failed"
            return 1
        fi
    else
        log_error "Failed to install OpenClaw via npm"
        return 1
    fi
}

# Create workspace structure
create_workspace_structure() {
    local workspace_dir="$1"
    
    log_section "📁 Creating workspace structure..."
    
    # Create main workspace directory
    if ! mkdir -p "$workspace_dir"; then
        log_error "Failed to create workspace directory: $workspace_dir"
        return 1
    fi
    
    # Create subdirectories
    local subdirs=("memory" "projects" "skills" "logs" "temp")
    for dir in "${subdirs[@]}"; do
        if ! mkdir -p "$workspace_dir/$dir"; then
            log_error "Failed to create subdirectory: $workspace_dir/$dir"
            return 1
        fi
    done
    
    log_success "Workspace directory structure created: $workspace_dir"
    return 0
}

# Create workspace configuration files
create_workspace_files() {
    local workspace_dir="$1"
    
    log_section "📋 Creating workspace configuration files..."
    
    # SOUL.md - AI personality and core directives
    cat > "$workspace_dir/SOUL.md" << 'EOF'
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
EOF
    
    # USER.md - User profile and business context
    cat > "$workspace_dir/USER.md" << 'EOF'
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
EOF
    
    # AGENTS.md - Operational guidelines
    cat > "$workspace_dir/AGENTS.md" << 'EOF'
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
EOF
    
    # TOOLS.md - Local configuration notes
    cat > "$workspace_dir/TOOLS.md" << 'EOF'
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
EOF
    
    # MEMORY.md - Long-term memory for main session
    cat > "$workspace_dir/MEMORY.md" << 'EOF'
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
EOF
    
    # Create initial memory directory with today's file
    local today=$(date +"%Y-%m-%d")
    cat > "$workspace_dir/memory/$today.md" << EOF
# Memory Log - $today

## Setup and Installation
- OpenClaw Enterprise Edition installed successfully
- Workspace created at: $workspace_dir
- Initial configuration files created
- Ready to begin automation development

## Next Steps
- Configure API keys in .env file
- Update USER.md with business details
- Customize SOUL.md for specific needs
- Begin with first automation project

## Notes
- Installation completed at $(date)
- System ready for production automation development
EOF
    
    log_success "Workspace configuration files created successfully"
    return 0
}

# Create environment file
create_environment_file() {
    local workspace_dir="$1"
    local api_key="$2"
    
    log_section "🔧 Creating environment configuration..."
    
    local env_file="$workspace_dir/.env"
    
    # Determine API key value
    local openclaw_key
    if [ -n "$api_key" ]; then
        openclaw_key="$api_key"
    else
        openclaw_key="your-openclaw-api-key-here"
    fi
    
    cat > "$env_file" << EOF
# OpenClaw Configuration
OPENCLAW_API_KEY=$openclaw_key

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
WORKSPACE_PATH=$workspace_dir
BACKUP_ENABLED=true
MONITORING_ENABLED=true

# Security Configuration
SESSION_SECRET=your-session-secret-here
JWT_SECRET=your-jwt-secret-here
ENCRYPTION_KEY=your-encryption-key-here
EOF
    
    # Create .env.example for reference
    cp "$env_file" "$workspace_dir/.env.example"
    
    log_success "Environment configuration created: $env_file"
    return 0
}

# Test OpenClaw Gateway
test_openclaw_gateway() {
    log_section "🧪 Testing OpenClaw Gateway..."
    
    if openclaw gateway status >/dev/null 2>&1; then
        log_success "OpenClaw Gateway is ready"
        return 0
    else
        log_warning "Gateway requires API key configuration"
        log "Complete API key setup and run: openclaw gateway start"
        return 1
    fi
}

# Show API key configuration instructions
show_api_key_instructions() {
    local env_file="$1"
    
    log_section "🔑 API Key Configuration"
    log "Configure your API keys in the .env file:"
    log ""
    
    # API key information
    declare -a api_keys=(
        "OpenClaw API Key|OPENCLAW_API_KEY|REQUIRED|Your OpenClaw API key for AI automation|https://app.openclaw.com/api-keys"
        "Supabase URL|SUPABASE_URL|REQUIRED|Your Supabase project URL for data storage|https://app.supabase.com"
        "Supabase Anon Key|SUPABASE_ANON_KEY|REQUIRED|Your Supabase anonymous key|https://app.supabase.com"
        "Resend API Key|RESEND_API_KEY|Optional|Email sending service (optional)|https://resend.com/api-keys"
    )
    
    for key_info in "${api_keys[@]}"; do
        IFS='|' read -ra KEY_PARTS <<< "$key_info"
        local key_name="${KEY_PARTS[0]}"
        local env_var="${KEY_PARTS[1]}"
        local required="${KEY_PARTS[2]}"
        local description="${KEY_PARTS[3]}"
        local url="${KEY_PARTS[4]}"
        
        echo -e "${GREEN}$key_name:${NC}"
        echo -e "  Description: ${WHITE}$description${NC}"
        echo -e "  Environment Variable: ${WHITE}$env_var${NC}"
        echo -e "  Get Key: ${CYAN}$url${NC}"
        
        if [ "$required" = "REQUIRED" ]; then
            echo -e "  Status: ${RED}REQUIRED${NC}"
        else
            echo -e "  Status: ${YELLOW}Optional${NC}"
        fi
        echo ""
    done
    
    echo -e "${CYAN}To complete setup:${NC}"
    echo -e "${WHITE}1. Edit $env_file${NC}"
    echo -e "${WHITE}2. Replace placeholder values with your actual API keys${NC}"
    echo -e "${WHITE}3. Run: openclaw gateway start${NC}"
    echo -e "${WHITE}4. Test with: openclaw chat${NC}"
}

# Show completion summary
show_completion_summary() {
    local workspace_dir="$1"
    local env_file="$2"
    
    echo ""
    echo -e "${GREEN}🎉 Installation Complete!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}Workspace Location: $workspace_dir${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo -e "${WHITE}1. Configure API keys in: $env_file${NC}"
    echo -e "${WHITE}2. Update your information in: $workspace_dir/USER.md${NC}"
    echo -e "${WHITE}3. Customize your AI persona in: $workspace_dir/SOUL.md${NC}"
    echo -e "${WHITE}4. Start the OpenClaw Gateway: openclaw gateway start${NC}"
    echo -e "${WHITE}5. Begin automating: openclaw chat${NC}"
    echo ""
    echo -e "${CYAN}Documentation: https://docs.openclaw.com${NC}"
    echo -e "${CYAN}Support: https://community.openclaw.com${NC}"
    echo -e "${CYAN}Enterprise Guide: https://erronatus.com/enterprise${NC}"
    echo ""
    echo -e "${GREEN}Your AI automation journey begins now! 🚀${NC}"
}

# Main installation function
main() {
    # Initial setup
    log_success "🚀 OpenClaw Enterprise Edition Installer"
    log "Installing complete automation and AI workflow system..."
    log ""
    
    # Check internet connection
    if ! check_internet; then
        log_error "Internet connection required for installation. Please check your connection and try again."
        exit 1
    fi
    
    # Detect operating system
    local os=$(detect_os)
    if [ "$os" = "unknown" ]; then
        log_error "Unsupported operating system. This installer supports macOS and Linux only."
        exit 1
    fi
    
    log_info "Detected operating system: $os"
    
    # Step 1: Node.js installation
    if [ "$SKIP_NODE" != "true" ]; then
        log_section "📦 Step 1: Checking Node.js installation..."
        
        local node_version=$(get_node_version)
        if [ -n "$node_version" ]; then
            if version_ge "$node_version" "18.0.0"; then
                log_success "Node.js v$node_version found"
            else
                log_warning "Node.js v$node_version is too old. Required: v18.0.0+"
                if ! install_nodejs; then
                    log_error "Node.js installation failed. Please install manually and retry with --skip-node-install."
                    exit 1
                fi
            fi
        else
            log "Node.js not found. Installing..."
            if ! install_nodejs; then
                log_error "Node.js installation failed. Please install manually and retry with --skip-node-install."
                exit 1
            fi
        fi
    fi
    
    # Step 2: OpenClaw installation
    if ! install_openclaw; then
        log_error "OpenClaw installation failed. Please check your npm configuration and try again."
        exit 1
    fi
    
    # Step 3: Workspace setup
    if [ -d "$WORKSPACE_DIR" ]; then
        if [ "$FORCE" = "true" ]; then
            log "Removing existing workspace directory..."
            rm -rf "$WORKSPACE_DIR"
        else
            log_warning "Workspace directory already exists: $WORKSPACE_DIR"
            if [ "$QUIET" != "true" ]; then
                read -p "Overwrite existing workspace? (y/N): " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log_error "Installation cancelled."
                    exit 1
                fi
            fi
            rm -rf "$WORKSPACE_DIR"
        fi
    fi
    
    if ! create_workspace_structure "$WORKSPACE_DIR"; then
        log_error "Failed to create workspace structure."
        exit 1
    fi
    
    # Step 4: Create workspace files
    if ! create_workspace_files "$WORKSPACE_DIR"; then
        log_error "Failed to create workspace configuration files."
        exit 1
    fi
    
    # Step 5: Environment configuration
    local env_file="$WORKSPACE_DIR/.env"
    if ! create_environment_file "$WORKSPACE_DIR" "$API_KEY"; then
        log_error "Failed to create environment configuration."
        exit 1
    fi
    
    # Step 6: Gateway test (optional)
    test_openclaw_gateway >/dev/null 2>&1
    
    # Step 7: Show completion summary
    if [ "$QUIET" != "true" ]; then
        show_api_key_instructions "$env_file"
        show_completion_summary "$WORKSPACE_DIR" "$env_file"
    fi
    
    exit 0
}

# Error handling
trap 'log_error "Installation failed. For support, visit: https://community.openclaw.com"; exit 1' ERR

# Run main installation
main "$@"