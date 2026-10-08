# ROGUE visual asset library

Owner: Brand/Growth cofounder (assignment pending); Product/Ops reviews garment fidelity  
Status: Local working system; commercial approvals remain UNKNOWN unless evidenced  
Last reviewed: 2026-10-08


This is the index of ROGUE's creative resources. Original product, studio and campaign files stay in their existing
canonical folders. The dashboard reads this index; it does not move, publish, generate or approve anything.

## Start browsing

From the workspace root, run `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-dashboard.ps1`.
It refreshes the index and opens http://127.0.0.1:8765/ in your browser. Keep that terminal open; Ctrl+C stops it.
No internet, account connection, npm packages or framework is required. Python 3 runs the restricted local server.

## Where information belongs

- [Asset manifest](asset-manifest.csv): identity, classification, provenance, campaign/production links and review records.
- [Existing asset register](../10-OPERATIONS/asset-register.csv): authoritative ownership and independent-backup evidence;
  existing non-digital/external records remain. The gallery mirrors its owner/backup fields, never assumes a backup.
- Canonical media: existing folders under Brand Identity, Products, Creative Studio and Marketing.
- generated-thumbnails: disposable local previews with asset ID and source hash; never masters.
- reports: dated local scan reports. dashboard/data/gallery.json is generated and ignored by Git.

## Daily routine

Register an existing file in place, or explicitly copy one supplied original into its appropriate canonical folder.
Use the [import procedure](import-workflow.md); classify and review in the CSV, then rebuild. Review stage and
publication are separate from file location. Read the [rights and fidelity checklist](media-rights-and-provenance.md)
before marking an exact version approved. The dashboard is read-only; CSV/Markdown editing is intentional.

FACT: five expected RG-H001 intake records are prepared. Their actual files, creators, capture dates and usage
permissions are UNKNOWN. No photograph is fabricated or counted as imported. The existing hoodie is a testing
prototype, not necessarily the final launch product.

## Navigation

[Taxonomy](asset-taxonomy.md) | [Naming](naming-conventions.md) | [Metadata schema](metadata-schema.md) |
[Import workflow](import-workflow.md) | [Review template](review-template.md) | [Dashboard guide](../dashboard/README.md)
