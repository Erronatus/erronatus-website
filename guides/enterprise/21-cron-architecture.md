# Chapter 21: Advanced Cron Architecture
## 50 Templates for Every Use Case

---

### The Cron Operating System

Cron jobs are the heartbeat of an autonomous system. Every automated action — every scrape, every alert, every email, every report — runs on a schedule.

This chapter gives you 50 production-ready cron templates organized by category, plus the architectural patterns to build your own.

### Architecture Patterns

**Pattern 1: Check → Alert**
Check a condition. Alert only if it's interesting.
```
Schedule → Check data → Threshold crossed? → Yes: Alert | No: Log silently
```

**Pattern 2: Gather → Process → Deliver**
Collect information, process it, deliver results.
```
Schedule → Fetch data from multiple sources → AI summarizes → Send report
```

**Pattern 3: Monitor → Decide → Act**
Continuous monitoring with autonomous action.
```
Schedule → Monitor condition → Rules check → Execute action → Log outcome
```

**Pattern 4: Pipeline**
Multi-step process where each step feeds the next.
```
Schedule → Step 1: Scrape → Step 2: Enrich → Step 3: Score → Step 4: Outreach
```

### The 50 Templates

#### 📰 Information & News (1-8)

**1. Morning Briefing**
Schedule: `0 8 * * *` (8 AM daily)
Task: Pull top headlines, weather, calendar events. Format and deliver via Telegram.

**2. Industry News Monitor**
Schedule: `0 */4 * * *` (every 4 hours)
Task: Search for news about your industry/keywords. Alert on significant stories only.

**3. Competitor Mention Tracker**
Schedule: `0 */6 * * *` (every 6 hours)
Task: Search web for competitor brand mentions. Summarize new findings.

**4. RSS Feed Digest**
Schedule: `0 7 * * *` (7 AM daily)
Task: Aggregate posts from 10-20 RSS feeds. AI selects top 5 most relevant.

**5. Regulatory Change Monitor**
Schedule: `0 9 * * 1` (Monday 9 AM)
Task: Search for regulatory changes in your industry. Alert on anything affecting your business.

**6. Technology Trend Report**
Schedule: `0 10 * * 5` (Friday 10 AM)
Task: Research emerging tools, frameworks, and AI models. Weekly tech digest.

**7. Social Media Sentiment**
Schedule: `0 */8 * * *` (every 8 hours)
Task: Monitor social mentions of your brand. Classify sentiment. Alert on negative trends.

**8. Academic Paper Scanner**
Schedule: `0 6 * * 1` (Monday 6 AM)
Task: Search for new papers in your field. Summarize top 3 most relevant.

#### 📊 Market & Finance (9-16)

**9. Market Open Briefing**
Schedule: `25 9 * * 1-5` (9:25 AM weekdays, 5 min before open)
Task: Pre-market movers, futures, overnight news affecting watchlist.

**10. RSI Watchlist Monitor**
Schedule: `0 */2 9-16 * * 1-5` (every 2 hours, market hours)
Task: Check RSI for all watchlist symbols. Alert on threshold crossings.

**11. Portfolio Performance**
Schedule: `0 16 * * 1-5` (4 PM weekdays, at close)
Task: Calculate daily P&L, compare to benchmarks, summarize position changes.

**12. Earnings Calendar**
Schedule: `0 8 * * 0` (Sunday 8 AM)
Task: Check earnings calendar for upcoming week. Flag watchlist companies reporting.

**13. Crypto Market Pulse**
Schedule: `0 */4 * * *` (every 4 hours, 24/7)
Task: Top 10 crypto prices, 24h changes, volume anomalies.

**14. Economic Calendar**
Schedule: `0 7 * * 1` (Monday 7 AM)
Task: Major economic releases this week (CPI, jobs, Fed meetings).

**15. Sector Rotation Analysis**
Schedule: `0 17 * * 5` (Friday 5 PM)
Task: Weekly sector performance. Identify money flow between sectors.

**16. Options Unusual Activity**
Schedule: `0 */3 9-16 * * 1-5` (every 3 hours, market hours)
Task: Search for unusual options activity on watchlist symbols.

#### 💼 Business Operations (17-28)

**17. Lead Pipeline Update**
Schedule: `0 9 * * *` (9 AM daily)
Task: New leads discovered, leads contacted, responses received, meetings scheduled.

**18. Email Outreach Dispatcher**
Schedule: `0 10 * * 1-5` (10 AM weekdays)
Task: Send today's scheduled outreach emails. Log results.

**19. Follow-Up Processor**
Schedule: `0 14 * * 1-5` (2 PM weekdays)
Task: Check for leads due for follow-up. Send next sequence email.

**20. Client Health Check**
Schedule: `0 8 * * 1` (Monday 8 AM)
Task: Review client metrics. Flag accounts with declining engagement.

**21. Invoice Reminder**
Schedule: `0 9 1,15 * *` (1st and 15th of month)
Task: Check for outstanding invoices. Send polite reminders.

**22. Weekly Revenue Report**
Schedule: `0 9 * * 1` (Monday 9 AM)
Task: Stripe revenue, new customers, churn, MRR trend.

