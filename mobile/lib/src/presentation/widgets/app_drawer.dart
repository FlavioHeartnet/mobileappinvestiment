import 'package:firebase_auth/firebase_auth.dart';
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
  final emailFromState = ref.watch(authProvider).userEmail;
  final user = FirebaseAuth.instance.currentUser;
  final dn = user?.displayName;
  final displayName = (dn != null && dn.trim().isNotEmpty) ? dn : 'Meu Perfil';
  final email = user?.email ?? emailFromState ?? 'usuario@exemplo.com';
  final photoUrl = user?.photoURL;
  final initials = () {
    String source = displayName.trim();
    if (source.isEmpty || source == 'Meu Perfil') {
      source = email.split('@').first;
    }
    final parts = source
        .split(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ0-9]+'))
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    final first = parts[0][0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }();

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
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                        ? NetworkImage(photoUrl)
                        : null,
                    child: (photoUrl == null || photoUrl.isEmpty)
                        ? Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          email,
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
            ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: const Text('Planos de Assinatura'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/plans');
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
