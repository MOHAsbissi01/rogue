# Financial input rules and assumptions

Owner: Both cofounders (assignment pending)  
Approval status: PROPOSAL - awaiting founder review  
Last reviewed: 2026-10-08

Initial baseline: all commercial inputs were UNKNOWN and no sample monetary values were included.
The 2026-10-08 manufacturing update adds a preliminary estimate and separately labeled illustrative scenarios.
No numeric scenario is actual or approved. Every illustrative row/report must be labeled
**SAMPLE DATA - NOT ROGUE ACTUALS** and kept separate from decisions based on real inputs.

## Input register requirements

For each amount record product/spec, quantity basis, currency (TND for local planning), tax basis, quote/source
code, observation date, validity and owner. Use blank numeric cells for missing inputs and a status explaining why.
Do not enter the word UNKNOWN in numeric cells; CSV status/notes carry the explanation. A true zero needs evidence.

## Scenario calculation guide

In price-scenarios: merchandise revenue = units_per_order x list_price_per_unit. Net sales adds delivery_charge_to_customer,
then subtracts discount_per_order, refund_revenue_allowance and tax_collected_excluded. Variable cost before acquisition
is the sum of landed_goods_cost, payment_fees, delivery_cost, pick_pack_cost, return_handling_allowance,
damage_allowance and other_variable_costs. Contribution before acquisition = net sales less that sum;
after acquisition = before acquisition less cac. Margin after = after / net sales x 100, if net sales > 0.
Break-even orders = ceiling(fixed_launch_costs / contribution_after_acquisition) only when contribution > 0.
Break-even units = orders x units_per_order, with the mix assumption stated. Maximum break-even CAC uses
the before-acquisition contribution for a new customer's first order; do not confuse all orders with new customers.

## Assumptions to resolve

Returns/refusals, payment fee basis, delivery subsidy, damages, taxes, units per order, supplier deposits,
settlement delay and customer acquisition cost require evidence. Clarify which expenses are fixed versus variable
and which are already included in quotes. Compare downside inputs before approving a commitment.
Next action: fill source-backed costs first and leave results unavailable until prerequisites are complete.

## Related files

[unit economics](unit-economics.md) | [price scenarios](price-scenarios.csv)

## Dated input register - 2026-10-08

| Input | Status | Source and limitation |
| --- | --- | --- |
| Supplier: Costas | FACT - founder supplied | Identity reported; no independent supplier verification |
| Manufacturing estimate: 20-25 TND/unit | PRELIMINARY - final quote UNKNOWN | Founder update; quantity, validity and tax basis not established |
| Cost coverage | UNKNOWN | Blank, graphics, embroidery, printing, packaging and transport not itemized |
| No minimum quantity; very small orders accepted | FACT about founder report | Not independently verified contract terms or a price guarantee |
| Landed product cost: 35 TND | SAMPLE DATA - NOT ROGUE ACTUALS | User-requested illustration; unrelated to a validated landed cost |
| Retail options: 59 / 69 / 79 / 89 TND | PROVISIONAL SAMPLE DATA - NOT APPROVED | Candidate illustrations, not actual selling prices |
| RG-H001 launch selection | UNKNOWN | Existing testing prototype may be replaced by another design |

Sample rows assume one unit per order solely to compare displayed prices and illustrative product cost. Tax,
discounts, delivery, fees, returns, damages and acquisition inputs remain blank, so net revenue, contribution,
margin, break-even and maximum CAC are deliberately unavailable. Do not aggregate SAMPLE rows with real records.
See [scenario explanation](illustrative-price-scenarios.md) and [quotation checklist](../10-OPERATIONS/supplier-quotation-checklist.md).
