# Chapter 12: Advanced Memory
## Context Management at Scale

---

### Beyond Simple Memory Files

The basic memory system from Chapter 6 works for personal use. But when you're running a business operation — multiple projects, trading positions, client work, content schedules — you need structured context management.

This chapter introduces three advanced memory systems:

1. **Active Context** — What's happening right now
2. **Task Queue** — What needs to happen next
3. **Credential Vault** — Secure reference index for all your keys

### System 1: Active Context

Create `~/.openclaw/memory/active-context.json`:

```json
{
  "lastSession": {
    "date": "2026-03-08",
    "summary": "Completed API toolchain setup. All 9/9 services verified.",
    "pendingFollowUp": ["Create trading cron job", "Test email automation"]
  },
  "activeProjects": [
    {
      "name": "erronatus-website",
      "status": "deployed",
      "lastUpdate": "2026-03-08",
      "nextAction": "Add Stripe products, connect custom domain"
    },
    {
      "name": "trading-bot",
      "status": "in-progress",
      "lastUpdate": "2026-03-08",
      "nextAction": "Set up RSI monitoring cron job"
    }
  ],
  "openPositions": [],
  "dailyBudgetUsed": 2.35,
  "importantDates": [
    { "date": "2026-03-15", "event": "Project deadline" }
  ]
}
```

Your AI reads this on session start to instantly know:
- What was the last thing you worked on
- What projects are active and their status
- What follow-up items are pending
- What positions are open
- How much budget has been used today

### System 2: Task Queue

Create `~/.openclaw/memory/tasks/task-queue.json`:

```json
{
  "queue": [
    {
      "id": "task-001",
      "priority": "high",
      "title": "Set up RSI monitoring cron for watchlist",
      "description": "Create cron job: every 2h, market hours, check AAPL/TSLA/NVDA/AMZN/GOOGL RSI",
      "created": "2026-03-08",
      "status": "pending",
      "assignedTo": "cron"
    },
    {
      "id": "task-002",
      "priority": "medium",
      "title": "Create Stripe products for Blueprint",
      "description": "Personal ($47), Business ($97), Enterprise ($299) — one-time payments",
      "created": "2026-03-08",
      "status": "pending",
      "assignedTo": "manual"
    }
  ],
  "completed": [
    {
      "id": "task-000",
      "title": "Verify all API connections",
      "completed": "2026-03-08",
      "result": "9/9 pass"
    }
  ]
}
```

Your AI maintains this queue:
- New tasks get added when you mention them
- Completed tasks move to the `completed` array
- Priority determines what gets suggested first
- Your AI can proactively say: "You have 2 high-priority tasks pending. Want to tackle the RSI monitoring setup?"

### System 3: Credential Vault Index

Create `~/.openclaw/memory/credentials/vault.json`:

```json
{
  "credentials": [
    {
      "service": "Alpaca",
      "type": "paper-trading",
      "envKeys": ["ALPACA_API_KEY", "ALPACA_SECRET_KEY"],
      "status": "active",
      "lastVerified": "2026-03-08",
      "notes": "Paper account. $100k buying power."
    },
    {
      "service": "Stripe",
      "type": "payment-processing",
      "envKeys": ["STRIPE_SECRET_KEY", "STRIPE_PUBLISHABLE_KEY"],
      "status": "active",
      "lastVerified": "2026-03-08",
      "notes": "Live keys. Balance: $0.00"
    }
  ],
  "totalCredentials": 22,
  "lastFullAudit": "2026-03-08"
}
```

This is a reference index — it doesn't store the actual keys (those stay in `.env`). It tracks what credentials you have, their status, and when they were last verified. Your AI can reference this to know what services are available without reading the `.env` file directly.

### Boot File: Session Initialization

Create `~/.openclaw/boot.md` — a comprehensive context file loaded on every session start:

```markdown
# Boot Context

## Who I Am
[AI name and role]

## Engine Routing Rules
[Model tiers and routing logic]

## API Toolchain
[Available functions and their locations]

## Active Context
[Current project statuses and priorities]

## Key File Locations
[Paths to all important files]

## Standing Instructions
[Rules that always apply]
```

This single file gives your AI complete operational awareness within the first few seconds of every session. No warm-up period. No asking "what were we working on?" It knows.

### Memory Maintenance Automation

Create a daily cron job for memory maintenance:

**Schedule:** Every day at 11 PM
**Task:**
1. Read today's daily log
2. Extract significant events, decisions, and outcomes
3. Update active-context.json with current project states
4. Move completed tasks from queue to completed
5. Update MEMORY.md if any long-term insights emerged
6. Verify no sensitive data leaked into memory files

This runs automatically. Your memory system stays clean, organized, and current without manual intervention.

### Project-Specific Memory

For larger projects, create dedicated memory directories:

```
~/.openclaw/memory/
├── projects/
│   ├── index.json              ← Project registry
│   ├── erronatus-website/
│   │   ├── decisions.md        ← Key decisions and rationale
│   │   ├── architecture.md     ← System design notes
│   │   └── changelog.md        ← What changed and when
│   └── trading-bot/
│       ├── strategy.md         ← Trading strategy documentation
│       ├── performance.md      ← Performance tracking
│       └── rules.md            ← Risk management rules
```

Your AI can navigate this structure to find relevant context for any project without loading everything into memory at once.

### What You've Built

✅ Active context system for instant session awareness
✅ Task queue with priority management
✅ Credential vault index for service tracking
✅ Boot file for comprehensive session initialization
✅ Automated memory maintenance via cron
✅ Project-specific memory directories
✅ A memory system that scales with your operation

---

*Next Chapter: Custom Skill Development →*
