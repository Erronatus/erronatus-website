# Chapter 15: Payment Integration
## Build Professional Payment Systems That Convert

*Payment processing is where businesses succeed or fail. Get it wrong, and you lose customers at the final moment. Get it right, and you have a conversion machine that turns visitors into revenue. This chapter shows you how to build enterprise-grade payment systems using Stripe that handle everything from one-time purchases to complex subscription billing.*

### Why This Matters

Payment integration is not just about accepting money. It's about:
- **Conversion Optimization**: Reducing friction in the buying process
- **Customer Experience**: Making payments feel secure and professional
- **Business Intelligence**: Understanding your revenue streams
- **Automation**: Handling fulfillment, refunds, and customer service automatically
- **Compliance**: Meeting PCI DSS requirements without the headaches

The businesses making millions online have payment systems that just work. No dropped transactions, no confusing checkout flows, no manual fulfillment. This chapter shows you how to build yours.

## Stripe Fundamentals: How Money Flows

### The Payment Journey
```
Customer clicks "Buy" 
    ↓
Frontend creates Checkout Session
    ↓ 
Customer enters payment details (Stripe-hosted)
    ↓
Payment processed by Stripe
    ↓
Webhook notification sent to your server
    ↓
Your server fulfills the order
    ↓
Customer receives product/access
```

### Key Stripe Concepts

**Payment Intents**: Represents a payment from creation to completion
**Checkout Sessions**: Hosted payment pages that handle the entire flow
**Webhooks**: Real-time notifications about payment events
**Products & Prices**: Your catalog items and pricing
**Customers**: Buyer information and payment history

## Complete Stripe Setup

### Step 1: Account Configuration

```bash
# Set up environment variables
cat >> ~/.openclaw/workspace/.env << 'EOF'
# Stripe Configuration
STRIPE_PUBLISHABLE_KEY=pk_test_51...
STRIPE_SECRET_KEY=sk_test_51...
STRIPE_WEBHOOK_SECRET=whsec_...
STRIPE_SUCCESS_URL=https://yourdomain.com/success
STRIPE_CANCEL_URL=https://yourdomain.com/cancel

# Company Information
COMPANY_NAME=Your Company Name
COMPANY_DOMAIN=yourdomain.com
SUPPORT_EMAIL=support@yourdomain.com
EOF
```

### Step 2: Initialize Stripe Integration

```javascript
// ~/.openclaw/workspace/scripts/stripe-setup.js
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

class StripeSetup {
    constructor() {
        this.stripe = stripe;
    }

    async initializeAccount() {
        try {
            console.log('🚀 Initializing Stripe account...');
            
            // Test API connection
            const balance = await this.stripe.balance.retrieve();
            console.log('✅ Stripe API connected successfully');
            console.log(`💰 Available balance: $${(balance.available[0]?.amount || 0) / 100}`);
            
            // Get account information
            const account = await this.stripe.accounts.retrieve();
            console.log(`🏢 Account: ${account.business_profile?.name || account.email}`);
            console.log(`🌍 Country: ${account.country}`);
            
            // Check webhook endpoints
            const webhooks = await this.stripe.webhookEndpoints.list();
            console.log(`🔗 Configured webhooks: ${webhooks.data.length}`);
            
            return {
                connected: true,
                balance: balance.available[0]?.amount || 0,
                account: account,
                webhooks: webhooks.data.length
            };
            
        } catch (error) {
            console.error('❌ Stripe initialization failed:', error.message);
            return { connected: false, error: error.message };
        }
    }

    async createBasicProducts() {
        console.log('📦 Creating basic product catalog...');
        
        const products = [
            {
                name: 'Digital Guide',
                description: 'Comprehensive guide with actionable insights',
                price: 2997, // $29.97
                type: 'one_time'
            },
            {
                name: 'Monthly Subscription',
                description: 'Access to premium features and content',
                price: 1997, // $19.97/month
                type: 'recurring',
                interval: 'month'
            },
            {
                name: 'Annual Subscription',
                description: 'Full yearly access with 20% discount',
                price: 19176, // $191.76/year (20% off monthly)
                type: 'recurring',
                interval: 'year'
            }
        ];

        const createdProducts = [];

        for (const productData of products) {
            try {
                // Create product
                const product = await this.stripe.products.create({
                    name: productData.name,
                    description: productData.description,
                    metadata: {
                        type: productData.type,
                        setup_date: new Date().toISOString()
                    }
                });

                // Create price
                const priceConfig = {
                    product: product.id,
                    unit_amount: productData.price,
                    currency: 'usd',
                    metadata: {
                        setup_date: new Date().toISOString()
                    }
                };

                if (productData.type === 'recurring') {
                    priceConfig.recurring = {
                        interval: productData.interval
                    };
                }

                const price = await this.stripe.prices.create(priceConfig);

                console.log(`✅ Created: ${productData.name} (${product.id})`);
                
                createdProducts.push({
                    product: product,
                    price: price,
                    displayPrice: `$${productData.price / 100}${productData.type === 'recurring' ? '/' + productData.interval : ''}`
                });

            } catch (error) {
                console.error(`❌ Failed to create ${productData.name}:`, error.message);
            }
        }

        return createdProducts;
    }

    async setupWebhook(endpointUrl) {
        try {
            console.log(`🔗 Setting up webhook endpoint: ${endpointUrl}`);
            
            const webhook = await this.stripe.webhookEndpoints.create({
                url: endpointUrl,
                enabled_events: [
                    'checkout.session.completed',
                    'payment_intent.succeeded',
                    'payment_intent.payment_failed',
                    'customer.subscription.created',
                    'customer.subscription.updated',
                    'customer.subscription.deleted',
                    'invoice.payment_succeeded',
                    'invoice.payment_failed'
                ],
                metadata: {
                    created_by: 'openclaw_setup',
                    setup_date: new Date().toISOString()
                }
            });

            console.log(`✅ Webhook created: ${webhook.id}`);
            console.log(`🔐 Webhook secret: ${webhook.secret}`);
            console.log('⚠️  Save this webhook secret in your environment variables as STRIPE_WEBHOOK_SECRET');
            
            return webhook;
            
        } catch (error) {
            console.error('❌ Webhook setup failed:', error.message);
            throw error;
        }
    }
}

// CLI Usage
if (require.main === module) {
    const setup = new StripeSetup();
    
    const command = process.argv[2];
    
    switch (command) {
        case 'init':
            setup.initializeAccount().then(result => {
                console.log('\n📊 Setup Result:', JSON.stringify(result, null, 2));
            });
            break;
            
        case 'products':
            setup.createBasicProducts().then(products => {
                console.log(`\n✅ Created ${products.length} products:`);
                products.forEach(p => {
                    console.log(`  • ${p.product.name}: ${p.displayPrice} (${p.price.id})`);
                });
            });
            break;
            
        case 'webhook':
            const url = process.argv[3];
            if (!url) {
                console.error('Usage: node stripe-setup.js webhook https://yourdomain.com/webhook');
                process.exit(1);
            }
            setup.setupWebhook(url);
            break;
            
        default:
            console.log('Usage: node stripe-setup.js [init|products|webhook]');
            console.log('');
            console.log('Commands:');
            console.log('  init                    - Test connection and show account info');
            console.log('  products                - Create sample product catalog');
            console.log('  webhook <url>           - Set up webhook endpoint');
    }
}

module.exports = StripeSetup;
```

