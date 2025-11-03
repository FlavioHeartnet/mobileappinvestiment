# Data Model: Retirement Investment Projection

## Overview
The simulator runs entirely on-device, transforming a validated `InvestmentScenario` into a month-by-month ledger and aggregated `SimulationSummary`. Calculations follow Brazilian fixed-income rules, including optional come-cotas withholding and custody tax accrual.

## Entities

### InvestmentScenario
- **Fields**
  - `initialPrincipal` (decimal, currency): starting balance; min 0.
  - `monthlyContribution` (decimal, currency): contribution added at the start of each month; min 0.
  - `monthlyInterestRate` (decimal, pct as fraction): gross monthly rate entered as percentage/100; range 0–1.
  - `annualYield` (decimal, pct as fraction): expected annual effective rate; range 0–1.
  - `investmentYears` (integer): horizon in years; range 1–40.
  - `custodyTaxRate` (decimal, pct as fraction): annual custody rate; range 0–1.
  - `comeCotasEnabled` (bool): toggles semiannual withholding.
  - `acknowledgedYieldMismatch` (bool): user confirmation flag when annual/monthly rates diverge >0.1pp.
  - `validationErrors` (map<string, ValidationIssue>): per-field issues, empty when valid.
- **Relationships**
  - references `TaxSchedule` to compute tax liabilities.
  - produces a resolved `SimulationSummary` and a list of `MonthlyLedgerEntry` after calculation.
- **Validation Rules**
  - Monetary fields must be non-negative.
  - Rates must be between 0 and 1 (inclusive of 0, exclusive of 1 unless explicitly allowed by regulation guardrails).
  - Annual vs monthly yield delta >0.1 percentage points triggers `acknowledgedYieldMismatch == true` before simulation proceeds.
  - Duration must be integer years within [1, 40].
- **State Transitions**
  - `Draft` → `Validated` (all validation rules satisfied).
  - `Validated` → `AwaitingConfirmation` (yield mismatch detected).
  - `AwaitingConfirmation` → `Confirmed` (user acknowledges mismatch).
  - `Validated` or `Confirmed` → `Simulated` (ledger + summary generated).

### TaxSchedule
- **Fields**
  - `brackets` (ordered list<TaxBracket>): official Brazilian fixed-income IR schedules.
  - `comeCotasMonths` (set<int>): months-of-year (5, 11) when withholding applies.
  - `finalSettlementRate` (decimal): tax rate due at redemption after come-cotas.
  - `custodyTaxFrequency` (enum: monthly, annual): pro-rating approach, default monthly.
- **Relationships**
  - referenced by `InvestmentScenario` during simulation.
  - owns `TaxBracket` records.
- **Validation Rules**
  - Bracket ranges must be contiguous/non-overlapping and cover the full investment horizon.
  - `comeCotasMonths` only allowed when `comeCotasEnabled` is true.
  - Custody tax frequency determines when debits are recorded in ledger.
- **State Transitions**
  - `Configured` (defaults loaded) → `Adjusted` (if user overrides rates for scenario tests).

### TaxBracket
- **Fields**
  - `maxHoldingDays` (int): upper bound day count for bracket eligibility.
  - `rate` (decimal): tax rate applied within bracket.
- **Relationships**
  - parent: `TaxSchedule`.
- **Validation Rules**
  - `maxHoldingDays` must increase with each bracket.
  - `rate` must be within official bracket percentages (22.5%, 20%, 17.5%, 15%).

### MonthlyLedgerEntry
- **Fields**
  - `monthIndex` (int): 1-based sequence index.
  - `startingBalance` (decimal).
  - `contribution` (decimal).
  - `interestAccrued` (decimal) — computed using `startingBalance + contribution`.
  - `custodyTaxDebited` (decimal).
  - `incomeTaxWithheld` (decimal).
  - `endingBalance` (decimal).
  - `cumulativeContribution` (decimal).
  - `cumulativeInterest` (decimal).
- **Relationships**
  - belongs to exactly one `InvestmentScenario`.
  - aggregated into `SimulationSummary`.
- **Validation Rules**
  - Ending balance = starting + contribution + interest - taxes (rounded to two decimals).
  - Accumulated totals must match running sums of prior entries.
  - Come-cotas withholding occurs only when `monthIndex` corresponds to May or November and holding period exceeds threshold.

### SimulationSummary
- **Fields**
  - `totalContributions` (decimal).
  - `totalInterest` (decimal).
  - `totalCustodyTax` (decimal).
  - `totalIncomeTax` (decimal).
  - `grossFinalBalance` (decimal).
  - `netAfterTaxes` (decimal).
  - `effectiveAliquot` (decimal).
  - `projectionHorizonMonths` (int).
- **Relationships**
  - references source `InvestmentScenario`.
  - aggregates data from `MonthlyLedgerEntry`.
- **Validation Rules**
  - `grossFinalBalance` = `totalContributions` + `totalInterest`.
  - `netAfterTaxes` = `grossFinalBalance` - (`totalCustodyTax` + `totalIncomeTax`).
  - `effectiveAliquot` = `totalIncomeTax` / max(`totalInterest`, 0.01) (guard division by zero).

### ValidationIssue
- **Fields**
  - `field` (string).
  - `code` (enum: required, range_error, format_error, regulatory_limit).
  - `message` (string).
- **Relationships**
  - owned by `InvestmentScenario.validationErrors`.
- **Purpose**
  - surfaces inline feedback and blocks simulation until resolved.

## Derived Calculations
- Custody tax proration: `monthlyCustodyRate = (1 + custodyTaxRate)^(1/12) - 1` for monthly debits; annual debit recorded in final month when `custodyTaxFrequency == annual`.
- Income tax bracket selection: map elapsed days since initial investment to bracket thresholds and apply come-cotas prepayments.
- Yield reconciliation: compute implied annual rate from `monthlyInterestRate` as `(1 + monthlyInterestRate)^{12} - 1` and compare to `annualYield`.
