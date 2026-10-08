# Production records and joins

Owner: Creative lead (cofounder assignment pending)  
Status: PROPOSAL - not approved; no production executed  
Last reviewed: 2026-10-08

## CSV conventions

UTF-8, comma separated, exact header order, ISO dates, decimal-point numbers and no currency symbols inside numeric
cells. Blank numbers mean UNKNOWN, not zero. TEMPLATE rows are examples of structure and never real events. All
computed outputs are manually calculated/reviewed using the written formulas; CSV does not auto-recalculate.

| Register | Grain / key | Source of truth and important fields |
| --- | --- | --- |
| production-index | One package / production_id | Product/campaign, objective, state, blocker, owner, local path and real approval evidence |
| deliverables | One destination-version record / deliverable_id + content_id when split | Brief, master/version/hash, state, approval, actual post and metric |
| production generation-log | One actual submitted attempt / attempt_id | Shot/revision, media type, model/settings/prompt/ref, job/output/outcome and individual reviews |
| prompt-experiments | One comparison protocol / experiment_id | One variable, actual attempt IDs, criteria, result and next decision |
| model-comparisons | One workflow/configuration comparison record / comparison_id | Capability source/date, reference/settings, actual results and limitations |
| higgsfield-credit-log | One provider ledger event / event_id | Attempt/job, plan/period, debit/refund/grant/expiry/adjustment and verified evidence |
| production-costs | One nonduplicated cost allocation / cost_id | Category, estimate/actual basis, original currency/FX, TND, expense/payment dates and budget approval |

Allowed production states: IDEA, BRIEFED, GENERATING, EDITING, REVIEW, APPROVED, PUBLISHED. Blockers are independent.
Attempt outcome suggestions: SUBMITTED, FAILED, CANCELLED, RETURNED, REJECTED, SELECTED. RETURNED is not approved;
SELECTED still needs complete-edit QA. Each attempt's credits fields are a reconciled view of linked credit ledger
events, never a second authoritative ledger. Costs are linked by cost reference and are not calculated from a fixed rate.

Use relative workspace paths and safe evidence codes, not credentials or identifying records. Product originals stay
in the product collection. One generation log per production owns attempt records; the old general log is preserved.
Content calendar IDs link the same production briefs without copying them. Analytics files remain authoritative for
real measured values; performance notes explain interpretation, windows and limitations.

## Related records

[production index](04-VIDEO-PRODUCTIONS/production-index.csv) | [deliverables](04-VIDEO-PRODUCTIONS/deliverables.csv) | [budget estimator](08-PRODUCTION-FINANCE/budget-estimator.md) | [csv guide](../../../00-HQ/csv-guide.md)
