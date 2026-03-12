import type { APIRoute } from 'astro';

export const prerender = false;

// Map edition → PDF filename in Supabase
const EDITION_FILES: Record<string, { file: string; label: string }> = {
  personal: {
    file: 'erronatus-blueprint-personal.pdf',
    label: 'Personal Edition',
  },
  business: {
    file: 'erronatus-blueprint-business.pdf',
    label: 'Business Edition',
  },
  enterprise: {
    file: 'erronatus-blueprint-enterprise.pdf',
    label: 'Enterprise Edition',
  },
};

async function createSignedUrl(file: string): Promise<string | null> {
  const SUPABASE_URL = import.meta.env.SUPABASE_URL;
  const SUPABASE_SERVICE_KEY = import.meta.env.SUPABASE_SERVICE_KEY;
  const BUCKET = 'blueprints';
  // 7-day expiry
  const expiresIn = 7 * 24 * 60 * 60;

  const res = await fetch(`${SUPABASE_URL}/storage/v1/object/sign/${BUCKET}/${file}`, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${SUPABASE_SERVICE_KEY}`,
      apikey: SUPABASE_SERVICE_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ expiresIn }),
  });

  const data = await res.json();
  if (data.signedURL) {
    return `${SUPABASE_URL}/storage/v1${data.signedURL}`;
  }
  return null;
}

async function sendDeliveryEmail(
  email: string,
  edition: string,
  downloadUrl: string,
  customerName?: string
) {
  const RESEND_API_KEY = import.meta.env.RESEND_API_KEY;
  const editionInfo = EDITION_FILES[edition] || EDITION_FILES.personal;
  const name = customerName || 'there';

  const html = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin:0;padding:0;background:#060608;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;">
  <div style="max-width:560px;margin:0 auto;padding:40px 24px;">
    <!-- Header -->
    <div style="text-align:center;margin-bottom:40px;">
      <div style="display:inline-block;width:48px;height:48px;border-radius:12px;background:linear-gradient(135deg,#C46A2F,#D4A853);line-height:48px;text-align:center;">
        <span style="color:#fff;font-weight:800;font-size:20px;">E</span>
      </div>
      <h1 style="color:#f0f0f5;font-size:24px;font-weight:800;margin:16px 0 4px;">Your Blueprint is Ready</h1>
      <p style="color:#7a7a8a;font-size:14px;margin:0;">Thank you for your purchase</p>
    </div>

    <!-- Main content -->
    <div style="background:#0d0d14;border:1px solid #1e1e26;border-radius:16px;padding:32px;margin-bottom:24px;">
      <p style="color:#e0e0e8;font-size:15px;line-height:1.6;margin:0 0 16px;">
        Hey ${name},
      </p>
      <p style="color:#94949e;font-size:14px;line-height:1.6;margin:0 0 24px;">
        Your copy of <strong style="color:#e0e0e8;">The Erronatus Blueprint — ${editionInfo.label}</strong> is ready to download. Click the button below to get your PDF.
      </p>

      <!-- Download Button -->
      <div style="text-align:center;margin:32px 0;">
        <a href="${downloadUrl}" style="display:inline-block;padding:14px 32px;background:linear-gradient(135deg,#C46A2F,#D4A853);color:#fff;font-size:14px;font-weight:700;text-decoration:none;border-radius:999px;letter-spacing:0.5px;">
          DOWNLOAD YOUR BLUEPRINT
        </a>
      </div>

      <p style="color:#5a5a66;font-size:12px;line-height:1.5;margin:0;">
        This link expires in 7 days. If you need a fresh link, just reply to this email and we'll send one right away.
      </p>
    </div>

    <!-- What's next -->
    <div style="background:#0d0d14;border:1px solid #1e1e26;border-radius:16px;padding:24px;margin-bottom:24px;">
      <h3 style="color:#f0f0f5;font-size:14px;font-weight:700;margin:0 0 12px;">What's Next?</h3>
      <ul style="color:#94949e;font-size:13px;line-height:1.8;margin:0;padding-left:20px;">
        <li>Open the PDF and follow Chapter 1 to set up your foundation</li>
        <li>Join the <a href="https://discord.com/invite/clawd" style="color:#D4843A;text-decoration:none;">OpenClaw community</a> for support</li>
        <li>Check the <a href="https://erronatus.com/blog" style="color:#D4843A;text-decoration:none;">blog</a> for tips and tutorials</li>
      </ul>
    </div>

    <!-- Guarantee -->
    <div style="text-align:center;padding:16px;border:1px solid #1e1e26;border-radius:12px;margin-bottom:32px;">
      <p style="color:#7a7a8a;font-size:12px;margin:0;">
        🛡️ 30-day money-back guarantee. Not satisfied? Reply to this email for a full refund.
      </p>
    </div>

    <!-- Footer -->
    <div style="text-align:center;padding-top:24px;border-top:1px solid #1e1e26;">
      <p style="color:#5a5a66;font-size:11px;margin:0;">
        © 2026 Erronatus · <a href="https://erronatus.com" style="color:#5a5a66;">erronatus.com</a>
      </p>
    </div>
  </div>
</body>
</html>`;

  const res = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${RESEND_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: 'Erronatus <hello@erronatus.com>',
      to: email,
      subject: `Your Erronatus Blueprint (${editionInfo.label}) — Download Inside`,
      html,
    }),
  });

  const data = await res.json();
  return { ok: res.ok, data };
}

