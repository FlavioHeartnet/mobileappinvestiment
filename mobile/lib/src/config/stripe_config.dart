// Stripe configuration.
// IMPORTANT:
// - Do NOT put your secret key (sk_...) in the client app. Store it on a server.
// - Put your publishable key (pk_...) here or (preferably) inject it at build/runtime
//   from a secure source. This file contains a placeholder only.

class StripeConfig {
  // Replace with your publishable key (pk_test_... or pk_live_...)
  // Do NOT store Stripe secret keys here.
  static const String publishableKey = 'pk_test_51P0U4tE8qUMXaBnMrSWIhnH76X5DU5FMTEIc7QgnbW3z3RwuXfiITb9zCeD7SDVbNUmZKSWCt8bOF2NGV9Oob8HW00xBGU0oDg';

  // Your backend endpoint that creates PaymentIntents / ephemeral keys.
  // Implement a server endpoint that returns a JSON with at least { clientSecret }
  // Example: { "clientSecret": "pi_..._secret_..." }
  static const String serverBaseUrl = 'https://your-server.example.com';
}
