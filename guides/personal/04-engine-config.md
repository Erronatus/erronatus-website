# Chapter 4: Engine Configuration
*Choosing AI models, managing costs, and building your model routing strategy*

## What You're Building

By the end of this chapter, you'll have:
- Deep understanding of different AI model architectures and capabilities
- Strategic model routing that optimizes costs vs. performance
- Real-time cost tracking and budget alerts configured
- Personal cost optimization strategy tailored to your usage
- Model comparison data to make informed switching decisions
- Automated model selection based on task complexity
- Confidence managing AI provider relationships and billing

You'll transform from "using whatever model works" to running a cost-optimized, performance-tuned AI operation.

## Understanding AI Models: Architecture and Capabilities

AI models aren't interchangeable. They have different strengths, weaknesses, costs, and use cases. Understanding these differences is crucial for building efficient automation.

### Model Categories by Architecture

**Large Language Models (LLMs)**
- Primary function: Text understanding and generation
- Best for: Conversation, analysis, writing, reasoning
- Examples: GPT-4, Claude, PaLM-2

**Multimodal Models**  
- Primary function: Text + images/audio/video
- Best for: Image analysis, document processing, multimedia tasks
- Examples: GPT-4V, Claude-3 Vision, Gemini Pro Vision

**Code-Specialized Models**
- Primary function: Programming and technical tasks
- Best for: Code generation, debugging, system administration
- Examples: CodeLlama, GPT-4 Code Interpreter, Claude-3 for coding

**Tool-Use Models**
- Primary function: Function calling and API integration
- Best for: Automation, data retrieval, system control
- Examples: GPT-4 Turbo, Claude-3.5 Sonnet, Command-R+

### Model Capabilities Breakdown

Understanding what each model excels at helps you route tasks appropriately:

**Reasoning and Analysis:**
- **GPT-4 Turbo:** Excellent logical reasoning, good at multi-step problems
- **Claude-3.5 Sonnet:** Superior at nuanced analysis, great at understanding context
- **Claude-3 Opus:** Best-in-class reasoning, slower but most accurate
- **Gemini Pro:** Strong mathematical reasoning, good at structured data

**Creative and Writing:**
- **GPT-4:** Natural, engaging writing style
- **Claude-3.5 Sonnet:** Sophisticated prose, excellent at matching tone
- **PaLM-2:** Good at creative tasks, strong multilingual capabilities

**Technical and Coding:**
- **GPT-4 Turbo:** Comprehensive programming knowledge, good debugging
- **Claude-3.5 Sonnet:** Excellent code explanation and architecture
- **CodeLlama:** Specialized for code generation, very fast

**Tool Use and Automation:**
- **GPT-4 Turbo:** Reliable function calling, good API usage
- **Claude-3.5 Sonnet:** Excellent at complex workflows, strong tool chaining
- **Command-R+:** Optimized for retrieval and tool use

### Why This Matters: The Right Tool for the Job

Using the wrong model is like using a Formula 1 car for grocery shopping - expensive and inefficient.

**Example task routing:**
```
"What's the weather?" → GPT-3.5 Turbo (cheap, simple)
"Analyze this 50-page financial report" → Claude-3 Opus (premium reasoning)
"Write a Python script to parse CSV files" → Claude-3.5 Sonnet (technical)
"Summarize today's news" → GPT-4 Turbo (balanced speed/quality)
```

Each task gets the right capability level at the right price point.

## AI Provider Landscape: Choosing Your Stack

Different providers offer different models, pricing structures, and reliability characteristics.

### Major Providers Comparison

#### OpenRouter (Recommended for Beginners)
**Pros:**
- Single API for 100+ models
- Transparent pricing with real-time costs
- Easy model switching without code changes
- Good documentation and community
- Fallback routing (if one model fails, try another)

**Cons:**
- Slight markup over direct provider pricing
- Extra latency (routing layer)
- Limited access to newest models initially

**Best for:** Getting started, experimentation, model comparison

**Pricing:** Pay-per-token with transparent markup
- GPT-4 Turbo: $0.01/1K input tokens, $0.03/1K output tokens
- Claude-3.5 Sonnet: $0.003/1K input, $0.015/1K output

