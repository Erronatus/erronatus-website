import type { APIRoute } from 'astro';

const SITE_URL = import.meta.env.SITE_URL || 'https://erronatus.com';

export const prerender = false;

export const POST: APIRoute = async ({ request }) => {
  try {
    // Lazy-load Stripe only when the endpoint is called
    const Stripe = (await import('stripe')).default;
    const stripe = new Stripe(import.meta.env.STRIPE_SECRET_KEY || '', {
      apiVersion: '2023-10-16',
    });

    const data = await request.json();
    const { priceId, email, edition } = data;

    if (!priceId || !edition) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      );
    }

    const session = await stripe.checkout.sessions.create({
      line_items: [
        {
          price: priceId,
          quantity: 1,
        },
      ],
      customer_email: email || undefined,
      mode: 'payment',
      success_url: `${SITE_URL}/thank-you?session_id={CHECKOUT_SESSION_ID}`,
      cancel_url: `${SITE_URL}/#blueprint`,
      metadata: {
        edition,
        date: new Date().toISOString(),
      },
      allow_promotion_codes: true,
    });

    return new Response(
      JSON.stringify({ url: session.url }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    );
  } catch (error: any) {
    console.error('Stripe checkout error:', error);
    return new Response(
      JSON.stringify({ error: error.message || 'Failed to create checkout session' }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    );
  }
};
