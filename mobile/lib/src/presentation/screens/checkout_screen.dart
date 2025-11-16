import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/src/config/stripe_config.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'credit-card';
  bool _loading = false;
  String _cardBrand = 'unknown';
  String _selectedPlan = 'monthly';

  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(() {
      final formatted = _formatCardNumber(_cardNumberController.text);
      final digits = formatted.replaceAll(RegExp(r'[^0-9]'), '');
      final detected = _detectCardBrand(digits);
      if (detected != _cardBrand) {
        setState(() => _cardBrand = detected);
      }
      if (formatted != _cardNumberController.text) {
        _cardNumberController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length.clamp(0, formatted.length)),
        );
      }
    });
    _expiryController.addListener(() {
      final formatted = _formatExpiry(_expiryController.text);
      if (formatted != _expiryController.text) {
        _expiryController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length.clamp(0, formatted.length)),
        );
      }
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgLight = const Color(0xFFF7F8F9);
    final bgDark = const Color(0xFF121212);
    final bg = isDark ? bgDark : bgLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
  backgroundColor: bg,
  foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Finalize sua Assinatura', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text('Seu Pedido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Plan selector
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPlan = 'monthly'),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _selectedPlan == 'monthly' ? theme.colorScheme.primary : (isDark ? const Color(0xFF000000).withValues(alpha: 0.04) : const Color(0xFF000000).withValues(alpha: 0.02)),
                          ),
                          alignment: Alignment.center,
                          child: Text('Mensal • R\$ 19,90', style: TextStyle(color: _selectedPlan == 'monthly' ? Colors.black : theme.textTheme.bodyMedium?.color)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPlan = 'annual'),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _selectedPlan == 'annual' ? theme.colorScheme.primary : (isDark ? const Color(0xFF000000).withValues(alpha: 0.04) : const Color(0xFF000000).withValues(alpha: 0.02)),
                          ),
                          alignment: Alignment.center,
                          child: Text('Anual • R\$ 179,90', style: TextStyle(color: _selectedPlan == 'annual' ? Colors.black : theme.textTheme.bodyMedium?.color)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF000000).withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(_selectedPlan == 'annual' ? 'Plano Anual Pro' : 'Plano Mensal Pro', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                          Text(_selectedPlan == 'annual' ? 'R\$ 179,90' : 'R\$ 19,90', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Text('Total a pagar', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
                          Text(_selectedPlan == 'annual' ? 'R\$ 179,90' : 'R\$ 19,90', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                const Text('Escolha como pagar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _paymentMethod = 'credit-card'),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _paymentMethod == 'credit-card' ? theme.colorScheme.primary : (isDark ? const Color(0xFF000000).withValues(alpha: 0.06) : const Color(0xFF000000).withValues(alpha: 0.03)),
                          ),
                          alignment: Alignment.center,
                          child: Text('Cartão Crédito/Débito', style: TextStyle(color: _paymentMethod == 'credit-card' ? Colors.black : theme.textTheme.bodyMedium?.color)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _paymentMethod = 'wallet-pay'),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: _paymentMethod == 'wallet-pay' ? theme.colorScheme.primary : (isDark ? const Color(0xFF000000).withValues(alpha: 0.06) : const Color(0xFF000000).withValues(alpha: 0.03)),
                          ),
                          alignment: Alignment.center,
                          child: Text('Google/Apple Pay', style: TextStyle(color: _paymentMethod == 'wallet-pay' ? Colors.black : theme.textTheme.bodyMedium?.color)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const Text('Número do Cartão', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0000 0000 0000 0000',
                    prefixIcon: const Icon(Icons.credit_card),
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _cardBrandWidget(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Nome do Titular', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: _cardHolderController,
                  decoration: const InputDecoration(hintText: 'Nome como no cartão'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Validade', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _expiryController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: 'MM/AA'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CVV', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                            TextField(
                              controller: _cvvController,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: InputDecoration(hintText: _cardBrand == 'amex' ? '1234' : '123'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212).withValues(alpha: 0.8) : const Color(0xFFF7F8F9).withValues(alpha: 0.95),
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : () => _startPayment(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Finalizar Pagamento', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Ambiente 100% seguro. Seus dados estão protegidos.', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startPayment() async {
    setState(() => _loading = true);
    try {
      // Validate inputs before attempting payment
      final validation = _validateForm();
      final ok = validation['ok'] == true;
      if (!ok) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validation['message'] as String)));
        return;
      }
      final uri = Uri.parse('${StripeConfig.serverBaseUrl}/create-payment-intent');
      final userEmail = FirebaseAuth.instance.currentUser?.email;
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'plan': _selectedPlan, 'email': userEmail}),
      );
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Server error: ${resp.statusCode}');
      }
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final clientSecret = body['clientSecret'] ?? body['client_secret'] ?? body['paymentIntentClientSecret'];
      if (clientSecret == null) throw Exception('Missing client secret from server');

      // Initialize and present the Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'SimuladorInvestimento',
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'BR',
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'BR',
            testEnv: true,
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      if (!mounted) return;
      Navigator.of(context).pushNamed('/payment-confirmation');
    } on StripeException catch (e) {
      final msg = e.error.localizedMessage ?? e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro no pagamento: $msg')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: ${e.toString()}')));
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Map<String, Object> _validateForm() {
    final rawNumber = _cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawNumber.length < 13) return {'ok': false, 'message': 'Número do cartão inválido'};
    if (!_luhnCheck(rawNumber)) return {'ok': false, 'message': 'Número do cartão inválido (checagem Luhn falhou)'};

    final expiry = _expiryController.text.replaceAll(RegExp(r'[^0-9/]'), '');
    final parts = expiry.split('/');
    if (parts.length != 2) return {'ok': false, 'message': 'Validade inválida'};
    final mm = int.tryParse(parts[0]);
    final yy = int.tryParse(parts[1]);
    if (mm == null || yy == null) return {'ok': false, 'message': 'Validade inválida'};
    if (mm < 1 || mm > 12) return {'ok': false, 'message': 'Mês de validade inválido'};
    final now = DateTime.now();
    final fourDigitYear = yy < 100 ? (2000 + yy) : yy;
    final lastDay = DateTime(fourDigitYear, mm + 1, 0);
    if (lastDay.isBefore(now)) return {'ok': false, 'message': 'Cartão expirado'};

    final cvv = _cvvController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cvv.length < 3 || cvv.length > 4) return {'ok': false, 'message': 'CVV inválido'};

    final holder = _cardHolderController.text.trim();
    if (holder.isEmpty) return {'ok': false, 'message': 'Nome do titular é obrigatório'};

    return {'ok': true, 'message': 'ok'};
  }

  bool _luhnCheck(String digits) {
    final nums = digits.split('').reversed.map(int.parse).toList();
    var sum = 0;
    for (var i = 0; i < nums.length; i++) {
      var val = nums[i];
      if (i % 2 == 1) {
        val *= 2;
        if (val > 9) val -= 9;
      }
      sum += val;
    }
    return sum % 10 == 0;
  }

  String _formatCardNumber(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    final groups = <String>[];
    for (var i = 0; i < digits.length; i += 4) {
      groups.add(digits.substring(i, (i + 4).clamp(0, digits.length)));
    }
    return groups.join(' ');
  }

  String _formatExpiry(String input) {
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length <= 2) return digits;
    return '${digits.substring(0,2)}/${digits.substring(2, digits.length.clamp(2,4))}';
  }

  String _detectCardBrand(String digits) {
    if (digits.isEmpty) return 'unknown';
    if (RegExp(r'^4').hasMatch(digits)) return 'visa';
    if (RegExp(r'^(5[1-5])').hasMatch(digits) || RegExp(r'^2').hasMatch(digits)) return 'mastercard';
    if (RegExp(r'^(34|37)').hasMatch(digits)) return 'amex';
    if (RegExp(r'^(6)').hasMatch(digits)) return 'discover';
    return 'unknown';
  }

  Widget _cardBrandWidget() {
    final b = _cardBrand;
    switch (b) {
      case 'visa':
        return const Text('VISA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600));
      case 'mastercard':
        return const Text('MC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600));
      case 'amex':
        return const Text('AMEX', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600));
      case 'discover':
        return const Text('DISC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600));
      default:
        return const SizedBox.shrink();
    }
  }
}
