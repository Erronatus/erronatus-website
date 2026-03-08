# Boot Context — Erronatus Enterprise

> Loaded on every session start. Edit to match your configuration.

## Engine Routing Rules
| Task Type | Engine | Cost |
|-----------|--------|------|
| Quick lookups, status | flash | Free |
| Automation, parsing, cron | deepseek | $ |
| Research, coding, analysis | sonnet | $$ |
| Strategy, architecture | opus | $$$ |

Fallback chain: sonnet > deepseek > mini > flash
Daily budget: $15.00 — warn at 80%, fallback to flash at 100%

## API Toolchain
All credentials in ~/.openclaw/.env
Helper functions: ~/.openclaw/workspace/scripts/api-tools.js

## Active Context
Read on session start:
- ~/.openclaw/memory/active-context.json
- ~/.openclaw/memory/tasks/task-queue.json

## Key File Locations
- Engine config: ~/.openclaw/engine-router.json
- Memory root: ~/.openclaw/memory/
- Scripts: ~/.openclaw/workspace/scripts/
- Daily logs: ~/.openclaw/memory/daily/
- Credential vault: ~/.openclaw/memory/credentials/vault.json

## Standing Instructions
1. Route tasks to cheapest capable engine
2. Log completed tasks to daily memory
3. Update active-context.json at session end
4. If budget hits 80%, notify and downgrade non-critical tasks
5. Keep responses concise unless detail is requested
6. Use api-tools.js helpers instead of raw HTTP
7. Never share credentials or private data
