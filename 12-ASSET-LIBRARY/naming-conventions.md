# Asset identity and filenames

Owner: Brand/Growth cofounder (assignment pending); Product/Ops reviews garment fidelity  
Status: Local working system; commercial approvals remain UNKNOWN unless evidenced  
Last reviewed: 2026-10-08


## Preserve originals

The import script preserves the entire original filename, including spaces and case. It refuses a destination
collision. Use display_name for a readable name, such as "Studio front view", without renaming the source.
If two different originals share a name, select separate dated album directories. Register an existing canonical
file in place instead of copying it into the library. Exact content duplicates are rejected during import.

Existing non-ASCII filenames are preserved; use ASCII for new folder names and authored documents. Suggested new
derivatives: YYYY-MM-DD_PRODUCTID_view_vNN.ext. Keep edited/composited/AI variants separate from the source and
describe their provenance. Never overwrite a photograph to improve its appearance or change product detail.

## Stable record IDs

Discovered assets use AST- plus the first 20 hexadecimal characters of SHA-256 of the lowercase relative path.
The scanner sorts records by asset ID. Five founder intake slots use AST-INTAKE-001 through AST-INTAKE-005 and retain
those IDs when linked to files. IDs are organizational identifiers, not proof of rights or image authenticity.
Manual relocation outside the scripts leaves a missing old record and a new discovered record: reconcile explicitly,
preserve the old history and never silently treat a new file as the same approved version.

Thumbnails use asset ID plus the first 16 characters of the source-content hash. A changed original gets a new
thumbnail filename; existing previews are not overwritten. Old thumbnails can remain until an explicitly authorized
cache cleanup. SHA-256 identifies bytes, not authorship, backup or permission.

Related: [import workflow](import-workflow.md), [manifest](asset-manifest.csv).
