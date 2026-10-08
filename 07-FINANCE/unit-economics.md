# Unit and order economics

Owner: Both cofounders; finance responsibility unassigned  
Approval status: PROPOSAL - awaiting founder review  
Last reviewed: 2026-10-08

## Purpose and evidence status

Use this model to understand a proposed offer before approving price, production or acquisition spend.
Currency: TND. FACT: no cost, retail price or margin is confirmed. All numeric inputs remain blank (UNKNOWN).
No illustrative money figures or profitability claims are seeded. CSVs are editable records, not live formula engines.

## Landed unit cost

**landed unit cost = production + decoration + packaging + inbound freight + allocated production overhead**

Use costs per saleable unit on a consistent tax basis. Allocate inbound freight and production overhead across
the realistic saleable quantity, not a fictitious order size. Record the allocation base and source. Do not count
an overhead expense again in fixed launch costs if it is already recovered in unit cost. Separate sampling and
one-time creative costs where they are genuinely fixed launch expenses. Supplier-confidential originals stay outside Git.

## Net sales and variable costs

Define `net sales revenue = merchandise revenue before discounts + customer delivery charges - discounts
- refunds/returns revenue allowance - taxes collected on behalf of authorities`, on a consistent basis.
Do not subtract tax again if source revenue is already tax-exclusive. Tax rates/treatment are UNKNOWN and require
local professional verification. Customer delivery charges are included here so the full courier cost appears below.

Variable order costs include landed goods consumed, payment/COD/collection fees where actually applicable,
outbound delivery, pick/pack, expected return handling, damage/unsaleable allowance and acquisition cost when
included in the selected view. Verify actual payment options and fee bases; no provider capability is assumed.
Delivery subsidy = full delivery cost minus customer delivery charge. In this convention it is already captured
through revenue and cost; do not subtract that subsidy a second time.

For returns, record refunded revenue separately from return handling and goods loss. A resalable returned item
can restore inventory value under the chosen accounting basis; a damaged item cannot. Do not subtract the same
refund or lost garment through both an allowance and an actual return entry for the same period/order cohort.
Expected allowances and realized results must be clearly separated and later reconciled.

## Contribution and acquisition

**contribution per order = net sales revenue - all variable order costs**

Show two labeled views: contribution **before acquisition** excludes acquisition cost; contribution **after
acquisition** includes it. Never compare CAC to the after-acquisition figure as if it were a pre-acquisition ceiling.

**contribution margin percentage = contribution / net sales revenue**, multiplied by 100 for a percentage display.
Use the same before/after acquisition basis in numerator and label. If revenue is zero or inputs are missing,
the rate is unavailable. A negative contribution is a real loss signal, not a formatting error.

**maximum break-even CAC = contribution per new customer before acquisition costs**.
For the first-order planning view use first-order contribution per acquired customer, with returns/delivery included.
Do not assume repeat purchases or lifetime value. A future repeat-purchase model needs actual cohort evidence.
Break-even CAC leaves no room for fixed costs or profit, so founders must choose a lower affordable ceiling if needed.

## Break-even and cash

**break-even units = fixed launch costs / contribution per order when contribution is positive**.
This formula yields units only under the explicit **one unit per order** assumption. Otherwise it yields
break-even orders; multiply by evidence-based units per order for units, or use a consistent unit contribution.
Round required orders/units upward. If contribution is zero/negative, there is no finite break-even at that offer.

Contribution is not net profit or cash. Include fixed costs, taxes as applicable, settlement delays, supplier
deposits, delivery settlement timing and reserves in the separate cashflow review.

## Working method

1. Fill dated inputs in costing-template, with source and validity; mark real zeros explicitly.
2. Fill each price scenario with complete order assumptions and manually calculate its output columns.
3. Have the second founder independently review inputs, arithmetic, allocation and return treatment.
4. Reconcile planned ad spend, fixed launch budget and cash timing; record approval or missing evidence.
5. Revisit after actual orders and matured returns. No price becomes approved because a formula is positive.

## Related files

[costing template](costing-template.csv) | [price scenarios](price-scenarios.csv) | [break even model](break-even-model.md) | [financial assumptions](financial-assumptions.md)
