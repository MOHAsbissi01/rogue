# Safe import and first hoodie intake

Owner: Brand/Growth cofounder (assignment pending); Product/Ops reviews garment fidelity  
Status: Local working system; commercial approvals remain UNKNOWN unless evidenced  
Last reviewed: 2026-10-08


## Before import

Inspect a supplied file locally for sensitive content/metadata, rights and provenance. Do not import signed releases,
identity records, customer photos without permission, financial documents or credentials. Cloud-only files must be
made available deliberately by their owner; scanners skip them. Imports read only one explicitly selected source.

When a file is already in an eligible canonical project folder, omit DestinationFolder: the script registers it in
place. Otherwise choose an existing product/studio/campaign home; the script copies the unchanged filename there,
retains the source and checks matching hashes. It never renames, moves, deletes or overwrites originals. If an
identical master already exists, register that path rather than creating another copy. A collision requires a separate
album folder for a genuinely different file, not silent replacement.

## Five pending RG-H001 records

| Asset ID | Display name / expected category | Suggested canonical subfolder |
| --- | --- | --- |
| AST-INTAKE-001 | Cuffs and hem close-up | prototypes/v01/details |
| AST-INTAKE-002 | Studio front view | prototypes/v01/front |
| AST-INTAKE-003 | Drawstring/fabric close-up | prototypes/v01/details |
| AST-INTAKE-004 | Studio back view showing anatomical graphic | prototypes/v01/back |
| AST-INTAKE-005 | Outdoor lifestyle photograph | photography/lifestyle |

These are requested descriptions, not verified visual observations. No original files were accessible at setup.
Confirm whether the physical sample really corresponds to the v01 documentation slot before choosing that folder;
create a distinct revision/album if needed. No photo implies validated color, fabric, size, quality or launch readiness.

## Commands from the workspace root

Replace the example source path with an actual accessible file. Confirm ACTUAL_PHOTO only from evidence; default
UNVERIFIED remains available. Run once per actual file with the corresponding AssetId and destination above.

```powershell
.\scripts\import-assets.ps1 -SourcePath 'C:\incoming\original front.jpg' -DestinationFolder '03-PRODUCTS/collections/DROP-001/products/RG-H001/prototypes/v01/front' -AssetId AST-INTAKE-002 -DisplayName 'Studio front view' -ProductSku RG-H001 -Category front -Provenance UNVERIFIED

# An original already in its canonical folder: register it without copying.
.\scripts\import-assets.ps1 -SourcePath '.\03-PRODUCTS\collections\DROP-001\products\RG-H001\photography\lifestyle\original outdoor.jpg' -AssetId AST-INTAKE-005 -ProductSku RG-H001 -Category lifestyle -Provenance UNVERIFIED

.\scripts\build-asset-gallery.ps1
.\scripts\audit-workspace.ps1
```

Imports fill the unresolved record and set CLASSIFIED, never APPROVED/PUBLISHED. The script then refreshes the
gallery and operations register. Set creator, capture date, safe rights summary, links, tags and review notes in the
manifest when evidence arrives. Set owner/backup evidence in the operations register. Refresh the browser after
rebuilding; Reload index only reloads JSON and cannot scan disks. The server reads the latest JSON without restart.

## Failure and collaboration

Nominate one writer and let OneDrive finish. A local lock coordinates scripts only on one computer. Managed CSV/JSON
updates use the existing transaction backups and concurrent-edit checks. If copying succeeds but indexing fails,
the copy and source remain; inspect the journal in .local/transactions and register/reconcile the retained file.
Do not blindly retry or delete assets. Rebuild never removes missing records or assumes replacement approval.

Related: [review template](review-template.md), [metadata schema](metadata-schema.md), [script guide](../scripts/README.md).
