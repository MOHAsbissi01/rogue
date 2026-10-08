# Editable metadata contract

Owner: Brand/Growth cofounder (assignment pending); Product/Ops reviews garment fidelity  
Status: Local working system; commercial approvals remain UNKNOWN unless evidenced  
Last reviewed: 2026-10-08


## Sources of truth

One row per source/version in asset-manifest.csv. One path may occur only once. Preserve all ordered headers.
Existing CSV schemas are unchanged; this manifest has a new registered schema. Scripts validate quoting, IDs,
paths and approval evidence. Use UTF-8 comma-separated CSV, import all text fields as text in Excel, and never
paste customer data or confidential agreement contents. CSV cells beginning =, +, - or @ must be imported as text,
not evaluated as spreadsheet formulas. The web viewer renders metadata as text, never as executable HTML.

| Field group | Fields | Editing rule |
| --- | --- | --- |
| Identity | asset_id, file_path, display_name | ID stable; file_path workspace-relative with forward slashes; no private/external absolute path; preserve original filename |
| Relationships | product_sku, collection, campaign_id, higgsfield_production_id | Use registered product, collection, CAM and HV references; blank means unlinked |
| Description | category, asset_type, tags, description | Type IMAGE/VIDEO/OTHER; tags separated by semicolons; location hints need human review |
| Origin | provenance, creator, capture_date | ACTUAL_PHOTO, RETOUCHED_COMPOSITE, AI_GENERATED, REAL_FOOTAGE, DESIGN_SOURCE or UNVERIFIED; capture_date ISO date or blank |
| Rights | rights_status, commercial_use_approval, product_accuracy_approval | UNKNOWN until evidenced; use APPROVED only for scope/version reviewed; also REJECTED or NEEDS_REVIEW |
| Distribution | platform, publication_status, publication_reference | UNKNOWN/UNPUBLISHED/PUBLISHED; real public post ID or safe reference when published; never inferred from a folder |
| Review | workflow_state, reviewer, review_notes, approval_reference, last_updated | Workflow states documented in taxonomy; last_updated ISO date; reviewer/reference mandatory for approval |
| Ownership/backup mirror | owner, backup_status, backup_reference | Edit the existing operations asset register, then rebuild; do not infer backup from OneDrive or Git |
| Observed location | git_status, availability | Computed on scan; TRACKED/UNTRACKED/IGNORED/UNKNOWN; LOCAL/UNRESOLVED/MISSING_OR_OFFLINE; external backup tracked separately |
| Technical metadata | size_bytes, width, height, duration_seconds, modified_utc, sha256, thumbnail_path | Generated, not hand-authored; unknown values blank; file modified time is not capture time |

No capture date, photographer, AI origin, rights or approval is inferred from EXIF or a filename. The scanner does
not export EXIF/GPS. Original files may still contain sensitive metadata: review before import and sharing; creating
thumbnails does not sanitize masters. Review notes must contain safe summaries, not identity documents or contracts.

## Generated JSON

dashboard/data/gallery.json has schema_version 1, generated_utc, arrays assets/products/campaigns/productions/
deliverables/documents/albums, limitations and scope. It is a generated local view, not another editable source.
The server resolves media by asset ID and selected text documents from the index; it does not expose arbitrary
paths. Technical image dimensions use Windows System.Drawing for supported raster formats. Optional ffprobe adds
video duration/dimensions. Missing metadata stays unknown; browser playback may still work.

## Missing and external records

An empty file_path can describe an expected intake, never a discovered file. A missing or offline path remains in
the manifest without becoming a broken image or local-media count. External storage references and restore evidence
remain in the operations register; externally backed-up and locally stored are independent properties. No remote
file is downloaded automatically. Publication history may remain after archive or file changes; it does not approve
the current bytes. Before reuse, revalidate rights, fidelity and actual available file.

Related: [existing register](../10-OPERATIONS/asset-register.csv), [taxonomy](asset-taxonomy.md).
