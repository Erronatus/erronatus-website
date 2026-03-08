# Chapter 6: Memory Systems
## Giving Your AI a Brain

---

### The Amnesia Problem

Here's the dirty secret of AI assistants: they forget everything.

Every time you start a new session with ChatGPT, Claude, or any AI tool, it has zero memory of previous conversations. You're starting from scratch every single time. That's fine for one-off questions, but it's fatal for automation.

An automation system needs to remember:
- What you discussed yesterday
- What projects are in progress
- What your preferences are
- What happened in previous sessions
- What tasks are pending

OpenClaw solves this with a file-based memory system. Your AI reads and writes memory files that persist across sessions. When it wakes up, it reads its memory. When something important happens, it writes it down.

### How Memory Works

OpenClaw's memory system has three layers:

```
┌──────────────────────────────────────┐
│           MEMORY.md                  │ ← Curated long-term memory
│    (The important stuff, distilled)  │
├──────────────────────────────────────┤
│      memory/YYYY-MM-DD.md            │ ← Daily logs
│    (Raw notes from each day)         │
├──────────────────────────────────────┤
│         Session Context              │ ← Current conversation
│    (In-memory, resets each session)  │
└──────────────────────────────────────┘
```

**Session Context** is automatic — OpenClaw maintains context within a conversation. You don't need to configure anything.

**Daily Logs** are semi-automatic. Your AI writes to `memory/YYYY-MM-DD.md` during sessions. You can also write to them manually or ask your AI to record specific things.

**Long-term Memory (MEMORY.md)** is curated. This is the distilled essence of everything important. Your AI should periodically review daily logs and update MEMORY.md with the insights worth keeping permanently.

### Setting Up the Memory Structure

Your workspace should already have:

```
~/.openclaw/workspace/
├── MEMORY.md           ← Long-term memory (create if missing)
├── memory/             ← Daily logs directory (create if missing)
│   └── .gitkeep
```

If the `memory/` directory doesn't exist, create it:
```bash
mkdir -p ~/.openclaw/workspace/memory
```

### Configuring Memory Behavior

In your `AGENTS.md`, add memory instructions:

```markdown
## Memory Protocol

### Every Session Start
1. Read MEMORY.md for long-term context
2. Read memory/YYYY-MM-DD.md for today's notes
3. Read yesterday's notes if today's file is empty

### During Sessions
- Write significant events to today's daily log
- Record decisions, outcomes, and lessons learned
- Note any tasks that were completed or created
- Log API results that might be useful later

### Memory Maintenance
- Periodically review recent daily logs
- Update MEMORY.md with important long-term information
- Remove outdated information from MEMORY.md
- Keep MEMORY.md concise and organized
```

### What to Remember

Not everything needs to be stored. Here's a framework:

**Always record:**
- Decisions and the reasoning behind them
- Project milestones and status changes
- New preferences or requirements you mention
- Errors encountered and how they were resolved
- API configuration changes
- Important dates and deadlines

**Skip:**
- Casual conversation
- Information easily found online
- Temporary data that expires quickly
- Sensitive credentials (never store in memory files)

### The Memory Lifecycle

Here's how memory flows through the system:

**Day 1:**
You have a conversation about setting up a trading bot.

Your AI writes to `memory/2026-03-08.md`:
```markdown
# 2026-03-08

## Trading Bot Discussion
- User wants to monitor AAPL, TSLA, NVDA
- RSI-based alerts when crossing 70 or 30
- Paper trading only for now
- Check every 2 hours during market hours
```

**Day 7:**
Your AI reviews the week's daily logs and updates MEMORY.md:
```markdown
## Active Projects
- **Trading Bot**: RSI monitoring for AAPL, TSLA, NVDA
  - Paper trading mode
  - 2-hour check interval during market hours
  - Status: Running since March 8
```

**Day 30:**
Your AI has a rich context. When you say "How's the trading bot doing?", it knows exactly what you mean, what symbols you're tracking, and can pull the latest data immediately.

### Testing Memory

**Test 1: Short-term Memory**
```
You: My project deadline is March 15th. Remember that.
AI: Noted — project deadline March 15th.

[Next message in same session]
You: When's my deadline?
AI: March 15th.
```

**Test 2: Cross-session Memory**
```
Session 1:
You: I prefer morning briefings at 8 AM Central time.
AI: [Records to memory file]

Session 2 (next day):
You: What time do I want my briefings?
AI: You prefer morning briefings at 8 AM Central time.
```

**Test 3: Memory File Verification**
```
You: Show me what's in today's memory file.
AI: [Reads and displays memory/2026-03-08.md]
```

### Advanced: Memory Search

OpenClaw includes semantic memory search. When your AI needs to recall something, it searches across all memory files to find relevant context:

```
You: What did we decide about the email automation last week?
AI: [Searches memory files, finds the relevant entry, responds with context]
```

This means your AI doesn't need to read every memory file every session — it can search for specific topics efficiently.

### What You've Built

At the end of this chapter, you have:

✅ Daily log system recording session events
✅ Long-term memory curation in MEMORY.md
✅ Memory reading on session start for context
✅ Cross-session continuity — your AI remembers
✅ Semantic search across memory files

Your AI now has a brain. It remembers past conversations, accumulates knowledge, and maintains context across sessions. This is the foundation that makes automation truly intelligent.

---

*Next Chapter: Automation — Cron Jobs & Scheduled Tasks →*
