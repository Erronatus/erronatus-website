# Chapter 9: Appendix
*Complete reference materials, templates, and resources*

## Complete .env Template

Copy this template to `~/.openclaw/.env` and replace placeholders with your actual keys:

```bash
# =============================================================================
# OpenClaw Environment Configuration
# =============================================================================
# ⚠️  NEVER commit this file to version control or share publicly
# ⚠️  These keys provide access to paid services - protect them carefully

# =============================================================================
# AI MODEL PROVIDERS (Choose at least one)
# =============================================================================

# OpenRouter - Recommended for beginners (single API for multiple models)
# Sign up: https://openrouter.ai/
OPENROUTER_API_KEY=sk-or-v1-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef
OPENROUTER_DEFAULT_MODEL=anthropic/claude-3.5-sonnet

# Anthropic - Direct access to Claude models  
# Sign up: https://console.anthropic.com/
ANTHROPIC_API_KEY=sk-ant-api03-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef

# OpenAI - Direct access to GPT models
# Sign up: https://platform.openai.com/
OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef1234

# Google AI - Gemini models (competitive pricing)
# Sign up: https://ai.google.dev/
GOOGLE_AI_API_KEY=AIzaSy1234567890abcdef1234567890abcdef123

# =============================================================================
# COMMUNICATION CHANNELS
# =============================================================================

# Telegram Bot - Primary mobile interface
# Setup: Message @BotFather on Telegram, create new bot, copy token
TELEGRAM_BOT_TOKEN=YOUR_TELEGRAM_BOT_TOKEN_HERE

# Discord Bot - Team/server interface  
# Setup: https://discord.com/developers/applications
DISCORD_BOT_TOKEN=YOUR_DISCORD_BOT_TOKEN_HERE

# =============================================================================
# DATA SOURCES AND APIS
# =============================================================================

# Brave Search - Web search capabilities
# Sign up: https://brave.com/search/api/
BRAVE_SEARCH_API_KEY=BSA1234567890abcdef1234567890abcdef

# Alpha Vantage - Stock and financial data
# Sign up: https://www.alphavantage.co/
ALPHAVANTAGE_API_KEY=ABCD1234EFGH5678IJKL9012MNOP3456

# NewsAPI - News and headlines
# Sign up: https://newsapi.org/  
NEWS_API_KEY=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6

# Supabase - Database and storage
# Sign up: https://supabase.com/
SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYyNjI3ODYwOCwiZXhwIjoxOTQxODU0NjA4fQ.example-anon-key-here
SUPABASE_DB_URL=postgresql://postgres:your-password@db.abcdefghijklmnop.supabase.co:5432/postgres

# GitHub API - Repository management
# Setup: https://github.com/settings/tokens (create Personal Access Token)
GITHUB_TOKEN=ghp_1234567890abcdefghijklmnopqrstuvwxyz1234

# =============================================================================
# SYSTEM CONFIGURATION
# =============================================================================

# Logging Level (debug, info, warn, error)
LOG_LEVEL=info

# Node.js Environment
NODE_ENV=production

# OpenClaw Gateway Configuration
OPENCLAW_PORT=8080
OPENCLAW_HOST=localhost

# Database Configuration (if using local database)
DATABASE_URL=sqlite:///home/USERNAME/.openclaw/data/openclaw.db

# Security Settings
ENCRYPT_MEMORY=true
SESSION_SECRET=your-random-session-secret-here-make-it-long-and-random

# Performance Settings
MAX_CONTEXT_TOKENS=100000
DEFAULT_TEMPERATURE=0.7
REQUEST_TIMEOUT=30000

# Cost Control
DAILY_COST_LIMIT=10.00
WEEKLY_COST_LIMIT=50.00
MONTHLY_COST_LIMIT=200.00

# Backup Settings
BACKUP_ENABLED=true
BACKUP_INTERVAL=daily
BACKUP_RETENTION_DAYS=30

# =============================================================================
# OPTIONAL: ADDITIONAL SERVICES
# =============================================================================

# Weather API (if needed)
# WEATHER_API_KEY=your-weather-api-key

# Email Configuration (for notifications)
# SMTP_HOST=smtp.gmail.com  
# SMTP_PORT=587
# SMTP_USER=your-email@gmail.com
# SMTP_PASS=your-app-password

# Calendar Integration
# GOOGLE_CALENDAR_CLIENT_ID=your-client-id
# GOOGLE_CALENDAR_CLIENT_SECRET=your-client-secret

# =============================================================================
# DEVELOPMENT/TESTING (Optional)
# =============================================================================

# Development mode settings (uncomment for testing)
# NODE_ENV=development
# LOG_LEVEL=debug
# MOCK_API_RESPONSES=false

# =============================================================================
# PROVIDER-SPECIFIC SETTINGS
# =============================================================================

# OpenRouter Configuration
OPENROUTER_HTTP_REFERER=https://localhost:8080
OPENROUTER_X_TITLE=OpenClaw Personal AI

# Anthropic Configuration  
ANTHROPIC_MODEL_VERSION=2023-06-01

# OpenAI Configuration
OPENAI_ORGANIZATION=your-org-id-if-applicable

# =============================================================================
# MONITORING AND ALERTS
# =============================================================================

# Health Check Configuration
HEALTH_CHECK_INTERVAL=300
HEALTH_CHECK_TIMEOUT=30

# Alert Thresholds
MEMORY_ALERT_THRESHOLD=80
CPU_ALERT_THRESHOLD=80  
DISK_ALERT_THRESHOLD=90

# Notification Channels for Alerts
ALERT_TELEGRAM=true
ALERT_EMAIL=false
ALERT_DISCORD=false

# =============================================================================
# END OF CONFIGURATION
# =============================================================================
```

