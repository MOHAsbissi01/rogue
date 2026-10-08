# Provisional retail price illustrations

Owner: Both cofounders; financial reviewer unassigned  
Approval status: SAMPLE DATA - NOT ROGUE ACTUALS - NOT APPROVED SELLING PRICES  
Last reviewed: 2026-10-08

## Purpose and limits

Compare the four retail options requested by the founders before obtaining complete commercial inputs.
**All figures below are illustrative. The 35 TND landed product cost is a hypothetical planning input, not an
actual RG-H001 cost, a Costas quotation or a verified sum of manufacturing and other charges.** RG-H001 is the
planning reference only; it is a testing prototype and may not become the final launch product.

FACT about founder report: Costas' manufacturing estimate is preliminarily 20-25 TND/unit. Whether that includes
blank garment, graphics, embroidery, printing, packaging or transport is UNKNOWN. Do not derive the 35 TND
illustration from that range or assume the difference covers missing charges. Final tax treatment is UNKNOWN.

## SAMPLE DATA - NOT ROGUE ACTUALS

One unit per illustrative order. Listed price is a provisional display-price option, not established net revenue.

| Scenario | Provisional retail option (TND) | Illustrative landed product cost (TND) | Price less product cost only (TND) |
| --- | ---: | ---: | ---: |
| SAMPLE-RETAIL-59 | 59 | 35 | 24 |
| SAMPLE-RETAIL-69 | 69 | 35 | 34 |
| SAMPLE-RETAIL-79 | 79 | 35 | 44 |
| SAMPLE-RETAIL-89 | 89 | 35 | 54 |

The last column is only subtraction: listed price minus hypothetical landed product cost. It is **not profit,
contribution, margin, affordable CAC or cash available to spend**. It omits discounts, refund/revenue allowances,
taxes where applicable, payment fees, customer delivery charges, delivery cost/subsidy, pick/pack, returns handling,
damage allowances, other variable costs and customer acquisition. Fixed launch costs also remain unknown.

## Editing the CSV safely

The four SAMPLE rows are appended in [price-scenarios.csv](price-scenarios.csv); the three earlier blank-input
scenarios are preserved. CSV column order and schema are unchanged. The only numeric sample inputs populated are
units_per_order = 1, list_price_per_unit = 59/69/79/89, and landed_goods_cost = 35. All missing inputs and all
net-revenue/contribution/margin/break-even/CAC outputs remain blank, never implicit zero.

Filter out IDs beginning SAMPLE- and statuses marked SAMPLE DATA from actual reporting. Do not replace a sample
label with ACTUAL merely because an output is positive. Build a separately identified sourced scenario once each
input has evidence, quantity/spec basis, date, validity and tax treatment. CSVs do not calculate automatically.

## Founder decision questions

What is the fully itemized cost for the selected design and sizes? Which delivery charges does the customer pay?
What fees and return/refusal allowances apply? What does customer evidence say about each proposed offer?
What downside and cash requirement are acceptable? Only then review a selling price and acquisition ceiling.

Next action: obtain the [Costas quotation details](../10-OPERATIONS/supplier-quotation-checklist.md), complete
[financial assumptions](financial-assumptions.md), and use the [unit economics formulas](unit-economics.md).
No selling price, production quantity or advertising spend is approved by these illustrations.
