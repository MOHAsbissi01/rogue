# KPI dictionary

Owner: Both cofounders (assignment pending)  
Approval status: PROPOSAL - awaiting founder review  
Last reviewed: 2026-10-08

No real KPI data is supplied. All metrics begin UNAVAILABLE. Proposed owners below require assignment.
Choose a reporting timezone explicitly; the initial workspace uses Africa/Lagos for schedules. Store export
timezones must be recorded and aligned before comparison. ISO dates and TND apply to relevant fields.

| Metric | Exact working definition | Source | Time period | Proposed owner | Limitations | Required inputs |
| --- | --- | --- | --- | --- | --- | --- |
| Reach | Unique accounts reached as defined by the source platform; never sum content reach as unique campaign reach | Platform insights if accessible | Weekly and per-content fixed window | Brand/Growth | Platform deduplication and reporting availability; channels cannot be deduplicated by addition | source-reported unique reach, content ID, window |
| Saves | Source-reported save actions; optional save rate = saves / reach x 100 | Platform insights | Same content window as reach | Brand/Growth | Actions may not be unique people; zero/missing reach makes rate unavailable | saves, matched reach, content ID |
| Shares | Source-reported share actions; optional share rate = shares / reach x 100 | Platform insights | Same content window as reach | Brand/Growth | Private shares may have limited visibility; cross-platform definitions differ | shares, matched reach |
| Engaged views | Views meeting an explicitly named duration/engagement threshold supported by the platform | Platform video insights | Per creative, fixed observation window | Brand/Growth | No universal cross-platform definition; unavailable if threshold data absent | engaged views, threshold seconds/definition, eligible views |
| Follower growth | Ending followers minus starting followers; growth % = difference / starting x 100 | Account insights | Weekly snapshots at matching boundaries | Brand/Growth | Organic/paid attribution may be unavailable; starting zero makes % unavailable | start count, end count, dates |
| Product-page visits | Measured sessions visiting a product page under a documented session rule | Store analytics if supported | Weekly with timezone and exclusions | Product/Ops | May be unavailable; clicks are not a substitute; consent/device effects | eligible sessions, page ID, source, session definition |
| Add-to-cart / order intent | Distinct measured sessions triggering the named event; report message intent separately | Store event source or anonymized manual intent tally | Weekly, same eligible population | Product/Ops | Platform may not expose cart events; messages do not equal orders; deduplicate | event definition, distinct session count or separate intent count |
| Completed orders | Unique actual orders meeting the approved completion criterion; proposed delivered and paid, excluding cancelled/test orders | Authorized order/fulfillment aggregate | Order cohort with maturity cutoff | Product/Ops | Placed/accepted/paid are distinct statuses; late completion changes cohort counts | deduplicated aggregate, status mapping, cohort dates |
| AOV | Net sales revenue / completed orders for the matching cohort, TND per order | Reconciled order and finance aggregates | Weekly mature cohort or explicit provisional view | Finance owner | Refund lag; revenue/order populations must match; zero orders unavailable | net sales per finance definition, completed orders |
| CVR | Completed orders attributable to eligible store sessions / eligible store sessions x 100 | Store/order sources with valid join or attribution | Matched visit cohort with completion cutoff | Analytics owner | If session-to-order attribution is absent report unavailable; never divide unrelated weekly totals | eligible sessions, attributable completed orders, attribution window |
| CAC | Acquisition costs in stated scope / new customers acquired in the matching attributed cohort | Paid platforms plus reconciled new-customer aggregate | Test/cohort window plus conversion lag | Finance owner | Media-only CAC and fully loaded CAC must be labeled; deduplication may be limited | acquisition costs, new customer count, attribution method |
| Contribution | Net sales less all variable order costs; label before or after acquisition; margin = contribution / net sales x 100 | Finance cost and sales records | Matching order cohort and return cutoff | Finance owner | Missing costs invalidate result; not net profit; allowances vs actual returns must reconcile | net sales, goods, fees, delivery, handling, returns, damages, acquisition scope |
| ROAS | Attributed net sales revenue / advertising spend in the declared attribution window | Ad source reconciled to sales where possible | Per test/campaign with attribution window | Brand/Growth and Finance | Platform-reported revenue may be gross; label separate platform ROAS; not profitability | attributed net revenue, spend, attribution window/source |
| Return rate | Returned units / delivered units for the same delivery cohort x 100 | Fulfillment/returns aggregate | Cohort with stated observation cutoff | Product/Ops | Maturity lag; distinguish exchanges, refusals and cancellations; zero delivered unavailable | delivered units, returned units, cutoff, return classification |
| Customer feedback | Counts by defined theme plus anonymized qualitative evidence; report number of submissions/participants | Support/interview/consented feedback | Weekly or research round | Support owner | Self-selection, duplicates and small samples; quotes need permission | theme coding, anonymous IDs, date, denominator, quote consent |

## Reporting discipline

Preserve numerator, denominator, scope and observation window. Blank means unknown; verified zero is numeric zero.
Record source extraction date separately from event period. Do not sum ratios or unique audiences across periods.
Use matching aggregate sums to recompute ratios, retain cohort maturity and mark provisional results clearly.
No synthetic test event belongs in actual business results. Keep customer-level identifiers outside Git.
Next action: audit what each source can measure, approve definitions and assign a reporting owner before launch.

## Related files

[unit economics](../07-FINANCE/unit-economics.md) | [weekly report template](weekly-report-template.md)
