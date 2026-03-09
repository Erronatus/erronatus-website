# Chapter 5: API Integration
*Connecting external data sources to give your AI real-time information and capabilities*

## What You're Building

By the end of this chapter, you'll have:
- Brave Search API configured for real-time web search capabilities
- Alpha Vantage API providing live stock and economic data
- NewsAPI delivering filtered news feeds to your AI
- Supabase database for persistent data storage and retrieval
- GitHub API for repository management and code operations
- Comprehensive verification system testing all integrations
- Understanding of rate limits, costs, and optimization strategies
- Troubleshooting skills for common API connectivity issues

Your AI will transform from a text processor into a connected system with access to real-time global information.

## Understanding APIs: Your AI's Senses

APIs (Application Programming Interfaces) are how software systems communicate with each other. For your AI automation system, APIs are like senses - they provide information about the world and tools to act within it.

### What APIs Enable

**Without APIs, your AI knows only:**
- Information from its training data (usually 6-18 months old)
- Content from your conversations and files
- General knowledge without current context

**With APIs, your AI can:**
- Search the web for current information
- Get real-time stock prices, news, and economic data
- Store and retrieve persistent information across sessions
- Interact with external services and platforms
- Automate actions in connected systems

### API Security Fundamentals

**API Keys** are like passwords that identify your application to external services. They enable:
- **Authentication:** Proving you have permission to access the service
- **Rate limiting:** Controlling how many requests you can make per hour/day
- **Usage tracking:** Monitoring your API consumption and costs
- **Access control:** Determining which features you can use

**Security best practices:**
- Store API keys in `.env` files, never in code
- Use environment-specific keys (development vs production)
- Set spending limits on paid APIs
- Rotate keys periodically (every 90 days)
- Never commit `.env` files to version control

### Why This Matters: The Information Advantage

Real-time information access creates massive leverage:

**Example: Stock monitoring without APIs**
```
You: "How is Tesla doing today?"
AI: "Based on my training data from early 2024, Tesla has been volatile 
but generally trending upward. However, I don't have access to current 
stock prices or recent news."
```

**Example: Stock monitoring with APIs**
```
You: "How is Tesla doing today?"
AI: "Tesla (TSLA) is currently trading at $198.45, down 2.3% today. 
The decline follows news that production delays may affect Q1 delivery 
targets. Volume is 15% above average. Key support level at $195. 
Recent analyst upgrades suggest this is a buying opportunity."
```

The difference is actionable intelligence vs outdated information.

## Brave Search API: Web Intelligence

Brave Search provides privacy-focused web search with excellent results quality and developer-friendly API pricing.

### Step 1: Sign Up for Brave Search API

1. **Navigate to Brave Search API**
   - Go to: https://brave.com/search/api/
   - Click "Get Started" button

2. **Create Account**
   - Click "Sign Up" 
   - Enter email address and create password
   - Verify email address via confirmation link

3. **Choose Plan**
   - **Free Plan:** 2,000 queries/month, good for testing
   - **Pro Plan:** $5/month for 20,000 queries
   - **Scale Plan:** $50/month for 200,000 queries
   - Start with Free plan for initial setup

4. **Generate API Key**
   - Navigate to Dashboard → API Keys
   - Click "Create New Key"
   - Name: `OpenClaw Personal`
   - Copy the generated key (format: `BSA...`)

### Step 2: Configure Brave Search in OpenClaw

Add your Brave Search API key to your `.env` file:

```bash
# Navigate to OpenClaw directory
cd ~/.openclaw

# Edit .env file
# Windows
notepad .env
# macOS
open .env  
# Linux
nano .env
```

Add this line to your `.env` file:
```bash
BRAVE_SEARCH_API_KEY=BSA1234567890abcdef1234567890abcdef
```
Replace `BSA1234567890abcdef1234567890abcdef` with your actual API key from Brave.

### Step 3: Test Brave Search Integration

Restart your OpenClaw gateway to load the new API key:
```bash
openclaw gateway restart
```

Test the integration:
```bash
openclaw chat "Search the web for latest news about artificial intelligence"
```

