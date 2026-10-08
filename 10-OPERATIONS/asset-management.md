# Asset storage, Git and backup policy

Owner: Both cofounders (assignment pending)  
Approval status: PROPOSAL - awaiting founder review  
Last reviewed: 2026-10-08

## Storage classes

The asset register is the safe metadata source for owners, location, rights and verified backup evidence.
Generated inventories show what is present locally at scan time. Empty results mean no eligible media was found,
not that the physical prototype or all external assets do not exist.

Keep small original or approved reference-safe visual assets in Git only after checking rights, metadata, size
and privacy. JPG/PNG/SVG/WEBP are permitted by default; raw folders and large editing/audio/video formats are ignored.
Small approved MP4 previews are eligible but still require size/rights review before staging. Suggested review
ceiling: 10 MiB per Git asset, a PROPOSAL pending founder storage policy; the audit warns rather than uploads.

Keep raw media and editing projects in backed-up media storage. Ignored local folders are not secure vaults.
Store tokens, passwords, sessions, customer contacts/addresses, identifying invoices, confidential supplier files,
model identity documents and signed agreements in approved restricted storage outside this repository.
OneDrive may synchronize ignored files, so a Git ignore rule does not protect them from cloud access.

## Backup and access

PROPOSAL: maintain the working copy plus an independent versioned backup and a separate/offsite copy where
appropriate. Assign an owner, verify restoreability and record last restore test. Private GitHub and OneDrive
synchronization are not substitutes for secure access management or media backups. UNKNOWN: current backup
coverage and access policy. Never mark backed_up=YES based only on a OneDrive path.

## Optional Git LFS - not enabled

Git LFS was detected on the setup machine. Storage policy, quota, cost, collaborators' tooling and backup
arrangements are not agreed. No LFS filters or tracking rules are active in .gitattributes.
After explicit storage agreement, a maintainer may add narrowly scoped rules for approved large assets,
for example `git lfs track '02-BRAND-IDENTITY/logo/approved/*.psd'`, review generated .gitattributes and
add a narrow ignore exception if needed. Never automatically migrate existing Git history.
LFS pointers alone are not a backup of the underlying media. Remote creation and push need separate authorization.

## Inventory workflow

Run inventory-assets, review its ignored local report and update safe entries in asset-register.csv.
Use relative paths for workspace files, an external storage code for external assets, and avoid revealing private
paths in Git. Hashing is optional and can be expensive or hydrate cloud files; run it deliberately.
The script skips restricted folders, reparse points and online-only/offline files and reports its scope.
Next action: identify where the real sample photos and research files live and verify their backup/rights status.

## Related files

[decision log](../00-HQ/decisions/decision-log.md) | [README](README.md)

## Gallery integration - 2026-10-08

The [visual manifest](../12-ASSET-LIBRARY/asset-manifest.csv) owns asset-level creative review and publication metadata;
this department's register remains authoritative for owner, backup_status and backup_reference. Scanner-discovered
media receive matching IDs in both records. Existing physical/external records remain intact. Import intake rows are
unresolved, not proof of local media. A rebuild mirrors register ownership/backup data into the gallery, with read-only
Git tracking and content hashes. It never marks backup verified. See [schema](../12-ASSET-LIBRARY/metadata-schema.md).
