# Chapter 7: Automation
## Cron Jobs & Scheduled Tasks

---

### From Reactive to Proactive

Up to now, your AI responds when you message it. That's reactive. The real power comes when your AI acts on its own — checking data, sending alerts, and executing tasks on a schedule without any input from you.

This is the layer that turns an assistant into a workforce.

### Understanding Cron Jobs

A cron job is a scheduled task that executes automatically at specified times. OpenClaw's cron system supports three schedule types:

**One-shot timers:**
"Run this task in 20 minutes"
```json
{ "kind": "at", "at": "2026-03-08T20:30:00Z" }
```

**Recurring intervals:**
"Run this task every 4 hours"
```json
{ "kind": "every", "everyMs": 14400000 }
```

**Cron expressions:**
"Run every weekday at 8 AM Central"
```json
{ "kind": "cron", "expr": "0 8 * * 1-5", "tz": "America/Chicago" }
```

### Your First Cron Job: Morning Briefing

Let's build the most useful automation first — a daily morning briefing that arrives in your inbox before you start your day.

Tell your AI:

```
Create a cron job that runs every morning at 8 AM Central time.
It should:
1. Check today's top 5 business headlines
2. Search for any news about AI automation
3. Summarize everything into a clean briefing
4. Send it to me via Telegram
```

Your AI will create the cron job with a schedule and task definition. The result: every morning at 8 AM, you receive a formatted news briefing in Telegram without lifting a finger.

### Building Common Automations

Here are the most valuable cron jobs for personal use:

#### Weather Alert (Morning)
**Schedule:** Every day at 7 AM
**Task:** Check the weather forecast. If rain is expected, alert me. Otherwise, don't bother.

This is a smart automation — it only contacts you when there's something worth knowing.

#### Weekly Review (Sunday Evening)
**Schedule:** Every Sunday at 8 PM
**Task:** Summarize this week's memory files. What was accomplished? What's pending? What should I focus on next week?

Your AI reads the week's daily logs and produces a structured review. It's like having a personal chief of staff.

#### Market Check (Business Hours)
**Schedule:** Every 2 hours, 9 AM to 4 PM, weekdays
**Task:** Check RSI indicators for my watchlist. Only alert me if any symbol crosses above 70 or below 30.

This is conditional automation — your AI checks, but only interrupts you when action might be needed.

#### Daily Memory Maintenance
**Schedule:** Every day at 11 PM
**Task:** Review today's memory file. Extract any important information and update MEMORY.md. Clean up temporary notes.

This keeps your memory system healthy without manual intervention.

### Cron Job Management

**List all jobs:**
```
What cron jobs are currently active?
```

**Pause a job:**
```
Pause the morning briefing cron job
```

**Delete a job:**
```
Remove the weather alert cron job
```

**Run a job immediately:**
```
Run the morning briefing now (don't wait for the schedule)
```

### Heartbeat System

Beyond cron jobs, OpenClaw has a heartbeat system — periodic check-ins where your AI can proactively do useful work.

Create a `HEARTBEAT.md` file in your workspace:

```markdown
# HEARTBEAT.md

## Checks to perform (rotate through these):
- [ ] Check for urgent news about topics I follow
- [ ] Review pending tasks in memory
- [ ] Check if any memory maintenance is needed
```

When the heartbeat fires (typically every 30-60 minutes), your AI reads HEARTBEAT.md and performs the listed checks. If something needs attention, it messages you. If not, it stays quiet.

The key principle: **your AI should reach out when it has something useful to say, and stay silent when it doesn't.** Nobody wants an AI that messages "nothing new!" every 30 minutes.

### Smart Automation Principles

1. **Conditional alerts** — Don't alert on every check. Alert only when thresholds are crossed or anomalies detected.

2. **Batch operations** — Combine multiple checks into one cron job instead of creating many separate jobs.

3. **Quiet hours** — Configure your AI to suppress non-urgent alerts between 11 PM and 7 AM.

4. **Escalation** — Low-priority items get logged. Medium-priority items get a notification. High-priority items get immediate attention.

5. **Cost awareness** — Use cheap models (DeepSeek, Flash) for cron jobs. They run unattended and don't need premium reasoning.

### Testing Your Automations

After creating a cron job, test it before waiting for the schedule:

```
Run the morning briefing cron job now
```

This executes the task immediately so you can verify the output format, content quality, and delivery.

Check if automations ran successfully:
```
Show me the results of the last cron job execution
```

### What You've Automated

At the end of this chapter, you have:

✅ Morning briefing delivering news to your inbox daily
✅ Understanding of cron expressions and scheduling
✅ Conditional automation that only alerts when necessary
✅ Heartbeat system for periodic background work
✅ Smart automation principles for building more

This is where the compound effect kicks in. Every automation you add runs without ongoing effort. After a month, you'll have dozens of small automations doing useful work around the clock.

---

*Next Chapter: Deployment — Going Live on Vercel →*