**Expected response format:**
```
🔍 Web Search Results: "artificial intelligence latest news"

📰 Top Results:

1. **OpenAI Announces GPT-5 with Enhanced Reasoning**
   Source: TechCrunch • 2 hours ago
   Summary: OpenAI unveiled GPT-5 today, featuring improved logical reasoning 
   and multimodal capabilities. The model shows 40% better performance on 
   complex problem-solving tasks...
   
2. **Google's Gemini Ultra Beats GPT-4 in New Benchmarks** 
   Source: VentureBeat • 5 hours ago
   Summary: Google's latest Gemini Ultra model achieved superior scores across
   multiple AI benchmarks, particularly in mathematical reasoning and code
   generation tasks...

3. **AI Regulation Bill Passes Senate Committee**
   Source: Reuters • 1 day ago  
   Summary: The Senate Commerce Committee approved new AI oversight legislation
   requiring transparency reports from major AI companies...

Found 3 relevant articles from the past 24 hours.
```

If you see search results, Brave Search is working correctly.

### Step 4: Understanding Brave Search Features

Brave Search API provides several search types:

**Web Search:**
```bash
# General web search
openclaw chat "search web: Tesla earnings report Q4 2023"

# News-specific search  
openclaw chat "search news: cryptocurrency regulation updates"

# Recent results only
openclaw chat "search web recent: stock market performance today"
```

**Search Parameters You Can Request:**
- **Country/Region:** "search web in Canada: best investment apps"
- **Time Range:** "search web from last week: AI startup funding" 
- **Safe Search:** "search web safe: educational AI resources"
- **Result Count:** "search web 10 results: machine learning courses"

### Rate Limits and Cost Management

**Free Plan Limits:**
- 2,000 queries per month
- ~67 queries per day
- No commercial use restrictions for personal projects

**Usage Monitoring:**
```bash
# Check your Brave Search usage
openclaw stats apis

# Expected output format:
# Brave Search API Usage:
# Today: 15 queries (limit: 67/day)
# This month: 442 queries (limit: 2,000/month)  
# Remaining: 1,558 queries
```

**Cost Optimization Tips:**
- Cache search results locally for repeated queries
- Use specific search terms to get better results with fewer searches
- Batch related searches into single queries when possible

## Alpha Vantage API: Financial Data

Alpha Vantage provides comprehensive financial market data including stocks, forex, cryptocurrencies, and economic indicators.

### Step 1: Sign Up for Alpha Vantage API

1. **Navigate to Alpha Vantage**
   - Go to: https://www.alphavantage.co/
   - Click "Get free API key" button

2. **Create Free Account**
   - Fill out registration form:
     - First Name, Last Name
     - Email Address  
     - Organization: "Personal Use" or your company
     - Intended API usage: "Personal financial tracking and automation"
   - Click "GET FREE API KEY"

3. **Save Your API Key**
   - Copy the API key (format: `ABCD1234EFGH5678`)
   - This appears immediately after registration
   - Also emailed to your registered address

### Step 2: Configure Alpha Vantage in OpenClaw

Add your Alpha Vantage API key to `.env`:

```bash
# Edit your .env file
cd ~/.openclaw
nano .env

# Add this line:
ALPHAVANTAGE_API_KEY=ABCD1234EFGH5678IJKL9012MNOP3456
```

### Step 3: Test Alpha Vantage Integration

Restart gateway and test:
```bash
openclaw gateway restart
openclaw chat "Get current stock price for Apple (AAPL)"
```

**Expected response format:**
```
📈 AAPL Stock Data

Current Price: $182.31 (+2.47, +1.37%)
Volume: 45,234,567
Market Cap: $2.87T

Today's Range: $179.85 - $183.12
52-Week Range: $164.08 - $199.62

Key Metrics:
• P/E Ratio: 28.45
• EPS: $6.42
• Dividend Yield: 0.48%

Last Updated: 2024-03-08 4:00 PM EST
Data provided by Alpha Vantage
```

### Step 4: Available Financial Data Types