## OpenClaw CLI Command Reference

### Basic Commands

**System Information:**
```bash
# Show OpenClaw version
openclaw --version

# Show help
openclaw --help
openclaw help [command]

# Show system status
openclaw status

# Show configuration
openclaw config show
```

**Gateway Management:**
```bash
# Start gateway service
openclaw gateway start
openclaw gateway start --daemon
openclaw gateway start --port 8080

# Stop gateway service  
openclaw gateway stop

# Restart gateway service
openclaw gateway restart

# Check gateway status
openclaw gateway status

# View gateway logs
openclaw gateway logs
openclaw gateway logs --follow
openclaw gateway logs --lines 100
```

### Configuration Commands

**Configuration Management:**
```bash
# Show current configuration
openclaw config show

# Set configuration value
openclaw config set key value
openclaw config set defaultModel "anthropic/claude-3.5-sonnet"
openclaw config set logging.level "info"

# Get configuration value  
openclaw config get key
openclaw config get defaultModel

# Edit configuration file
openclaw config edit

# Reset to defaults
openclaw config reset

# Export configuration  
openclaw config export --file config-backup.json

# Import configuration
openclaw config import --file config-backup.json
```

### Chat and Interaction

**Direct Chat:**
```bash
# Single message
openclaw chat "Hello, how are you?"

# Interactive mode
openclaw chat --interactive

# Use specific model
openclaw chat --model "anthropic/claude-3-opus" "Analyze this data"

# Include file
openclaw chat --file document.txt "Summarize this document"

# Set temperature
openclaw chat --temperature 0.3 "Be very precise with this calculation"
```

**Session Management:**
```bash
# Start new session
openclaw session new

# List sessions  
openclaw session list

# Switch to session
openclaw session switch [session-id]

# Save session
openclaw session save [name]

# Load session
openclaw session load [name]

# Delete session
openclaw session delete [session-id]
```

### Cron Job Management

**Creating Cron Jobs:**
```bash
# Create time-based cron job
openclaw cron create "Job Name" \
  --schedule "0 0 7 * * 1-5" \
  --prompt "Your prompt here"

# Create interval-based job
openclaw cron create "Monitor Job" \
  --interval "15m" \
  --prompt "Check system status"

# Create one-time job
openclaw cron create "Reminder" \
  --at "2024-12-25 09:00" \
  --prompt "Christmas morning reminder"

# Create with specific model
openclaw cron create "Analysis Job" \
  --schedule "0 0 18 * * 0" \
  --model "anthropic/claude-3-opus" \
  --prompt "Weekly analysis"
```

