import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/src/providers/auth_notifier.dart';
import 'package:mobile/src/providers/input_params_notifier.dart';
// results are shown on a separate screen; no direct import here

class RetirementCalculatorScreen extends ConsumerStatefulWidget {
  const RetirementCalculatorScreen({super.key});

  @override
  ConsumerState<RetirementCalculatorScreen> createState() => _RetirementCalculatorScreenState();
}

class _RetirementCalculatorScreenState extends ConsumerState<RetirementCalculatorScreen> {
  final _initialController = TextEditingController(text: '10000');
  final _monthlyController = TextEditingController(text: '500');
  final _annualRateController = TextEditingController(text: '8');
  final _brokerageController = TextEditingController(text: '0.2');

  double _years = 25;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _initialController.dispose();
    _monthlyController.dispose();
    _annualRateController.dispose();
    _brokerageController.dispose();
    super.dispose();
  }

  void _clear() {
    setState(() {
      _initialController.text = '';
      _monthlyController.text = '';
      _annualRateController.text = '';
      _brokerageController.text = '';
      _years = 25;
    });
  }

  void _calculate() {
    double parseNum(String s) => double.tryParse(s.replaceAll('.', '').replaceAll(',', '.')) ?? 0.0;
    final initial = parseNum(_initialController.text);
    final monthly = parseNum(_monthlyController.text);
    final annual = parseNum(_annualRateController.text);
    final custody = parseNum(_brokerageController.text);

    final notifier = ref.read(inputParamsProvider.notifier);
    notifier.setInitialValue(initial);
    notifier.setMonthlyInvestment(monthly);
    notifier.setAnnualInterest(annual);
    notifier.setYears(_years.round());
    notifier.setCustodyTax(custody);

    // Navigate to dedicated results screen
    Navigator.of(context).pushNamed('/results');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgLight = const Color(0xFFF7F8F9);
    final bgDark = const Color(0xFF212121);
    final params = ref.watch(inputParamsProvider);

  return Scaffold(
      backgroundColor: isDark ? bgDark : bgLight,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
  backgroundColor: (isDark ? bgDark : bgLight).withValues(alpha: 0.8),
        title: const Text(
          'Calculadora de Aposentadoria',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              final auth = ref.read(authProvider.notifier);
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await auth.logout();
                if (!mounted) return;
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(SnackBar(content: Text('Erro ao sair: $e')));
              }
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 640;
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Inputs section
                    _Section(
                      child: Column(
                        children: [
                          _ResponsiveRow(
                            isWide: isWide,
                            children: [
                              _LabeledField(
                                label: 'Investimento Inicial',
                                hintText: 'R\$ 0,00',
                                controller: _initialController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              _LabeledField(
                                label: 'Aporte Mensal',
                                hintText: 'R\$ 0,00',
                                controller: _monthlyController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Years slider
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Por quanto tempo',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                '${_years.round()} anos',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _years,
                            min: 1,
                            max: 50,
                            divisions: 49,
                            onChanged: (v) => setState(() => _years = v),
                          ),
                          const SizedBox(height: 8),
                          _ResponsiveRow(
                            isWide: isWide,
                            children: [
                              _LabeledField(
                                label: 'Juros Anual',
                                hintText: '0% ',
                                suffixText: '%',
                                controller: _annualRateController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                              _LabeledField(
                                label: 'Taxa de Corretagem (%)',
                                hintText: '0% ',
                                suffixText: '%',
                                controller: _brokerageController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Come-cotas controls: enable switch + threshold slider
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                value: params.applyComeCotas,
                                onChanged: (v) => ref.read(inputParamsProvider.notifier).setApplyComeCotas(v),
                                title: const Text('Aplicar Come-cotas'),
                                subtitle: const Text('Aplica a cobrança semestral (maio/novembro)'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12, right: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Limite para aliquota reduzida: ${params.comeCotasThresholdMonths} meses', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Slider(
                                      value: params.comeCotasThresholdMonths.toDouble(),
                                      min: 6,
                                      max: 24,
                                      divisions: 18,
                                      label: '${params.comeCotasThresholdMonths}m',
                                      onChanged: params.applyComeCotas
                                          ? (v) => ref.read(inputParamsProvider.notifier).setComeCotasThreshold(v.round())
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Action buttons
                    _ResponsiveRow(
                      isWide: isWide,
                      children: [
                        SizedBox(
                          height: 56,
                          child: FilledButton(
                            onPressed: _calculate,
                            child: const Text('Calcular', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        SizedBox(
                          height: 56,
                          child: OutlinedButton(
                            onPressed: _clear,
                            child: const Text('Limpar Campos', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final Widget child;
  const _Section({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF2A2C34) : Colors.white,
      elevation: isDark ? 0 : 0.5,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

// Results widgets were moved to `ResultsDetailsScreen`.

class _ResponsiveRow extends StatelessWidget {
  final bool isWide;
  final List<Widget> children;
  const _ResponsiveRow({required this.isWide, required this.children});

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 12),
          ]
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i != children.length - 1) const SizedBox(width: 16),
        ]
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? suffixText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hintText,
    this.suffixText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            suffixText: suffixText,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2C34)
                : Colors.white,
          ),
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
