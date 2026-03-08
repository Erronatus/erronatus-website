# Chapter 4: Engine Configuration
## Choosing Your AI Models

---

### Why Model Selection Matters

Not all AI models are created equal. Some are fast and cheap. Others are slow and brilliant. The key to an efficient automation system is using the **right model for each task**.

Running everything through Claude Opus (the most powerful model available) is like hiring a brain surgeon to answer your phone calls. It works, but it's expensive and unnecessary.

Smart engine configuration means:
- **Free models** handle quick lookups and status checks
- **Low-cost models** handle parsing, summaries, and routine automation
- **Mid-tier models** handle research, coding, and analysis
- **Premium models** handle complex strategy and architecture only when needed

The result: you get premium intelligence when it matters and spend almost nothing on routine tasks.

### Understanding AI Providers

OpenClaw supports multiple AI providers through a unified interface:

| Provider | Key Models | Strength | Cost |
|----------|-----------|----------|------|
| **OpenRouter** | Access to 100+ models | One key, many models | Varies |
| **Anthropic** | Claude Sonnet, Opus | Best reasoning | $$ - $$$ |
| **OpenAI** | GPT-4o, GPT-4o-mini | Versatile, fast | $ - $$ |
| **Google** | Gemini Flash, Pro | Free tier available | Free - $$ |
| **DeepSeek** | DeepSeek V3 | Excellent value | $ |

**Our recommendation for beginners:** Start with OpenRouter. One API key gives you access to models from every provider. You can experiment with different models and find what works best for your use cases.

### Configuring Your Default Model

Your default model handles most interactions. Set it in `config.yaml`:

```yaml
model: anthropic/claude-sonnet-4-20250514
```

Claude Sonnet is the best all-around choice:
- Excellent at coding, research, and analysis
- Good at following complex instructions
- Reasonable cost ($3 per million input tokens)
- Fast enough for real-time conversation

### Setting Up Model Aliases

OpenClaw supports aliases for quick model switching. Add these to your configuration:

```yaml
aliases:
  flash: openrouter/google/gemini-2.0-flash-lite-001    # Free
  deepseek: openrouter/deepseek/deepseek-v3.2           # Budget
  sonnet: anthropic/claude-sonnet-4-20250514              # Standard
  opus: anthropic/claude-opus-4-6                         # Premium
  gpt: openai/gpt-4o                                     # Alternative
  mini: openai/gpt-4o-mini                               # Budget alternative
```

Now you can switch models on the fly:
- `/model flash` — Switch to the free model for quick tasks
- `/model sonnet` — Switch back to standard for complex work
- `/model opus` — Engage premium reasoning for important decisions

### Model Selection Guide

Here's how to think about which model to use:

**Use Flash (Free) when:**
- Checking the weather
- Simple math or conversions
- Quick factual lookups
- "What time is it in Tokyo?"
- Status checks and system monitoring

**Use DeepSeek ($) when:**
- Summarizing articles or documents
- Parsing data into structured formats
- Running cron job automations
- Basic code generation
- Email drafting

**Use Sonnet ($$) when:**
- Writing code for projects
- Research and analysis
- Debugging complex issues
- Blog writing and content creation
- Planning and project management

**Use Opus ($$$) when:**
- Architectural decisions for large projects
- Complex financial analysis
- Strategic planning and business decisions
- Multi-step reasoning problems
- Anything where the cost of being wrong exceeds the cost of the model

### Cost Management

Set a daily budget to prevent runaway spending:

You can track your spending with:
```
/status
```

This shows token usage, model distribution, and estimated cost for the current session.

**Cost optimization tips:**
1. Start every session on your default model (Sonnet)
2. Switch to Flash for quick lookups mid-conversation
3. Only invoke Opus when you explicitly need deep reasoning
4. Use cron jobs on DeepSeek — they run unattended and don't need premium models
5. Monitor your daily spend and adjust routing as needed

### Testing Your Configuration

Let's verify your models are working:

**Test 1: Default Model**
Send a message to your AI: "Explain quantum computing in 3 sentences."
Expected: A thoughtful, well-structured response from your default model.

**Test 2: Model Switching**
Send: "/model flash"
Then: "What's 2 + 2?"
Expected: A quick response from the free model.

**Test 3: Switch Back**
Send: "/model sonnet"
Then: "Write a Python function that calculates compound interest."
Expected: A detailed, working code response from Sonnet.

### What You've Configured

At the end of this chapter, you have:

✅ A default AI model set for general use
✅ Model aliases configured for quick switching
✅ Understanding of when to use each model tier
✅ Cost management awareness
✅ Multiple models tested and verified

Your AI now has flexible intelligence — it can be economical for routine tasks and brilliant for complex ones. In the next chapter, we'll give it the ability to interact with the outside world through APIs.

---

*Next Chapter: API Integration — Connecting Your First 5 Services →*