**Managing Cron Jobs:**
```bash
# List all cron jobs
openclaw cron list

# List with status filter
openclaw cron list --status failed
openclaw cron list --status running

# Show job details
openclaw cron show "Job Name"

# Edit existing job
openclaw cron edit "Job Name" --schedule "0 0 8 * * 1-5"
openclaw cron edit "Job Name" --prompt-file new-prompt.txt

# Run job manually
openclaw cron run "Job Name"

# Enable/disable job
openclaw cron enable "Job Name"  
openclaw cron disable "Job Name"

# Delete job
openclaw cron delete "Job Name"

# View job logs
openclaw cron logs "Job Name"
openclaw cron logs "Job Name" --last 10
```

### Memory Management

**Memory Operations:**
```bash
# Search memory
openclaw memory search "query"
openclaw memory search "tesla stock" --since "1 week ago"
openclaw memory search "investment decisions" --type "analysis"

# Get specific memory entry
openclaw memory get [memory-id]

# Create memory entry
openclaw memory create --type "note" --content "Important insight"

# Update memory
openclaw memory update [memory-id] --content "Updated content"

# Delete memory entry
openclaw memory delete [memory-id]

# Memory statistics
openclaw memory stats

# Memory maintenance
openclaw memory cleanup
openclaw memory reindex
openclaw memory compress
```

### Cost Tracking

**Cost Management:**
```bash
# Show cost summary
openclaw cost

# Detailed cost breakdown
openclaw cost detailed

# Cost by category
openclaw cost breakdown --category "cron"
openclaw cost breakdown --category "chat"

# Set budget limits
openclaw cost budget --daily 5.00
openclaw cost budget --weekly 25.00  
openclaw cost budget --monthly 100.00

# Export cost data
openclaw cost export --period "last-30-days" --file costs.csv

# Cost projections
openclaw cost forecast --days 30
```

### API and Integration

**API Testing:**
```bash
# Test API connections
openclaw api test
openclaw api test brave-search
openclaw api test alpha-vantage

# API usage statistics  
openclaw api usage
openclaw api usage --provider "brave-search"

# API configuration
openclaw api config --provider "openrouter" --key "new-key"
```

### Debugging and Diagnostics

**System Diagnostics:**
```bash
# System health check
openclaw health

# Debug information
openclaw debug
openclaw debug --verbose

# Token usage analysis
openclaw debug tokens

# Performance metrics
openclaw debug performance

# Network connectivity
openclaw debug network

# Log analysis
openclaw debug logs --errors-only
```

### Backup and Restore

**Backup Operations:**
```bash
# Create backup
openclaw backup create
openclaw backup create --name "pre-update-backup"

# List backups
openclaw backup list

# Restore from backup  
openclaw backup restore [backup-name]

# Export data
openclaw export --workspace
openclaw export --config
openclaw export --memory

# Import data
openclaw import --file backup.zip
```

## Cron Expression Reference

### Basic Syntax
```
┌───────────── second (0-59)
│ ┌─────────── minute (0-59)  
│ │ ┌───────── hour (0-23)
│ │ │ ┌─────── day of month (1-31)
│ │ │ │ ┌───── month (1-12)
│ │ │ │ │ ┌─── day of week (0-6, Sunday=0)
│ │ │ │ │ │
* * * * * *
```

### Common Patterns

**Daily Schedules:**
```bash
0 0 7 * * *        # Every day at 7:00 AM
0 0 7 * * 1-5      # Every weekday at 7:00 AM  
0 0 9,17 * * 1-5   # Every weekday at 9:00 AM and 5:00 PM
0 30 8 * * *       # Every day at 8:30 AM
0 0 */6 * * *      # Every 6 hours
```