### Step 3: Product and Price Management

```javascript
// ~/.openclaw/workspace/scripts/stripe-catalog.js
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

class StripeCatalog {
    constructor() {
        this.stripe = stripe;
    }

    async createProduct(productData) {
        try {
            // Create the product
            const product = await this.stripe.products.create({
                name: productData.name,
                description: productData.description,
                images: productData.images || [],
                metadata: {
                    category: productData.category || 'digital',
                    created_via: 'openclaw',
                    ...productData.metadata
                },
                url: productData.url || null
            });

            console.log(`✅ Created product: ${product.name} (${product.id})`);
            return product;

        } catch (error) {
            console.error('❌ Product creation failed:', error.message);
            throw error;
        }
    }

    async createPrice(productId, priceData) {
        try {
            const priceConfig = {
                product: productId,
                unit_amount: priceData.amount,
                currency: priceData.currency || 'usd',
                metadata: {
                    created_via: 'openclaw',
                    ...priceData.metadata
                }
            };

            // Handle recurring prices (subscriptions)
            if (priceData.recurring) {
                priceConfig.recurring = {
                    interval: priceData.recurring.interval, // 'month', 'year', etc.
                    interval_count: priceData.recurring.interval_count || 1
                };
            }

            const price = await this.stripe.prices.create(priceConfig);
            
            console.log(`✅ Created price: $${price.unit_amount / 100}${price.recurring ? '/' + price.recurring.interval : ''} (${price.id})`);
            return price;

        } catch (error) {
            console.error('❌ Price creation failed:', error.message);
            throw error;
        }
    }

    async createDigitalProduct(name, description, priceInCents, options = {}) {
        // Create product and price in one go
        const product = await this.createProduct({
            name,
            description,
            category: 'digital',
            ...options
        });

        const price = await this.createPrice(product.id, {
            amount: priceInCents,
            metadata: {
                product_type: 'digital',
                fulfillment_type: 'automatic'
            }
        });

        return { product, price };
    }

    async createSubscriptionTier(name, description, monthlyPrice, yearlyPrice) {
        // Create the base product
        const product = await this.createProduct({
            name,
            description,
            category: 'subscription'
        });

        // Create monthly price
        const monthlyPriceObj = await this.createPrice(product.id, {
            amount: monthlyPrice,
            recurring: { interval: 'month' },
            metadata: { billing_cycle: 'monthly' }
        });

        // Create yearly price (typically discounted)
        const yearlyPriceObj = await this.createPrice(product.id, {
            amount: yearlyPrice,
            recurring: { interval: 'year' },
            metadata: { billing_cycle: 'yearly' }
        });

        console.log(`📦 Created subscription tier: ${name}`);
        console.log(`   Monthly: $${monthlyPrice / 100}/month`);
        console.log(`   Yearly: $${yearlyPrice / 100}/year`);

        return {
            product,
            prices: {
                monthly: monthlyPriceObj,
                yearly: yearlyPriceObj
            }
        };
    }

    async listProducts() {
        try {
            const products = await this.stripe.products.list({
                active: true,
                expand: ['data.default_price'],
                limit: 100
            });

            console.log(`📦 Found ${products.data.length} active products:`);
            
            products.data.forEach(product => {
                const price = product.default_price;
                const priceDisplay = price ? 
                    `$${price.unit_amount / 100}${price.recurring ? '/' + price.recurring.interval : ''}` : 
                    'No default price';
                    
                console.log(`  • ${product.name}: ${priceDisplay} (${product.id})`);
            });

            return products.data;

        } catch (error) {
            console.error('❌ Failed to list products:', error.message);
            throw error;
        }
    }

    async updateProductPrice(productId, newPriceInCents) {
        try {
            // Create new price (Stripe doesn't allow price updates)
            const price = await this.createPrice(productId, {
                amount: newPriceInCents
            });

            // Update product to use new price as default
            await this.stripe.products.update(productId, {
                default_price: price.id
            });

            console.log(`✅ Updated product ${productId} with new price: $${newPriceInCents / 100}`);
            return price;

        } catch (error) {
            console.error('❌ Price update failed:', error.message);
            throw error;
        }
    }

    // Pre-configured product templates
    async createDigitalGuideProduct() {
        return await this.createDigitalProduct(
            'The Complete Digital Guide',
            'Everything you need to know, delivered instantly',
            2997, // $29.97
            {
                images: ['https://yourdomain.com/guide-cover.jpg'],
                url: 'https://yourdomain.com/guide',
                metadata: {
                    download_url: 'https://yourdomain.com/downloads/guide.pdf',
                    file_size: '2.5MB',
                    pages: '120'
                }
            }
        );
    }

    async createSaaSPricingTiers() {
        const tiers = [];

        // Starter tier
        const starter = await this.createSubscriptionTier(
            'Starter Plan',
            'Perfect for individuals getting started',
            997,   // $9.97/month
            9576   // $95.76/year (20% discount)
        );
        tiers.push(starter);

        // Professional tier
        const pro = await this.createSubscriptionTier(
            'Professional Plan',
            'Advanced features for growing businesses',
            2997,  // $29.97/month
            28776  // $287.76/year (20% discount)
        );
        tiers.push(pro);

        // Enterprise tier
        const enterprise = await this.createSubscriptionTier(
            'Enterprise Plan',
            'Full features with priority support',
            9997,  // $99.97/month
            95976  // $959.76/year (20% discount)
        );
        tiers.push(enterprise);

        console.log('🏢 Created complete SaaS pricing structure');
        return tiers;
    }
}

// CLI Usage
if (require.main === module) {
    const catalog = new StripeCatalog();
    
    const command = process.argv[2];
    
    switch (command) {
        case 'list':
            catalog.listProducts();
            break;
            
        case 'guide':
            catalog.createDigitalGuideProduct().then(result => {
                console.log('Guide product created:', result.product.id);
            });
            break;
            
        case 'saas':
            catalog.createSaaSPricingTiers().then(tiers => {
                console.log(`Created ${tiers.length} pricing tiers`);
            });
            break;
            
        case 'product':
            const name = process.argv[3];
            const price = parseInt(process.argv[4]);
            const description = process.argv[5] || 'Digital product';
            
            if (!name || !price) {
                console.error('Usage: node stripe-catalog.js product "Product Name" 2997 "Description"');
                process.exit(1);
            }
            
            catalog.createDigitalProduct(name, description, price).then(result => {
                console.log(`Product created: ${result.product.id}`);
                console.log(`Price created: ${result.price.id}`);
            });
            break;
            
        default:
            console.log('Usage: node stripe-catalog.js [list|guide|saas|product]');
    }
}

module.exports = StripeCatalog;
```

## Complete Checkout Flow

### Frontend Integration