export const POST: APIRoute = async ({ request }) => {
  try {
    const Stripe = (await import('stripe')).default;
    const stripe = new Stripe(import.meta.env.STRIPE_SECRET_KEY || '', {
      apiVersion: '2023-10-16',
    });

    const body = await request.text();
    const sig = request.headers.get('stripe-signature');

    // If webhook secret is configured, verify signature
    const webhookSecret = import.meta.env.STRIPE_WEBHOOK_SECRET;
    let event;

    if (webhookSecret && sig) {
      try {
        event = stripe.webhooks.constructEvent(body, sig, webhookSecret);
      } catch (err: any) {
        console.error('Webhook signature verification failed:', err.message);
        return new Response(JSON.stringify({ error: 'Invalid signature' }), {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        });
      }
    } else {
      // No webhook secret — parse event directly (for initial testing)
      event = JSON.parse(body);
    }

    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      const email = session.customer_email || session.customer_details?.email;
      const edition = session.metadata?.edition || 'personal';
      const customerName = session.customer_details?.name?.split(' ')[0];

      if (!email) {
        console.error('No email found in checkout session');
        return new Response(JSON.stringify({ error: 'No email' }), {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        });
      }

      const editionInfo = EDITION_FILES[edition];
      if (!editionInfo) {
        console.error(`Unknown edition: ${edition}`);
        return new Response(JSON.stringify({ error: 'Unknown edition' }), {
          status: 400,
          headers: { 'Content-Type': 'application/json' },
        });
      }

      // Generate signed download URL (7-day expiry)
      const downloadUrl = await createSignedUrl(editionInfo.file);
      if (!downloadUrl) {
        console.error('Failed to create signed URL');
        return new Response(JSON.stringify({ error: 'Failed to generate download' }), {
          status: 500,
          headers: { 'Content-Type': 'application/json' },
        });
      }

      // Send delivery email
      const emailResult = await sendDeliveryEmail(email, edition, downloadUrl, customerName);
      console.log(`Delivery email sent to ${email} for ${edition}:`, emailResult);

      return new Response(JSON.stringify({ received: true, delivered: emailResult.ok }), {
        status: 200,
        headers: { 'Content-Type': 'application/json' },
      });
    }

    // Acknowledge other event types
    return new Response(JSON.stringify({ received: true }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error: any) {
    console.error('Webhook error:', error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
};
