# Chapter 9: Multi-Engine Routing
## The Cost Optimization Playbook

---

### Beyond Manual Model Switching

In Chapter 4, you learned to switch models manually with `/model flash` or `/model sonnet`. That works for interactive use. But for a business operation running dozens of automated tasks daily, manual switching is inefficient and error-prone.

Multi-engine routing automates model selection. You define rules. Your system picks the cheapest capable model for every task automatically.

### The Routing Architecture

```
┌─────────────────────────┐
│    Incoming Task         │
├─────────────────────────┤
│    Route Classifier      │ ← What type of task is this?
├─────────────────────────┤
│    Engine Selection      │ ← Which model handles this tier?
├─────────────────────────┤
│    Budget Check          │ ← Are we within daily limits?
├─────────────────────────┤
│    Execute & Log         │ ← Run task, record cost
└─────────────────────────┘
```

### Defining Your Engine Tiers

Create an engine routing configuration. Here's the production-tested setup we use:

| Tier | Alias | Model | Cost/1M tokens | Use Case |
|------|-------|-------|----------------|----------|
| **Free** | flash | Gemini 2.0 Flash Lite | $0.00 | Status, weather, simple lookups |
| **Budget** | deepseek | DeepSeek V3.2 | $0.27 input / $1.10 output | Parsing, summaries, cron jobs |
| **Standard** | sonnet | Claude Sonnet 4 | $3.00 / $15.00 | Research, coding, analysis |
| **Premium** | opus | Claude Opus 4 | $15.00 / $75.00 | Strategy, architecture, complex reasoning |

The cost difference is massive. A task that costs $0.10 on Opus costs $0.001 on DeepSeek. That's 100x savings for tasks that don't need premium reasoning.

### Configuring the Router

Create `~/.openclaw/engine-router.json`:

```json
{
  "defaultEngine": "sonnet",
  "dailyBudget": 15.00,
  "warnThreshold": 0.80,
  "hardStopFallback": "flash",
  "tiers": {
    "free": {
      "model": "openrouter/google/gemini-2.0-flash-lite-001",
      "maxCostPerCall": 0,
      "tasks": ["status", "weather", "time", "simple_math", "health_check"]
    },
    "budget": {
      "model": "openrouter/deepseek/deepseek-v3.2",
      "maxCostPerCall": 0.01,
      "tasks": ["summarize", "parse", "cron", "monitor", "draft", "format"]
    },
    "standard": {
      "model": "anthropic/claude-sonnet-4-20250514",
      "maxCostPerCall": 0.10,
      "tasks": ["research", "code", "analyze", "write", "debug", "plan"]
    },
    "premium": {
      "model": "anthropic/claude-opus-4-6",
      "maxCostPerCall": 1.00,
      "tasks": ["strategy", "architecture", "financial_model", "complex_reasoning"]
    }
  },
  "fallbackChain": ["sonnet", "deepseek", "mini", "flash"]
}
```

### Budget Management

The budget system prevents runaway costs:

- **Daily budget: $15.00** — Total spend cap per 24-hour period
- **Warning at 80% ($12.00)** — Your AI notifies you and starts preferring cheaper models
- **Hard stop at 100% ($15.00)** — All tasks fall back to the free tier
- **Fallback chain** — If the selected model fails, try the next one in the chain

**Cost logging:**

Every API call gets logged to `~/.openclaw/logs/cost-log.jsonl`:

```json
{"timestamp":"2026-03-08T14:30:00Z","model":"sonnet","tokens_in":1500,"tokens_out":800,"cost":0.0165,"task":"code_review"}
{"timestamp":"2026-03-08T14:31:00Z","model":"deepseek","tokens_in":2000,"tokens_out":500,"cost":0.0011,"task":"summarize_email"}
```

This gives you full visibility into where your money goes. After a week of logging, you'll know exactly which tasks consume the most budget and where to optimize.

### Real-World Cost Analysis

Here's a typical day for a business user with smart routing:

| Time | Task | Model | Cost |
|------|------|-------|------|
| 8:00 | Morning briefing (cron) | deepseek | $0.003 |
| 8:05 | Weather check | flash | $0.000 |
| 9:00 | Code review | sonnet | $0.045 |
| 10:00 | Market scan (cron) | deepseek | $0.002 |
| 11:00 | Research task | sonnet | $0.060 |
| 12:00 | Market scan (cron) | deepseek | $0.002 |
| 13:00 | Email draft | deepseek | $0.004 |
| 14:00 | Market scan (cron) | deepseek | $0.002 |
| 15:00 | Architecture decision | opus | $0.350 |
| 16:00 | Market scan (cron) | deepseek | $0.002 |
| 17:00 | Blog post writing | sonnet | $0.080 |
| 21:00 | Evening review (cron) | deepseek | $0.005 |
| 23:00 | Memory maintenance (cron) | flash | $0.000 |
| **Total** | | | **$0.555** |

That's 55 cents for a full day of AI operations across 13 tasks. Even on heavy days with multiple Opus calls, you'll rarely exceed $5-10.

Compare that to:
- ChatGPT Pro subscription: $200/month (no automation)
- Claude Pro subscription: $20/month (no automation)
- Virtual assistant: $15-30/hour
- Custom AI SaaS: $500-2000/month

### Optimization Strategies

**1. Cron jobs always use budget tier**
Cron jobs run unattended. They don't need premium reasoning — they need to check data, format results, and deliver. DeepSeek handles this perfectly at 1/10th the cost.

**2. Reserve premium for decision-making**
The only tasks that justify Opus pricing are decisions with significant consequences: trading strategies, architectural choices, financial projections, legal analysis.

**3. Use context to reduce tokens**
Longer prompts cost more. Keep your system prompts concise. Use memory references instead of pasting full context into every message.

**4. Batch similar tasks**
Instead of 5 separate market checks, run one cron job that checks all 5 symbols and reports together.

**5. Monitor and adjust weekly**
Review your cost log every week. Identify any tasks running on more expensive models than necessary and adjust routing.

### What You've Optimized

At the end of this chapter, you have:

✅ Automatic model routing based on task complexity
✅ Daily budget with warning thresholds and hard stops
✅ Cost logging for full spending visibility
✅ Fallback chain for reliability
✅ Production-tested routing configuration

Your AI now makes smart economic decisions about which brain to use for each task. The savings compound daily.

---

*Next Chapter: The Full API Toolchain →*