```javascript
// ~/.openclaw/workspace/public/js/checkout.js
class StripeCheckout {
    constructor(publishableKey) {
        this.stripe = Stripe(publishableKey);
        this.isLoading = false;
    }

    async createCheckoutSession(priceId, options = {}) {
        if (this.isLoading) return;
        
        this.setLoading(true);
        
        try {
            const response = await fetch('/api/create-checkout-session', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    priceId: priceId,
                    quantity: options.quantity || 1,
                    customerEmail: options.customerEmail || null,
                    metadata: options.metadata || {},
                    successUrl: options.successUrl || window.location.origin + '/success',
                    cancelUrl: options.cancelUrl || window.location.origin + '/cancel'
                })
            });

            const session = await response.json();

            if (!response.ok) {
                throw new Error(session.error || 'Failed to create checkout session');
            }

            // Redirect to Stripe Checkout
            const result = await this.stripe.redirectToCheckout({
                sessionId: session.id
            });

            if (result.error) {
                throw new Error(result.error.message);
            }

        } catch (error) {
            console.error('Checkout error:', error);
            this.showError(error.message);
        } finally {
            this.setLoading(false);
        }
    }

    setLoading(loading) {
        this.isLoading = loading;
        const buttons = document.querySelectorAll('.checkout-button');
        
        buttons.forEach(button => {
            if (loading) {
                button.disabled = true;
                button.innerHTML = '<span class="spinner"></span> Processing...';
            } else {
                button.disabled = false;
                button.innerHTML = button.dataset.originalText || 'Buy Now';
            }
        });
    }

    showError(message) {
        const errorElement = document.getElementById('checkout-error');
        if (errorElement) {
            errorElement.textContent = message;
            errorElement.style.display = 'block';
            
            // Hide error after 5 seconds
            setTimeout(() => {
                errorElement.style.display = 'none';
            }, 5000);
        } else {
            alert('Error: ' + message);
        }
    }

    // Initialize checkout buttons
    initializeButtons() {
        document.querySelectorAll('.checkout-button').forEach(button => {
            // Store original text
            button.dataset.originalText = button.innerHTML;
            
            button.addEventListener('click', (e) => {
                e.preventDefault();
                
                const priceId = button.dataset.priceId;
                const quantity = parseInt(button.dataset.quantity) || 1;
                const customerEmail = document.getElementById('customer-email')?.value;
                
                if (!priceId) {
                    this.showError('Price ID not found');
                    return;
                }
                
                this.createCheckoutSession(priceId, {
                    quantity,
                    customerEmail,
                    metadata: {
                        source: 'website',
                        page: window.location.pathname
                    }
                });
            });
        });
    }
}

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    const publishableKey = document.querySelector('meta[name="stripe-publishable-key"]')?.content;
    
    if (publishableKey) {
        const checkout = new StripeCheckout(publishableKey);
        checkout.initializeButtons();
        
        // Make globally available
        window.stripeCheckout = checkout;
    }
});
```

### Backend Checkout Session Creation

```javascript
// ~/.openclaw/workspace/api/create-checkout-session.js
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
);

async function createCheckoutSession(req, res) {
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
        const {
            priceId,
            quantity = 1,
            customerEmail,
            metadata = {},
            successUrl,
            cancelUrl
        } = req.body;

        if (!priceId) {
            return res.status(400).json({ error: 'Price ID is required' });
        }

        // Get price details to validate
        const price = await stripe.prices.retrieve(priceId, {
            expand: ['product']
        });

        if (!price.active) {
            return res.status(400).json({ error: 'Price is not active' });
        }

        // Prepare session configuration
        const sessionConfig = {
            payment_method_types: ['card'],
            line_items: [
                {
                    price: priceId,
                    quantity: quantity,
                }
            ],
            mode: price.recurring ? 'subscription' : 'payment',
            success_url: successUrl || `${req.headers.origin}/success?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: cancelUrl || `${req.headers.origin}/cancel`,
            metadata: {
                ...metadata,
                created_at: new Date().toISOString(),
                origin: req.headers.origin,
                user_agent: req.headers['user-agent']
            }
        };

        // Add customer email if provided
        if (customerEmail) {
            sessionConfig.customer_email = customerEmail;
        }

        // Handle subscription-specific settings
        if (price.recurring) {
            sessionConfig.billing_address_collection = 'required';
            sessionConfig.subscription_data = {
                metadata: {
                    product_name: price.product.name,
                    created_via: 'website'
                }
            };
        }

        // Create the checkout session
        const session = await stripe.checkout.sessions.create(sessionConfig);

        // Log the session creation (optional)
        await logCheckoutSession({
            session_id: session.id,
            price_id: priceId,
            product_name: price.product.name,
            amount: price.unit_amount,
            currency: price.currency,
            mode: sessionConfig.mode,
            customer_email: customerEmail,
            created_at: new Date().toISOString()
        });

        res.json({
            id: session.id,
            url: session.url
        });

    } catch (error) {
        console.error('Checkout session creation failed:', error);
        
        res.status(500).json({
            error: 'Failed to create checkout session',
            message: error.message
        });
    }
}

async function logCheckoutSession(sessionData) {
    try {
        const { error } = await supabase
            .from('checkout_sessions')
            .insert([sessionData]);

        if (error) {
            console.error('Failed to log checkout session:', error);
        }
    } catch (error) {
        console.error('Database logging error:', error);
    }
}

module.exports = createCheckoutSession;

// For Vercel/Netlify deployment
if (typeof window === 'undefined') {
    module.exports.handler = createCheckoutSession;
    module.exports.default = createCheckoutSession;
}
```

## Webhook Implementation with Signature Verification

```javascript
// ~/.openclaw/workspace/api/webhooks/stripe.js
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { createClient } = require('@supabase/supabase-js');

const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_ROLE_KEY // Use service role for admin operations
);

class StripeWebhookHandler {
    constructor() {
        this.stripe = stripe;
        this.webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;
    }

    async handleWebhook(req, res) {
        let event;

        try {
            // Verify webhook signature
            const signature = req.headers['stripe-signature'];
            const body = req.body;

            event = this.stripe.webhooks.constructEvent(
                body,
                signature,
                this.webhookSecret
            );

        } catch (error) {
            console.error('Webhook signature verification failed:', error.message);
            return res.status(400).json({
                error: 'Webhook signature verification failed'
            });
        }

        console.log(`📥 Received webhook: ${event.type}`);

        try {
            // Handle the event
            switch (event.type) {
                case 'checkout.session.completed':
                    await this.handleCheckoutCompleted(event.data.object);
                    break;

                case 'payment_intent.succeeded':
                    await this.handlePaymentSucceeded(event.data.object);
                    break;

                case 'payment_intent.payment_failed':
                    await this.handlePaymentFailed(event.data.object);
                    break;

                case 'customer.subscription.created':
                    await this.handleSubscriptionCreated(event.data.object);
                    break;

                case 'customer.subscription.updated':
                    await this.handleSubscriptionUpdated(event.data.object);
                    break;

                case 'customer.subscription.deleted':
                    await this.handleSubscriptionCancelled(event.data.object);
                    break;

                case 'invoice.payment_succeeded':
                    await this.handleInvoicePaymentSucceeded(event.data.object);
                    break;

                case 'invoice.payment_failed':
                    await this.handleInvoicePaymentFailed(event.data.object);
                    break;

                default:
                    console.log(`ℹ️  Unhandled event type: ${event.type}`);
            }

            // Log successful webhook processing
            await this.logWebhookEvent(event, 'success');

            res.json({ received: true });

        } catch (error) {
            console.error('Webhook processing error:', error);
            
            // Log failed webhook processing
            await this.logWebhookEvent(event, 'failed', error.message);
            
            res.status(500).json({
                error: 'Webhook processing failed',
                message: error.message
            });
        }
    }

