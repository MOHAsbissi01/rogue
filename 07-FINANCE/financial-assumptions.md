# Financial input rules and assumptions

Owner: Both cofounders (assignment pending)  
Approval status: PROPOSAL - awaiting founder review  
Last reviewed: 2026-10-08

All commercial inputs are UNKNOWN. No numeric scenario is labeled actual or approved. No sample monetary
values are included. If illustrative scenarios are added later, prefix every relevant row and report with
**SAMPLE DATA - NOT ROGUE ACTUALS** and keep them separate from decisions based on real inputs.

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