**Weekly Schedules:**
```bash
0 0 18 * * 0       # Every Sunday at 6:00 PM
0 0 7 * * 1        # Every Monday at 7:00 AM  
0 0 17 * * 5       # Every Friday at 5:00 PM
0 0 9 * * 1-5      # Weekdays at 9:00 AM
0 0 10 * * 6,0     # Weekends at 10:00 AM
```

**Monthly Schedules:**
```bash
0 0 9 1 * *        # First day of month at 9:00 AM
0 0 17 L * *       # Last day of month at 5:00 PM  
0 0 12 15 * *      # 15th of every month at noon
0 0 8 1-7 * 1      # First Monday of month at 8:00 AM
0 0 14 * */3 *     # Every 3 months at 2:00 PM
```

**Interval Patterns:**
```bash
0 */15 * * * *     # Every 15 minutes
0 0,30 * * * *     # Every 30 minutes (at :00 and :30)
0 0 */2 * * *      # Every 2 hours
0 0 8-17 * * 1-5   # Every hour from 8 AM to 5 PM, weekdays
0 */5 9-16 * * 1-5 # Every 5 minutes during business hours
```

**Special Cases:**
```bash
@yearly            # 0 0 0 1 1 * (January 1st at midnight)
@monthly           # 0 0 0 1 * * (1st of month at midnight)
@weekly            # 0 0 0 * * 0 (Sunday at midnight)  
@daily             # 0 0 0 * * * (Every day at midnight)
@hourly            # 0 0 * * * * (Top of every hour)
```

### Market Hours Schedules

**US Stock Market (EST/EDT):**
```bash
# Market open (9:30 AM EST)
0 30 9 * * 1-5     

# Market close (4:00 PM EST)  
0 0 16 * * 1-5     

# Pre-market monitoring (6:00-9:30 AM EST)
0 0 6-9 * * 1-5    

# After-hours monitoring (4:00-8:00 PM EST)
0 0 16-20 * * 1-5  

# Trading hours every 15 minutes
0 0,15,30,45 9-16 * * 1-5
```

**European Markets (CET/CEST):**
```bash
# London Stock Exchange (8:00 AM - 4:30 PM GMT)
0 0 8 * * 1-5      # Market open
0 30 16 * * 1-5    # Market close

# Frankfurt Stock Exchange (9:00 AM - 5:30 PM CET)  
0 0 9 * * 1-5      # Market open
0 30 17 * * 1-5    # Market close
```

## Glossary of Terms

**API (Application Programming Interface):** A set of protocols and tools for building software applications. In OpenClaw, APIs connect your AI to external data sources like stock prices or news feeds.

**API Key:** A unique identifier used to authenticate access to an API. Functions like a password for API services.

**Automation:** The use of technology to perform tasks without manual intervention. In OpenClaw, this includes scheduled cron jobs and triggered responses.

**Claude:** Anthropic's family of large language models (Claude-3 Haiku, Claude-3.5 Sonnet, Claude-3 Opus) known for strong reasoning and analysis capabilities.

**Context Window:** The maximum amount of text (measured in tokens) that an AI model can process in a single request, including both input and output.

**Cron Job:** A scheduled task that runs automatically at specified times or intervals. Named after the Unix cron utility.

**Curation:** The process of selecting, organizing, and maintaining information in your AI's memory system. Converting raw conversation logs into structured knowledge.

**Daemon:** A background process that runs continuously, providing services to other programs or users. OpenClaw gateway runs as a daemon.

**Environment Variables:** Configuration values stored outside your code, typically in a `.env` file. Used for API keys, database URLs, and other sensitive or environment-specific settings.

**Gateway:** OpenClaw's central routing system that handles incoming messages, manages sessions, and coordinates responses across different channels (Telegram, Discord, CLI).

**GPT (Generative Pre-trained Transformer):** OpenAI's family of large language models (GPT-3.5, GPT-4, GPT-4 Turbo) widely used for conversation and text generation.

**Heartbeat:** A periodic check-in system where your AI proactively looks for tasks to complete, as opposed to waiting for scheduled cron jobs.