Alpha Vantage provides extensive financial data through OpenClaw:

**Stock Data:**
```bash
# Current quote
openclaw chat "AAPL current price"

# Daily chart data
openclaw chat "AAPL daily chart last 30 days"

# Company overview
openclaw chat "AAPL company fundamentals"

# Earnings data
openclaw chat "AAPL earnings history"
```

**Market Indices:**
```bash
# S&P 500 performance
openclaw chat "SPY index performance today"

# NASDAQ tracking  
openclaw chat "QQQ current price and volume"
```

**Cryptocurrency:**
```bash
# Bitcoin price
openclaw chat "Bitcoin current price in USD"

# Ethereum tracking
openclaw chat "ETH price and 24h change"
```

**Economic Indicators:**
```bash
# Unemployment rate
openclaw chat "US unemployment rate latest"

# GDP data
openclaw chat "US GDP growth quarterly"

# Interest rates
openclaw chat "Federal funds rate current"
```

### Rate Limits and Optimization

**Free Plan Limits:**
- 25 API calls per day
- 5 API calls per minute
- No intraday data (15-minute delays)

**Premium Plans:**
- Standard: $50/month - 1,200 calls/day, real-time data
- Professional: $150/month - 3,600 calls/day, premium endpoints

**Optimization Strategies:**
```bash
# Check Alpha Vantage usage
openclaw stats apis alphavantage

# Cache frequently requested symbols
openclaw config set caching.alphavantage.ttl 300  # 5-minute cache

# Batch multiple symbols in watchlist queries
openclaw chat "Get prices for AAPL, TSLA, GOOGL, MSFT"
```

## NewsAPI: Filtered News Intelligence

NewsAPI provides access to news articles from 80,000+ sources worldwide with advanced filtering and search capabilities.

### Step 1: Sign Up for NewsAPI

1. **Navigate to NewsAPI**
   - Go to: https://newsapi.org/
   - Click "Get API Key" button

2. **Register for Free Account**
   - Click "Register" (top right)
   - Fill out form:
     - First Name, Last Name
     - Email Address
     - Password
     - Country
   - Check agreement checkbox
   - Click "Submit"

3. **Verify Account**
   - Check your email for verification link
   - Click verification link to activate account
   - Log in to NewsAPI dashboard

