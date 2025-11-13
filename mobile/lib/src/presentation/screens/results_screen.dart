import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/src/providers/simulation_provider.dart';
import 'package:mobile/src/utils/formatters.dart';
import 'package:mobile/src/presentation/widgets/glass_card.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncResult = ref.watch(simulationProvider);

    return CupertinoPageScaffold(
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('Resultados'),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => ref.invalidate(simulationProvider),
                child: const Text('Recalcular'),
              ),
            ),
            SliverToBoxAdapter(
              child: asyncResult.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CupertinoActivityIndicator()),
                ),
                error: (e, st) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Erro: $e'),
                ),
                data: (data) => Column(
                  children: [
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Montante final',
                              style: TextStyle(fontSize: 14, color: CupertinoColors.inactiveGray)),
                          const SizedBox(height: 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Formatters.money(data.finalAmount),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _SummaryList(
                      invested: data.totalPrincipal,
                      interest: data.totalInterest,
                      taxes: data.totalTaxes,
                      effectiveAliquotPercent: data.effectiveAliquotPercent,
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            asyncResult.maybeWhen(
              data: (data) => SliverList.builder(
                itemCount: data.monthly.length,
                itemBuilder: (context, i) {
                  final m = data.monthly[i];
                  return _MonthlyTile(
                    month: m.month,
                    interest: m.interestEarned,
                    tax: m.govTaxPaid,
                    custody: m.custodyTaxPaid,
                    total: m.cumulativeTotal,
                  );
                },
              ),
              orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            )
          ],
        ),
      ),
    );
  }
}

class _SummaryList extends StatelessWidget {
  final double invested;
  final double interest;
  final double taxes;
  final double effectiveAliquotPercent;
  const _SummaryList({
    required this.invested,
    required this.interest,
    required this.taxes,
    required this.effectiveAliquotPercent,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(header: const Text('Resumo'), children: [
      CupertinoFormRow(
        prefix: const Text('Total Investido (sem juros)'),
        helper: Align(
          alignment: Alignment.centerRight,
          child: _ResponsiveValueText(Formatters.money(invested)),
        ),
        child: const SizedBox(width: 0),
      ),
      CupertinoFormRow(
        prefix: const Text('Total de Juros'),
        helper: Align(
          alignment: Alignment.centerRight,
          child: _ResponsiveValueText(Formatters.money(interest)),
        ),
        child: const SizedBox(width: 0),
      ),
      CupertinoFormRow(
        prefix: const Text('Impostos Governamentais'),
        helper: Align(
          alignment: Alignment.centerRight,
          child: _ResponsiveValueText(Formatters.money(taxes)),
        ),
        child: const SizedBox(width: 0),
      ),
      CupertinoFormRow(
        prefix: const Text('Alíquota Efetiva'),
        helper: Align(
          alignment: Alignment.centerRight,
          child: _ResponsiveValueText('${effectiveAliquotPercent.toStringAsFixed(2)}%'),
        ),
        child: const SizedBox(width: 0),
      ),
    ]);
  }
}

class _MonthlyTile extends StatelessWidget {
  final int month;
  final double interest;
  final double tax;
  final double custody;
  final double total;
  const _MonthlyTile({
    required this.month,
    required this.interest,
    required this.tax,
    required this.custody,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mês $month', style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  'Juros: ${Formatters.money(interest)}  •  Imposto: ${Formatters.money(tax)}  •  Custódia: ${Formatters.money(custody)}',
                  style: const TextStyle(fontSize: 12, color: CupertinoColors.inactiveGray),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 140,
            child: Align(
              alignment: Alignment.centerRight,
              child: _ResponsiveValueText(Formatters.money(total)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveValueText extends StatelessWidget {
  final String text;
  const _ResponsiveValueText(this.text);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerRight,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
      ),
    );
  }
}

