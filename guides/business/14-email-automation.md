# Chapter 14: Email Automation
## Resend Integration & Workflows

---

### Why Email Automation

Email remains the most reliable channel for business communication. With Resend integration, your AI can:

- Send transactional emails (receipts, confirmations, notifications)
- Deliver scheduled reports to clients or team members
- Process incoming email summaries and draft responses
- Manage newsletter distribution
- Trigger email sequences based on events

### Setting Up Resend

1. Go to resend.com and create an account
2. Verify your sending domain (requires DNS records)
3. Generate an API key
4. Add to `.env`:

```bash
RESEND_API_KEY=re_your-key-here
EMAIL_FROM=hello@yourdomain.com
```

### Domain Verification

For email deliverability, verify your domain in Resend:

1. Go to Resend dashboard → Domains → Add Domain
2. Enter your domain (e.g., erronatus.com)
3. Add the DNS records Resend provides:
   - **SPF record** — Authorizes Resend to send from your domain
   - **DKIM record** — Cryptographically signs your emails
   - **DMARC record** — Policy for handling authentication failures

Add these records in your DNS provider (Cloudflare, Namecheap, etc.). Verification usually takes a few minutes.

### Sending Your First Email

Test the integration:

```
You: Send a test email to me@example.com with subject "Test" and body "Email automation is working!"
AI: ✅ Email sent successfully.
    To: me@example.com
    Subject: Test
    Status: Delivered
```

### Email Automation Workflows

#### 1. Daily Report Delivery

Schedule a cron job to email you a daily summary:

```
Create a cron job: Every day at 6 PM, compile a summary of
today's activities, completed tasks, and open items.
Email the report to me at jackson@erronatus.com.
```

Your AI generates the report and sends it via Resend — no manual effort.

#### 2. Client Update Emails

After generating a client report (Chapter 13's skill), automatically email it:

```
Generate the weekly report for Client X and email it to
client@company.com with the subject "Weekly Performance Report — March 8"
```

#### 3. Alert Escalation to Email

For critical alerts that need more than a Telegram notification:

```
If a trading alert reaches 🔴 Action level, also send an email
with the full analysis to my business email.
```

#### 4. Welcome Email Sequences

When someone purchases your product (via Stripe webhook), trigger a welcome sequence:

- **Immediately:** Purchase confirmation + download link
- **Day 1:** Getting started tips
- **Day 3:** "How's it going?" check-in with support link
- **Day 7:** Advanced features highlight
- **Day 14:** Request for review/testimonial

### Email Templates

Create reusable HTML email templates that your AI populates with dynamic content:

```html
<!DOCTYPE html>
<html>
<body style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
  <div style="background: #0a0a0a; padding: 40px; border-radius: 12px;">
    <img src="https://erronatus.com/logo.png" width="120" />
    <h1 style="color: #fff; margin-top: 24px;">{{title}}</h1>
    <p style="color: #a0a0a0; line-height: 1.6;">{{body}}</p>
    <a href="{{cta_url}}" style="display: inline-block; padding: 12px 24px;
       background: linear-gradient(135deg, #3b82f6, #8b5cf6); color: #fff;
       border-radius: 999px; text-decoration: none; margin-top: 16px;">
      {{cta_text}}
    </a>
  </div>
</body>
</html>
```

Store templates in `~/.openclaw/workspace/templates/emails/` and reference them in automations.

### Deliverability Best Practices

1. **Always use verified domains** — Never send from gmail.com or yahoo.com
2. **Include unsubscribe links** — Required by law (CAN-SPAM, GDPR)
3. **Keep bounce rates low** — Remove invalid addresses promptly
4. **Warm up new domains** — Start with low volume, increase gradually
5. **Monitor reputation** — Check Resend analytics for delivery rates

### What You've Built

✅ Resend email API integrated and verified
✅ Domain authentication (SPF, DKIM, DMARC)
✅ Automated report delivery via cron
✅ Alert escalation to email
✅ HTML email templates for professional communications
✅ Welcome sequence framework for product purchases

---

*Next Chapter: Payment Integration →*