**Integration:** The process of connecting different software systems or services. OpenClaw integrates with APIs, databases, and communication platforms.

**JSON (JavaScript Object Notation):** A lightweight data interchange format used for configuration files and API responses.

**Large Language Model (LLM):** An AI system trained on vast amounts of text data to understand and generate human-like text. Examples include GPT-4, Claude, and Gemini.

**Latency:** The delay between sending a request and receiving a response. Important for real-time automation and user experience.

**Memory Layers:** OpenClaw's three-tier memory system - Session Memory (temporary), Working Memory (daily logs), and Long-term Memory (curated insights).

**Node.js:** A JavaScript runtime environment that allows JavaScript to run outside web browsers. OpenClaw is built on Node.js.

**npm (Node Package Manager):** The default package manager for Node.js, used to install and manage JavaScript packages like OpenClaw.

**OpenRouter:** A service that provides unified API access to multiple AI models from different providers through a single interface.

**Personal Access Token (PAT):** A secure authentication token used to access APIs like GitHub. Functions as an alternative to passwords for automated systems.

**Persistent Service:** A software service that runs continuously, automatically starts on system boot, and restarts after crashes or system restarts.

**Rate Limiting:** Restrictions on the number of API requests you can make within a specific time period (e.g., 100 requests per hour).

**Session:** A continuous conversation thread with your AI that maintains context across multiple messages until ended or cleared.

**Slash Commands:** Special commands that start with "/" used to control OpenClaw system functions rather than having normal conversations (e.g., /status, /model, /cost).

**Supabase:** An open-source Firebase alternative that provides database, authentication, and real-time functionality for applications.

**systemd:** A system and service manager for Linux operating systems, used to start, stop, and manage system services.

**Telegram Bot:** An automated account on Telegram that can receive and send messages programmatically. Created through @BotFather.

**Token:** The basic unit of text processing in AI models. Roughly equivalent to 0.75 English words. Used for billing and context window measurements.

**Webhook:** A method of communication where one system sends real-time data to another system when events occur, rather than polling for updates.

**Workspace:** Your main working directory (`~/.openclaw/workspace/`) where OpenClaw stores configuration files, memory, and project data.

## Resource Links

### Official Documentation
- **OpenClaw Documentation:** https://openclaw.com/docs/
- **OpenClaw GitHub Repository:** https://github.com/openclaw/openclaw  
- **Community Forum:** https://community.openclaw.com/
- **Discord Server:** https://discord.gg/openclaw

### AI Model Providers
- **OpenRouter:** https://openrouter.ai/ (Unified access to multiple models)
- **Anthropic (Claude):** https://console.anthropic.com/
- **OpenAI (GPT):** https://platform.openai.com/  
- **Google AI Studio:** https://ai.google.dev/

### API Services  
- **Brave Search API:** https://brave.com/search/api/
- **Alpha Vantage (Financial Data):** https://www.alphavantage.co/
- **NewsAPI:** https://newsapi.org/
- **Supabase (Database):** https://supabase.com/
- **GitHub API:** https://docs.github.com/en/rest

### Communication Platforms
- **Telegram Bot Development:** https://core.telegram.org/bots
- **Discord Developer Portal:** https://discord.com/developers/applications
- **Telegram BotFather:** https://t.me/BotFather

### Learning Resources
- **Node.js Official Tutorial:** https://nodejs.org/en/learn/
- **Cron Expression Generator:** https://crontab.guru/
- **JSON Validation Tool:** https://jsonlint.com/
- **RegEx Testing:** https://regex101.com/

### System Administration
- **systemd Documentation:** https://systemd.io/
- **macOS launchd Guide:** https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/
- **Windows Task Scheduler:** https://docs.microsoft.com/en-us/windows/win32/taskschd/
- **NSSM (Windows Service Manager):** https://nssm.cc/

### Development Tools
- **Visual Studio Code:** https://code.visualstudio.com/ (Recommended editor)
- **Postman:** https://www.postman.com/ (API testing)
- **Git:** https://git-scm.com/ (Version control)
- **curl:** https://curl.se/ (Command-line API testing)

