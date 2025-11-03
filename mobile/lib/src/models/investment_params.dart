class InvestmentParamsModel {
  final double initialValue;
  final double monthlyInvestment;
  final double monthlyInterestPercent; // e.g., 1.0 means 1%
  final double annualInterestPercent; // e.g., 12.0 means 12%
  final int years;
  final double custodyTaxPercentAnnual; // e.g., 0.3 means 0.3%
  final bool applyComeCotas;

  const InvestmentParamsModel({
    required this.initialValue,
    required this.monthlyInvestment,
    required this.monthlyInterestPercent,
    required this.annualInterestPercent,
    required this.years,
    required this.custodyTaxPercentAnnual,
    required this.applyComeCotas,
  });

  InvestmentParamsModel copyWith({
    double? initialValue,
    double? monthlyInvestment,
    double? monthlyInterestPercent,
    double? annualInterestPercent,
    int? years,
    double? custodyTaxPercentAnnual,
    bool? applyComeCotas,
  }) {
    return InvestmentParamsModel(
      initialValue: initialValue ?? this.initialValue,
      monthlyInvestment: monthlyInvestment ?? this.monthlyInvestment,
      monthlyInterestPercent:
          monthlyInterestPercent ?? this.monthlyInterestPercent,
      annualInterestPercent: annualInterestPercent ?? this.annualInterestPercent,
      years: years ?? this.years,
      custodyTaxPercentAnnual:
          custodyTaxPercentAnnual ?? this.custodyTaxPercentAnnual,
      applyComeCotas: applyComeCotas ?? this.applyComeCotas,
    );
  }
}
