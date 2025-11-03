import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/simulation_result.dart';
import '../providers/input_params_notifier.dart';
import '../services/local_calculation_service.dart';

final simulationProvider = FutureProvider<SimulationResultModel>((ref) async {
  final params = ref.watch(inputParamsProvider);
  const service = LocalCalculationService();
  return service.calculate(params);
});
