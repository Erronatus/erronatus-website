import type { APIRoute } from 'astro';

export const prerender = false;

const CORS_HEADERS = {
  'Content-Type': 'application/json',
  'Access-Control-Allow-Origin': 'https://www.erronatus.com',
};

// Rate limiting: simple in-memory store (resets on cold start, fine for Vercel)
const submissions = new Map<string, number[]>();
const RATE_LIMIT = 3; // max 3 submissions per hour per IP
const RATE_WINDOW = 60 * 60 * 1000; // 1 hour

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

export const POST: APIRoute = async ({ request, clientAddress }) => {
  try {
    const ip = clientAddress || request.headers.get('x-forwarded-for') || 'unknown';

    if (isRateLimited(ip)) {
      return new Response(
        JSON.stringify({ error: 'Too many submissions. Please try again later.' }),
        { status: 429, headers: CORS_HEADERS }
      );
    }

    const data = await request.json();
    const { name, email, subject, message } = data;

    // Validate required fields
    if (!name || !email || !subject || !message) {
      return new Response(
        JSON.stringify({ error: 'All fields are required.' }),
        { status: 400, headers: CORS_HEADERS }
      );
    }

    // Basic email validation
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return new Response(
        JSON.stringify({ error: 'Invalid email address.' }),
        { status: 400, headers: CORS_HEADERS }
      );
    }

    // Sanitize inputs (basic XSS prevention)
    const sanitize = (s: string) => s.replace(/[<>]/g, '').trim().slice(0, 2000);
    const cleanName = sanitize(name);
    const cleanEmail = email.trim().toLowerCase().slice(0, 254);
    const cleanSubject = sanitize(subject);
    const cleanMessage = sanitize(message);

    const RESEND_API_KEY = import.meta.env.RESEND_API_KEY;
    if (!RESEND_API_KEY) {
      console.error('RESEND_API_KEY not configured');
      return new Response(
        JSON.stringify({ error: 'Server configuration error.' }),
        { status: 500, headers: CORS_HEADERS }
      );
    }

    const subjectMap: Record<string, string> = {
      support: '🔧 Blueprint Support',
      refund: '💰 Refund Request',
      question: '❓ Pre-Purchase Question',
      partnership: '🤝 Partnership Inquiry',
      other: '💬 General Inquiry',
    };

    const emailSubject = `[Erronatus Contact] ${subjectMap[cleanSubject] || cleanSubject} — ${cleanName}`;

    const html = `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 24px;">
        <div style="background: #0d0d14; border: 1px solid #1e1e26; border-radius: 12px; padding: 24px; margin-bottom: 16px;">
          <h2 style="color: #D4843A; margin: 0 0 16px; font-size: 18px;">New Contact Form Submission</h2>
          <table style="width: 100%; color: #e0e0e8; font-size: 14px;">
            <tr><td style="padding: 8px 0; color: #7a7a8a; width: 100px;">Name</td><td style="padding: 8px 0;">${cleanName}</td></tr>
            <tr><td style="padding: 8px 0; color: #7a7a8a;">Email</td><td style="padding: 8px 0;"><a href="mailto:${cleanEmail}" style="color: #D4843A;">${cleanEmail}</a></td></tr>
            <tr><td style="padding: 8px 0; color: #7a7a8a;">Subject</td><td style="padding: 8px 0;">${subjectMap[cleanSubject] || cleanSubject}</td></tr>
          </table>
        </div>
        <div style="background: #0d0d14; border: 1px solid #1e1e26; border-radius: 12px; padding: 24px;">
          <h3 style="color: #94949e; margin: 0 0 12px; font-size: 12px; text-transform: uppercase; letter-spacing: 0.1em;">Message</h3>
          <p style="color: #e0e0e8; font-size: 14px; line-height: 1.7; margin: 0; white-space: pre-wrap;">${cleanMessage}</p>
        </div>
        <p style="color: #5a5a66; font-size: 11px; margin-top: 16px; text-align: center;">
          Reply directly to this email to respond to ${cleanName}
        </p>
      </div>
    `;

    // Send to hello@erronatus.com with reply-to set to the customer
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Erronatus Contact <hello@erronatus.com>',
        to: 'hello@erronatus.com',
        reply_to: cleanEmail,
        subject: emailSubject,
        html,
      }),
    });

    if (!res.ok) {
      const err = await res.json();
      console.error('Resend error:', err);
      return new Response(
        JSON.stringify({ error: 'Failed to send message. Please email hello@erronatus.com directly.' }),
        { status: 500, headers: CORS_HEADERS }
      );
    }

    recordSubmission(ip);

    return new Response(
      JSON.stringify({ success: true, message: 'Message sent successfully.' }),
      { status: 200, headers: CORS_HEADERS }
    );
  } catch (error: any) {
    console.error('Contact form error:', error);
    return new Response(
      JSON.stringify({ error: 'Something went wrong. Please try again.' }),
      { status: 500, headers: CORS_HEADERS }
    );
  }
};
