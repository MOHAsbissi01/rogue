# CSV editing and data conventions

Owner: Both cofounders (assignment pending)  
Approval status: PROPOSAL - awaiting founder review  
Last reviewed: 2026-10-08

## Common rules

Every CSV has one header row, comma delimiters, UTF-8 text and one record per documented grain. Quotes inside
quoted fields are doubled. IDs are text, dates use YYYY-MM-DD, and timestamps specify their timezone. Numeric
cells use a decimal point without thousands separators or currency symbols. Blank numeric cells mean UNKNOWN;
verified zero is entered as 0. TEMPLATE/PROPOSAL rows are not observations and must be excluded from real reports.

Preserve exact header names and order because scripts validate them. Open in Excel through text/CSV import,
keep IDs as text and export CSV UTF-8. Do not paste untrusted formula-leading text (=, +, -, @) into text fields
without treating it as literal text. Negative numeric adjustments are permitted where the field definition allows.
No formulas are embedded in CSV cells. Calculated output columns are manually entered/reviewed from documented
formulas; input edits do not automatically recalculate them. Record source and review date after recalculation.

## Record grains and field interpretation

| Register | One row represents | Key conventions |
| --- | --- | --- |
| Product catalog | An organizational product | SKU/variant/spec fields blank until confirmed; available stock requires count evidence |
| Campaign index | A campaign code | Name/status/owner are draft until approved; date blanks mean unscheduled |
| Content calendar | A deliverable or an unscheduled brief | Concept/stage/pillar and primary measure; asset_path is workspace-relative; URL only after actual publication |
| AI generation log | A real authorized generation, or labeled template | Tool/model/prompt/reference/output and cost/rights/fidelity evidence; never treat TEMPLATE as a job |
| Paid experiment log | One test protocol and outcome | Variant/control, window, loss ceiling and evidence before decision |
| Marketing ad allocation | Allocation against a central finance budget line | Does not create separate spending authority; reconcile commitments/actuals |
| Finance costing | Product/spec/quantity/source cost set | Per-saleable-unit TND costs and allocation basis; five components sum to landed cost |
| Finance scenarios | A hypothetical offer with complete inputs | Order-level values; formulas and missing-input guards in financial-assumptions |
| Finance ad budget | Campaign ceiling for a period | Proposed/approved/committed/actual distinguish intentions and payments |
| Launch budget | One scoped cost line | Distinguish fixed expense, inventory and cash reserve; avoid duplicate media costs |
| Cashflow | One nonoverlapping period | Opening + inflows - outflows = closing; headroom = closing - minimum reserve |
| Competitor matrix | Observed product/brand comparison at a date | Evidence URL, market, currency, listed claims and observed engagement context |
| Social metrics | Content/account observation window | Reach is unique within source scope; actions and follower snapshots differ |
| Ad metrics | Campaign/test/variant observation | Attribution and new-customer inputs required for CAC/ROAS |
| Sales metrics | Matching aggregate cohort and cutoff | No customer-level details; definitions and maturity required for ratios |
| Customer feedback | An anonymized feedback observation | No names, handles, contacts or order IDs; permission required for direct quotes |
| Inventory | Variant/location reconciliation at a count date | Physical minus reserved minus quarantine = available; prototype is not saleable stock |
| Asset register | Asset or safe external record | Owner, rights, backup evidence and Git status are separate facts; hashes are optional |

Text fields ending in `_reference` contain a safe source code or permitted path/URL, never secrets or private
document contents. Fields ending `_pct` store percentage points (for example a computed percentage, not a fraction);
no illustrative numeric values are seeded. Currency defaults to TND only where explicitly marked. Competitor prices
retain their actual observed currency. UNKNOWN numeric results stay blank with an explanatory status/limitations field.

## Related files

[financial assumptions](../07-FINANCE/financial-assumptions.md) | [kpi dictionary](../09-ANALYTICS/kpi-dictionary.md) | [csv schemas](../scripts/csv-schemas.json)
