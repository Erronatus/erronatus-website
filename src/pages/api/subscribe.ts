import type { APIRoute } from 'astro';

export const prerender = false;

const CORS_HEADERS = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': 'https://www.erronatus.com',
};

// Rate limiting
const submissions = new Map<string, number[]>();
const RATE_LIMIT = 2;
const RATE_WINDOW = 60 * 60 * 1000;

function isRateLimited(ip: string): boolean {
  const now = Date.now();
  const history = (submissions.get(ip) || []).filter(t => now - t < RATE_WINDOW);
  submissions.set(ip, history);
  return history.length >= RATE_LIMIT;
}

function recordSubmission(ip: string): void {
  const history = submissions.get(ip) || [];
  history.push(Date.now());
  submissions.set(ip, history);
}

// Supported lists
type ListType = 'newsletter' | 'waitlist' | 'starter-kit';

const LIST_CONFIGS: Record<ListType, { tag: string; welcomeSubject: string; welcomeBody: string }> = {
  newsletter: {
    tag: 'newsletter',
    welcomeSubject: "You're in — The Automation Dispatch",
    welcomeBody: `
      <p>Welcome to <strong>The Automation Dispatch</strong>.</p>
      <p>Every week, you'll get:</p>
      <ul>
        <li>New tools and frameworks worth your time</li>
        <li>Automation strategies that actually work</li>
        <li>Systems that make money (not just noise)</li>
      </ul>
      <p>No filler. No spam. Just signal.</p>
      <p>First issue drops next week. In the meantime, check out the <a href="https://www.erronatus.com/blog" style="color: #D4843A;">blog</a> for a head start.</p>
    `,
  },
  waitlist: {
    tag: 'crontrepreneur-waitlist',
    welcomeSubject: "You're on the Crontrepreneur waitlist",
    welcomeBody: `
      <p>You're on the list for <strong>Crontrepreneur</strong> — the turnkey AI automation system.</p>
      <p>What you'll get when it launches:</p>
      <ul>
        <li>50+ pre-built cron job templates</li>
        <li>14 API integrations wired up</li>
        <li>5 AI engines pre-routed for optimal cost</li>
        <li>One-command install</li>
      </ul>
      <p>Early adopters get <strong>priority pricing</strong>. We'll email you the moment it's ready.</p>
    `,
  },
  'starter-kit': {
    tag: 'starter-kit-interest',
    welcomeSubject: "Your AI Automation Starter Kit interest — noted",
    welcomeBody: `
      <p>Thanks for your interest in the <strong>AI Automation Starter Kit</strong>.</p>
      <p>We'll notify you as soon as it's available. In the meantime:</p>
      <ul>
        <li>Check out <a href="https://www.erronatus.com/blog" style="color: #D4843A;">our blog</a> for free automation guides</li>
        <li>Follow <a href="https://x.com/Erronatus" style="color: #D4843A;">@Erronatus on X</a> for daily insights</li>
      </ul>
    `,
  },
};

export const POST: APIRoute = async ({ request, clientAddress }) => {
  try {
    const ip = clientAddress || request.headers.get('x-forwarded-for') || 'unknown';

    if (isRateLimited(ip)) {
      return new Response(
        JSON.stringify({ error: 'Already subscribed. Check your inbox.' }),
        { status: 429, headers: CORS_HEADERS }
      );
    }

    const data = await request.json();
    const { email, list = 'newsletter' } = data;

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return new Response(
        JSON.stringify({ error: 'Please enter a valid email address.' }),
        { status: 400, headers: CORS_HEADERS }
      );
    }

    const cleanEmail = email.trim().toLowerCase().slice(0, 254);
    const listType = (LIST_CONFIGS[list as ListType] ? list : 'newsletter') as ListType;
    const config = LIST_CONFIGS[listType];

    const RESEND_API_KEY = import.meta.env.RESEND_API_KEY;
    if (!RESEND_API_KEY) {
      console.error('RESEND_API_KEY not configured');
      return new Response(
        JSON.stringify({ error: 'Server configuration error.' }),
        { status: 500, headers: CORS_HEADERS }
      );
    }

    // 1. Add contact to Resend audience (if audience ID is configured)
    const RESEND_AUDIENCE_ID = import.meta.env.RESEND_AUDIENCE_ID;
    if (RESEND_AUDIENCE_ID) {
      try {
        await fetch(`https://api.resend.com/audiences/${RESEND_AUDIENCE_ID}/contacts`, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            email: cleanEmail,
            first_name: '',
            last_name: '',
            unsubscribed: false,
          }),
        });
      } catch (e) {
        console.error('Failed to add to audience:', e);
        // Non-blocking — still send welcome email
      }
    }

    // 2. Notify us internally
    await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Erronatus System <hello@erronatus.com>',
        to: 'hello@erronatus.com',
        subject: `📬 New ${config.tag} subscriber: ${cleanEmail}`,
        html: `<p><strong>${cleanEmail}</strong> joined <code>${config.tag}</code> at ${new Date().toISOString()}</p>`,
      }),
    });

    // 3. Send welcome email to subscriber
    const welcomeHtml = `
      <!DOCTYPE html>
      <html>
      <head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head>
      <body style="margin:0;padding:0;background:#060608;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
        <div style="max-width:560px;margin:0 auto;padding:40px 24px;">
          <div style="text-align:center;margin-bottom:32px;">
            <div style="display:inline-block;width:48px;height:48px;border-radius:12px;background:linear-gradient(135deg,#C46A2F,#D4A853);line-height:48px;text-align:center;">
              <span style="color:#fff;font-weight:800;font-size:20px;">E</span>
            </div>
          </div>
          <div style="background:#0d0d14;border:1px solid #1e1e26;border-radius:16px;padding:32px;color:#e0e0e8;font-size:14px;line-height:1.7;">
            ${config.welcomeBody}
            <p style="margin-top:24px;color:#7a7a8a;font-size:12px;">— Erronatus</p>
          </div>
          <div style="text-align:center;margin-top:24px;">
            <p style="color:#5a5a66;font-size:11px;">
              © 2026 Erronatus · <a href="https://www.erronatus.com" style="color:#5a5a66;">erronatus.com</a>
            </p>
          </div>
        </div>
      </body>
      </html>
    `;

    const welcomeRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Erronatus <hello@erronatus.com>',
        to: cleanEmail,
        subject: config.welcomeSubject,
        html: welcomeHtml,
      }),
    });

    if (!welcomeRes.ok) {
      const err = await welcomeRes.json();
      console.error('Welcome email failed:', err);
    }

    recordSubmission(ip);

    return new Response(
      JSON.stringify({ success: true, message: "You're in. Check your inbox." }),
      { status: 200, headers: CORS_HEADERS }
    );
  } catch (error: any) {
    console.error('Subscribe error:', error);
    return new Response(
      JSON.stringify({ error: 'Something went wrong. Please try again.' }),
      { status: 500, headers: CORS_HEADERS }
    );
  }
};
