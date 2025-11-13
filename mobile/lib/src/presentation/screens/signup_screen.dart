import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/src/providers/auth_notifier.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passController.text;
    final confirmPass = _confirmPassController.text;

    // Validation
    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos')),
      );
      return;
    }

    if (pass != confirmPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As senhas não conferem')),
      );
      return;
    }

    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A senha deve ter no mínimo 6 caracteres')),
      );
      return;
    }

    final notifier = ref.read(authProvider.notifier);
    final ok = await notifier.signup(name, email, pass);
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
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    final state = ref.watch(authProvider);

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
                          'Crie sua Conta',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comece a planejar seu futuro hoje mesmo.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Nome completo
                        Text('Nome Completo', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          enabled: !state.isLoading,
                          decoration: InputDecoration(
                            hintText: 'Digite seu nome completo',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        // Email
                        Text('E-mail', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          enabled: !state.isLoading,
                          decoration: InputDecoration(
                            hintText: 'seuemail@exemplo.com',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        // Senha
                        Text('Senha', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passController,
                          enabled: !state.isLoading,
                          decoration: InputDecoration(
                            hintText: 'Crie uma senha',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                              icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                          obscureText: !_showPassword,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),

                        // Confirmar Senha
                        Text('Confirmar Senha', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmPassController,
                          enabled: !state.isLoading,
                          decoration: InputDecoration(
                            hintText: 'Confirme sua senha',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                              icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                            ),
                          ),
                          obscureText: !_showConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                        ),

                        const SizedBox(height: 20),
                        // Cadastrar button
                        if (state.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          FilledButton(
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Cadastrar', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),

                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text('ou', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 12),
                        // Google button per official guidelines
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: state.isLoading ? null : _submitGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF3C4043),
                              side: const BorderSide(color: Color(0xFFDADCE0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w600),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
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
                                const Text('Entrar com Google'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        // Terms and existing account
                        Text(
                          'Ao se cadastrar, você concorda com nossos Termos e Condições.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                            child: RichText(
                              text: TextSpan(
                                text: 'Já tem uma conta? ',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                children: [
                                  TextSpan(
                                    text: 'Entre aqui',
                                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
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