**23. Content Calendar Planner**
Schedule: `0 10 * * 0` (Sunday 10 AM)
Task: Plan next week's content. Generate topic ideas based on trending keywords.

**24. SEO Rank Tracker**
Schedule: `0 6 * * *` (6 AM daily)
Task: Check rankings for target keywords. Alert on significant changes.

**25. Social Post Scheduler**
Schedule: `0 9,13,17 * * 1-5` (9 AM, 1 PM, 5 PM weekdays)
Task: Post pre-drafted content to social platforms.

**26. Meeting Prep**
Schedule: 30 minutes before each calendar event
Task: Research meeting participants. Prepare talking points and questions.

**27. Weekly Team Digest**
Schedule: `0 17 * * 5` (Friday 5 PM)
Task: Summarize week's accomplishments, blockers, and next week priorities.

**28. Expense Categorizer**
Schedule: `0 20 * * 0` (Sunday 8 PM)
Task: Review week's transactions. Categorize expenses. Flag anomalies.

#### 🛠️ System & Infrastructure (29-38)

**29. Server Health Check**
Schedule: `*/15 * * * *` (every 15 minutes)
Task: Ping all monitored services. Alert on any downtime.

**30. SSL Certificate Monitor**
Schedule: `0 8 * * *` (8 AM daily)
Task: Check SSL expiry for all domains. Alert if < 14 days remaining.

**31. Disk Space Monitor**
Schedule: `0 */6 * * *` (every 6 hours)
Task: Check disk usage. Alert if > 85% on any volume.

**32. Backup Verification**
Schedule: `0 3 * * *` (3 AM daily)
Task: Verify latest backups exist and are the expected size.

**33. API Health Dashboard**
Schedule: `0 */4 * * *` (every 4 hours)
Task: Test all 14 API connections. Report any failures.

**34. Cost Tracking**
Schedule: `0 22 * * *` (10 PM daily)
Task: Summarize today's AI model costs. Alert if approaching budget.

**35. Dependency Update Check**
Schedule: `0 8 * * 1` (Monday 8 AM)
Task: Check for security updates in project dependencies.

**36. Error Log Review**
Schedule: `0 */8 * * *` (every 8 hours)
Task: Scan recent logs for errors. Categorize and summarize.

**37. Database Cleanup**
Schedule: `0 2 * * 0` (Sunday 2 AM)
Task: Archive old records. Vacuum tables. Report database size.

**38. Performance Benchmark**
Schedule: `0 5 * * 1` (Monday 5 AM)
Task: Run performance tests on API endpoints. Compare to baseline.

#### 🧠 Memory & Self-Maintenance (39-46)

**39. Daily Memory Log**
Schedule: `0 23 * * *` (11 PM daily)
Task: Review today's events. Write daily memory file. Update active context.

**40. Weekly Memory Curation**
Schedule: `0 21 * * 0` (Sunday 9 PM)
Task: Review week's daily logs. Update MEMORY.md with lasting insights.

**41. Task Queue Review**
Schedule: `0 8 * * *` (8 AM daily)
Task: Review pending tasks. Reprioritize. Alert on overdue items.

**42. Credential Audit**
Schedule: `0 8 1 * *` (1st of month, 8 AM)
Task: Test all API credentials. Report expired or failing keys.

**43. Heartbeat Check**
Schedule: `*/30 * * * *` (every 30 minutes)
Task: Read HEARTBEAT.md. Execute any listed checks. Report or stay silent.

**44. Knowledge Base Update**
Schedule: `0 22 * * 5` (Friday 10 PM)
Task: Review week's learnings. Update skill files and documentation.

**45. Context Compression**
Schedule: `0 3 * * *` (3 AM daily)
Task: Compress old daily memory files into summaries. Archive raw data.

**46. Self-Assessment**
Schedule: `0 20 1 * *` (1st of month, 8 PM)
Task: Review month's performance. What automated well? What needs improvement?

#### 🎯 Special Purpose (47-50)

**47. Birthday/Anniversary Reminders**
Schedule: `0 8 * * *` (8 AM daily)
Task: Check contacts database for upcoming birthdays. Send personalized messages.

**48. Weather-Triggered Actions**
Schedule: `0 7 * * *` (7 AM daily)
Task: Check weather. If rain > 60%, remind about umbrella and suggest indoor plans.

**49. Habit Tracker**
Schedule: `0 21 * * *` (9 PM daily)
Task: Prompt for daily habit check-in. Log streaks. Encourage consistency.

**50. Opportunity Scanner**
Schedule: `0 10 * * 1,4` (Monday and Thursday 10 AM)
Task: Search for freelance gigs, contract opportunities, or partnerships matching your skills.

### Deploying Templates

Each template follows the same deployment pattern:

1. Choose the template
2. Customize schedule and parameters
3. Create the cron job via OpenClaw
4. Test with a manual run
5. Monitor the first few automated runs
6. Adjust and optimize based on results

### What You've Built

✅ 50 production-ready cron job templates
✅ Four architectural patterns for any automation
✅ Templates covering information, finance, business, infrastructure, and self-maintenance
✅ A framework for creating unlimited custom cron jobs

---

*Next Chapter: Trading Systems →*
