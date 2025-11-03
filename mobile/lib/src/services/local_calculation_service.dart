import 'dart:math' as math;

import '../models/investment_params.dart';
import '../models/monthly_breakdown_entry.dart';
import '../models/simulation_result.dart';
import '../repositories/calculation_repository.dart';

class LocalCalculationService implements ICalculationRepository {
  const LocalCalculationService();

  @override
  Future<SimulationResultModel> calculate(InvestmentParamsModel params) async {
    final int totalMonths = params.years * 12;
    double total = params.initialValue;
    double totalPrincipal = params.initialValue;
    double totalInterest = 0.0;
    double totalTaxes = 0.0;
    double comeCotasPaid = 0.0;
    double profitSinceLastTax = 0.0;
    int monthsSinceLastTax = 0;

    final double monthlyRate = params.monthlyInterestPercent / 100.0;
    final double annualRate = params.annualInterestPercent / 100.0;
    final double monthlyCustodyRate = (params.custodyTaxPercentAnnual / 100.0) / 12.0;

    final List<MonthlyBreakdownEntry> entries = <MonthlyBreakdownEntry>[];

    for (int m = 1; m <= totalMonths; m++) {
      // Monthly contribution at start of month
      total += params.monthlyInvestment;
      totalPrincipal += params.monthlyInvestment;

      // Apply monthly interest
      final double interestMonthly = total * monthlyRate;
      total += interestMonthly;
      totalInterest += interestMonthly;
      profitSinceLastTax += interestMonthly;

      // Apply annual interest at end of each 12th month (if provided)
      if (annualRate > 0 && m % 12 == 0) {
        final double interestAnnual = total * annualRate;
        total += interestAnnual;
        totalInterest += interestAnnual;
        profitSinceLastTax += interestAnnual;
      }

      // Annual custody tax (deduct as percentage of total) at month 12 of each year
      double custodyTaxPaid = 0.0;
      if (params.custodyTaxPercentAnnual > 0 && m % 12 == 0) {
        final double custodyAnnual = total * (params.custodyTaxPercentAnnual / 100.0);
        total -= custodyAnnual;
        totalTaxes += custodyAnnual;
        custodyTaxPaid = custodyAnnual;
      } else if (monthlyCustodyRate > 0) {
        // If the user provided annual custody tax, we also consider distributing monthly for smoother curve
        final double custodyMonthly = total * monthlyCustodyRate;
        total -= custodyMonthly;
        totalTaxes += custodyMonthly;
        custodyTaxPaid = custodyMonthly;
      }

      // Come-cotas: May (5) and November (11) of each year
      double govTaxPaid = 0.0;
      monthsSinceLastTax++;
      if (params.applyComeCotas) {
        final int mm = ((m - 1) % 12) + 1; // 1..12
        final bool isComeCotasMonth = (mm == 5 || mm == 11);
        if (isComeCotasMonth && profitSinceLastTax > 0) {
          final double aliquot = _comeCotasAliquot(monthsSinceLastTax);
          final double tax = profitSinceLastTax * aliquot;
          total -= tax;
          totalTaxes += tax;
          govTaxPaid = tax;
          comeCotasPaid += tax;
          profitSinceLastTax = 0.0;
          monthsSinceLastTax = 0;
        }
      }

      entries.add(MonthlyBreakdownEntry(
        month: m,
        interestEarned: interestMonthly,
        govTaxPaid: govTaxPaid,
        custodyTaxPaid: custodyTaxPaid,
        cumulativeTotal: total,
      ));
    }

    // Final tax settlement: apply fixed-income table based on total holding period
    final double grossProfit = (total - totalPrincipal).clamp(0.0, double.infinity);
    final double finalAliquot = _finalAliquotForMonths(totalMonths);
    final double taxDue = math.max(0.0, (grossProfit * finalAliquot) - comeCotasPaid);
    if (taxDue > 0) {
      total -= taxDue;
      totalTaxes += taxDue;
    }

    final double effectiveAliquotPercent = grossProfit > 0 ? (totalTaxes / grossProfit) * 100.0 : 0.0;

    return SimulationResultModel(
      finalAmount: total,
      totalPrincipal: totalPrincipal,
      totalInterest: totalInterest,
      totalTaxes: totalTaxes,
      effectiveAliquotPercent: effectiveAliquotPercent,
      monthly: entries,
    );
  }

  // Come-cotas aliquot: if gains retained >= 12 months treat as long-term 15%, otherwise 20%
  double _comeCotasAliquot(int monthsSinceLastTax) {
    return monthsSinceLastTax >= 12 ? 0.15 : 0.20;
  }

  // Brazilian fixed-income final income tax table
  // <= 6 months: 22.5%
  // > 6 and <= 12: 20%
  // > 12 and <= 24: 17.5%
  // > 24: 15%
  double _finalAliquotForMonths(int totalMonths) {
    if (totalMonths <= 6) return 0.225;
    if (totalMonths <= 12) return 0.20;
    if (totalMonths <= 24) return 0.175;
    return 0.15;
  }
}
