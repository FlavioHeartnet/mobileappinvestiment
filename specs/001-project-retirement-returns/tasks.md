## Flutter Investment Simulator Backlog

### Epic: 1. Project Scaffolding & Core Architecture

- [x] Set up strict linting (analysis_options.yaml) to enforce clean code.

- [x] Define project folder structure: lib/src with subfolders for models, repositories, services, presentation (screens/widgets), providers.

- [x] Configure flutter_riverpod by adding ProviderScope to the main.dart root.

- [x] Create a main CupertinoApp scaffold with a CupertinoTabScaffold to manage navigation (e.g., "Simulator" and "Results" tabs).

- [x] (Glassmorphism) Design a reusable GlassNavigationBar widget. This widget must wrap CupertinoNavigationBar and use BackdropFilter to create the blurred, translucent "frosted glass" effect.

- [x] (Glassmorphism) Implement the custom GlassNavigationBar as the app's main app bar.

- [x] (Glassmorphism) Design a reusable GlassCard widget. This will be a Container with ClipRRect, a semi-transparent CupertinoDynamicColor, and an ImageFiltered or BackdropFilter child for a consistent frosted glass look on all cards.

- [x] Ensure all UI layouts respect SafeArea to avoid the Dynamic Island and bottom navigation gestures on modern iPhones.

## Epic: 2. Investment Input Form

- [x] Create InvestmentInputScreen.dart using a CupertinoPageScaffold.

- [x] Build the input form using a CupertinoFormSection to group related fields.

- [x] Implement CupertinoTextField inputs for:

    Initial Value (R$)

    Monthly Investment (R$)

    Monthly Interest (%)

    Annual Interest (%)

    Annual Custody Tax (%)

- [x] Add a CupertinoSlider for "Years Investing" (e.g., 1-40 years) for fluid input.

- [x] Add a CupertinoSwitch labeled "Apply 'Come Cotas' Tax" to toggle the Brazil-specific tax logic.

- [x] Use the intl package to ensure all currency and percentage fields use correct Brazilian formatting (BRL, pt_BR).

- [x] Implement a main call-to-action button using CupertinoButton.filled labeled "Simular".

- [x] Create the Riverpod provider (StateNotifierProvider) to manage the state of the input form data.

Epic: 3. Core Calculation Engine (Brazil-Specific)

- [x] Define the data model InvestmentParamsModel (initialValue, monthlyInvestment, interestRates, years, custodyTax, applyComeCotas).

- [x] Define the output data models:

    MonthlyBreakdownEntry (month, interestEarned, govTaxPaid, custodyTaxPaid, cumulativeTotal)

    SimulationResultModel (finalAmount, totalPrincipal, totalInterest, totalTaxes, effectiveAliquot, List<MonthlyBreakdownEntry>)

- [x] Create an abstract class ICalculationRepository defining a Future<SimulationResultModel> calculate(InvestmentParamsModel params) method.

- [x] Implement LocalCalculationService that implements ICalculationRepository.

- [x] (Core Logic) Inside LocalCalculationService, build the month-by-month simulation loop (from 1 to years * 12).

- [x] (Core Logic) Inside the loop, correctly apply compound interest (monthly and annual).

- [x] (Core Logic - Come Cotas) Implement the "come cotas" logic. If applyComeCotas is true, on the last business day of May and November (i.e., months 5 and 11), calculate the profit since the last tax event and apply the correct tax (15% or 20%) on those gains, deducting it from the principal.

- [x] (Core Logic) Implement logic for annual custody tax.

- [x] (Core Logic) Implement final Income Tax (aliquot) calculation at the end of the simulation, accounting for any "come cotas" already paid.

- [x] Create a Riverpod FutureProvider that calls the LocalCalculationService and provides the SimulationResultModel to the UI.

## Epic: 4. Simulation Results Display

- [x] Create ResultsScreen.dart using CupertinoPageScaffold with a CupertinoSliverNavigationBar for a large-title effect.

- [x] (Glassmorphism) At the top of the screen, display a "hero" GlassCard (from Epic 1) showing the primary result: "Final Amount".

- [x] Create a summary section (e.g., CupertinoListSection) to display key metrics from SimulationResultModel:

Total Amount Invested (w/o interest)

Total Interest Earned

Total Gov. Taxes Paid

Final Effective Aliquot (%)

- [x] Implement a ListView.builder to display the detailed List<MonthlyBreakdownEntry>. This is critical for performance ("fluidity") on long simulations.

- [x] Design a custom MonthlyBreakdownListTile to clearly show Month #, Interest, Tax Paid, and Total for each entry.

- [x] Implement a "pull to refresh" or a "Recalculate" button on the CupertinoNavigationBar to re-run the simulation if inputs change.

- [x] Implement a CupertinoActivityIndicator (loading spinner) that displays while the FutureProvider from Epic 3 is in its loading state.