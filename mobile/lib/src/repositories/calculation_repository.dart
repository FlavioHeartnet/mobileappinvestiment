import 'package:mobile/src/models/investment_params.dart';
import 'package:mobile/src/models/simulation_result.dart';

abstract class ICalculationRepository {
  Future<SimulationResultModel> calculate(InvestmentParamsModel params);
}
