# Chapter 13: Custom Skill Development
## Teaching Your AI New Tricks

---

### What Are Skills?

Skills are packaged capabilities you can install into OpenClaw. Each skill includes a `SKILL.md` file that teaches your AI how to perform a specific type of task — weather lookups, deep research, document analysis, trading analysis, and more.

Think of skills as specialized training modules. Your AI reads the SKILL.md when a matching task is detected and follows its instructions precisely.

### Anatomy of a Skill

Every skill lives in a directory with this structure:

```
~/.openclaw/workspace/skills/your-skill/
├── SKILL.md              ← Instructions your AI follows
├── scripts/              ← Helper scripts (optional)
│   └── helper.js
├── templates/            ← Output templates (optional)
│   └── report.md
└── README.md             ← Human-readable documentation
```

The `SKILL.md` is the critical file. It defines:
- **When** the skill should activate (trigger conditions)
- **What** the skill does (step-by-step process)
- **How** to format output (templates and standards)
- **Where** to find resources (scripts, APIs, reference data)

### Building Your First Custom Skill

Let's build a "Client Report" skill that generates weekly performance reports for a business:

**Create the directory:**
```bash
mkdir -p ~/.openclaw/workspace/skills/client-report
```

**Create `SKILL.md`:**

```markdown
# Client Report Skill

## Trigger
Activate when user asks to generate a client report, weekly report,
or performance summary.

## Process
1. Read the client configuration from memory/clients/{client_name}.json
2. Pull relevant metrics from the configured data sources
3. Compare current period to previous period
4. Identify trends, anomalies, and opportunities
5. Generate a formatted report using the template

## Data Sources
- Supabase: Query the metrics table for the client
- Google Analytics: Via web search for public metrics
- Custom APIs: As specified in client configuration

## Output Format
Use the template in templates/weekly-report.md
Include:
- Executive summary (3-4 sentences)
- Key metrics with trend arrows (↑↓→)
- Charts described in text format
- Recommendations (2-3 actionable items)
- Next steps

## Quality Standards
- All numbers must cite their source
- Percentages include comparison period
- Recommendations must be specific and actionable
- Report length: 500-1000 words
```

**Create the template:**

```markdown
# Weekly Performance Report
**Client:** {{client_name}}
**Period:** {{start_date}} — {{end_date}}
**Generated:** {{generated_date}}

---

## Executive Summary
{{summary}}

## Key Metrics
| Metric | Current | Previous | Change |
|--------|---------|----------|--------|
{{#each metrics}}
| {{name}} | {{current}} | {{previous}} | {{change}} |
{{/each}}

## Analysis
{{analysis}}

## Recommendations
{{#each recommendations}}
{{@index}}. **{{title}}**: {{description}}
{{/each}}

## Next Steps
{{next_steps}}
```

### Skill Discovery

OpenClaw automatically detects skills in your `skills/` directory. When you ask your AI to do something that matches a skill's trigger conditions, it loads and follows that skill's instructions.

You can also install pre-built skills from ClawHub:

```bash
clawhub search trading
clawhub install trading
clawhub install deep-research-pro
```

### Installing Pre-Built Skills

Several powerful skills are available:

| Skill | Purpose |
|-------|---------|
| `trading` | Technical analysis, chart patterns, risk management |
| `deep-research-pro` | Multi-source web research with cited reports |
| `market-research` | Market sizing, competitor analysis, opportunity validation |
| `weather` | Current weather and forecasts |
| `document-pro` | PDF, DOCX, PPTX processing and extraction |
| `document-summary` | Technical document summarization |
| `code` | Coding workflow with planning and testing |

Install with:
```bash
clawhub install skill-name
```

### Advanced Skill Patterns

**Chained Skills:** One skill's output feeds into another:
```
Research Skill → generates findings →
Analysis Skill → produces recommendations →
Report Skill → formats deliverable
```

**Parameterized Skills:** Accept configuration for different use cases:
```markdown
## Parameters
- depth: quick | standard | deep
- format: summary | detailed | executive
- audience: technical | business | general
```

**Scheduled Skills:** Trigger via cron instead of user message:
```
Cron job → activates skill → generates output → delivers to channel
```

### What You've Built

✅ Understanding of skill architecture and SKILL.md format
✅ A custom Client Report skill with templates
✅ Skill installation from ClawHub marketplace
✅ Advanced patterns: chaining, parameters, scheduled activation
✅ A framework for creating unlimited custom capabilities

---

*Next Chapter: Email Automation →*