    async handleCheckoutCompleted(session) {
        console.log(`✅ Checkout completed: ${session.id}`);

        try {
            // Get full session details with line items
            const fullSession = await this.stripe.checkout.sessions.retrieve(session.id, {
                expand: ['line_items', 'customer']
            });

            // Save transaction record
            const transaction = {
                stripe_session_id: session.id,
                stripe_payment_intent_id: session.payment_intent,
                customer_email: session.customer_details?.email || session.customer_email,
                customer_name: session.customer_details?.name,
                amount_total: session.amount_total,
                currency: session.currency,
                payment_status: session.payment_status,
                mode: session.mode,
                metadata: session.metadata,
                line_items: fullSession.line_items.data,
                created_at: new Date().toISOString()
            };

            const { data, error } = await supabase
                .from('transactions')
                .insert([transaction])
                .select()
                .single();

            if (error) throw error;

            console.log(`💾 Transaction saved: ${data.id}`);

            // Handle fulfillment based on mode
            if (session.mode === 'payment') {
                await this.fulfillOneTimePayment(session, data);
            } else if (session.mode === 'subscription') {
                await this.handleNewSubscription(session, data);
            }

        } catch (error) {
            console.error('Error handling checkout completion:', error);
            throw error;
        }
    }

    async fulfillOneTimePayment(session, transaction) {
        console.log(`📦 Fulfilling one-time payment: ${transaction.id}`);

        try {
            // Get line items to understand what was purchased
            const fullSession = await this.stripe.checkout.sessions.retrieve(session.id, {
                expand: ['line_items.data.price.product']
            });

            for (const item of fullSession.line_items.data) {
                const product = item.price.product;
                
                console.log(`📋 Processing item: ${product.name}`);

                // Generate download links or access
                if (product.metadata?.download_url) {
                    await this.generateDigitalDownload(
                        transaction,
                        product,
                        session.customer_details.email
                    );
                }

                // Send welcome/confirmation email
                await this.sendPurchaseConfirmation(
                    session.customer_details.email,
                    product.name,
                    transaction
                );
            }

            // Update transaction status
            await supabase
                .from('transactions')
                .update({
                    fulfillment_status: 'fulfilled',
                    fulfilled_at: new Date().toISOString()
                })
                .eq('id', transaction.id);

            console.log(`✅ Fulfillment completed for transaction: ${transaction.id}`);

        } catch (error) {
            console.error('Fulfillment error:', error);
            
            // Update transaction with error status
            await supabase
                .from('transactions')
                .update({
                    fulfillment_status: 'failed',
                    fulfillment_error: error.message
                })
                .eq('id', transaction.id);
                
            throw error;
        }
    }

    async generateDigitalDownload(transaction, product, customerEmail) {
        console.log(`🔗 Generating download link for: ${product.name}`);

        try {
            // Create secure download token
            const downloadToken = this.generateSecureToken();
            const expiresAt = new Date();
            expiresAt.setDate(expiresAt.getDate() + 7); // 7-day expiry

            // Save download record
            const { data, error } = await supabase
                .from('digital_downloads')
                .insert([{
                    transaction_id: transaction.id,
                    product_id: product.id,
                    product_name: product.name,
                    customer_email: customerEmail,
                    download_token: downloadToken,
                    download_url: product.metadata.download_url,
                    expires_at: expiresAt.toISOString(),
                    max_downloads: 10, // Allow 10 downloads
                    download_count: 0
                }])
                .select()
                .single();

            if (error) throw error;

            console.log(`💾 Download record created: ${data.id}`);

            // Send download email
            await this.sendDownloadEmail(customerEmail, product.name, downloadToken);

            return data;

        } catch (error) {
            console.error('Digital download generation failed:', error);
            throw error;
        }
    }

    async sendDownloadEmail(email, productName, downloadToken) {
        // This would integrate with your email system (Resend, etc.)
        const downloadUrl = `${process.env.WEBSITE_URL}/download/${downloadToken}`;
        
        console.log(`📧 Sending download email to ${email}`);
        console.log(`🔗 Download URL: ${downloadUrl}`);

        // TODO: Integrate with your email automation system
        // For now, just log the details
        
        return downloadUrl;
    }

    async sendPurchaseConfirmation(email, productName, transaction) {
        console.log(`📧 Sending purchase confirmation to ${email}`);
        
        // TODO: Integrate with your email system to send receipt
        // Include transaction details, receipt, and next steps
    }

    async handleNewSubscription(session, transaction) {
        console.log(`🔄 Processing new subscription: ${session.subscription}`);

        try {
            // Get subscription details
            const subscription = await this.stripe.subscriptions.retrieve(session.subscription);

            // Save subscription record
            const { data, error } = await supabase
                .from('subscriptions')
                .insert([{
                    stripe_subscription_id: subscription.id,
                    stripe_customer_id: subscription.customer,
                    customer_email: session.customer_details.email,
                    status: subscription.status,
                    current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
                    current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
                    plan_name: subscription.items.data[0].price.nickname || 'Subscription',
                    amount: subscription.items.data[0].price.unit_amount,
                    currency: subscription.items.data[0].price.currency,
                    interval: subscription.items.data[0].price.recurring.interval,
                    transaction_id: transaction.id
                }])
                .select()
                .single();

            if (error) throw error;

            console.log(`💾 Subscription saved: ${data.id}`);

            // Grant access/activate features
            await this.activateSubscriptionAccess(data);

            return data;

        } catch (error) {
            console.error('Subscription processing error:', error);
            throw error;
        }
    }

    async activateSubscriptionAccess(subscription) {
        console.log(`🔓 Activating access for subscription: ${subscription.id}`);
        
        // TODO: Implement your access activation logic
        // - Create user account if needed
        // - Grant access to premium features
        // - Send welcome email with login details
        // - Set up user dashboard access
    }

    async handlePaymentSucceeded(paymentIntent) {
        console.log(`💰 Payment succeeded: ${paymentIntent.id}`);
        
        // Update transaction status if needed
        await supabase
            .from('transactions')
            .update({
                payment_status: 'succeeded',
                stripe_payment_intent_id: paymentIntent.id
            })
            .eq('stripe_payment_intent_id', paymentIntent.id);
    }

    async handlePaymentFailed(paymentIntent) {
        console.log(`❌ Payment failed: ${paymentIntent.id}`);
        
        // Log payment failure and potentially retry or notify customer
        await supabase
            .from('transactions')
            .update({
                payment_status: 'failed',
                payment_error: paymentIntent.last_payment_error?.message
            })
            .eq('stripe_payment_intent_id', paymentIntent.id);
    }

    async handleSubscriptionUpdated(subscription) {
        console.log(`🔄 Subscription updated: ${subscription.id}`);
        
        // Update subscription record
        await supabase
            .from('subscriptions')
            .update({
                status: subscription.status,
                current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
                current_period_end: new Date(subscription.current_period_end * 1000).toISOString()
            })
            .eq('stripe_subscription_id', subscription.id);
    }

    async handleSubscriptionCancelled(subscription) {
        console.log(`❌ Subscription cancelled: ${subscription.id}`);
        
        // Update subscription record and revoke access at period end
        await supabase
            .from('subscriptions')
            .update({
                status: 'cancelled',
                cancelled_at: new Date().toISOString(),
                access_until: new Date(subscription.current_period_end * 1000).toISOString()
            })
            .eq('stripe_subscription_id', subscription.id);
    }

