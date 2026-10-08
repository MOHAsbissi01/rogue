# Manual storefront audit checklist

Owner: Product/Ops cofounder (assignment pending)  
Approval status: PROPOSAL - awaiting founder review  
Last reviewed: 2026-10-08

FACT: https://rogue-tn.converty.shop/ is the user-supplied shop URL. Functionality and quality are UNVERIFIED.
No live test, purchase or account change was performed. Every row starts NOT TESTED.

Record test date, tester, browser/device, viewport, page URL, steps, expected behavior, actual result,
severity, redacted screenshot and retest evidence. Never store admin sessions or customer data in Git.

| Area | Manual check | Expected evidence | Initial status |
| --- | --- | --- | --- |
| Mobile landing | Open on an actual phone and a narrow desktop view | Content readable, main action clear, no obstructing overlay | NOT TESTED |
| Product images | Inspect front/back/detail/fit, zoom and color consistency | Actual garment, useful crop and readable artwork | NOT TESTED |
| Price | Compare visible price, variant and any discount | Same approved TND offer across journey | NOT TESTED |
| Size guide | Open from product view; compare units/landmarks | Approved measured chart, no invented fit claims | NOT TESTED |
| Shipping | Find service area, cost and timing before commitment | Matches verified provider terms | NOT TESTED |
| Payment | Review displayed methods, fees and instructions | Only actually available methods are promised | NOT TESTED |
| Cart / order intent | Where supported, choose valid/invalid variants and quantities | Correct totals and clear errors; no unavailable stock promise | NOT TESTED |
| Checkout | Inspect required fields, consent, totals and validation | Clear terms and privacy; stop before placing a live order | NOT TESTED |
| Notifications | Plan a separately authorized controlled test | Actual expected confirmation and fulfillment notifications | NOT TESTED |
| Returns | Locate policy and support route | Clear reviewed terms before ordering | NOT TESTED |
| Accessibility | Keyboard, focus, text contrast and image descriptions | Key flow understandable and operable | NOT TESTED |
| Measurement | Compare authorized test events with source logs | Events defined and deduplicated; no assumed integration | NOT TESTED |

A controlled real order needs explicit authorization and a plan for payment, fulfillment and data handling.
Never simulate completion or report pass without observing it. Critical price/checkout/stock failures block
traffic spend. Next action: assign tester and complete safe read-only checks first when live inspection is authorized.

## Related files

[README](README.md) | [brand facts](../00-HQ/brand-facts.md)
