import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/input_params_notifier.dart';
import '../widgets/glass_navigation_bar.dart';
import '../../utils/formatters.dart';
import '../../providers/tab_controller.dart';

class InvestmentInputScreen extends ConsumerWidget {
  const InvestmentInputScreen({super.key});

  void _goToResults(BuildContext context) {
    tabController.index = 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = ref.watch(inputParamsProvider);
    final notifier = ref.read(inputParamsProvider.notifier);

    return CupertinoPageScaffold(
      navigationBar: const GlassNavigationBar(title: 'Simulador'),
      child: SafeArea(
        bottom: true,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('Valores iniciais'),
              children: [
                _MoneyField(
                  label: 'Valor Inicial (R\$)',
                  value: params.initialValue,
                  onChanged: notifier.setInitialValue,
                ),
                _MoneyField(
                  label: 'Aporte Mensal (R\$)',
                  value: params.monthlyInvestment,
                  onChanged: notifier.setMonthlyInvestment,
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('Taxas'),
              children: [
                _PercentField(
                  label: 'Juros Mensal (%)',
                  value: params.monthlyInterestPercent,
                  onChanged: notifier.setMonthlyInterest,
                ),
                _PercentField(
                  label: 'Juros Anual (%)',
                  value: params.annualInterestPercent,
                  onChanged: notifier.setAnnualInterest,
                ),
                _PercentField(
                  label: 'Taxa de Custódia Anual (%)',
                  value: params.custodyTaxPercentAnnual,
                  onChanged: notifier.setCustodyTax,
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(
              header: const Text('Período'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Anos investindo: ${params.years}')
                    ],
                  ),
                ),
                CupertinoSlider(
                  value: params.years.toDouble(),
                  min: 1,
                  max: 40,
                  divisions: 39,
                  onChanged: (v) => notifier.setYears(v.round()),
                ),
              ],
            ),
            CupertinoFormSection.insetGrouped(children: [
              CupertinoFormRow(
                prefix: const Text("Aplicar 'Come Cotas'"),
                child: CupertinoSwitch(
                  value: params.applyComeCotas,
                  onChanged: notifier.setApplyComeCotas,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CupertinoButton.filled(
                onPressed: () => _goToResults(context),
                child: const Text('Simular'),
              ),
            ),
            const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _MoneyField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      prefix: Text(label),
      placeholder: Formatters.money(value),
      textAlign: TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
      onChanged: (s) {
        // Simple, forgiving parsing: allow comma or dot as decimal separator
        final normalized = s.replaceAll(',', '.');
        final v = double.tryParse(normalized) ?? value;
        onChanged(v);
      },
    );
  }
}

class _PercentField extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _PercentField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      prefix: Text(label),
      placeholder: '${value.toStringAsFixed(2)} %',
      textAlign: TextAlign.end,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
      onChanged: (s) {
        final normalized = s.replaceAll(',', '.');
        final v = double.tryParse(normalized) ?? value;
        onChanged(v);
      },
    );
  }
}