    async handleInvoicePaymentSucceeded(invoice) {
        console.log(`✅ Invoice payment succeeded: ${invoice.id}`);
        
        // Log successful recurring payment
        if (invoice.subscription) {
            await supabase
                .from('invoice_payments')
                .insert([{
                    stripe_invoice_id: invoice.id,
                    stripe_subscription_id: invoice.subscription,
                    amount_paid: invoice.amount_paid,
                    currency: invoice.currency,
                    status: 'paid',
                    period_start: new Date(invoice.period_start * 1000).toISOString(),
                    period_end: new Date(invoice.period_end * 1000).toISOString(),
                    paid_at: new Date().toISOString()
                }]);
        }
    }

    async handleInvoicePaymentFailed(invoice) {
        console.log(`❌ Invoice payment failed: ${invoice.id}`);
        
        // Handle dunning management - notify customer, retry payment, etc.
        if (invoice.subscription) {
            await supabase
                .from('invoice_payments')
                .insert([{
                    stripe_invoice_id: invoice.id,
                    stripe_subscription_id: invoice.subscription,
                    amount_due: invoice.amount_due,
                    currency: invoice.currency,
                    status: 'payment_failed',
                    payment_error: invoice.last_finalization_error?.message,
                    period_start: new Date(invoice.period_start * 1000).toISOString(),
                    period_end: new Date(invoice.period_end * 1000).toISOString(),
                    failed_at: new Date().toISOString()
                }]);
        }
    }

    async logWebhookEvent(event, status, error = null) {
        try {
            await supabase
                .from('webhook_logs')
                .insert([{
                    event_id: event.id,
                    event_type: event.type,
                    status: status,
                    error_message: error,
                    created_at: new Date().toISOString(),
                    processed_at: new Date().toISOString(),
                    data: event.data
                }]);
        } catch (logError) {
            console.error('Failed to log webhook event:', logError);
        }
    }

    generateSecureToken() {
        return require('crypto').randomBytes(32).toString('hex');
    }
}

// Export for serverless functions
async function handler(req, res) {
    const webhookHandler = new StripeWebhookHandler();
    return await webhookHandler.handleWebhook(req, res);
}

module.exports = { StripeWebhookHandler, handler };
module.exports.default = handler;
```

## Digital Product Fulfillment Pipeline

```javascript
// ~/.openclaw/workspace/scripts/digital-fulfillment.js
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

class DigitalFulfillment {
    constructor() {
        this.supabase = createClient(
            process.env.SUPABASE_URL,
            process.env.SUPABASE_SERVICE_ROLE_KEY
        );
        this.downloadsDir = path.join(process.env.HOME, '.openclaw/workspace/downloads');
    }

    async handleDownloadRequest(req, res) {
        const { token } = req.params;

        if (!token) {
            return res.status(400).json({ error: 'Download token required' });
        }

        try {
            // Get download record
            const { data: download, error } = await this.supabase
                .from('digital_downloads')
                .select('*')
                .eq('download_token', token)
                .single();

            if (error || !download) {
                return res.status(404).json({ error: 'Download not found or expired' });
            }

            // Check if download is still valid
            const now = new Date();
            const expiresAt = new Date(download.expires_at);

            if (now > expiresAt) {
                return res.status(410).json({ error: 'Download link has expired' });
            }

            if (download.download_count >= download.max_downloads) {
                return res.status(429).json({ error: 'Download limit exceeded' });
            }

            // Increment download count
            await this.supabase
                .from('digital_downloads')
                .update({
                    download_count: download.download_count + 1,
                    last_downloaded: new Date().toISOString()
                })
                .eq('id', download.id);

            // Generate signed URL if file is in cloud storage
            const fileUrl = await this.generateSignedDownloadURL(download);
            
            if (fileUrl) {
                // Redirect to signed URL
                return res.redirect(fileUrl);
            } else {
                // Serve file directly
                return this.serveLocalFile(download, res);
            }

        } catch (error) {
            console.error('Download error:', error);
            return res.status(500).json({ error: 'Download failed' });
        }
    }

    async generateSignedDownloadURL(download) {
        try {
            // If using Supabase storage
            if (download.download_url.startsWith('supabase://')) {
                const filePath = download.download_url.replace('supabase://', '');
                
                const { data, error } = await this.supabase.storage
                    .from('digital-products')
                    .createSignedUrl(filePath, 300); // 5 minute expiry

                if (error) throw error;
                
                return data.signedUrl;
            }
            
            // If using AWS S3, Google Cloud, etc.
            // Implement your cloud storage signed URL generation here
            
            return null; // Local file serving
            
        } catch (error) {
            console.error('Signed URL generation failed:', error);
            return null;
        }
    }

    async serveLocalFile(download, res) {
        try {
            const fileName = path.basename(download.download_url);
            const filePath = path.join(this.downloadsDir, fileName);

            if (!fs.existsSync(filePath)) {
                return res.status(404).json({ error: 'File not found' });
            }

            // Set appropriate headers
            res.setHeader('Content-Disposition', `attachment; filename="${fileName}"`);
            res.setHeader('Content-Type', 'application/octet-stream');
            
            // Stream file to response
            const fileStream = fs.createReadStream(filePath);
            fileStream.pipe(res);

        } catch (error) {
            console.error('File serving error:', error);
            return res.status(500).json({ error: 'File serving failed' });
        }
    }

    async createDigitalProduct(productData) {
        try {
            console.log(`📦 Creating digital product: ${productData.name}`);

            // Upload file to storage
            const fileUrl = await this.uploadProductFile(
                productData.filePath, 
                productData.name
            );

            // Create product record
            const { data, error } = await this.supabase
                .from('digital_products')
                .insert([{
                    name: productData.name,
                    description: productData.description,
                    file_url: fileUrl,
                    file_size: fs.statSync(productData.filePath).size,
                    file_type: path.extname(productData.filePath),
                    price: productData.price,
                    active: true,
                    metadata: productData.metadata || {},
                    created_at: new Date().toISOString()
                }])
                .select()
                .single();

            if (error) throw error;

            console.log(`✅ Digital product created: ${data.id}`);
            return data;

        } catch (error) {
            console.error('Digital product creation failed:', error);
            throw error;
        }
    }

    async uploadProductFile(filePath, productName) {
        try {
            const fileName = `${Date.now()}-${path.basename(filePath)}`;
            const fileBuffer = fs.readFileSync(filePath);

            // Upload to Supabase storage
            const { data, error } = await this.supabase.storage
                .from('digital-products')
                .upload(fileName, fileBuffer, {
                    contentType: this.getMimeType(filePath),
                    metadata: {
                        product_name: productName,
                        uploaded_at: new Date().toISOString()
                    }
                });

            if (error) throw error;

            return `supabase://${data.path}`;

        } catch (error) {
            console.error('File upload failed:', error);
            throw error;
        }
    }

    getMimeType(filePath) {
        const ext = path.extname(filePath).toLowerCase();
        const mimeTypes = {
            '.pdf': 'application/pdf',
            '.zip': 'application/zip',
            '.epub': 'application/epub+zip',
            '.mp4': 'video/mp4',
            '.mp3': 'audio/mpeg',
            '.jpg': 'image/jpeg',
            '.png': 'image/png'
        };
        
        return mimeTypes[ext] || 'application/octet-stream';
    }

