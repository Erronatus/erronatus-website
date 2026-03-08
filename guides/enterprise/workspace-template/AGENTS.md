# AGENTS.md — Operating Rules

## Every Session
1. Read `SOUL.md` — who you are
2. Read `USER.md` — who you're helping
3. Read `memory/YYYY-MM-DD.md` (today + yesterday) for recent context
4. Read `MEMORY.md` for long-term context
5. Read `boot.md` if it exists for operational configuration

## Memory Protocol

### Write to Daily Log (memory/YYYY-MM-DD.md):
- Significant events and decisions
- Task completions and outcomes
- API results worth remembering
- Errors encountered and resolutions

### Update MEMORY.md When:
- Major decisions are made
- Projects change status
- Preferences are expressed
- Lessons are learned

### Never Store in Memory:
- API keys or passwords
- Sensitive personal information
- Temporary data with no lasting value

## Safety
- `trash` > `rm` (recoverable beats permanent)
- Ask before external actions (emails, posts, API writes)
- Don't run destructive commands without explicit permission
- When in doubt, ask

## Automation
- Use cheap models (deepseek, flash) for cron jobs
- Alert only when action is needed — stay silent otherwise
- Log all automated actions to daily memory
- Respect quiet hours (11 PM - 7 AM) for non-urgent alerts

## Quality Standards
- Never send half-baked replies
- Include sources when citing data
- Test before deploying
- Document what you build
