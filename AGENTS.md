# Working in the ROGUE headquarters

Read [START-HERE](START-HERE.md), [brand facts](00-HQ/brand-facts.md),
[dashboard](00-HQ/dashboard.md), and the current [decision log](00-HQ/decisions/decision-log.md) first.

## Evidence and authority

- Distinguish FACT / PROPOSAL / UNKNOWN explicitly. Preserve NEEDS VALIDATION flags.
- User-confirmed aspirations are facts about intentions, not verified product claims.
- Never invent market research, supplier commitments, customer validation, specifications,
  founder names, approval decisions, stock, financial inputs or real-world KPI results.
- Proposed owners are roles awaiting assignment. Two cofounders exist; names and division of work are unknown.
- Write clear professional English for nontechnical cofounders. Future campaign copy may use
  French or Tunisian Arabic after a fluent reviewer approves meaning and tone.
- Record evidence URLs and ISO observation dates for real research. Work offline when possible.

## Change discipline

- Before a significant change, state the impacted files or directories. Inspect existing content first.
- Never delete, overwrite, rename or relocate existing user assets without explicit approval.
  Never overwrite original images or videos. Create versioned derivatives.
- Preserve Git history. Do not create a remote or run git push without explicit authorization.
- When a product is created, use the onboarding script and update the product catalog,
  collection README and relevant product indexes. Organizational IDs are not commercial names.
- When a campaign is added, update the campaign index, campaigns README and content calendar.
- Keep decision records append-only. A proposal becomes approved only with actual founder evidence.
- After changes, summarize created/modified paths and report only checks actually executed.
- Run scripts against a disposable copy when testing mutations. Do not use real customer records in tests.

## External actions and confidentiality

- Never publish, deploy, spend money, buy domains or modify live storefronts without explicit user authorization.
- Never send messages, activate advertising, connect accounts or perform purchases as part of a document audit.
- Never put tokens, passwords, admin sessions, phone numbers, physical addresses, identifying invoices,
  supplier-confidential files, model identity documents or signed agreements in Git.
- Private GitHub and OneDrive synchronization are not substitutes for secure access management or media backups.
- Keep sensitive records in approved restricted storage. Ignored folders here are organizational aids, not secure vaults.
- Do not copy another brand's artwork into reusable assets. AI garment imagery must pass real-prototype fidelity review.

## Validation

Run `powershell -NoProfile -File .\scripts\audit-workspace.ps1` after structural edits.
Preserve CSV headers; blank numeric inputs mean unknown, not zero. Review links and indexes.
Read [script usage](scripts/README.md) before extending automation and update the manifest/schema when
intentionally adding an essential template. Do not silently weaken checks to make them pass.


## Higgsfield production system

Read the [Higgsfield handbook](04-CREATIVE-STUDIO/ai-creation/higgsfield/HIGGSFIELD-HANDBOOK.md), production index
and relevant product references before production work. Higgsfield is ROGUE's core AI creative production tool
by explicit user direction. The goal is complete, coherent, publication-ready work with a documented story and
marketing objective, not disconnected clips.

- Product fidelity is mandatory: exact approved SKU/variant, canonical front/back/details/fit photographs and spec.
  Never intentionally redesign or hallucinate the garment. RG-H001 alone is an organizational ID, not a final variant.
- Never overwrite real product originals. Prefer links to canonical product files over duplicate copies.
- No generation succeeds solely because a tool returns media. Review story, subject movement, camera, continuity,
  garment accuracy, music/sound presence, rights, mobile readability, CTA and full exported playback.
- Plan and assign assembly/sound/finishing before generating. Use a supplementary editor when verified native
  capabilities cannot complete delivery; do not leave founders an unplanned professional editing task.
- Log every actual attempt, including failures, revisions and cancelled jobs; record verified credit events separately
  from monetary cost. Never infer free failure/refund or a fixed credit-to-money exchange rate.
- Verify current capabilities, model/settings, account entitlement, limits, costs and usage rights before execution.
  Unknown means UNVERIFIED; installed tool names or old tests are not proof of current provider behavior.
- Nothing becomes approved automatically. No generation, external asset upload, purchase/subscription, paid service,
  publication or advertising action without explicit user authorization for the specific scope.
- Check applicable licenses, consent, likeness/voice permissions, commercial-use terms, disclosures and platform
  policies for the actual destination, territory and period. Keep personal agreements/credentials outside Git.
- Use new-higgsfield-production.ps1 for local onboarding. Maintain production index, deliverables, content-calendar
  links and CSV schemas together. Use stable HV IDs; retain versioned approvals and lessons from failed attempts.
- Run the extended workspace audit and safely test script changes in a temporary workspace. Do not call provider
  APIs, consume credits or upload product references merely to validate the local production-management system.