    async generateProductCoupon(productId, discountPercent, validDays = 30) {
        try {
            const couponCode = this.generateCouponCode();
            const expiresAt = new Date();
            expiresAt.setDate(expiresAt.getDate() + validDays);

            const { data, error } = await this.supabase
                .from('product_coupons')
                .insert([{
                    product_id: productId,
                    coupon_code: couponCode,
                    discount_percent: discountPercent,
                    expires_at: expiresAt.toISOString(),
                    max_uses: 1,
                    used_count: 0,
                    active: true,
                    created_at: new Date().toISOString()
                }])
                .select()
                .single();

            if (error) throw error;

            console.log(`🎟️ Generated coupon: ${couponCode} (${discountPercent}% off)`);
            return data;

        } catch (error) {
            console.error('Coupon generation failed:', error);
            throw error;
        }
    }

    generateCouponCode() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let result = '';
        for (let i = 0; i < 8; i++) {
            result += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return result;
    }

    // Analytics and reporting
    async getDownloadStats(productId, days = 30) {
        try {
            const startDate = new Date();
            startDate.setDate(startDate.getDate() - days);

            const { data, error } = await this.supabase
                .from('digital_downloads')
                .select('*')
                .eq('product_id', productId)
                .gte('created_at', startDate.toISOString());

            if (error) throw error;

            const stats = {
                totalDownloads: data.reduce((sum, d) => sum + d.download_count, 0),
                uniqueCustomers: new Set(data.map(d => d.customer_email)).size,
                averageDownloadsPerCustomer: 0,
                downloadsByDay: this.groupDownloadsByDay(data),
                conversionRate: 0 // Would need purchase data to calculate
            };

            stats.averageDownloadsPerCustomer = 
                stats.uniqueCustomers > 0 ? 
                (stats.totalDownloads / stats.uniqueCustomers).toFixed(2) : 0;

            return stats;

        } catch (error) {
            console.error('Stats generation failed:', error);
            return null;
        }
    }

    groupDownloadsByDay(downloads) {
        const grouped = {};
        
        downloads.forEach(download => {
            const date = new Date(download.created_at).toISOString().split('T')[0];
            grouped[date] = (grouped[date] || 0) + download.download_count;
        });
        
        return grouped;
    }
}

module.exports = DigitalFulfillment;
```

## Revenue Dashboard System

```javascript
// ~/.openclaw/workspace/scripts/revenue-dashboard.js
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
const { createClient } = require('@supabase/supabase-js');

class RevenueDashboard {
    constructor() {
        this.stripe = stripe;
        this.supabase = createClient(
            process.env.SUPABASE_URL,
            process.env.SUPABASE_SERVICE_ROLE_KEY
        );
    }

    async generateDashboardData(period = 'month') {
        try {
            console.log(`📊 Generating revenue dashboard for: ${period}`);

            const dateRange = this.getDateRange(period);
            
            const dashboardData = {
                period: period,
                dateRange: dateRange,
                revenue: await this.getRevenueMetrics(dateRange),
                subscriptions: await this.getSubscriptionMetrics(dateRange),
                products: await this.getProductMetrics(dateRange),
                customers: await this.getCustomerMetrics(dateRange),
                growth: await this.getGrowthMetrics(dateRange),
                generatedAt: new Date().toISOString()
            };

            // Save dashboard snapshot
            await this.saveDashboardSnapshot(dashboardData);

            return dashboardData;

        } catch (error) {
            console.error('Dashboard generation failed:', error);
            throw error;
        }
    }

    getDateRange(period) {
        const now = new Date();
        const ranges = {
            'today': {
                start: new Date(now.getFullYear(), now.getMonth(), now.getDate()),
                end: now
            },
            'week': {
                start: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
                end: now
            },
            'month': {
                start: new Date(now.getFullYear(), now.getMonth(), 1),
                end: now
            },
            'quarter': {
                start: new Date(now.getFullYear(), Math.floor(now.getMonth() / 3) * 3, 1),
                end: now
            },
            'year': {
                start: new Date(now.getFullYear(), 0, 1),
                end: now
            }
        };

        return ranges[period] || ranges.month;
    }

    async getRevenueMetrics(dateRange) {
        try {
            // Get transactions from database
            const { data: transactions, error } = await this.supabase
                .from('transactions')
                .select('*')
                .eq('payment_status', 'succeeded')
                .gte('created_at', dateRange.start.toISOString())
                .lte('created_at', dateRange.end.toISOString());

            if (error) throw error;

            // Also get data from Stripe for verification
            const stripeCharges = await this.stripe.charges.list({
                created: {
                    gte: Math.floor(dateRange.start.getTime() / 1000),
                    lte: Math.floor(dateRange.end.getTime() / 1000)
                },
                limit: 100
            });

            const totalRevenue = transactions.reduce((sum, t) => sum + (t.amount_total || 0), 0);
            const transactionCount = transactions.length;
            const averageOrderValue = transactionCount > 0 ? totalRevenue / transactionCount : 0;

            // Revenue by day
            const revenueByDay = this.groupRevenueByDay(transactions);

            return {
                totalRevenue: totalRevenue / 100, // Convert from cents
                transactionCount,
                averageOrderValue: averageOrderValue / 100,
                revenueByDay,
                stripeTotal: stripeCharges.data.reduce((sum, c) => sum + c.amount, 0) / 100,
                currency: 'USD'
            };

        } catch (error) {
            console.error('Revenue metrics failed:', error);
            return {
                totalRevenue: 0,
                transactionCount: 0,
                averageOrderValue: 0,
                revenueByDay: {},
                stripeTotal: 0,
                currency: 'USD'
            };
        }
    }

    async getSubscriptionMetrics(dateRange) {
        try {
            const { data: subscriptions, error } = await this.supabase
                .from('subscriptions')
                .select('*')
                .gte('created_at', dateRange.start.toISOString())
                .lte('created_at', dateRange.end.toISOString());

            if (error) throw error;

            // Also get active subscriptions count
            const { data: activeSubscriptions, error: activeError } = await this.supabase
                .from('subscriptions')
                .select('*')
                .eq('status', 'active');

            if (activeError) throw activeError;

            const newSubscriptions = subscriptions.length;
            const totalActive = activeSubscriptions.length;
            
            // Calculate MRR (Monthly Recurring Revenue)
            const mrr = activeSubscriptions.reduce((sum, sub) => {
                if (sub.interval === 'month') {
                    return sum + (sub.amount || 0);
                } else if (sub.interval === 'year') {
                    return sum + ((sub.amount || 0) / 12);
                }
                return sum;
            }, 0);

            // Calculate churn rate
            const churnRate = await this.calculateChurnRate(dateRange);

            return {
                newSubscriptions,
                totalActive,
                mrr: mrr / 100, // Convert from cents
                churnRate,
                subscriptionsByPlan: this.groupSubscriptionsByPlan(activeSubscriptions)
            };

        } catch (error) {
            console.error('Subscription metrics failed:', error);
            return {
                newSubscriptions: 0,
                totalActive: 0,
                mrr: 0,
                churnRate: 0,
                subscriptionsByPlan: {}
            };
        }
    }