#### OpenAI (Direct)
**Pros:**
- Latest GPT models first
- Best-in-class developer tools
- Reliable API with good uptime
- Strong function calling capabilities

**Cons:**  
- Limited model variety (only OpenAI models)
- Higher pricing for premium models
- Usage policies restrict some automation use cases

**Best for:** GPT-focused workflows, production applications

**Pricing:** Tiered based on usage volume
- GPT-4 Turbo: $0.01/1K input, $0.03/1K output
- GPT-3.5 Turbo: $0.0005/1K input, $0.0015/1K output

#### Anthropic (Direct)
**Pros:**
- Claude models often outperform GPT on analysis
- Strong safety and alignment focus  
- Excellent at long-form reasoning
- Good customer support

**Cons:**
- Only Anthropic models available
- Higher pricing than OpenAI
- Newer company with less ecosystem

**Best for:** Research, analysis, content creation

**Pricing:** Token-based with volume discounts
- Claude-3.5 Sonnet: $0.003/1K input, $0.015/1K output  
- Claude-3 Opus: $0.015/1K input, $0.075/1K output

#### Google AI (Gemini)
**Pros:**
- Competitive pricing, generous free tier
- Strong multimodal capabilities
- Good integration with Google services
- Fast inference speed

**Cons:**
- Newer platform with fewer models
- Limited third-party integrations
- Usage policies still evolving

**Best for:** Multimodal tasks, budget-conscious usage

**Pricing:** Very competitive
- Gemini Pro: $0.0005/1K input, $0.0015/1K output
- Gemini Pro Vision: $0.00025/image + text pricing

### Provider Selection Strategy

**Start with OpenRouter** for learning and experimentation
- Single account, multiple models
- Easy cost comparison
- Built-in fallback routing

**Add direct providers** as you scale
- OpenAI for GPT-specific features
- Anthropic for Claude-specific capabilities  
- Google for cost optimization

**Enterprise considerations** (Business Edition preview)
- Multiple provider redundancy
- Custom model fine-tuning
- Volume discount negotiations

## The Model Tier System

Organizing models into tiers helps you match capabilities to requirements systematically.

### Free Tier (Development and Testing)
**Use for:** Testing, development, non-critical tasks
**Cost target:** $0-5/month
**Models:**
- Gemini Pro (Google): 60 requests/minute free
- GPT-3.5 Turbo: $0.0005/$0.0015 per 1K tokens
- Claude-3 Haiku: $0.00025/$0.00125 per 1K tokens

**Typical tasks:**
- Basic Q&A and conversation
- Simple text processing
- Development and debugging
- Non-critical automation

### Budget Tier ($10-50/month)
**Use for:** Daily automation, personal productivity
**Cost target:** $10-50/month  
**Models:**
- GPT-4 Turbo: $0.01/$0.03 per 1K tokens
- Claude-3.5 Sonnet: $0.003/$0.015 per 1K tokens
- Command-R+: $0.0005/$0.0015 per 1K tokens

**Typical tasks:**
- Morning briefings and summaries
- Email analysis and responses
- Stock research and alerts
- File organization and management

### Standard Tier ($50-200/month)
**Use for:** Professional workflows, business automation  
**Cost target:** $50-200/month
**Models:**
- GPT-4 Turbo (high-volume): Volume discounts
- Claude-3.5 Sonnet: Primary reasoning engine
- Specialized models for specific tasks

**Typical tasks:**
- Comprehensive research projects
- Complex analysis and reporting  
- Multi-step automation workflows
- Customer service automation

### Premium Tier ($200+/month)
**Use for:** Mission-critical applications, advanced reasoning
**Cost target:** $200+/month
**Models:**
- Claude-3 Opus: Best-in-class reasoning
- GPT-4 Turbo (enterprise): Dedicated instances
- Custom fine-tuned models

**Typical tasks:**
- Strategic business analysis
- Complex decision support systems
- High-stakes automation (financial, legal)
- Large-scale content generation

## Configuring Your Default Model

OpenClaw uses a hierarchical model selection system:

1. **Task-specific model** (if specified)
2. **Channel default** (Telegram vs Discord vs CLI)  
3. **Global default** (fallback for everything)
4. **Provider fallback** (if primary fails)

### Setting Global Defaults

Edit your OpenClaw configuration:

