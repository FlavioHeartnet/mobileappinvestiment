import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/src/models/simulation_result.dart';
import 'package:mobile/src/providers/input_params_notifier.dart';
import 'package:mobile/src/services/local_calculation_service.dart';

final simulationProvider = FutureProvider<SimulationResultModel>((ref) async {
  final params = ref.watch(inputParamsProvider);
  const service = LocalCalculationService();
  return service.calculate(params);
});
