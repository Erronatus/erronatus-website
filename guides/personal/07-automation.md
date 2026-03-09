# Chapter 7: Automation & Cron Jobs
*The Erronatus Blueprint Personal Edition*

## The Always-On Advantage

Your AI agent sleeps when you're not chatting. But opportunities don't sleep. Markets move overnight. Emails arrive at 3 AM. APIs go down on weekends. The difference between a reactive assistant and a wealth-building system is automation.

**Manual Monitoring:**
```
6:00 AM: Check emails manually
7:00 AM: Read market news
8:00 AM: Look for trading opportunities
9:00 AM: Check system health
...
6:00 PM: Summarize the day
7:00 PM: Plan tomorrow
```

**Automated Operations:**
```
6:00 AM: Morning briefing delivered to phone
6:01 AM: Market scanner finds 3 setups, alert sent
6:15 AM: Email summary: 2 urgent, 5 can wait
8:00 AM: Trading bot executed SPY position, +$120
...
6:00 PM: Day summary generated
6:01 PM: Tomorrow's calendar and priorities ready
11:30 PM: System health check: all green
```

This chapter teaches you to build these automated workflows using OpenClaw's cron system.

## Cron Jobs Explained From Scratch

**Cron** is a time-based job scheduler. Think of it as setting alarms for your computer, but instead of playing sounds, it runs commands.

### Basic Concept
```
"At 8:00 AM every weekday, run my morning briefing script"
"Every 15 minutes during market hours, check for trade signals"  
"At midnight every Sunday, backup my trading data"
```

### Why Cron Matters for AI Agents
- **Proactive instead of reactive**: Find opportunities before you wake up
- **Consistent execution**: Never forget routine tasks
- **Cost optimization**: Use mini models for monitoring, premium for analysis
- **24/7 operations**: Your system works while you sleep

## Cron Expression Syntax

Cron expressions have 5 fields: `minute hour day month weekday`

```
* * * * *
│ │ │ │ │
│ │ │ │ └─── Weekday (0-7, Sunday=0 or 7)
│ │ │ └───── Month (1-12)
│ │ └─────── Day of month (1-31)
│ └───────── Hour (0-23)
└─────────── Minute (0-59)
```

### 15+ Essential Examples

**Every minute** (testing only - expensive!):
```
* * * * *
```

**Every 5 minutes**:
```
*/5 * * * *
```

**Every hour at minute 0** (9:00, 10:00, 11:00...):
```
0 * * * *
```

**Every day at 8:00 AM**:
```
0 8 * * *
```

**Every weekday at 8:00 AM** (Monday-Friday):
```
0 8 * * 1-5
```

**Every 15 minutes during market hours** (9:30 AM - 4:00 PM, Mon-Fri):
```
30-59/15,*/15 9-15 * * 1-5
```

**Every Sunday at midnight** (weekly backup):
```
0 0 * * 0
```

**First day of every month at 9:00 AM** (monthly report):
```
0 9 1 * *
```

**Every 30 minutes, but only during business hours** (9 AM - 5 PM):
```
0,30 9-17 * * *
```

**Market close summary** (4:00 PM Monday-Friday):
```
0 16 * * 1-5
```

**Pre-market check** (8:30 AM Monday-Friday):
```
30 8 * * 1-5
```

**Evening review** (7:00 PM daily):
```
0 19 * * *
```

**Weekend research** (Saturday 10:00 AM):
```
0 10 * * 6
```

**Quarterly planning** (First Monday of each quarter at 9:00 AM):
```
0 9 1-7 1,4,7,10 1
```

