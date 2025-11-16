import 'package:flutter/material.dart';

/// Route shim that opens the plans as a modal action sheet (bottom sheet)
class SubscriptionPlanScreen extends StatefulWidget {
  const SubscriptionPlanScreen({super.key});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  @override
  void initState() {
    super.initState();
    // Open the sheet after the first frame so we have a valid context
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final selected = await showSubscriptionPlanSheet(context);
      if (!mounted) return;
      if (selected != null) {
        // Navigate to checkout with the chosen plan
        Navigator.of(context).pushNamed('/checkout', arguments: {'plan': selected});
      }
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Empty container; this route only exists to trigger the sheet
    return const SizedBox.shrink();
  }
}

Future<String?> showSubscriptionPlanSheet(BuildContext context) {
  final theme = Theme.of(context);
  final bgLight = const Color(0xFFF7F8F9);
  final bgDark = const Color(0xFF121212);
  final baseBg = theme.brightness == Brightness.dark ? bgDark : bgLight;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.6,
        maxChildSize: 0.96,
        expand: false,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: baseBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Grab handle + close
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 120),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).maybePop(),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Acesso completo para planejar sua aposentadoria',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.15,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: [
                            _AnnualPlanCard(),
                            const SizedBox(height: 12),
                            _MonthlyPlanCard(),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Benefícios da assinatura',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const _BenefitRow(icon: Icons.insights, text: 'Planejamento de aposentadoria ilimitado'),
                        _Separator(),
                        const _BenefitRow(icon: Icons.donut_small, text: 'Análise de todos os seus investimentos'),
                        _Separator(),
                        const _BenefitRow(icon: Icons.query_stats, text: 'Simulador de cenários futuros'),
                        _Separator(),
                        const _BenefitRow(icon: Icons.support_agent, text: 'Suporte prioritário'),
                        const SizedBox(height: 24),
                        Text(
                          'Cancele a qualquer momento. A cobrança será iniciada automaticamente após o período de teste de 14 dias, a menos que seja cancelada. Ao continuar, você concorda com nossos Termos de Serviço e Política de Privacidade.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _AnnualPlanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final primary = scheme.primary;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.20 : 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Anual', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Mais vantajoso',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF121212) : Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ 179,90',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text('/ano', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _onChoose(context, 'annual'),
              child: const Text('Escolher Plano Anual', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          const _CheckRow(text: 'equivalente a R\$ 14,99 por mês'),
          const _CheckRow(text: '14 dias grátis'),
        ],
      ),
    );
  }

  void _onChoose(BuildContext context, String plan) {
    // Close the bottom sheet returning the selected plan
    Navigator.of(context).pushNamed('/checkout', arguments: {'plan': plan});
  }
}

class _MonthlyPlanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF434957) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mensal', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ 19,90',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text('/mês', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
                foregroundColor: isDark ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _onChoose(context, 'monthly'),
              child: const Text('Escolher Plano Mensal', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          const _CheckRow(text: '14 dias grátis'),
        ],
      ),
    );
  }

  void _onChoose(BuildContext context, String plan) {
    // Close the bottom sheet returning the selected plan
    Navigator.of(context).pushNamed('/checkout', arguments: {'plan': plan});
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(color: Theme.of(context).dividerColor.withValues(alpha: 0.6), height: 1);
  }
}

class _CheckRow extends StatelessWidget {
  final String text;
  const _CheckRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