    async calculateChurnRate(dateRange) {
        try {
            // Get subscriptions that were cancelled in this period
            const { data: cancelled, error: cancelError } = await this.supabase
                .from('subscriptions')
                .select('*')
                .eq('status', 'cancelled')
                .gte('cancelled_at', dateRange.start.toISOString())
                .lte('cancelled_at', dateRange.end.toISOString());

            if (cancelError) throw cancelError;

            // Get total active at start of period
            const { data: activeAtStart, error: activeError } = await this.supabase
                .from('subscriptions')
                .select('*')
                .in('status', ['active', 'cancelled'])
                .lte('created_at', dateRange.start.toISOString());

            if (activeError) throw activeError;

            const cancelledCount = cancelled.length;
            const activeAtStartCount = activeAtStart.length;
            
            return activeAtStartCount > 0 ? 
                ((cancelledCount / activeAtStartCount) * 100).toFixed(2) : 0;

        } catch (error) {
            console.error('Churn calculation failed:', error);
            return 0;
        }
    }

    async getProductMetrics(dateRange) {
        try {
            const { data: transactions, error } = await this.supabase
                .from('transactions')
                .select('line_items, created_at')
                .eq('payment_status', 'succeeded')
                .gte('created_at', dateRange.start.toISOString())
                .lte('created_at', dateRange.end.toISOString());

            if (error) throw error;

            const productSales = {};
            let totalItems = 0;

            transactions.forEach(transaction => {
                if (transaction.line_items) {
                    transaction.line_items.forEach(item => {
                        const productName = item.description || 'Unknown Product';
                        const quantity = item.quantity || 1;
                        const amount = item.amount_total || 0;

                        if (!productSales[productName]) {
                            productSales[productName] = {
                                quantity: 0,
                                revenue: 0,
                                orders: 0
                            };
                        }

                        productSales[productName].quantity += quantity;
                        productSales[productName].revenue += amount;
                        productSales[productName].orders += 1;
                        totalItems += quantity;
                    });
                }
            });

            // Convert to sorted array
            const topProducts = Object.entries(productSales)
                .map(([name, data]) => ({
                    name,
                    quantity: data.quantity,
                    revenue: data.revenue / 100, // Convert from cents
                    orders: data.orders,
                    averageOrderValue: (data.revenue / data.orders) / 100
                }))
                .sort((a, b) => b.revenue - a.revenue)
                .slice(0, 10);

            return {
                topProducts,
                totalItems,
                uniqueProducts: Object.keys(productSales).length
            };

        } catch (error) {
            console.error('Product metrics failed:', error);
            return {
                topProducts: [],
                totalItems: 0,
                uniqueProducts: 0
            };
        }
    }

    async getCustomerMetrics(dateRange) {
        try {
            const { data: transactions, error } = await this.supabase
                .from('transactions')
                .select('customer_email, amount_total, created_at')
                .eq('payment_status', 'succeeded')
                .gte('created_at', dateRange.start.toISOString())
                .lte('created_at', dateRange.end.toISOString());

            if (error) throw error;

            const uniqueCustomers = new Set(transactions.map(t => t.customer_email)).size;
            const returningCustomers = this.countReturningCustomers(transactions);
            const newCustomers = uniqueCustomers - returningCustomers;

            // Customer lifetime value (CLV) estimate
            const clv = await this.estimateCustomerLifetimeValue();

            return {
                newCustomers,
                returningCustomers,
                uniqueCustomers,
                retentionRate: uniqueCustomers > 0 ? 
                    ((returningCustomers / uniqueCustomers) * 100).toFixed(2) : 0,
                estimatedCLV: clv
            };

        } catch (error) {
            console.error('Customer metrics failed:', error);
            return {
                newCustomers: 0,
                returningCustomers: 0,
                uniqueCustomers: 0,
                retentionRate: 0,
                estimatedCLV: 0
            };
        }
    }

    async getGrowthMetrics(dateRange) {
        try {
            // Compare with previous period
            const periodLength = dateRange.end.getTime() - dateRange.start.getTime();
            const previousPeriod = {
                start: new Date(dateRange.start.getTime() - periodLength),
                end: dateRange.start
            };

            const [currentMetrics, previousMetrics] = await Promise.all([
                this.getRevenueMetrics(dateRange),
                this.getRevenueMetrics(previousPeriod)
            ]);

            const revenueGrowth = previousMetrics.totalRevenue > 0 ?
                (((currentMetrics.totalRevenue - previousMetrics.totalRevenue) / previousMetrics.totalRevenue) * 100).toFixed(2) : 0;

            const customerGrowth = previousMetrics.transactionCount > 0 ?
                (((currentMetrics.transactionCount - previousMetrics.transactionCount) / previousMetrics.transactionCount) * 100).toFixed(2) : 0;

            return {
                revenueGrowth: parseFloat(revenueGrowth),
                customerGrowth: parseFloat(customerGrowth),
                periodComparison: {
                    current: currentMetrics.totalRevenue,
                    previous: previousMetrics.totalRevenue
                }
            };

        } catch (error) {
            console.error('Growth metrics failed:', error);
            return {
                revenueGrowth: 0,
                customerGrowth: 0,
                periodComparison: { current: 0, previous: 0 }
            };
        }
    }

    groupRevenueByDay(transactions) {
        const revenueByDay = {};
        
        transactions.forEach(transaction => {
            const date = new Date(transaction.created_at).toISOString().split('T')[0];
            revenueByDay[date] = (revenueByDay[date] || 0) + (transaction.amount_total || 0);
        });
        
        // Convert from cents
        Object.keys(revenueByDay).forEach(date => {
            revenueByDay[date] = revenueByDay[date] / 100;
        });
        
        return revenueByDay;
    }

    groupSubscriptionsByPlan(subscriptions) {
        const planCounts = {};
        
        subscriptions.forEach(sub => {
            const planName = sub.plan_name || 'Unknown Plan';
            planCounts[planName] = (planCounts[planName] || 0) + 1;
        });
        
        return planCounts;
    }

    countReturningCustomers(transactions) {
        const customerFirstPurchase = {};
        
        transactions.forEach(transaction => {
            const email = transaction.customer_email;
            const date = new Date(transaction.created_at);
            
            if (!customerFirstPurchase[email] || customerFirstPurchase[email] > date) {
                customerFirstPurchase[email] = date;
            }
        });
        
        // Count customers with purchases before this period
        return Object.values(customerFirstPurchase).filter(date => {
            // Logic to determine if customer is returning
            return true; // Simplified for example
        }).length;
    }

    async estimateCustomerLifetimeValue() {
        try {
            // Simple CLV calculation: Average Order Value × Purchase Frequency × Gross Margin × Lifespan
            const { data: allTransactions, error } = await this.supabase
                .from('transactions')
                .select('customer_email, amount_total, created_at')
                .eq('payment_status', 'succeeded')
                .order('created_at', { ascending: true });

            if (error || !allTransactions.length) return 0;

            const customerData = {};
            
            allTransactions.forEach(transaction => {
                const email = transaction.customer_email;
                if (!customerData[email]) {
                    customerData[email] = {
                        totalSpent: 0,
                        purchaseCount: 0,
                        firstPurchase: new Date(transaction.created_at),
                        lastPurchase: new Date(transaction.created_at)
                    };
                }
                
                const customer = customerData[email];
                customer.totalSpent += transaction.amount_total;
                customer.purchaseCount += 1;
                
                const purchaseDate = new Date(transaction.created_at);
                if (purchaseDate < customer.firstPurchase) {
                    customer.firstPurchase = purchaseDate;
                }
                if (purchaseDate > customer.lastPurchase) {
                    customer.lastPurchase = purchaseDate;
                }
            });

            // Calculate averages
            const customers = Object.values(customerData);
            const avgOrderValue = customers.reduce((sum, c) => sum + (c.totalSpent / c.purchaseCount), 0) / customers.length;
            const avgPurchaseFrequency = customers.reduce((sum, c) => sum + c.purchaseCount, 0) / customers.length;
            
            // Estimate CLV (simplified calculation)
            const grossMargin = 0.7; // Assume 70% margin
            const estimatedLifespanMonths = 24; // Assume 2 year lifespan
            
            const clv = (avgOrderValue / 100) * avgPurchaseFrequency * grossMargin * (estimatedLifespanMonths / 12);
            
            return clv.toFixed(2);

        } catch (error) {
            console.error('CLV estimation failed:', error);
            return 0;
        }
    }

