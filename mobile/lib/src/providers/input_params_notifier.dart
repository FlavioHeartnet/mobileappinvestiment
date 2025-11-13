import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:state_notifier/state_notifier.dart';

import '../models/investment_params.dart';

class InputParamsNotifier extends StateNotifier<InvestmentParamsModel> {
    InputParamsNotifier()
            : super(const InvestmentParamsModel(
                    initialValue: 1000.0,
                    monthlyInvestment: 500.0,
                    monthlyInterestPercent: 0.8,
                    annualInterestPercent: 0.0,
                    years: 10,
                    custodyTaxPercentAnnual: 0.3,
                    applyComeCotas: false,
                    comeCotasThresholdMonths: 12,
                ));

  void setInitialValue(double v) => state = state.copyWith(initialValue: v);
  void setMonthlyInvestment(double v) =>
      state = state.copyWith(monthlyInvestment: v);
  void setMonthlyInterest(double v) =>
            state = state.copyWith(
                monthlyInterestPercent: v,
                annualInterestPercent: _annualFromMonthly(v),
            );
  void setAnnualInterest(double v) =>
            state = state.copyWith(
                annualInterestPercent: v,
                monthlyInterestPercent: _monthlyFromAnnual(v),
            );
  void setYears(int v) => state = state.copyWith(years: v);
  void setCustodyTax(double v) =>
      state = state.copyWith(custodyTaxPercentAnnual: v);
  void setApplyComeCotas(bool v) =>
      state = state.copyWith(applyComeCotas: v);
  void setComeCotasThreshold(int v) =>
      state = state.copyWith(comeCotasThresholdMonths: v);
}

final inputParamsProvider =
    StateNotifierProvider<InputParamsNotifier, InvestmentParamsModel>(
  (ref) => InputParamsNotifier(),
);

double _monthlyFromAnnual(double annualPercent) {
    // Convert annual effective rate to monthly effective rate
    final a = annualPercent / 100.0;
    final m = math.pow(1 + a, 1 / 12) - 1;
    return (m * 100.0).toDouble();
}

double _annualFromMonthly(double monthlyPercent) {
    final m = monthlyPercent / 100.0;
    final a = math.pow(1 + m, 12) - 1;
    return (a * 100.0).toDouble();
}
