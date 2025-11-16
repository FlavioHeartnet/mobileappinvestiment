import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/src/providers/simulation_provider.dart';
import 'package:mobile/src/utils/formatters.dart';

class ResultsDetailsScreen extends ConsumerWidget {
  const ResultsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(simulationProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text('Calculadora de Aposentadoria'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: asyncResult.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erro: $e'),
                ),
                data: (data) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top result cards (primary-tinted + white)
                      LayoutBuilder(builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;

                        // Card 1 (passive income)
                        final card1 = Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Renda Passiva Mensal',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Formatters.money(data.monthly.isNotEmpty ? data.monthly.last.interestEarned : 0),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        );

                        // Card 2 (total)
                        final card2 = Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Total (Após o Imposto)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.85),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Formatters.money(data.finalAmount),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        );

                        if (isWide) {
                          // Don't stretch children vertically here — the surrounding
                          // Column/Sliver layout can provide unbounded height on large
                          // viewports. Use start so children size to their intrinsic
                          // height and Expanded only affects horizontal sizing.
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Container(margin: const EdgeInsets.only(right: 12), child: card1)),
                              Expanded(child: Container(margin: const EdgeInsets.only(left: 12), child: card2)),
                            ],
                          );
                        }

                        // Vertical (narrow): stack cards full-width with spacing
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(margin: const EdgeInsets.only(bottom: 12), child: card1),
                            Container(margin: const EdgeInsets.only(bottom: 12), child: card2),
                          ],
                        );
                      }),

                      const SizedBox(height: 12),

                      // Details card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detalhes da Projeção',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(builder: (context, c) {
                              final twoCols = c.maxWidth > 500;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _detailTile('Valor Total Investido', Formatters.money(data.totalPrincipal), valueColor: const Color.fromRGBO(93, 135, 255, 1)),
                                  _detailTile('Total (Antes do Imposto)', Formatters.money(data.totalPrincipal + data.totalInterest), valueColor: const Color.fromRGBO(93, 135, 255, 1)),
                                  _detailTile('Juros', '+ ${Formatters.money(data.totalInterest)}', valueColor: Colors.green[600]),
                                  _detailTile('Imposto de Renda', '- ${Formatters.money(data.totalTaxes)}', valueColor: Colors.red[600]),
                                ].map((w) {
                                  return SizedBox(width: twoCols ? (c.maxWidth - 12) / 2 : c.maxWidth, child: w);
                                }).toList(),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
            asyncResult.maybeWhen(
              data: (data) => SliverList.builder(
                itemCount: data.monthly.length,
                itemBuilder: (context, i) {
                  final m = data.monthly[i];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 1))],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text('Mês ${m.month}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Juros: ${Formatters.money(m.interestEarned)}  •  Imposto: ${Formatters.money(m.govTaxPaid)}  •  Custódia: ${Formatters.money(m.custodyTaxPaid)}',
                            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.75)),
                          ),
                        ),
                        Expanded(flex: 4, child: Text(Formatters.money(m.cumulativeTotal), textAlign: TextAlign.end)),
                      ],
                    ),
                  );
                },
              ),
              orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: valueColor ?? Colors.black)),
        ],
      ),
    );
  }
}