```bash
# Edit config file
openclaw config edit

# Or use command line
openclaw config set model "anthropic/claude-3.5-sonnet"
openclaw config set fallback_model "openai/gpt-4-turbo"
```

Configuration file (`~/.openclaw/config.json`):
```json
{
  "defaultModel": "anthropic/claude-3.5-sonnet",
  "fallbackModel": "openai/gpt-4-turbo", 
  "modelTiers": {
    "fast": "anthropic/claude-3-haiku",
    "standard": "anthropic/claude-3.5-sonnet", 
    "premium": "anthropic/claude-3-opus"
  },
  "channelDefaults": {
    "telegram": "anthropic/claude-3.5-sonnet",
    "discord": "openai/gpt-4-turbo", 
    "cli": "anthropic/claude-3-opus"
  }
}
```

### Channel-Specific Configuration

Different channels may warrant different model defaults:

```bash
# Set Telegram to use faster/cheaper models (mobile usage)
openclaw config set telegram.defaultModel "anthropic/claude-3-haiku"

# Set CLI to use premium models (deep work)  
openclaw config set cli.defaultModel "anthropic/claude-3-opus"

# Set Discord to balance cost/quality (group usage)
openclaw config set discord.defaultModel "openai/gpt-4-turbo"
```

### Why This Matters: Context-Appropriate Defaults

**Telegram (mobile):** Fast responses more important than perfect quality
**Discord (social):** Good balance of capability and cost
**CLI (deep work):** Premium quality for complex tasks

This ensures you get appropriate responses without constantly specifying models manually.

## Dynamic Model Switching

The `/model` command lets you switch models on-demand:

### Basic Model Commands

```bash
# See current model
/model

# List available models  
/model list

# Switch to specific model
/model anthropic/claude-3-opus

# Switch by tier
/model premium
/model standard  
/model fast

# Switch for one message only
/model openai/gpt-4-turbo "Analyze this complex financial document..."
```

### Advanced Model Selection

```bash
# Switch with reasoning
/model anthropic/claude-3-opus reasoning:on

# Switch with cost limit
/model openai/gpt-4-turbo maxcost:0.50

# Switch with context window
/model anthropic/claude-3-opus context:200000

# Temporary model with auto-revert
/model temp anthropic/claude-3-opus
```

### Automatic Model Selection

OpenClaw can automatically choose models based on task characteristics:

```json
{
  "autoModelSelection": {
    "enabled": true,
    "rules": [
      {
        "trigger": "code generation|programming|debug",
        "model": "anthropic/claude-3.5-sonnet"
      },
      {
        "trigger": "image analysis|photo|picture", 
        "model": "openai/gpt-4-vision"
      },
      {
        "trigger": "quick question|simple|fast",
        "model": "anthropic/claude-3-haiku"
      },
      {
        "trigger": "complex analysis|research|detailed",
        "model": "anthropic/claude-3-opus"
      }
    ]
  }
}
```

This analyzes your message content and automatically routes to the most appropriate model.

## Understanding Tokens, Context Windows, and Pricing

Tokens are the fundamental unit of AI model billing and capability.

### What Are Tokens?

**Tokens** are chunks of text that models process. Roughly:
- 1 token = 0.75 English words  
- 1 token = 4 characters
- "Hello world" = 2 tokens
- This paragraph = ~50 tokens

**Context window** is the maximum tokens a model can process in one request (input + output combined).

**Token limits by model:**
```
GPT-4 Turbo: 128,000 tokens (~100 pages)
Claude-3.5 Sonnet: 200,000 tokens (~150 pages)  
Claude-3 Opus: 200,000 tokens (~150 pages)
Gemini Pro: 2,000,000 tokens (~1,500 pages)
```

### Pricing Structure Deep Dive

All major providers use **input/output token pricing:**

**Input tokens:** What you send (your message + context)
**Output tokens:** What the AI generates (response)

**Example pricing (March 2024):**
```
Claude-3.5 Sonnet:
  Input: $0.003 per 1,000 tokens  
  Output: $0.015 per 1,000 tokens (5x more expensive)

GPT-4 Turbo:
  Input: $0.01 per 1,000 tokens
  Output: $0.03 per 1,000 tokens (3x more expensive)
```

