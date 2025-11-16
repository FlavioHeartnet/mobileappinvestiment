Stripe example server for SimuladorInvestimento

This is a minimal Node/Express example that demonstrates how to create a PaymentIntent
using the Stripe secret key on the server and return the client secret to the client app.

WARNING: Do NOT commit your Stripe secret key to version control. Use environment variables.

Setup

1. Install dependencies

```bash
cd specs/server
npm install
```

2. Set environment variables (example Linux/macOS)

```bash
export STRIPE_SECRET_KEY="sk_test_..."
# Optional: if you created Prices for your subscription plans, set these too
export STRIPE_MONTHLY_PRICE_ID="price_..."
export STRIPE_ANNUAL_PRICE_ID="price_..."
```

3. Run the server

```bash
npm start
```

4. Update the Flutter client

- Set `StripeConfig.serverBaseUrl` in `mobile/lib/src/config/stripe_config.dart` to the server URL (e.g. `http://localhost:4242`).
- Set `StripeConfig.publishableKey` to your Stripe publishable key (pk_test_...).

API

POST /create-payment-intent
- body (one of the following):
	- { plan: 'monthly' | 'annual', email: 'customer@example.com' }
		- If `STRIPE_MONTHLY_PRICE_ID` or `STRIPE_ANNUAL_PRICE_ID` are configured, the server will
			create a Subscription for the customer and return the client secret for the first invoice's
			PaymentIntent so the client can collect the initial payment.
		- Response: { clientSecret: string | null, subscriptionId: string }

	- { amount: number (in cents), currency: string }
		- Fallback: creates a one-off PaymentIntent and returns { clientSecret: string }

