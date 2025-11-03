class MonthlyBreakdownEntry {
  final int month;
  final double interestEarned;
  final double govTaxPaid;
  final double custodyTaxPaid;
  final double cumulativeTotal;

  const MonthlyBreakdownEntry({
    required this.month,
    required this.interestEarned,
    required this.govTaxPaid,
    required this.custodyTaxPaid,
    required this.cumulativeTotal,
  });
}
