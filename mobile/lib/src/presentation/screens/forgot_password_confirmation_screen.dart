import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/providers/auth_notifier.dart';

class ForgotPasswordConfirmationScreen extends ConsumerWidget {
  const ForgotPasswordConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final notifier = ref.read(authProvider.notifier);
    final state = ref.watch(authProvider);
    final email = notifier.lastRequestedEmail;

    String maskedEmail(String? e) {
      if (e == null || e.isEmpty) return 'seu e-mail';
      final parts = e.split('@');
      if (parts.first.length <= 2) return '***@${parts.last}';
      final local = parts.first;
      final visible = '${local.substring(0, 1)}*****${local.substring(local.length - 1)}';
      return '$visible@${parts.last}';
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.mark_email_read, size: 44, color: color),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Verifique seu e-mail',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enviamos um link para redefinir sua senha para ${maskedEmail(email)}. Pode levar alguns minutos para chegar. Não se esqueça de verificar sua caixa de spam.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75)),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                          style: FilledButton.styleFrom(
                            backgroundColor: color,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Voltar para o Login', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  final ok = await notifier.resendPasswordResetEmail();
                                  if (ok && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('E-mail reenviado.')));
                                  } else if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error ?? 'Falha ao reenviar')));
                                  }
                                },
                          child: state.isLoading
                              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Não recebeu? Reenviar e-mail'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
