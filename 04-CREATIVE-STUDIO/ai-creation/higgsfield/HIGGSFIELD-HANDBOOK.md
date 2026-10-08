# ROGUE Higgsfield production handbook

Owner: Creative lead (cofounder assignment pending)  
Status: PROPOSAL - not approved; no production executed  
Last reviewed: 2026-10-08

## The job to be done

FACT, from the continuation brief: Higgsfield is a core ROGUE AI creative production tool. The deliverable is
a coherent, publication-ready video with story, accurate garment, purposeful movement, finished sound and a
measurable marketing objective. A returned clip is an input, not a successful finished production.

FACT, user-reported prior experimentation: design/placement drift, missing music/sound, static-looking action,
disconnected scenes and excessive manual editing have occurred. Source clips, models, settings, costs and
frequencies were not supplied. This system detects those risks without inventing a model diagnosis.

## From a hoodie and an idea to an approved video

1. Register a production and its product/campaign IDs. Choose one objective and one viewer takeaway.
2. Link real front/back/detail/fit photographs and the controlled specification. Resolve the exact commercial
   SKU/variant before commercial generation. RG-H001 is currently an organizational ID, not a confirmed variant.
3. Write a connected beginning, middle and ending: protagonist, tension, physical action, turning point, product role and CTA.
4. Storyboard timed shots. Define subject movement separately from camera motion, screen direction and entry/exit poses.
5. Plan music, effects, voice if needed, edit order and finishing responsibility before any generation.
6. Verify current workflow capability, permitted references, settings, plan/credits and cost evidence. Obtain explicit
   authorization for generation/upload and any spend. The present task authorizes none of these actions.
7. Generate only within that scope. Log every attempt, including failures/cancellations and unknown charges.
   Reject garment drift; change one test variable at a time. Use authentic footage or verified compositing when needed.
8. An assigned editor/finisher assembles the full timeline, sound, typography, logo and CTA. Founders review a complete
   master rather than being expected to assemble unrelated clips. If no finishing owner exists, the job stays blocked.
9. Review at full size and on mobile, with sound and muted. Compare every garment-visible sequence to references.
   Capture version-specific cofounder approval. Export and review each destination variant separately.
10. Publish only under separate explicit authorization; then record actual post/ad ID, date, scope and measured results.

## Source of truth

Use production-index.csv for package status and deliverables.csv for video variants/post relationships.
Each production's generation-log.csv owns attempt outcomes. The central credit ledger owns actual provider credits;
production-costs.csv owns monetary cost lines. Join with production_id, deliverable_id and attempt_id, not filenames alone.
The existing generations-log.csv and prompt-template.md are preserved as historical/general entry points. Do not
double-enter new attempts in that legacy log; link to the production attempt record instead.

## Ready means evidence, not a folder name

IDEA -> BRIEFED -> GENERATING -> EDITING -> REVIEW -> APPROVED -> PUBLISHED.
Keep blockers in a separate field. Revisions return to the appropriate stage and invalidate approval for changed
exports. APPROVED requires actual cofounder evidence; PUBLISHED requires a real authorized post. No automation sets either.

UNKNOWN: current provider models/features/limits, plan, credits, prices, approved product references, commercial SKU,
music rights, final logo, editor and launch offer. The three HV-001 briefs are alternatives requiring selection.
Next action: follow HV-001's first-production checklist when the real hoodie photographs are available locally.

## Related records

[production workflow](production-workflow.md) | [README](04-VIDEO-PRODUCTIONS/README.md) | [first production checklist](04-VIDEO-PRODUCTIONS/HV-001-FIRST-HOODIE/first-production-checklist.md) | [budget estimator](08-PRODUCTION-FINANCE/budget-estimator.md) | [models and tools](models-and-tools.md)

## Visual archive integration - 2026-10-08

The [asset library](../../../12-ASSET-LIBRARY/README.md) indexes canonical references, generated scenes and final
exports without creating competing masters. Link asset rows with the actual HV production ID, SKU and campaign.
The [local dashboard](../../../dashboard/README.md) reads production-index.csv and deliverables.csv, links briefs,
and distinguishes missing exports from actual media. A generation location never proves AI provenance or approval.
Review source accuracy/rights and exact hashes before approving commercial reuse. It does not call Higgsfield.