### Monitoring and Analytics
- **Grafana:** https://grafana.com/ (Metrics visualization)
- **Prometheus:** https://prometheus.io/ (Monitoring system)
- **LogRotate:** https://linux.die.net/man/8/logrotate (Log management)

### Cloud Providers (For VPS Deployment)
- **DigitalOcean:** https://www.digitalocean.com/
- **Linode:** https://www.linode.com/  
- **AWS EC2:** https://aws.amazon.com/ec2/
- **Google Cloud Compute:** https://cloud.google.com/compute
- **Vultr:** https://www.vultr.com/

### Security Resources
- **API Security Best Practices:** https://owasp.org/www-project-api-security/
- **Environment Variable Security:** https://12factor.net/config
- **SSH Key Management:** https://docs.github.com/en/authentication/connecting-to-github-with-ssh

### Financial Data Sources
- **Yahoo Finance API:** https://www.yahoofinanceapi.com/
- **IEX Cloud:** https://iexcloud.io/
- **Quandl:** https://www.quandl.com/
- **Polygon.io:** https://polygon.io/

### News and Information APIs  
- **Reddit API:** https://www.reddit.com/dev/api/
- **Twitter API:** https://developer.twitter.com/
- **RSS Feeds:** Various financial news sources
- **Economic Data APIs:** FRED, World Bank, etc.

## Quick Reference Card

### Most-Used Commands

**Daily Operations:**
```bash
# Check system status
openclaw status

# Manual chat
openclaw chat "your message here"

# Check costs
openclaw cost

# View cron jobs
openclaw cron list

# Search memory  
openclaw memory search "query"
```

**System Management:**
```bash
# Start/stop gateway
openclaw gateway start
openclaw gateway stop
openclaw gateway restart

# View logs
openclaw gateway logs --follow

# System health
openclaw health
```

**Cron Job Shortcuts:**
```bash
# Run job now (testing)
openclaw cron run "Job Name"

# Quick status check
openclaw cron list --status failed

# View recent job logs
openclaw cron logs "Job Name" --last 5
```

### Essential Slash Commands (In Chat)

```bash
/status          # System information
/model           # Current model info
/model list      # Available models  
/cost            # Usage and costs
/memory search   # Find past conversations
/help            # Command reference
```

### Emergency Recovery

**If OpenClaw stops working:**
```bash
# Check if gateway is running
openclaw gateway status

# Restart gateway
openclaw gateway restart

# Check for errors
openclaw debug --verbose

# View recent logs
openclaw gateway logs --lines 50
```

**If service won't start:**
```bash
# Check system service (Linux)
systemctl status openclaw.service
journalctl -u openclaw.service -n 20

# Manual start for testing
openclaw gateway start --verbose

# Check file permissions
ls -la ~/.openclaw/
```

### Configuration Quick Fixes

**Reset configuration:**
```bash
# Backup current config
cp ~/.openclaw/config.json ~/.openclaw/config.json.backup

# Reset to defaults  
openclaw config reset

# Restore specific settings
openclaw config set defaultModel "anthropic/claude-3.5-sonnet"
```

**API key issues:**
```bash
# Test API connections
openclaw api test

# Update API key
openclaw config set apiKeys.openrouter "new-key-here"

# Check .env file format
cat ~/.openclaw/.env | grep API_KEY
```

This completes "The Erronatus Blueprint" Personal Edition. You now have a comprehensive guide to building, deploying, and managing a sophisticated AI automation system using OpenClaw.

The system you've built provides 24/7 AI assistance with real-time data access, persistent memory, automated monitoring, and production-grade reliability. This is your foundation for scaling to more advanced automation as your needs grow.

Remember: The best AI automation system is one that reliably solves real problems in your daily life. Start with the core workflows that provide clear value, then expand gradually as you identify new opportunities for automation.

Your journey from AI user to AI operator is complete. Now build something remarkable.

---

*End of Guide*