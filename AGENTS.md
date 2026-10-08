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