4. **Get API Key**
   - Navigate to Account page
   - Copy your API key (format: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`)

### Step 2: Configure NewsAPI in OpenClaw

Add NewsAPI key to your `.env` file:

```bash
cd ~/.openclaw
nano .env

# Add this line:
NEWS_API_KEY=a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

### Step 3: Test NewsAPI Integration

```bash
openclaw gateway restart
openclaw chat "Get latest news about Tesla"
```

**Expected response format:**
```
📰 Latest News: Tesla

1. **Tesla Q4 Earnings Beat Expectations Despite Challenges**
   Source: Reuters • 2 hours ago
   Summary: Tesla reported Q4 revenue of $25.17 billion, beating analyst 
   estimates of $25.87 billion. CEO Elon Musk emphasized the company's 
   focus on autonomous driving capabilities...

2. **Tesla Cybertruck Production Ramps Up in Texas**
   Source: Bloomberg • 4 hours ago  
   Summary: Tesla's Austin factory is increasing Cybertruck production 
   to meet growing demand, with deliveries expected to accelerate in Q2...

3. **Analyst Upgrades Tesla Stock on AI Potential** 
   Source: CNBC • 6 hours ago
   Summary: Morgan Stanley raised Tesla's price target to $250, citing 
   the company's leadership in AI and autonomous vehicle development...

Found 3 articles published in the last 8 hours.
Data provided by NewsAPI
```

### Step 4: Advanced News Filtering

NewsAPI supports sophisticated filtering through OpenClaw:

**Source-Specific News:**
```bash
# Financial news only
openclaw chat "news from Bloomberg about cryptocurrency"

# Tech news from specific sources
openclaw chat "news from TechCrunch, Verge about AI"

# Multiple sources
openclaw chat "news from Reuters, AP, BBC about economy"
```

**Category Filtering:**
```bash
# Business news
openclaw chat "business news about tech stocks"

# Technology news
openclaw chat "technology news about Apple"

# Science news  
openclaw chat "science news about space exploration"
```

**Time-Based Filtering:**
```bash
# Today's news only
openclaw chat "today's news about stock market"

# Last 24 hours
openclaw chat "news from last day about Federal Reserve"

# This week's news
openclaw chat "this week's news about AI regulation"
```

**Geographic Filtering:**
```bash
# US news
openclaw chat "US news about inflation"

# UK news
openclaw chat "UK news about Brexit impact"

# Global news in English
openclaw chat "international news about climate change"
```

### Rate Limits and Plans

**Developer Plan (Free):**
- 1,000 requests per day
- Headlines endpoint only
- Attribution required

**Business Plan ($449/month):**
- 250,000 requests per day
- Everything endpoint access
- Commercial use allowed

**Enterprise Plan (Custom pricing):**
- Unlimited requests
- Premium support
- Custom integration assistance

## Supabase: Database Storage

Supabase provides PostgreSQL database hosting with real-time features, authentication, and APIs - perfect for storing your AI's persistent data.

### Step 1: Sign Up for Supabase

1. **Navigate to Supabase**
   - Go to: https://supabase.com/
   - Click "Start your project" button

2. **Create Account**
   - Click "Sign up"
   - Choose sign up method:
     - GitHub (recommended for developers)
     - Google
     - Email/password
   - Complete authentication process

3. **Create New Project**
   - Click "New project"
   - Choose organization (create new if first time)
   - Project settings:
     - Name: `openclaw-personal`
     - Database Password: Generate strong password (save this!)
     - Region: Choose closest to your location
     - Pricing Plan: Free (up to 2 databases)
   - Click "Create new project"

4. **Get Database Credentials**
   - Wait for project setup (2-3 minutes)
   - Go to Settings → Database
   - Copy Connection String (format: `postgresql://...`)
   - Go to Settings → API
   - Copy Project URL and anon public key

### Step 2: Configure Supabase in OpenClaw

Add Supabase credentials to `.env`:

```bash
cd ~/.openclaw  
nano .env

# Add these lines:
SUPABASE_URL=https://abcdefghijklmnop.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_DB_URL=postgresql://postgres:password@db.abcdefghijklmnop.supabase.co:5432/postgres
```

### Step 3: Create Your First Table

Use Supabase dashboard to create a memory storage table:

1. **Open Table Editor**
   - Go to Dashboard → Table Editor
   - Click "Create a new table"

2. **Create Memory Table**
   - Table name: `ai_memory`
   - Columns:
     ```
     id: bigint, primary key, auto-increment
     session_id: text, not null  
     timestamp: timestamptz, default now()
     content_type: text, not null (values: conversation, analysis, alert)
     title: text
     content: text, not null
     metadata: jsonb
     ```

3. **Set Row Level Security**
   - Enable RLS on table
   - Add policy for authenticated access
   - Or disable RLS for personal use (less secure but simpler)

### Step 4: Test Supabase Integration  

```bash
openclaw gateway restart
openclaw chat "Save this conversation to memory: Today I learned about API integration"
```

**Expected response:**
```
✅ Memory Saved Successfully

Stored conversation in database:
• Table: ai_memory  
• Session: telegram-123456789
• Type: conversation
• Timestamp: 2024-03-08T19:45:23Z
• Content: "Today I learned about API integration"

You can search this memory later with:
/memory search "API integration"
```

**Test memory retrieval:**
```bash
openclaw chat "/memory search API"
```

**Expected response:**
```
🧠 Memory Search Results: "API"

Found 1 matching entry:

📝 **Conversation** - March 8, 2024 7:45 PM
Content: "Today I learned about API integration"
Session: telegram-123456789
Relevance: 95%

Use /memory get [id] for full details.
```

### Step 5: Understanding Supabase Features

**Database Operations:**
```bash
# Store structured data
openclaw chat "Save my stock watchlist: AAPL, TSLA, GOOGL with target prices"

# Query historical data  
openclaw chat "Find all my stock alerts from last month"

# Update existing records
openclaw chat "Update my AAPL target price to $200"
```

**Real-time Subscriptions:**
- Your AI can receive notifications when data changes
- Useful for collaborative features or external data updates
- Automatic synchronization across multiple devices

**File Storage:**
- Store documents, images, and other files
- Automatic CDN distribution for fast access
- Integration with OpenClaw's file handling

## GitHub API: Code Repository Management

GitHub API enables your AI to interact with code repositories, manage issues, and automate development workflows.

### Step 1: Create GitHub Personal Access Token

1. **Navigate to GitHub Settings**
   - Go to: https://github.com/settings/tokens
   - Or: GitHub → Profile → Settings → Developer settings → Personal access tokens → Tokens (classic)

2. **Generate New Token**
   - Click "Generate new token" → "Generate new token (classic)"
   - Token description: `OpenClaw Personal AI`
   - Expiration: 90 days (for security)
   - Select scopes:
     ```
     ✅ repo (Full control of private repositories)
     ✅ workflow (Update GitHub Action workflows)  
     ✅ user (Update user data)
     ✅ project (Full control of projects)
     ✅ notifications (Access notifications)
     ```

3. **Copy Token**
   - Click "Generate token"
   - Copy token immediately (format: `ghp_1234567890abcdef...`)
   - Store securely - you can't view it again

### Step 2: Configure GitHub API in OpenClaw

Add GitHub token to `.env`:

```bash
cd ~/.openclaw
nano .env

# Add this line:
GITHUB_TOKEN=ghp_1234567890abcdefghijklmnop1234567890
```

### Step 3: Test GitHub Integration

```bash
openclaw gateway restart
openclaw chat "List my GitHub repositories"
```

**Expected response format:**
```
📁 Your GitHub Repositories

Public Repositories (5):
1. **my-website** - HTML/CSS personal portfolio site
   Last updated: 2 days ago
   https://github.com/yourusername/my-website

2. **python-trading-bot** - Python algorithmic trading scripts  
   Last updated: 1 week ago  
   https://github.com/yourusername/python-trading-bot

3. **data-analysis-notebooks** - Jupyter notebooks for data science
   Last updated: 3 weeks ago
   https://github.com/yourusername/data-analysis-notebooks

Private Repositories (2):
4. **personal-finance-tracker** - Private finance management app
5. **ai-automation-config** - OpenClaw configuration and scripts

Total: 7 repositories
```

### Step 4: GitHub Automation Capabilities

Your AI can perform various GitHub operations:

**Repository Management:**
```bash
# Create new repository
openclaw chat "Create new GitHub repo called 'market-analysis-tools'"

# Clone repository locally  
openclaw chat "Clone my python-trading-bot repository to workspace"

# Check repository status
openclaw chat "What's the status of my website repository?"
```

**Issue Management:**
```bash
# List open issues
openclaw chat "Show open issues in my trading-bot repository"

# Create new issue
openclaw chat "Create issue in trading-bot repo: Add support for cryptocurrency APIs"

# Close completed issues
openclaw chat "Close issue #15 in trading-bot repo with comment: Fixed in latest release"
```

**Code Analysis:**
```bash
# Analyze code quality
openclaw chat "Review the code quality in my latest commit"

# Suggest improvements
openclaw chat "What improvements can be made to my Python trading bot?"

# Security scan
openclaw chat "Scan my repositories for security vulnerabilities"
```

## Comprehensive Verification System

Test all your API integrations systematically to ensure everything works correctly.

### API Connection Test Script

Create this test in your workspace:

```bash
cd ~/.openclaw/workspace
nano test-apis.md
```

Add this content:
```markdown
# API Integration Test Script

## Test 1: Brave Search
Command: `openclaw chat "search web: current weather in Austin Texas"`
Expected: Weather results from web search
Status: [ ] Pass [ ] Fail

## Test 2: Alpha Vantage  
Command: `openclaw chat "get stock price for AAPL"`
Expected: Current Apple stock price and basic metrics
Status: [ ] Pass [ ] Fail

## Test 3: NewsAPI
Command: `openclaw chat "get latest news about artificial intelligence"`  
Expected: 3-5 recent AI news articles with summaries
Status: [ ] Pass [ ] Fail

## Test 4: Supabase
Command: `openclaw chat "save to memory: API test completed successfully"`
Expected: Confirmation of database storage
Status: [ ] Pass [ ] Fail

## Test 5: GitHub
Command: `openclaw chat "list my GitHub repositories"`
Expected: List of your repositories with recent activity
Status: [ ] Pass [ ] Fail
```

### Automated API Health Check

Set up ongoing API monitoring:

```bash
# Create API monitoring cron job
openclaw cron create "API Health Check" \
  --schedule "0 */6 * * *" \
  --prompt "Check status of all integrated APIs: Brave Search, Alpha Vantage, NewsAPI, Supabase, GitHub. Report any failures or unusual response times."
```

This runs every 6 hours and alerts you to API issues automatically.

### Rate Limit Monitoring

Configure rate limit tracking:

```bash
openclaw chat "What are my current API usage levels?"
```

**Expected response format:**
```
📊 API Usage Summary - March 8, 2024

🔍 Brave Search API:
Usage: 23/67 daily queries (34% used)
Reset: 23h 42m  
Status: ✅ Healthy

📈 Alpha Vantage API:
Usage: 8/25 daily calls (32% used)  
Reset: 23h 42m
Status: ✅ Healthy

📰 NewsAPI:
Usage: 45/1000 daily requests (4.5% used)
Reset: 23h 42m  
Status: ✅ Healthy

💾 Supabase:
Database: 2.3MB used (23% of free tier)
API calls: 156 today
Status: ✅ Healthy

🐙 GitHub API:
Rate limit: 4,847/5000 per hour
Reset: 52m
Status: ✅ Healthy

Overall Status: All APIs operational
```

## Pro Tips: API Integration Best Practices

💡 **Cache expensive API calls.** Store stock prices, news articles, and search results locally for 5-15 minutes to avoid unnecessary API usage on repeated requests.

💡 **Use webhook notifications when possible.** Instead of polling for updates every few minutes, configure services to notify your AI when important events occur.

💡 **Implement graceful fallbacks.** If Alpha Vantage is down, fall back to Yahoo Finance. If NewsAPI fails, use Brave Search for news queries.

💡 **Monitor costs daily.** Set up daily budget alerts for paid APIs. A runaway automation can consume your monthly budget in hours.

💡 **Batch related requests.** Instead of 5 separate stock price lookups, request all 5 symbols in one API call when possible.

## Troubleshooting: Common API Integration Issues

### Problem: "API key invalid" errors

**Diagnosis:** Key copied incorrectly or expired.
**Fix:**
```bash
# Check .env file format
cat ~/.openclaw/.env | grep API_KEY

# Verify no extra spaces or characters
# Keys should be: PROVIDER_API_KEY=actual_key_here (no quotes)

# Test API key directly
curl -H "Authorization: Bearer YOUR_KEY" https://api.provider.com/test
```

### Problem: Rate limit exceeded

**Diagnosis:** Too many API calls in short period.
**Fix:**
```bash
# Check current usage  
openclaw stats apis

# Enable API caching
openclaw config set caching.enabled true
openclaw config set caching.ttl 300

# Reduce automation frequency
openclaw cron list
openclaw cron edit "Morning Briefing" --schedule "0 8 * * *"  # Once daily instead of hourly
```

### Problem: API responses are slow

**Diagnosis:** Network latency or provider issues.
**Fix:**
- Check provider status pages
- Test from different network
- Enable response caching for repeated requests
- Configure timeout limits: `openclaw config set api.timeout 30`

### Problem: Database connection fails

**Diagnosis:** Supabase credentials incorrect or database sleeping.
**Fix:**
```bash
# Test database connection
psql $SUPABASE_DB_URL -c "SELECT 1;"

# Wake up sleeping database (free tier)
curl -X GET "$SUPABASE_URL/rest/v1/" \
  -H "apikey: $SUPABASE_ANON_KEY"

# Check connection string format
echo $SUPABASE_DB_URL
# Should be: postgresql://postgres:password@host:5432/postgres
```

### Problem: GitHub operations fail

**Diagnosis:** Token permissions insufficient or expired.
**Fix:**
```bash
# Test token permissions
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user

# Check token scopes in response headers
# Regenerate token with correct scopes if needed
```

## Try This: Build Your First Automated Research System

Create an end-to-end automation that demonstrates all your API integrations working together.

### Research Automation Example

Create this automation setup:

```bash
# Create morning research briefing
openclaw cron create "Morning Market Brief" \
  --schedule "0 7 * * 1-5" \
  --prompt "Create my daily market briefing:

1. Use Alpha Vantage to get current prices for: AAPL, GOOGL, TSLA, SPY
2. Use NewsAPI to find top 3 business news stories from last 24 hours
3. Use Brave Search to find any breaking news about my watchlist stocks
4. Save the complete briefing to Supabase database
5. Format as structured summary with actionable insights

Include price changes, key news impacts, and any alerts I should know about."
```

### Test Your Automation

Trigger manually to test:
```bash
openclaw cron run "Morning Market Brief"
```

**Expected output format:**
```
📊 Morning Market Brief - March 8, 2024

🏷️ WATCHLIST PRICES
• AAPL: $182.31 (+1.37% | +$2.47)
• GOOGL: $138.45 (-0.82% | -$1.15)  
• TSLA: $198.67 (+2.14% | +$4.17)
• SPY: $511.23 (+0.45% | +$2.28)

📰 TOP BUSINESS NEWS
1. **Fed Signals Potential Rate Cut** - Markets rally on dovish comments
2. **Apple Announces AI Partnership** - Stock up in premarket trading  
3. **Tesla Production Beats Estimates** - Q1 delivery numbers exceed forecasts

🔍 STOCK-SPECIFIC NEWS
• AAPL: New AI features driving iPhone upgrade cycle
• TSLA: Cybertruck production ramping faster than expected
• No significant news for GOOGL today

💾 Briefing saved to database: briefing-2024-03-08-070015
Next briefing: Tomorrow at 7:00 AM

⚡ ALERTS
• TSLA approaching your $200 target price
• Consider reviewing GOOGL position (underperforming)
```

### ✅ Integration Verification Checklist

Complete this checklist to verify your API integrations:

**Basic Connectivity:**
- [ ] Brave Search returns current web results
- [ ] Alpha Vantage provides real stock prices  
- [ ] NewsAPI delivers recent news articles
- [ ] Supabase stores and retrieves data successfully
- [ ] GitHub API lists your repositories

**Advanced Features:**
- [ ] API caching reduces redundant calls
- [ ] Rate limit monitoring prevents overages
- [ ] Error handling gracefully manages API failures
- [ ] Cost tracking monitors daily usage
- [ ] Automated health checks detect issues

**Integration Testing:**
- [ ] Multi-API workflows complete successfully  
- [ ] Data flows correctly between APIs (e.g., news search → database storage)
- [ ] Authentication persists across OpenClaw restarts
- [ ] All .env variables loaded correctly

**Performance:**  
- [ ] API responses under 10 seconds for complex queries
- [ ] Cached responses return in under 2 seconds
- [ ] No timeout errors during normal usage
- [ ] Concurrent API calls handle properly

## What's Next

Chapter 6 covers memory systems - how to give your AI persistent memory across sessions, intelligent information curation, and searchable knowledge bases. You'll learn to build systems that remember context, learn from experience, and provide continuity across time.

Your AI now has access to real-time global information through five major APIs. The next step is building memory systems so it can learn from this information, remember important insights, and build knowledge over time rather than starting fresh each conversation.

Make sure all five API integrations are working reliably before proceeding. The memory systems in Chapter 6 will use these APIs to gather and store information automatically.

---

*Next: Chapter 6 - Memory Systems*