# Chapter 15: Payment Integration
## Stripe Checkout & Revenue Systems

---

### Building a Revenue Engine

Every business needs a way to accept money. Stripe is the industry standard — used by Amazon, Google, Shopify, and millions of businesses. With Stripe integration, your AI-powered system can:

- Accept one-time payments for digital products
- Process subscriptions for recurring revenue
- Handle refunds and disputes
- Track revenue analytics
- Trigger fulfillment workflows on successful payment

### Stripe Account Setup

1. Go to stripe.com and create an account
2. Complete identity verification (required for live payments)
3. Navigate to Developers → API Keys
4. Copy your keys:

```bash
# Test mode (for development)
STRIPE_SECRET_KEY=sk_test_your-key
STRIPE_PUBLISHABLE_KEY=pk_test_your-key

# Live mode (for production — switch when ready)
# STRIPE_SECRET_KEY=sk_live_your-key
# STRIPE_PUBLISHABLE_KEY=pk_live_your-key
```

> **Important:** Start with test keys. Test everything thoroughly. Switch to live keys only when your entire flow works perfectly.

### Creating Products and Prices

In the Stripe Dashboard → Products → Add Product:

**Product 1: Personal Edition**
- Name: "The Erronatus Blueprint — Personal Edition"
- Description: "Complete guide to AI automation with OpenClaw"
- Price: $47.00 (one-time)
- Copy the Price ID (e.g., `price_1ABC123`)

**Product 2: Business Edition**
- Name: "The Erronatus Blueprint — Business Edition"
- Price: $97.00 (one-time)
- Copy the Price ID

**Product 3: Enterprise Edition**
- Name: "The Erronatus Blueprint — Enterprise Edition"
- Price: $299.00 (one-time)
- Copy the Price ID

### Building the Checkout Flow

The checkout process:

```
User clicks "Buy" → Your server creates a Stripe Checkout Session →
User redirects to Stripe's hosted payment page → User pays →
Stripe redirects to your success page → Webhook triggers fulfillment
```

**Server endpoint** (`/api/checkout`):

```javascript
// Creates a Stripe Checkout Session
export async function POST({ request }) {
  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
  const { priceId, email, edition } = await request.json();

  const session = await stripe.checkout.sessions.create({
    line_items: [{ price: priceId, quantity: 1 }],
    customer_email: email,
    mode: 'payment',
    success_url: 'https://yourdomain.com/thank-you?session_id={CHECKOUT_SESSION_ID}',
    cancel_url: 'https://yourdomain.com/#pricing',
    metadata: { edition },
    allow_promotion_codes: true,
  });

  return Response.json({ url: session.url });
}
```

### Webhook-Powered Fulfillment

When a payment succeeds, Stripe sends a webhook to your server. This triggers automatic fulfillment:

1. **Set up webhook endpoint** in Stripe Dashboard → Webhooks → Add Endpoint
2. **URL:** `https://yourdomain.com/api/webhook`
3. **Events:** Select `checkout.session.completed`
4. **Copy the webhook signing secret** to your `.env`

**Webhook handler:**

```javascript
export async function POST({ request }) {
  const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
  const signature = request.headers.get('stripe-signature');
  const body = await request.text();

  const event = stripe.webhooks.constructEvent(
    body,
    signature,
    process.env.STRIPE_WEBHOOK_SECRET
  );

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const email = session.customer_email;
    const edition = session.metadata.edition;

    // Send the product via email
    await sendProductEmail(email, edition);

    // Log the sale
    await logSale(session);
  }

  return new Response('OK', { status: 200 });
}
```

### Automated Product Delivery

When payment is confirmed, your system:

1. **Generates a secure download link** (signed URL, expires in 72 hours)
2. **Sends delivery email** via Resend with the download link
3. **Logs the sale** to Supabase for analytics
4. **Triggers welcome sequence** (Day 1, 3, 7, 14 emails)
5. **Updates your AI's memory** with the sale event

The buyer receives their product within seconds of payment. Fully automated.

### Testing with Stripe Test Mode

Stripe provides test card numbers:

| Card Number | Result |
|-------------|--------|
| `4242 4242 4242 4242` | Successful payment |
| `4000 0000 0000 0002` | Declined |
| `4000 0000 0000 3220` | Requires 3D Secure |

Use any future expiration date, any 3-digit CVC, and any ZIP code.

**Test the full flow:**
1. Click "Buy" on your website
2. Enter the test card number
3. Complete checkout
4. Verify redirect to success page
5. Check your email for the delivery
6. Verify the sale logged in Supabase

### Revenue Analytics

Track your business metrics:

```
You: What are my sales numbers this month?
AI: [Queries Supabase sales table]

March 2026 Revenue Report:
─────────────────────────
Total sales: 47
Revenue: $3,891.00
Average order: $82.79

By edition:
- Personal ($47): 28 sales — $1,316
- Business ($97): 15 sales — $1,455
- Enterprise ($299): 4 sales — $1,196

Conversion rate: 3.2% (47 sales / 1,469 visitors)
```

### What You've Built

✅ Stripe account configured with products and prices
✅ Checkout flow with hosted payment page
✅ Webhook-powered automatic fulfillment
✅ Secure download link generation
✅ Email delivery via Resend on purchase
✅ Sale logging to Supabase
✅ Revenue analytics accessible through your AI

---

*Next Chapter: 24/7 Operations →*
