# Workspace automation

Owner: Both cofounders (assignment pending)  
Approval status: Local automation; see executed QA report  
Last reviewed: 2026-10-08

## Commands

Run from the workspace root in Windows PowerShell 5.1. All scripts use only local filesystem/.NET and optional
read-only Git status commands. No dependency installation, account access, upload, commit or purchase is performed.

| Script | Inputs | Creates / updates |
| --- | --- | --- |
| new-product.ps1 | ProductId, Collection; prompts if omitted; WorkspaceRoot optional | Full product tree, catalog row, collection README; new collection docs if needed |
| new-campaign.ps1 | CampaignCode; prompts if omitted; WorkspaceRoot optional | Clean CAM-001-based framework, campaign register/index, unscheduled calendar row |
| inventory-assets.ps1 | WorkspaceRoot optional; IncludeHashes switch | Unique CSV and Markdown inventory in .local/reports |
| audit-workspace.ps1 | WorkspaceRoot optional | Unique local audit report; exit 1 on errors, 0 on successful checks |

Usage examples are in [START-HERE](../START-HERE.md). common.ps1 contains shared path, CSV, template and transaction
helpers. Do not run it as an onboarding command. Files in templates are clean reusable structures derived from
the initial product/campaign framework; they contain no approved commercial facts or past results.

## Preservation and recovery

Onboarding refuses invalid IDs, duplicate IDs/numbers, existing destinations, incompatible CSV headers and
paths outside the prepared workspace. It creates files exclusively and never overwrites original assets.
Catalog/index/calendar changes are intentional updates with staged replacements, backups and a journal in
ignored .local/transactions. A local lock prevents concurrent scripts on one machine. It does not coordinate
OneDrive peers or an editor writing between checks; agree one writer and finish synchronization first.

If an index update fails, the script attempts to restore only indexes that still match what it wrote.
Concurrent edits are retained and flagged for manual recovery. Newly created folders remain for inspection;
they are not deleted or silently reused. Stop after failure, read the journal, compare `.before` backups with
current indexes, and reconcile the catalog/index before retrying. Do not delete an active lock or restore blindly.
If templates change, review generated links and tests before normal use. New products never inherit prototype
existence, colors, sizes, costs, approvals or test results from RG-H001.

## Audit coverage

workspace-manifest.json lists essential files/folders. csv-schemas.json defines exact ordered headers.
Update these deliberately when a schema or essential template changes. The audit checks inline local links
and ordinary Markdown heading anchors, CSV quoting/width/header consistency, selected numeric/date fields and
product/campaign index relationships. It does not validate external URLs, every possible Markdown syntax,
privacy automatically, business truth, legal compliance or live checkout. Template token links are checked
after a generated record is created. Reparse/offline files and sensitive storage are outside normal scans.

Inventory is read-only for assets. It writes new reports, joins owner/backup metadata from the register and
can hash eligible files. Empty inventory is a valid result. Store external assets in the register rather than
inventing local files. Hashing does not verify a backup or usage rights.

## Testing

Use a temporary prepared copy with a path containing spaces. Test success, duplicate/invalid IDs, a new
collection, damaged CSV headers, malformed quoted rows, missing files and broken links. Keep test products,
campaigns and metrics out of the real headquarters. The delivered QA report records the checks actually executed.

## Related files

[qa report](../00-HQ/qa-report.md) | [csv schemas](csv-schemas.json) | [workspace manifest](workspace-manifest.json)


## Higgsfield onboarding and audit extension

new-higgsfield-production.ps1 asks for production name/ID, registered product SKU/base ID, registered campaign,
platform, content type and objective. See the [usage examples](../START-HERE.md#create-a-higgsfield-production-record).
Its single template source is the production-template folder in the Higgsfield department, not a competing copy.
higgsfield-production-structure.json defines template files/folders and allowed options.

The script updates four managed files together: production-index.csv, deliverables.csv, the marketing content
calendar and CSV schemas for the new generation log. Existing record rows and schema definitions are preserved.
It reuses the lock, backups and conditional rollback helpers. It never generates media, uploads, spends or approves.

higgsfield-audit.ps1 is a helper loaded by audit-workspace.ps1. It validates production IDs, product/campaign links,
template completeness, generation-log registration, deliverable/calendar relationships and approval/publication
evidence fields. These checks detect missing records, not whether the claimed approval is authentic; human review remains required.

## Visual asset commands

| Command | Purpose | Changes |
| --- | --- | --- |
| build-asset-gallery.ps1 | Scan explicit canonical roots and refresh the read-only gallery | Preserves human metadata; updates manifest/register/generated JSON with transactional backups; creates versioned thumbnails and a report |
| import-assets.ps1 | Register one existing original or explicitly copy one accessible external original | Preserves filename/source; refuses existing destination or identical content; attaches unresolved intake ID if given; never approves |
| start-dashboard.ps1 | Rebuild and launch the loopback-only viewer | Runs Python stdlib server; Ctrl+C stops it; no install or network needed |

gallery-common.ps1 supplies the allowlist/classification/review checks. gallery-audit.ps1 extends the existing
workspace audit. serve-dashboard.py is the read-only HTTP server with range requests and restricted file routing.
See [import examples](../12-ASSET-LIBRARY/import-workflow.md), [dashboard guide](../dashboard/README.md) and
[validation record](../12-ASSET-LIBRARY/validation-report.md). Optional build flags: SkipThumbnails, SkipVideoMetadata;
WorkspaceRoot supports temporary paths with spaces. Rebuilds hash accessible media to invalidate stale approvals.
