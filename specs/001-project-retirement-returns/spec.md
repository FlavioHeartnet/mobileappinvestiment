# Feature Specification: Retirement Investment Projection

**Feature Branch**: `001-project-retirement-returns`  
**Created**: 2025-11-03  
**Status**: Draft  
**Input**: User description: "This is an app that simulates how much money Ill have invested every month after a given period of time. The goal is to determine how much Id have for retirement. The earnings from his investment, I will provide the initial value, monthly interest, and the annual interest income, years investing, annual custody tax, if this has come cotas, this is based on the Brazilian market and its monetary laws, the out put will be the final amount(interest + sum of the month sports), interest incomes, amount without interests, interests, gov taxs, amount after taxs, and aliquots, the app should be fluid and intuitive and fit the newstet I phones"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Retirement Balance Simulation (Priority: P1)

As a saver planning retirement, I enter my initial capital, monthly contributions, expected returns, investment horizon, and taxes to immediately see monthly growth and the final balance for my goal.

**Why this priority**: This journey delivers the core promise of the app—showing whether the user is on track for retirement—so it must work end-to-end before any enhancements.

**Independent Test**: Provide a known example with spreadsheet-calculated results, run the simulation, and confirm the summary outputs match the reference within the defined tolerance.

**Acceptance Scenarios**:

1. **Given** a user enters valid initial amount, monthly contribution, monthly interest rate, annualized yield, years investing, custody tax, and disables come-cotas, **When** they tap calculate, **Then** the app displays final amount, total contributions, total interest, gross tax amount, net after taxes, and the effective aliquot on the results screen.
2. **Given** a user provides valid data for more than one year, **When** they open the monthly breakdown, **Then** each month lists starting balance, contribution, interest earned, cumulative totals, and remaining horizon consistent with the summary totals.

---

### User Story 2 - Compare Come-Cotas Impact (Priority: P2)

As an investor evaluating funds subject to come-cotas, I toggle the come-cotas option to understand how semiannual tax withholding affects my retirement total.

**Why this priority**: Brazilian investors often hold funds with and without come-cotas; contrasting the impact is a high-value decision aid once the base simulator exists.

**Independent Test**: Run the same scenario twice (come-cotas on/off) and verify the tax collections and final balance shift according to the Brazilian withholding rules.

**Acceptance Scenarios**:

1. **Given** a user has entered valid investment parameters and enabled come-cotas, **When** they calculate the projection, **Then** the results show semiannual tax debits in May and November, a reduced final balance compared to the no come-cotas scenario, and an explanatory note that come-cotas was applied.

---

### User Story 3 - Review Tax Breakdown on Mobile (Priority: P3)

As a mobile user double-checking my tax exposure, I view the summary on a modern iPhone without horizontal scrolling and can clearly read the amounts and aliquots.

**Why this priority**: The product must stay usable on the newest iPhones to build trust and reduce churn, even if layout polish follows the core calculations.

**Independent Test**: Open the results screen on an iPhone 15-or-equivalent viewport, verify all tax components fit within the view, and confirm tap targets meet accessibility guidelines.

**Acceptance Scenarios**:

1. **Given** the simulator has produced results, **When** the user opens the summary on a 6.1" iPhone viewport, **Then** the amounts and labels display without horizontal scroll, tap targets are at least 44px high, and key tax numbers remain legible.

---

### Edge Cases

- Zero monthly contribution or zero initial capital should still calculate, showing growth (or lack thereof) from the remaining inputs.
- Interest rates at or below 0% must trigger guidance that returns will not grow the balance and produce accurate (possibly declining) projections.
- Custody tax or income tax rates entered above regulatory limits must be rejected with a helpful message.
- Durations longer than 40 years or non-integer years should prompt the user to adjust to a supported range before calculating.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to enter initial investment, recurring monthly contribution, monthly interest rate, equivalent annual yield, investment duration in years, annual custody tax rate, and whether the asset is subject to come-cotas.
- **FR-002**: System MUST validate that monetary values are non-negative, that rates fall between 0% and 100%, and that duration is within 1–40 years, providing inline errors when entries fall outside the supported range.
- **FR-003**: System MUST reconcile the provided monthly and annual yields, alerting the user when the implied annual rate differs by more than 0.1 percentage points from the entered annual value and allowing them to proceed only after confirming or correcting the inputs.
- **FR-004**: System MUST generate a month-by-month projection using the validated monthly rate, adding contributions first, applying returns, and rounding monetary outputs to two decimal places at each step.
- **FR-005**: System MUST calculate total contributions, gross interest earned, accumulated custody tax, income tax debits, final gross balance, and net balance after taxes for the entire investment horizon.
- **FR-006**: System MUST apply Brazilian income tax brackets for fixed-income funds (22.5%, 20%, 17.5%, 15% based on holding period) and, when come-cotas is enabled, deduct the appropriate withholding in May and November while reconciling any remaining tax at redemption.
- **FR-007**: System MUST deduct the annual custody tax by pro-rating it across the year (monthly or annual debit) before calculating net results, and clearly show the total custody cost in the summary.
- **FR-008**: System MUST display the outputs requested by the user—final amount (contributions plus interest), total contributions without interest, total interest, government taxes paid, amount after taxes, and effective aliquots—in a layout optimized for current iPhone screen sizes.
- **FR-009**: System MUST provide a collapsible breakdown that lets users switch between summary totals and detailed monthly tables without recalculating the scenario.

### Key Entities *(include if feature involves data)*

- **Investment Scenario**: Captures user-provided parameters (initial balance, monthly contribution, interest assumptions, duration, custody tax, come-cotas flag) and the validation state for each field.
- **Tax Schedule**: Encapsulates Brazilian income tax brackets and come-cotas withholding events used to compute periodic tax debits relative to the investment horizon.
- **Simulation Summary**: Stores calculated totals (contributions, interest, custody tax, income tax, net balance, effective aliquot) and references the month-by-month ledger used for drill-down.

## Assumptions

- Users contribute the same amount every month; the system treats missed or variable contributions as outside the feature scope.
- Monthly interest rate represents expected gross performance before taxes, and the annual yield supplied by the user is intended as the effective annual rate for cross-checking purposes.
- Income tax calculations follow the standard Brazilian long-term fund brackets (22.5% up to 6 months, 20% up to 12 months, 17.5% up to 24 months, 15% beyond 24 months), with come-cotas withholding occurring in May and November.
- Custody tax is charged once per year at the entered rate and is applied proportionally across months for simulation accuracy.
- The interface targets current iPhone models (e.g., iPhone 14–16 family) with support for both light and dark modes; tablets and desktop layouts are handled separately.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: For scenarios up to 40 years with monthly contributions and standard tax rates, the full calculation and summary display within 2 seconds on a modern iPhone.
- **SC-002**: When compared to a verified spreadsheet model, the final balance and total tax values differ by no more than 0.5%.
- **SC-003**: In moderated usability tests, at least 80% of participants can correctly identify the net amount after taxes and the effective aliquot without facilitator assistance.
- **SC-004**: On a 6.1" iPhone reference device, all monetary values and labels remain legible (minimum 14pt equivalent) and no horizontal scrolling is required in portrait orientation.