**Why output costs more:** Generating text requires more computational work than understanding it.

### Real Usage Cost Examples

**Simple question:**
```
You: "What's the weather in Austin?" (8 tokens)
Context: Your workspace files (2,000 tokens)  
AI Response: "It's 75°F and sunny..." (50 tokens)

Cost calculation (Claude-3.5 Sonnet):
Input: 2,008 tokens × $0.003/1K = $0.006
Output: 50 tokens × $0.015/1K = $0.0007
Total: $0.0067 (~$0.007)
```

**Complex research:**
```
You: "Research Tesla's competitive position..." (200 tokens)
Context: Workspace + memory files (10,000 tokens)
AI Response: Comprehensive analysis (5,000 tokens)

Cost calculation:
Input: 10,200 tokens × $0.003/1K = $0.031
Output: 5,000 tokens × $0.015/1K = $0.075  
Total: $0.106 (~$0.11)
```

**Daily briefing automation:**
```
System: Morning briefing prompt (500 tokens)
Context: Yesterday's events + preferences (15,000 tokens)
AI Response: Structured briefing (3,000 tokens)

Cost: ~$0.09 per briefing
Monthly cost: ~$2.70 for daily briefings
```

### Cost Optimization Strategies

**Minimize context bloat:**
- Keep workspace files concise
- Archive old conversation history
- Use targeted memory searches instead of loading everything

**Optimize prompts:**
- Be specific to avoid rambling responses
- Use structured output formats
- Request summaries instead of full analysis when appropriate

**Strategic model routing:**
- Simple tasks → cheap models
- Complex reasoning → premium models  
- Batch similar requests together

## Cost Tracking and Budget Management

Real-time cost visibility prevents surprise bills and enables optimization.

### Built-in Cost Tracking

OpenClaw tracks costs automatically:

```bash
# Current usage
/cost

# Detailed breakdown  
/cost detailed

# Set budget alerts
/cost budget 50 # Alert when approaching $50/month

# Export usage data
/cost export march-2024.csv
```

**Sample cost report:**
```
💰 API Cost Summary - March 2024

Today: $3.47
  • Model calls: $2.89 (83%)
  • Tool usage: $0.58 (17%)

This week: $18.32
This month: $67.89

Top expenses:
  1. Claude-3.5 Sonnet: $45.23 (67%)
  2. GPT-4 Turbo: $15.67 (23%)  
  3. Tools/APIs: $6.99 (10%)

Avg cost per conversation: $0.23
Most expensive session: $4.56 (financial research)
```

### Budget Alert Configuration

```json
{
  "budgetAlerts": {
    "daily": {
      "warning": 5.00,
      "critical": 10.00
    },
    "monthly": {
      "warning": 100.00,
      "critical": 200.00  
    },
    "notificationChannels": ["telegram", "email"],
    "autoThrottling": {
      "enabled": true,
      "fallbackModel": "anthropic/claude-3-haiku"
    }
  }
}
```

When you approach budget limits:
1. **Warning alert** sent to your Telegram
2. **Model downgrade** to cheaper alternatives
3. **Critical alert** with option to pause automation
4. **Detailed usage report** with optimization recommendations

### Provider-Level Cost Management

**Set spending limits at the source:**

**OpenRouter:**
- Account → Billing → Set monthly limit
- Receive alerts at 80% and 95% usage

**OpenAI:**  
- Usage → Limits → Set soft and hard limits
- Automatic suspension when limit reached

**Anthropic:**
- Console → Billing → Usage alerts
- Email notifications for spending thresholds

**Why this matters:** Provider-level limits prevent runaway costs from system bugs or automation loops.

## Building Your Personal Cost Optimization Strategy

Your optimization strategy depends on usage patterns and budget constraints.

### Usage Pattern Analysis

Track your patterns for 2 weeks, then optimize:

**High-frequency, low-complexity** (daily briefings, alerts)
→ Route to cheap models (Claude-3 Haiku, GPT-3.5 Turbo)

**Medium-frequency, medium-complexity** (research, analysis)  
→ Route to standard models (Claude-3.5 Sonnet, GPT-4 Turbo)

**Low-frequency, high-complexity** (strategic planning, complex reasoning)
→ Route to premium models (Claude-3 Opus)