    async saveDashboardSnapshot(dashboardData) {
        try {
            const { error } = await this.supabase
                .from('revenue_snapshots')
                .insert([{
                    period: dashboardData.period,
                    total_revenue: dashboardData.revenue.totalRevenue,
                    transaction_count: dashboardData.revenue.transactionCount,
                    mrr: dashboardData.subscriptions.mrr,
                    active_subscriptions: dashboardData.subscriptions.totalActive,
                    new_customers: dashboardData.customers.newCustomers,
                    revenue_growth: dashboardData.growth.revenueGrowth,
                    snapshot_data: dashboardData,
                    created_at: new Date().toISOString()
                }]);

            if (error) throw error;
            
            console.log('📈 Dashboard snapshot saved');

        } catch (error) {
            console.error('Snapshot save failed:', error);
        }
    }

    async exportDashboardReport(period = 'month', format = 'json') {
        const dashboardData = await this.generateDashboardData(period);
        
        if (format === 'csv') {
            return this.convertToCSV(dashboardData);
        }
        
        return JSON.stringify(dashboardData, null, 2);
    }

    convertToCSV(dashboardData) {
        // Convert dashboard data to CSV format
        let csv = 'Metric,Value\n';
        csv += `Total Revenue,$${dashboardData.revenue.totalRevenue}\n`;
        csv += `Transaction Count,${dashboardData.revenue.transactionCount}\n`;
        csv += `Average Order Value,$${dashboardData.revenue.averageOrderValue}\n`;
        csv += `MRR,$${dashboardData.subscriptions.mrr}\n`;
        csv += `Active Subscriptions,${dashboardData.subscriptions.totalActive}\n`;
        csv += `New Customers,${dashboardData.customers.newCustomers}\n`;
        csv += `Revenue Growth,${dashboardData.growth.revenueGrowth}%\n`;
        
        return csv;
    }
}

// CLI Usage
if (require.main === module) {
    const dashboard = new RevenueDashboard();
    
    const period = process.argv[2] || 'month';
    const format = process.argv[3] || 'json';
    
    dashboard.exportDashboardReport(period, format).then(report => {
        console.log(report);
    }).catch(error => {
        console.error('Dashboard generation failed:', error);
    });
}

module.exports = RevenueDashboard;
```

## Pro Tips

**💳 Test Everything:** Use Stripe's test mode extensively. Test successful payments, failed payments, webhooks, refunds, and edge cases.

**🔐 Webhook Security:** Always verify webhook signatures. Attackers can send fake webhook data to your endpoints.

**📊 Monitor Key Metrics:** Track conversion rates, average order values, refund rates, and churn. These numbers tell you what's working.

**⚡ Optimize Checkout:** Every extra click loses customers. Keep checkout as simple as possible while collecting necessary information.

**🎯 Customer Experience:** Failed payments are frustrating. Provide clear error messages and easy retry mechanisms.

## Troubleshooting

### Issue 1: Webhooks Not Being Received
**Symptoms:** Stripe events firing but webhook handler not being called
**Diagnosis:** Network connectivity or endpoint configuration
**Fix:**
```bash
# Test webhook endpoint locally with ngrok
ngrok http 3000

# Test webhook with Stripe CLI
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# Verify webhook endpoint in Stripe dashboard
curl -X POST https://yourdomain.com/api/webhooks/stripe -H "stripe-signature: test"
```

### Issue 2: Payment Intent Failures
**Symptoms:** Customers can't complete payments
**Diagnosis:** Card declined, insufficient funds, or fraud detection
**Fix:**
```javascript
// Handle payment failures gracefully
async function handlePaymentFailure(paymentIntent) {
    const errorCode = paymentIntent.last_payment_error?.code;
    
    const errorMessages = {
        'card_declined': 'Your card was declined. Please try a different payment method.',
        'insufficient_funds': 'Insufficient funds. Please try a different card.',
        'expired_card': 'Your card has expired. Please update your payment information.',
        'incorrect_cvc': 'The security code is incorrect. Please check and try again.'
    };
    
    return errorMessages[errorCode] || 'Payment failed. Please try again.';
}
```

### Issue 3: Duplicate Webhook Processing
**Symptoms:** Same webhook event processed multiple times
**Diagnosis:** Webhook retries due to non-200 responses or slow processing
**Fix:**
```javascript
// Implement idempotency keys
const processedEvents = new Set();

async function handleWebhook(event) {
    if (processedEvents.has(event.id)) {
        return { received: true, duplicate: true };
    }
    
    processedEvents.add(event.id);
    // Process event...
    
    return { received: true };
}
```

### Issue 4: Subscription Billing Failures
**Symptoms:** Subscriptions failing to renew automatically
**Diagnosis:** Expired cards, failed payments, or webhook processing issues
**Fix:**
```javascript
// Implement dunning management
async function handleFailedPayment(invoice) {
    const subscription = await stripe.subscriptions.retrieve(invoice.subscription);
    const customer = await stripe.customers.retrieve(subscription.customer);
    
    // Send payment failure notification
    await sendPaymentFailureEmail(customer.email, {
        amount: invoice.amount_due,
        nextRetry: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000) // 3 days
    });
    
    // Update subscription status
    await supabase
        .from('subscriptions')
        .update({ status: 'past_due' })
        .eq('stripe_subscription_id', subscription.id);
}
```

### Issue 5: High Refund Rates
**Symptoms:** Many customers requesting refunds
**Diagnosis:** Product not meeting expectations or difficult fulfillment
**Fix:**
```javascript
// Analyze refund patterns
async function analyzeRefunds() {
    const refunds = await stripe.refunds.list({ limit: 100 });
    
    const refundReasons = {};
    refunds.data.forEach(refund => {
        const reason = refund.reason || 'requested_by_customer';
        refundReasons[reason] = (refundReasons[reason] || 0) + 1;
    });
    
    console.log('Refund analysis:', refundReasons);
    
    // If high 'fraudulent' refunds, review fraud detection
    // If high 'duplicate' refunds, review checkout flow
    // If high 'requested_by_customer', review product/service quality
}
```

Payment integration is where good businesses become great businesses. A smooth, professional payment experience increases conversion rates, reduces abandoned carts, and builds customer trust. Build it right once, and it becomes a revenue multiplier that compounds over time.

The businesses making millions online don't just accept payments — they optimize every step of the payment journey to maximize conversions and customer satisfaction. This chapter gave you the blueprint to build yours.