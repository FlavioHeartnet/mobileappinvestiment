import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/src/providers/auth_notifier.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _submitEmail() async {
    final notifier = ref.read(authProvider.notifier);
    final email = _userController.text.trim();
    final pass = _passController.text;
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }
    final ok = await notifier.login(email, pass);
    if (ok && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/calculator', (route) => false);
    }
  }

  Future<void> _submitGoogle() async {
    final notifier = ref.read(authProvider.notifier);
    final ok = await notifier.signInWithGoogle();
    if (ok && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/calculator', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 6,
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Bem-vindo(a) de volta!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Faça login para continuar',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'seu@email.com',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passController,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: '••••••••',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submitEmail(),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text('Esqueceu a senha?', style: TextStyle(color: color)),
                          ),
                        ),
                        const SizedBox(height: 6),

                        if (state.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          FilledButton(
                            onPressed: _submitEmail,
                            style: FilledButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Entrar'),
                          ),

                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text('OU', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 12),
                        // Google button styled closer to official guidelines
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: state.isLoading ? null : _submitGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF3C4043), // Google neutral ink
                              side: const BorderSide(color: Color(0xFFDADCE0)), // Google gray border
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w600),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Google "G" mark at the left
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Image.network(
                                      'https://developers.google.com/identity/images/g-logo.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stack) => const Icon(
                                        Icons.g_mobiledata,
                                        size: 18,
                                        color: Color(0xFF4285F4),
                                      ),
                                    ),
                                  ),
                                ),
                                const Text('Entrar com o Google'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pushNamed('/signup'),
                            child: RichText(
                              text: TextSpan(
                                text: 'Não tem uma conta? ',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                children: [
                                  TextSpan(
                                    text: 'Criar Conta',
                                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        if (state.error != null) ...[
                          const SizedBox(height: 8),
                          Text(state.error!, style: TextStyle(color: theme.colorScheme.error)),
                        ],

                      ],
                    ),
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