**Night maintenance** (2:00 AM daily when you're asleep):
```
0 2 * * *
```

## Three OpenClaw Schedule Types

OpenClaw supports three scheduling patterns: cron, interval, and one-shot.

### Type 1: Cron (Time-based)
**Use for**: Specific times and dates

```json
{
  "name": "morning-briefing",
  "type": "cron", 
  "schedule": "0 8 * * 1-5",
  "prompt": "Generate morning briefing with market overview and calendar",
  "model": "anthropic/claude-sonnet",
  "channels": ["telegram:@jacksontrades"]
}
```

### Type 2: Interval (Frequency-based)  
**Use for**: Recurring checks without precise timing

```json
{
  "name": "api-health-check",
  "type": "interval",
  "schedule": "30m",
  "prompt": "Check all API endpoints and alert if any are down",
  "model": "anthropic/claude-haiku",
  "conditions": {
    "maxFailures": 3,
    "alertChannels": ["discord:alerts"]
  }
}
```

**Valid intervals**: `1m`, `5m`, `15m`, `30m`, `1h`, `2h`, `6h`, `12h`, `1d`

### Type 3: One-shot (Single execution)
**Use for**: Reminders and delayed actions

```json
{
  "name": "earnings-reminder",
  "type": "one-shot", 
  "schedule": "2024-12-20T09:00:00-06:00",
  "prompt": "NVDA earnings report due today. Review position and set alerts.",
  "model": "anthropic/claude-sonnet",
  "channels": ["telegram:@jacksontrades"]
}
```

## The 5 Essential Cron Jobs

These five cron jobs form the foundation of an autonomous AI system. Each includes complete implementation with exact configuration.

### 1. Morning Briefing

**Purpose**: Start each day with context and priorities
**Schedule**: 8:00 AM weekdays
**Model**: Standard (balances cost and quality)

```bash
# Add morning briefing cron job
openclaw cron add morning-briefing "0 8 * * 1-5" '
You are starting the day fresh. Provide a comprehensive morning briefing.

## Tasks:
1. **Email Summary**: Check unread emails, categorize by urgency
2. **Calendar Overview**: Today and tomorrow events, prep needed
3. **Market Conditions**: Pre-market futures, key economic events  
4. **Weather**: Current conditions and forecast for the day
5. **System Health**: Check trading bot status, API quotas, server uptime
6. **Action Priorities**: Top 3 priorities based on calendar and projects

## Format:
Use clear sections with emoji headers. Keep total under 500 words.
Highlight urgent items in **bold**. 

## Memory:
Update memory/YYYY-MM-DD.md with briefing summary.

## Voice:
If good news (profits, opportunities), use voice message for key points.
' --model="anthropic/claude-sonnet" --channel="telegram:@jacksontrades"
```

**Expected Output Example:**
```
🌅 MORNING BRIEFING - December 16, 2024

📧 EMAIL (3 unread)
- **URGENT**: Client wants API demo moved to 2 PM today
- Marketing: Newsletter draft for review (can wait)  
- Broker: Monthly statement available

📅 CALENDAR  
- 10:00 AM: Team standup (30 min)
- **2:00 PM: Client demo (MOVED UP)**
- 4:00 PM: Fed announcement (watch markets)

📈 MARKETS
- S&P futures +0.3% overnight
- **Fed decision today at 2 PM EST**
- Bitcoin holding $42k support

☀️ WEATHER
- Clear, 45°F high
- Good for outdoor lunch

⚡ SYSTEMS
- Trading bot: +$85 overnight on EUR/USD
- APIs: All green, 78% quota remaining
- Server: 99.2% uptime

🎯 TOP PRIORITIES
1. **Prep client demo slides** (deadline: 1:30 PM)
2. Review Fed decision impact on positions  
3. Response to urgent client email ASAP
```

### 2. Market Monitor

**Purpose**: Watch for trading opportunities and risk events
**Schedule**: Every 15 minutes during market hours (9:30 AM - 4:00 PM)
**Model**: Mini (cost-effective for frequent checks)

```bash
# Add market monitoring cron job  
openclaw cron add market-monitor "30-59/15,*/15 9-15 * * 1-5" '
Monitor watchlist symbols for trading opportunities.

## Watchlist Symbols:
- SPY (S&P 500 ETF)
- QQQ (Nasdaq ETF)  
- IWM (Russell 2000 ETF)
- XLE (Energy sector)
- TLT (20+ year bonds)

## Alert Criteria:
**RSI Divergence Setup:**
- RSI below 30 OR above 70
- Volume 50%+ above 20-day average
- Price near key support/resistance

**Breakout Setup:**
- Price breaks above 20-day high with volume
- RSI between 40-60 (not overbought)

**Risk Alert:**
- Any symbol down >2% in 15 minutes
- VIX up >15% (fear spike)

## Actions:
- **High probability setups**: Send immediate alert with entry/exit plan
- **Risk events**: Alert with position review recommendation
- **No opportunities**: Update memory/trading-log.json with timestamp

## Format:
ALERTS: Use 🚨 for urgent, 📊 for opportunities, ⚠️ for risk
Keep under 200 words unless urgent setup found.
' --model="anthropic/claude-haiku" --channel="telegram:@jacksontrades"
```

**Watchlist Data Structure** (`~/.openclaw/workspace/memory/trading-log.json`):
```json
{
  "watchlist": {
    "SPY": {
      "lastPrice": 485.20,
      "rsi": 45.2,
      "volume": 850000,
      "alerts": []
    },
    "QQQ": {
      "lastPrice": 395.80, 
      "rsi": 52.1,
      "volume": 640000,
      "alerts": []
    }
  },
  "lastCheck": "2024-12-16T14:15:00Z",
  "opportunities": 0,
  "alerts": 2
}
```

### 3. Evening Review

**Purpose**: Summarize the day and prepare for tomorrow
**Schedule**: 7:00 PM daily  
**Model**: Standard (needs reasoning for synthesis)

```bash
# Add evening review cron job
openclaw cron add evening-review "0 19 * * *" '
Generate comprehensive end-of-day review and tomorrow preparation.

## Review Tasks:
1. **Daily Performance**: Trading P&L, completed tasks, wins/lessons
2. **Memory Update**: Read today daily log, extract insights for MEMORY.md
3. **Email Cleanup**: Archive processed emails, flag items needing response  
4. **System Status**: Final health check, backup verification
5. **Tomorrow Prep**: Calendar review, priorities, potential blockers

## Memory Actions:
- Read memory/YYYY-MM-DD.md for today
- Update MEMORY.md with significant decisions/learnings
- Archive completed action items
- Roll forward unfinished tasks

## Analysis:
- What worked well today? 
- What could be improved?
- Any patterns emerging?
- Opportunities identified for tomorrow?

## Format:
Structured report with clear sections. Include specific metrics where available.
End with top 3 priorities for tomorrow.

## Voice:
If day was profitable or achieved major milestone, use voice summary.
' --model="anthropic/claude-sonnet" --channel="telegram:@jacksontrades"
```

**Evening Review Template Output:**
```
🌆 EVENING REVIEW - December 16, 2024

📊 PERFORMANCE
**Trading**: +$120 (SPY call, held 45 min)
**Tasks**: 7/9 completed (client demo ✅, blog post ❌)
**Systems**: 99.8% uptime, no alerts

💡 KEY INSIGHTS
- Fed dovish pivot triggered SPY breakout (pattern: watch Fed language)
- Client demo went well, they want Phase 2 (+$12k potential)
- Evening work sessions more productive than morning (adjust schedule?)

📚 MEMORY UPDATES
- Added "Fed pivot pattern" to trading insights
- Updated client project status: Phase 2 proposal needed
- Noted productive hours: 2-4 PM, 7-9 PM

⚡ TOMORROW'S TOP 3
1. **Draft Phase 2 proposal** (client is hot, strike while warm)
2. **Blog post**: "How to Trade Fed Announcements" (content ready)
3. **System upgrade**: Research Claude 3.5 Haiku for cost optimization
```

### 4. Weekly Report  

**Purpose**: Track progress toward goals and identify trends
**Schedule**: Sunday at 6:00 PM  
**Model**: Standard (needs analysis and synthesis)

```bash
# Add weekly report cron job
openclaw cron add weekly-report "0 18 * * 0" '
Generate comprehensive weekly performance report.

## Metrics to Track:
**Financial:**
- Trading P&L (daily breakdown)
- Client revenue (invoiced vs collected)
- System costs (API, hosting, tools)
- Net profit margin

**Operational:**  
- Tasks completed vs planned
- System uptime percentage
- API response times
- Error rates

**Strategic:**
- Goals progress (monthly/quarterly targets)
- New opportunities identified
- Skills learned or tools adopted
- Process improvements implemented

## Data Sources:
- memory/ files from past 7 days
- MEMORY.md for strategic context
- System logs for operational metrics
- Trading logs for financial data

## Analysis:
- What trends are emerging?
- Which strategies are working/failing?
- Where should focus shift next week?
- Any course corrections needed?

## Action Items:
Generate specific tasks for next week based on analysis.

## Format:
Executive summary first, then detailed breakdowns.
Include charts/graphs if possible.
End with next week priorities.
' --model="anthropic/claude-sonnet" --channel="telegram:@jacksontrades"
```

**Weekly Metrics Dashboard** (`~/.openclaw/workspace/memory/weekly-metrics.json`):
```json
{
  "week": "2024-12-16",
  "financial": {
    "tradingPnL": 480,
    "clientRevenue": 2400,
    "systemCosts": 89,
    "netProfit": 2791
  },
  "operational": {
    "tasksCompleted": 34,
    "tasksPlanned": 38,
    "systemUptime": 99.2,
    "avgResponseTime": 145
  },
  "strategic": {
    "goalsProgress": {
      "monthlyProfitTarget": 1200,
      "currentProfit": 1850,
      "percentComplete": 154
    },
    "opportunitiesIdentified": 3,
    "toolsAdopted": ["Claude 3.5 Haiku", "TradingView API"]
  }
}
```

### 5. System Health Monitor

**Purpose**: Ensure all systems are running optimally
**Schedule**: Every 2 hours during waking hours (8 AM - 10 PM)
**Model**: Mini (simple checks, only alert on problems)

```bash
# Add system health monitor cron job
openclaw cron add system-health "0 8-22/2 * * *" '
Perform comprehensive system health check.

## Health Checks:
**API Status:**
- OpenAI API (test simple completion)
- Anthropic API (test simple completion)
- Trading APIs (check auth, balance)
- Email API (connection test)

**System Resources:**
- Disk space (alert if <10% free)
- Memory usage (alert if >80%)
- CPU usage (alert if sustained >70%)
- Network connectivity

**Application Health:**
- OpenClaw gateway status
- Database connections
- Log file sizes (rotate if >100MB)
- Backup verification

## Alert Conditions:
**IMMEDIATE (voice + text):**
- Any API completely down
- Disk space <5%
- System unresponsive

**WARNING (text only):**
- API slow response (>5s)
- Disk space <10%
- High resource usage

**INFO (memory log only):**
- All systems green
- Routine maintenance completed

## Actions:
- Log results to memory/system-health.json
- Only send message if warnings/errors
- Auto-rotate large log files
- Update system status dashboard

## Format:
Silent unless problems detected. Then brief, actionable alert.
' --model="anthropic/claude-haiku" --channel="telegram:@jacksontrades"
```

**System Health Log** (`~/.openclaw/workspace/memory/system-health.json`):
```json
{
  "lastCheck": "2024-12-16T14:00:00Z",
  "status": "healthy",
  "apis": {
    "openai": {"status": "ok", "responseTime": 234},
    "anthropic": {"status": "ok", "responseTime": 189},
    "ibkr": {"status": "ok", "responseTime": 456}
  },
  "resources": {
    "diskSpace": {"total": "500GB", "free": "87GB", "freePercent": 17},
    "memory": {"used": "45%", "available": "55%"},
    "cpu": {"usage": "23%", "load": 0.8}
  },
  "alerts": [],
  "lastMaintenance": "2024-12-15T02:00:00Z"
}
```

## HEARTBEAT.md System

The heartbeat system complements cron jobs by handling interactive monitoring during active sessions. While cron jobs run independently, heartbeats leverage ongoing conversation context.

### What Is HEARTBEAT.md?

HEARTBEAT.md is a file that tells your agent what to check during periodic heartbeat polls. It's like a checklist that gets executed every 30-60 minutes while you're actively using OpenClaw.

**Create your heartbeat configuration:**
```bash
# Create heartbeat instruction file
cat > ~/.openclaw/workspace/HEARTBEAT.md << 'EOF'
# Heartbeat Checklist

Check these items in rotation (2-3 per heartbeat to avoid token burn):

## 📧 Email Check (every 2 hours)
- Count unread messages
- Flag anything marked urgent/important
- **Alert if**: >5 unread OR urgent from key contacts

## 📅 Calendar Scan (every 4 hours)  
- Events in next 4 hours
- Prep needed for upcoming meetings
- **Alert if**: Meeting in <2 hours with no prep

## 💹 Market Quick Scan (market hours only)
- Major index moves (>1% moves)
- VIX levels (>25 = high volatility)
- **Alert if**: Portfolio positions at risk

## 🚨 System Alerts (every hour)
- Check system-health.json for errors
- Review recent error logs
- **Alert if**: Any critical failures

## 📊 Opportunity Scan (twice daily)  
- Review news for trends
- Check social mentions for insights
- **Alert if**: High-probability opportunity found

## Memory Maintenance (once daily)
- Review today's daily log
- Extract insights for MEMORY.md  
- Archive old files if needed

---
**Tracking**: Update heartbeat-state.json with last check times.
**Quiet Hours**: 23:00-08:00 unless emergency (trading loss >$500)
EOF
```

### Heartbeat State Tracking

Track what's been checked to avoid redundancy:

```bash
# Create heartbeat state tracking
cat > ~/.openclaw/workspace/memory/heartbeat-state.json << 'EOF'
{
  "lastChecks": {
    "email": null,
    "calendar": null,
    "market": null,
    "system": null,
    "opportunities": null,
    "memory": null
  },
  "alertsSent": 0,
  "quietHoursActive": false,
  "lastHeartbeat": null
}
EOF
```

### Heartbeat vs Cron: Decision Matrix

| Scenario | Use Heartbeat | Use Cron |
|----------|---------------|----------|
| **Need conversation context** | ✅ | ❌ |
| **Exact timing critical** | ❌ | ✅ |
| **Works when session inactive** | ❌ | ✅ |
| **Can batch multiple checks** | ✅ | ❌ |
| **Interactive follow-up needed** | ✅ | ❌ |
| **Background monitoring** | ❌ | ✅ |
| **Lower cost (fewer API calls)** | ✅ | ❌ |

**Heartbeat examples:**
- Check email and ask if you want to respond to specific message
- Calendar reminder with meeting prep questions
- Trading opportunity with "Should I enter this position?"

**Cron examples:**  
- Morning briefing at exactly 8:00 AM
- Market close summary at exactly 4:00 PM
- System backup at exactly midnight

## Cost Optimization: Model Tier Strategy

Different cron jobs need different thinking levels. Using the right model tier can save 80%+ on API costs.

### Mini Model Jobs (anthropic/claude-haiku)
**Cost**: ~$0.01 per job
**Use for**: Simple monitoring, data collection, routine checks

```bash
# System health check
openclaw cron add health-check "0 */2 * * *" "Check system status" --model="anthropic/claude-haiku"

# API endpoint monitoring  
openclaw cron add api-monitor "*/5 * * * *" "Test API responses" --model="anthropic/claude-haiku"

# Log rotation and cleanup
openclaw cron add log-cleanup "0 1 * * *" "Rotate and archive logs" --model="anthropic/claude-haiku"
```

### Standard Model Jobs (anthropic/claude-sonnet)  
**Cost**: ~$0.10 per job
**Use for**: Analysis, synthesis, decision-making

```bash
# Morning briefing
openclaw cron add morning-brief "0 8 * * 1-5" "Generate morning briefing" --model="anthropic/claude-sonnet"

# Evening review
openclaw cron add evening-review "0 19 * * *" "Summarize day and plan tomorrow" --model="anthropic/claude-sonnet"

# Market analysis  
openclaw cron add market-analysis "0 16 * * 1-5" "Analyze market close" --model="anthropic/claude-sonnet"
```

### Premium Model Jobs (anthropic/claude-sonnet-4)
**Cost**: ~$1.00+ per job  
**Use for**: Strategic planning, complex analysis, high-stakes decisions

```bash
# Weekly strategic review
openclaw cron add weekly-strategy "0 18 * * 0" "Strategic planning session" --model="anthropic/claude-sonnet-4"

# Monthly financial analysis
openclaw cron add monthly-analysis "0 9 1 * *" "Deep financial review" --model="anthropic/claude-sonnet-4" 

# Quarterly business planning
openclaw cron add quarterly-plan "0 9 1 1,4,7,10 *" "Quarterly planning" --model="anthropic/claude-sonnet-4"
```

### Cost Calculation Example

**Before optimization (all Premium):**
- 5 daily jobs × $1.00 = $5.00/day = $150/month
- 3 hourly jobs × $1.00 × 24 = $72/day = $2,160/month
- **Total: $2,310/month** 💸

**After optimization (right-sized):**
- 2 daily Premium jobs × $1.00 = $2.00/day = $60/month  
- 3 daily Standard jobs × $0.10 = $0.30/day = $9/month
- 3 hourly Mini jobs × $0.01 × 24 = $0.72/day = $22/month
- **Total: $91/month** ✅

**Savings: $2,219/month (96% reduction)**

## Building a Custom Cron Job: Step-by-Step

Let's build a custom crypto arbitrage monitor from scratch.

### Step 1: Define Requirements
**Goal**: Find price differences between exchanges for profitable arbitrage
**Frequency**: Every 5 minutes during active hours
**Actions**: Alert if spread >0.5%, track opportunities
**Model**: Mini (frequent, simple checks)

### Step 2: Write the Prompt
```bash
# Create prompt file for reusability
cat > ~/.openclaw/workspace/prompts/crypto-arbitrage.md << 'EOF'
# Crypto Arbitrage Monitor

Monitor price differences between major crypto exchanges for arbitrage opportunities.

## Exchanges to Check:
- Coinbase Pro
- Kraken  
- Binance US
- Gemini

## Symbols to Monitor:
- BTC/USD
- ETH/USD
- SOL/USD
- LINK/USD

## Arbitrage Logic:
1. Fetch current prices from all exchanges
2. Calculate spreads: (highest - lowest) / lowest * 100
3. Account for trading fees (~0.5% total round trip)
4. Alert if net profit potential >0.5%

## Alert Format:
🚨 ARBITRAGE: [SYMBOL]
Buy: [EXCHANGE] at $[PRICE]
Sell: [EXCHANGE] at $[PRICE]  
Spread: [X.XX]% (net: [X.XX]% after fees)
Volume: [MIN_VOLUME] available

## Data Logging:
Update ~/memory/arbitrage-log.json with:
- Timestamp
- Opportunities found
- Executed trades (if any)
- Average spreads by symbol

## Error Handling:
- If any exchange API fails, continue with others
- Log errors to ~/memory/crypto-errors.log
- Alert if >50% exchanges unavailable
EOF
```

### Step 3: Set Up Data Structures
```bash
# Create arbitrage tracking file
cat > ~/.openclaw/workspace/memory/arbitrage-log.json << 'EOF'
{
  "lastUpdate": null,
  "opportunities": [],
  "spreads": {
    "BTC": [],
    "ETH": [],
    "SOL": [],
    "LINK": []
  },
  "errors": [],
  "stats": {
    "totalOpportunities": 0,
    "avgSpreadBTC": 0,
    "bestSpread": null
  }
}
EOF

# Create error log file
touch ~/.openclaw/workspace/memory/crypto-errors.log
```

### Step 4: Add the Cron Job
```bash
# Add crypto arbitrage monitor
openclaw cron add crypto-arbitrage "*/5 6-23 * * *" "$(cat ~/.openclaw/workspace/prompts/crypto-arbitrage.md)" \
  --model="anthropic/claude-haiku" \
  --channel="telegram:@jacksontrades" \
  --timeout=120
```

### Step 5: Test and Refine
```bash
# Test the job manually first
openclaw cron run crypto-arbitrage

# Check logs for any issues
tail ~/.openclaw/workspace/memory/crypto-errors.log

# View opportunities found
cat ~/.openclaw/workspace/memory/arbitrage-log.json

# Adjust frequency if needed
openclaw cron modify crypto-arbitrage --schedule="*/10 6-23 * * *"
```

### Step 6: Monitor Performance
```bash
# Check cron job status
openclaw cron list

# View execution history
openclaw cron logs crypto-arbitrage --limit=10

# Calculate profitability
grep "ARBITRAGE:" ~/.openclaw/workspace/memory/crypto-errors.log | wc -l
```

## Troubleshooting

### Problem: Cron Jobs Not Firing

**Symptoms:**
- Expected job output never arrives
- `openclaw cron list` shows job but last run is old/null
- No error messages

**Diagnosis:**
```bash
# Check if OpenClaw gateway is running
openclaw gateway status

# Check cron job configuration
openclaw cron list --verbose

# Check system time and timezone
date
timedatectl status  # Linux/Mac
# or
Get-Date # Windows PowerShell
```

**Solutions:**
```bash
# Restart OpenClaw gateway
openclaw gateway restart

# Fix timezone issues
openclaw config set TIMEZONE "America/Chicago"

# Check cron expression syntax (use online validator)
# Verify job exists and is enabled
openclaw cron enable crypto-arbitrage
```

### Problem: Wrong Timezone Execution

**Symptoms:**
- Jobs run at wrong times (off by several hours)
- Schedules don't match local expectations

**Diagnosis:**
```bash
# Check OpenClaw timezone setting
openclaw config get TIMEZONE

# Check system timezone
date
```

**Solutions:**
```bash
# Set correct timezone in OpenClaw
openclaw config set TIMEZONE "America/Chicago"  # Example

# Restart gateway to apply changes
openclaw gateway restart

# Test with a near-future job
openclaw cron add test-time "$(date -d '+2 minutes' +'%M %H %d %m') *" "Test time: $(date)"
```

### Problem: Model Errors in Cron Jobs

**Symptoms:**  
- Cron jobs fail with "model not available" errors
- Inconsistent execution success

**Diagnosis:**
```bash
# Check cron job logs for errors
openclaw cron logs morning-briefing --limit=5

# Test model availability
openclaw test-model "anthropic/claude-sonnet"
```

**Solutions:**
```bash
# Switch to known-working model
openclaw cron modify morning-briefing --model="anthropic/claude-sonnet-3-5"

# Add fallback model to job config
openclaw cron modify morning-briefing --fallback-model="anthropic/claude-haiku"

# Check API key configuration
openclaw config get ANTHROPIC_API_KEY
```

### Problem: Cost Overruns

**Symptoms:**
- Unexpectedly high API bills
- Jobs running more frequently than intended
- Premium model usage on simple tasks

**Diagnosis:**
```bash
# Check job frequency and models
openclaw cron list --verbose

# Review recent execution costs
openclaw usage report --last=7days

# Identify expensive jobs
openclaw cron logs --cost-analysis
```

**Solutions:**
```bash
# Reduce frequency of expensive jobs
openclaw cron modify market-analysis --schedule="0 16 * * 1-5"  # Daily instead of hourly

# Downgrade model tiers where appropriate
openclaw cron modify system-health --model="anthropic/claude-haiku"

# Set cost limits per job
openclaw cron modify morning-briefing --max-cost=0.50

# Add monthly budget limits
openclaw config set MONTHLY_BUDGET 200
```

### Problem: Jobs Running During Quiet Hours

**Symptoms:**
- Alerts at 2 AM when you're sleeping
- Weekend notifications when you're offline
- Disruption during vacation/breaks

**Solutions:**
```bash
# Modify schedule to respect quiet hours
openclaw cron modify urgent-alerts --schedule="0 8-22 * * 1-5"  # Business hours only

# Add conditional logic to prompts
openclaw cron modify evening-review --prompt="
Check current time. If after 10 PM or before 8 AM, save results to memory instead of sending alerts.
$(cat existing-prompt.md)
"

# Disable jobs temporarily
openclaw cron disable morning-briefing
# Later: openclaw cron enable morning-briefing
```

## Pro Tips

### 1. Cron Expression Generators
Use online tools to build complex schedules:
- [crontab.guru](https://crontab.guru) - Interactive cron expression builder
- [cron-job.org](https://cron-job.org/en/members/tools/generator/) - Advanced generator

### 2. Job Dependencies  
Some jobs should run in sequence:

```bash
# Morning briefing runs first
openclaw cron add morning-brief "0 8 * * 1-5" "Generate briefing"

# Market analysis waits 10 minutes for briefing to complete
openclaw cron add market-prep "10 8 * * 1-5" "Analyze market, reference morning briefing"
```

### 3. Seasonal Schedules
Adjust schedules for market holidays, vacation, etc.:

```bash
# Create holiday-aware trading schedule  
openclaw cron add holiday-check "0 6 * * 1-5" "
if [[ $(date +%m-%d) == '12-25' || $(date +%m-%d) == '01-01' ]]; then
  echo 'Markets closed for holiday'
  exit 0
fi
# Normal market analysis here
"
```

### 4. Performance Monitoring
Track cron job performance:

```bash
# Create cron performance tracker
cat > ~/.openclaw/workspace/memory/cron-performance.json << 'EOF'
{
  "jobs": {
    "morning-briefing": {
      "avgExecutionTime": 45,
      "successRate": 98.5,
      "avgCost": 0.12,
      "lastFailure": null
    }
  },
  "totalJobs": 156,
  "totalCost": 23.45,
  "costTrend": "stable"
}
EOF
```

### 5. Template Library
Build reusable job templates:

```bash
# Create templates directory
mkdir -p ~/.openclaw/workspace/templates/cron

# Daily summary template
cat > ~/.openclaw/workspace/templates/cron/daily-summary.md << 'EOF'
# Daily Summary Template

## Tasks:
1. Review memory/YYYY-MM-DD.md for today
2. Extract key insights and decisions
3. Update MEMORY.md with learnings
4. Plan tomorrow's priorities

## Format:
- Brief sections with clear headers
- Highlight completed goals ✅
- Note incomplete items for tomorrow ⏭️
- Include metrics where available

## Memory:
Update memory files, don't just read them.
EOF
```

With proper cron job automation, your AI agent becomes a 24/7 operations manager. It monitors opportunities, maintains systems, and keeps you informed without constant supervision. The key is starting with these 5 essential jobs, then building custom automation as you identify repetitive tasks that benefit from consistent execution.

Next chapter covers making this system persistent and bulletproof through proper deployment.