# Asset taxonomy and workflow

Owner: Brand/Growth cofounder (assignment pending); Product/Ops reviews garment fidelity  
Status: Local working system; commercial approvals remain UNKNOWN unless evidenced  
Last reviewed: 2026-10-08


## Canonical homes

| Resource | Home | Classification guidance |
| --- | --- | --- |
| Identity files | 02-BRAND-IDENTITY | Logos, labels, packaging and reference-safe artwork |
| Actual hoodie photos and design masters | 03-PRODUCTS/collections/DROP-001/products/RG-H001 | Product ID and collection from catalog; preserve unlimited albums and sample revisions |
| Shared creative material | 04-CREATIVE-STUDIO | Storyboards, raw footage, selected/edited work, final exports |
| AI production material | Existing Higgsfield production folders | Link real HV production ID; AI_GENERATED only when confirmed |
| Organic, paid and campaign versions | 05-MARKETING | Separate organic/paid locations; link campaign code without implying publication |
| Unclassified temporary intake | 12-ASSET-LIBRARY/import-inbox | Optional holding location; not a second master archive |

The scanner uses only these explicit roots. Private records, releases, sensitive-name paths, Git/cache directories,
reparse points and offline/cloud-only files are excluded. It does not crawl the whole computer. Generated thumbnails,
dashboard data and scan reports are outside scan roots. A canonical folder's name can suggest category, product,
collection or production context, but never provenance, rights, approval or publication.

## Review states

INBOX -> CLASSIFIED -> REVIEW -> APPROVED -> PUBLISHED -> ARCHIVED.

INBOX means insufficient classification; CLASSIFIED means the record is organized; REVIEW means a human is checking
it. APPROVED requires commercial-use and product-accuracy approvals, reviewer, evidence reference and exact source
SHA-256. PUBLISHED additionally requires publication status and a real post/ad reference after authorized release.
ARCHIVED preserves history and files; it does not delete anything. Revised bytes invalidate old approval and return
the record to REVIEW on rebuild. Revisit the original review if usage scope, rights or destination changes.

Use category names front, back, details, fit, lifestyle, editorial, storyboards, raw, generated-scenes, edited,
final-exports, mockups or a clear new controlled term. Keep tags semicolon-separated. Platform is manually recorded;
unknown stays blank. Product SKU may temporarily be RG-H001's organizational ID, never an invented commercial variant.

Related: [schema](metadata-schema.md), [review](media-rights-and-provenance.md).
