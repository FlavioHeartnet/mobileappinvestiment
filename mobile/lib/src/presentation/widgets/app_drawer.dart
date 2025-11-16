import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/providers/auth_notifier.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(authProvider.notifier).logout();
      // Close the drawer first
      navigator.pop();
      // Navigate to login clearing the stack
      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Erro ao sair: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final email = ref.watch(authProvider).userEmail;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBvQ68ttm17aM9OVCIY58CkZm5fs6WLRmeAIqMYdHisddEf3E_RvKKuhiOzRb8xQwfFHF3nxiSvwWEpczy_jmbqM0-_fk6gQsPmkw4T8k0e2vNrE93c5aM10yZewXg9DANprmQxieC1VlEZVCVX7htk5E4z47Xg4Vcu439YTQl__EgxC1OpvtUitpB0gYxkkBYsRg-wcN9zfO3NjAp0pYnbnokEyBmDdUNGK0pkWZ2vfffK5_rlUQYVtdn_rQbswwUwLbf_wFttWfed',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Meu Perfil',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          email ?? 'usuario@exemplo.com',
                          style: const TextStyle(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: const Text('Calculadora de Aposentadoria'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/calculator');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () => _logout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
