import 'package:mobile/src/models/monthly_breakdown_entry.dart';

class SimulationResultModel {
  final double finalAmount;
  final double totalPrincipal;
  final double totalInterest;
  final double totalTaxes;
  final double effectiveAliquotPercent; // e.g., 15.0 means 15%
  final List<MonthlyBreakdownEntry> monthly;

  const SimulationResultModel({
    required this.finalAmount,
    required this.totalPrincipal,
    required this.totalInterest,
    required this.totalTaxes,
    required this.effectiveAliquotPercent,
    required this.monthly,
  });
}