### Budget-Based Strategy Templates

**Budget: $25/month (Casual User)**
```json
{
  "defaultModel": "anthropic/claude-3-haiku",
  "upgradeThreshold": "complex analysis|detailed research",
  "premiumModel": "anthropic/claude-3.5-sonnet", 
  "dailyBudget": 0.83,
  "autoThrottling": true
}
```

**Budget: $100/month (Power User)**
```json
{  
  "defaultModel": "anthropic/claude-3.5-sonnet",
  "premiumModel": "anthropic/claude-3-opus",
  "dailyBudget": 3.33,
  "batchOptimization": true,
  "contextCaching": true
}
```

**Budget: $300/month (Professional)**
```json
{
  "defaultModel": "anthropic/claude-3.5-sonnet",
  "premiumModel": "anthropic/claude-3-opus", 
  "specializedModels": {
    "code": "openai/gpt-4-turbo",
    "vision": "openai/gpt-4-vision"  
  },
  "preemptiveUpgrade": true
}
```

### ROI Calculation Framework

Calculate the value of AI automation:

**Time saved calculation:**
```
Weekly hours saved: 10 hours
Hourly value of your time: $50  
Weekly value created: $500
Monthly value: $2,000

AI costs: $150/month  
ROI: ($2,000 - $150) / $150 = 1,233% ROI
```

**Opportunity cost analysis:**
- What could you do with 10 extra hours per week?
- New business development?
- Higher-value client work?  
- Personal time (also has value)

This framework justifies higher AI spending when it creates proportional value.

## Model Comparison: Real Benchmarks

Theoretical capabilities matter less than real-world performance on your tasks.

### Comprehensive Model Benchmark

**Test Task: Stock Analysis**
Prompt: "Analyze Tesla's Q4 2023 earnings and provide investment recommendation"

| Model | Response Time | Cost | Quality Score | Accuracy |  
|-------|-------------|------|---------------|----------|
| Claude-3 Opus | 45s | $0.18 | 9.5/10 | 95% |
| GPT-4 Turbo | 32s | $0.12 | 9.0/10 | 92% |  
| Claude-3.5 Sonnet | 28s | $0.08 | 9.2/10 | 93% |
| Gemini Pro | 22s | $0.04 | 8.0/10 | 87% |
| Claude-3 Haiku | 15s | $0.02 | 7.5/10 | 82% |

**Winner:** Claude-3.5 Sonnet (best value ratio)

**Test Task: Code Generation**  
Prompt: "Write Python script to analyze CSV financial data"

| Model | Response Time | Cost | Code Quality | Runs Without Bugs |
|-------|-------------|------|-------------|------------------|
| GPT-4 Turbo | 38s | $0.15 | 9.5/10 | 95% |
| Claude-3.5 Sonnet | 41s | $0.09 | 9.8/10 | 98% |
| Claude-3 Opus | 52s | $0.22 | 9.0/10 | 90% |
| CodeLlama 70B | 25s | $0.05 | 8.5/10 | 85% |

**Winner:** Claude-3.5 Sonnet (best code quality + reliability)

### Your Personal Benchmark Process

Create your own benchmarks with tasks you actually do:

1. **Define 5 representative tasks** from your work
2. **Test each model** on the same tasks  
3. **Score** on response quality, speed, cost
4. **Calculate** total cost for typical weekly usage
5. **Choose** primary and fallback models based on data

**Benchmark tracking template:**
```json
{
  "personalBenchmarks": {
    "emailSummary": {
      "claude-3.5-sonnet": {"time": 15, "cost": 0.03, "quality": 9},
      "gpt-4-turbo": {"time": 18, "cost": 0.05, "quality": 8.5}
    },
    "stockResearch": {
      "claude-3-opus": {"time": 45, "cost": 0.18, "quality": 9.5},
      "claude-3.5-sonnet": {"time": 28, "cost": 0.08, "quality": 9.2}
    }
  }
}
```

## Pro Tips: Engine Optimization

💡 **Start cheap, upgrade selectively.** Begin with Claude-3 Haiku or GPT-3.5 Turbo for everything. When you hit quality limits, upgrade specific use cases to better models.

💡 **Batch similar requests.** Instead of 5 separate stock lookups, send one request analyzing all 5 stocks. Reduces per-request overhead.

