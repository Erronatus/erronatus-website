# Chapter 20: Email Outreach
## Cold Email at Scale With AI Personalization

---

### Why AI-Personalized Outreach Wins

Generic cold emails get 1-2% reply rates. AI-personalized emails get 8-15%. The difference: your AI reads every prospect's website, social profile, and recent activity, then crafts a message that feels like it was written specifically for them. Because it was.

### The Outreach Architecture

```
Lead Database (Ch. 19)
    ↓
Template Selection (based on industry, score, signals)
    ↓
AI Personalization (opening line, pain point, CTA)
    ↓
Compliance Check (unsubscribe, CAN-SPAM)
    ↓
Send via Resend
    ↓
Track (opens, clicks, replies)
    ↓
Follow-up Sequence (Day 3, Day 7, Day 14)
    ↓
Response Handling (classify, alert, update status)
```

### Email Templates Library

Create templates in `~/.openclaw/workspace/templates/outreach/`:

**Template 1: The Value-First Approach**
```
Subject: {{personalized_subject}}

Hi {{first_name}},

{{personalized_opening — reference their company, recent news, or specific challenge}}

I noticed {{specific observation about their business}}. Most companies in {{industry}} struggle with {{common pain point}}, and it usually costs them {{quantified impact}}.

We built a system that {{specific solution}}. {{Social proof — "Companies like X have seen Y results"}}.

Would a 15-minute call this week make sense to see if this could help {{company_name}}?

{{your_name}}

P.S. {{personalized PS — reference something specific}}
```

**Template 2: The Quick Question**
```
Subject: Quick question about {{company_name}}

{{first_name}} — 

{{one sentence about what you do}}.

Curious: {{specific question about their current process/challenge}}?

No pitch. Just genuinely curious if {{industry}} companies are thinking about this.

{{your_name}}
```

**Template 3: The Trigger Event**
```
Subject: Congrats on {{trigger_event}}

Hi {{first_name}},

Saw that {{company_name}} just {{trigger event — new funding, product launch, expansion, new hire}}. Congrats!

Companies at your stage often {{common challenge that comes with this event}}.

{{How you help with that specific challenge}}. Happy to share what's worked for similar companies if useful.

{{your_name}}
```

### AI Personalization Engine

For each lead, your AI:

1. **Reads their website** — Extracts products, value proposition, target market
2. **Checks recent news** — Any press, launches, funding rounds
3. **Reviews social profiles** — Recent posts, topics of interest
4. **Identifies pain points** — Based on industry, size, and hiring patterns
5. **Selects the best template** — Matches the lead's profile and signals
6. **Writes the personalized elements** — Opening line, observation, PS

Example output:

```
To: jane@acmecorp.com
Subject: Saw your Series A — quick thought on scaling ops

Hi Jane,

Congrats on the $8M Series A — that's a strong signal the market's responding
to what you're building at Acme Corp. The B2B SaaS space is heating up.

I noticed you're hiring 3 engineers and a marketing lead. When companies
at your stage scale the team that fast, operational overhead usually
doubles before the new hires fully ramp. We see it constantly.

We help B2B SaaS companies automate the operational layer — reporting,
monitoring, client comms — so the founding team stays focused on product
and growth. Companies like [similar company] cut their ops time by 60%.

Would 15 minutes this week make sense to see if this fits where
Acme is headed?

Best,
[Your name]

P.S. I saw your post about "the scaling challenge nobody talks about" —
couldn't agree more. Happy to share what we've seen work.
```

That email took your AI 30 seconds to write. A human would need 15-20 minutes of research to match that level of personalization.

### Follow-Up Sequences

Most replies come from follow-ups, not initial emails:

**Day 0:** Initial email (personalized)
**Day 3:** Follow-up #1 — Short, adds new value
```
Hi {{first_name}}, wanted to share this {{relevant resource/case study}}
that might be useful regardless of whether we connect. Thought of
{{company_name}} when I read it.
```

**Day 7:** Follow-up #2 — Different angle
```
{{first_name}} — one more thought. {{New observation or approach}}.
If timing's off, no worries at all. But if {{pain point}} is on
your radar, I think we could help.
```

**Day 14:** Break-up email — Last touch
```
Hi {{first_name}}, I'll keep this brief. I've reached out a couple
times about {{topic}}. If it's not relevant, I completely understand
and won't bother you again. But if you'd like to explore it, I'm
here. Either way, best of luck with {{recent initiative}}.
```

### Compliance & Deliverability

**CAN-SPAM Requirements (US):**
- Include your physical business address
- Provide a clear unsubscribe mechanism
- Honor unsubscribe requests within 10 business days
- Don't use deceptive subject lines
- Identify the message as an advertisement

**Implementation:**
```html
<!-- Footer of every outreach email -->
<p style="font-size: 11px; color: #666;">
  You're receiving this because we think {{company_name}} could
  benefit from AI automation. If this isn't relevant,
  <a href="{{unsubscribe_url}}">click here to unsubscribe</a>
  and we won't contact you again.
  
  {{your_company}}, {{your_address}}
</p>
```

**Deliverability rules:**
- Warm up new sending domains gradually (10/day → 25 → 50 → 100)
- Keep bounce rates under 2%
- Maintain reply rates above 5% (indicates quality outreach)
- Remove bounced addresses immediately
- Use authenticated domain (SPF, DKIM, DMARC from Chapter 14)

### Tracking & Analytics

Log every email event to Supabase:

```sql
CREATE TABLE outreach_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lead_id UUID REFERENCES leads(id),
  event_type TEXT,  -- sent, opened, clicked, replied, bounced, unsubscribed
  template_used TEXT,
  sequence_step INTEGER,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  metadata JSONB
);
```

Your AI generates weekly analytics:

```
Email Outreach Report — Week of March 4
────────────────────────────────────────
Sent: 147 emails
Opened: 89 (60.5% open rate)
Replied: 18 (12.2% reply rate)
Positive replies: 12 (8.2%)
Meetings booked: 5 (3.4%)

Best performing:
- Template: "Trigger Event" (16% reply rate)
- Industry: B2B SaaS (14% reply rate)
- Day: Tuesday (highest open rate)
- Time: 10 AM local (highest reply rate)

Recommendations:
- Increase allocation to Trigger Event template
- Focus on B2B SaaS leads (2x avg reply rate)
- Schedule sends for Tuesday 10 AM
```

### What You've Built

✅ AI-personalized cold email at scale
✅ Three production email templates
✅ Automated 4-touch follow-up sequences
✅ CAN-SPAM compliance built into every email
✅ Domain warmup and deliverability protocols
✅ Full tracking and analytics pipeline
✅ Weekly performance reporting with recommendations

---

*Next Chapter: Advanced Cron Architecture →*
