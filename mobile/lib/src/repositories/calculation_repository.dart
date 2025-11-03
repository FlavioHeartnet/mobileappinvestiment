import '../models/investment_params.dart';
import '../models/simulation_result.dart';

abstract class ICalculationRepository {
  Future<SimulationResultModel> calculate(InvestmentParamsModel params);
}