💡 **Use structured output.** JSON or markdown format responses are easier to parse and often shorter than prose, saving output token costs.

💡 **Cache expensive responses.** Store research results, analysis, or complex calculations locally to avoid re-generating the same content.

💡 **Monitor provider reliability.** Track which providers have outages or slowdowns. Have backup providers configured for critical workflows.

## Troubleshooting: Common Configuration Issues

### Problem: Model not found or unavailable

**Diagnosis:** Model name incorrect or provider access issue.
**Fix:**
```bash
# Check available models
/model list

# Verify API key has access
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://api.openai.com/v1/models

# Check provider status
openclaw provider status openai
```

### Problem: Responses too expensive

**Diagnosis:** Using premium models for simple tasks.
**Fix:**
- Set daily budget limits: `/cost budget 5.00`  
- Enable auto-downgrade: `openclaw config set autoDowngrade true`
- Review large context usage: `/debug context`
- Optimize workspace file sizes

### Problem: Responses too slow  

**Diagnosis:** Network latency or model overload.
**Fix:**
- Switch to faster models temporarily
- Use multiple providers with failover
- Enable response streaming: `openclaw config set streaming true`
- Check network connectivity: `ping api.openai.com`

### Problem: Quality inconsistency

**Diagnosis:** Random model selection or context issues.
**Fix:**
- Lock to specific model for important tasks
- Check context window limits: `/debug tokens`
- Review and optimize system prompts
- Use temperature setting: `/model claude-3.5-sonnet temp:0.3`

### Problem: Budget alerts not working

**Diagnosis:** Configuration issue or tracking disabled.
**Fix:**
```bash
# Enable cost tracking  
openclaw config set costTracking.enabled true

# Set alert thresholds
openclaw config set budgetAlerts.daily.warning 5.00

# Test alert system
openclaw cost test-alert

# Check notification channels
openclaw config show | grep notification
```

## Try This: Model Optimization Exercise

Complete this exercise to build your personal model strategy:

### Week 1: Baseline Measurement

**Day 1-2: Default usage**
- Use Claude-3.5 Sonnet for everything
- Track costs with `/cost detailed` each day
- Note response quality and speed

**Day 3-7: Task categorization**
- Categorize each request: Simple/Medium/Complex
- Time each response  
- Rate quality 1-10
- Calculate cost per category

### Week 2: Strategy Testing

**Day 8-10: Tiered routing**
```bash
# Configure tiers
/model fast   # for simple questions
/model standard # for normal tasks  
/model premium # for complex analysis
```

**Day 11-14: Optimization**
- A/B test different models for same task types
- Measure cost savings vs quality loss
- Find your optimal model for each category

### Results Analysis

Create your personal model routing strategy:

```json
{
  "myOptimalRouting": {
    "simple": {
      "model": "anthropic/claude-3-haiku",
      "avgCost": 0.02,
      "qualityScore": 7.5
    },
    "standard": {  
      "model": "anthropic/claude-3.5-sonnet",
      "avgCost": 0.08,
      "qualityScore": 9.2
    },
    "complex": {
      "model": "anthropic/claude-3-opus", 
      "avgCost": 0.18,
      "qualityScore": 9.5
    }
  }
}
```

### ✅ Optimization Verification Checklist

- [ ] Baseline costs measured for 1 week
- [ ] 3+ models tested on identical tasks
- [ ] Personal benchmark data collected
- [ ] Budget alerts configured and tested
- [ ] Model routing strategy documented
- [ ] Cost vs quality tradeoffs understood
- [ ] Backup providers configured
- [ ] Usage patterns analyzed and optimized

## What's Next

Chapter 5 covers API integration - connecting your AI to external data sources like stock APIs, news feeds, weather services, and databases. You'll learn to give your AI "senses" and "tools" that dramatically expand its capabilities beyond pure conversation.

Your engine configuration is now optimized for your usage patterns and budget. The next step is connecting external APIs so your AI can access real-time data and take actions in the world - the foundation of true automation.

Make sure your model routing is working consistently before proceeding. The verification checklist above should all pass. Chapter 5 builds on this foundation with more complex integrations that rely on stable model performance.

---

*Next: Chapter 5 - API Integration*