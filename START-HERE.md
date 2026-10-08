# Start here

Owner: Both cofounders (assignment pending)  
Approval status: PROPOSAL - awaiting founder review  
Last reviewed: 2026-10-08

## First founder session

1. Read the [facts](00-HQ/brand-facts.md) and correct them with evidence if needed.
2. Assign the proposed Product/Ops and Brand/Growth responsibilities. Record real names only after agreement.
3. Locate the existing physical sample and original design/fabric research. Copy no private documents into Git.
4. Photograph front, back, details and fit; record measured specifications and test plans for RG-H001.
5. Pick the next three actions from the dashboard. Make no public launch or price promise yet.

## Use the files

Open this folder in VS Code. Markdown is editable text; use Ctrl+Shift+V for preview.
CSV files open in Excel or a text editor. In Excel use Data > From Text/CSV, select UTF-8 and comma,
and import IDs as text. Save back as CSV UTF-8 with the exact existing headers and ISO dates.
Do not paste personal customer details into templates. Numbers use decimal points and no TND symbol
inside numeric cells. Currency has its own `currency` field or `_tnd` header.
See the [CSV editing guide](00-HQ/csv-guide.md) for record grains, missing inputs and calculation rules.

Numeric blanks mean UNKNOWN, never zero. Most seeded rows are PROPOSAL or TEMPLATE, not observations.
CSV files are editable inputs and recorded results, not automatically recalculating workbooks.
Use the written [formulas](07-FINANCE/unit-economics.md) to calculate and review output fields.

## PowerShell scripts

Open a Windows PowerShell terminal at the workspace root. Commands handle spaces in paths.
Use `-WorkspaceRoot 'C:\path with spaces\rogue'` to target another prepared workspace.
Scripts accept Windows PowerShell 5.1, use no network and refuse existing product/campaign folders.
Do not change machine execution policy. If local policy blocks a script, a session-only command is:
`powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\audit-workspace.ps1`.
Use this only for the local scripts you have reviewed.

### Add a product

```powershell
.\scripts\new-product.ps1
.\scripts\new-product.ps1 -ProductId RG-H002 -Collection DROP-001
```

The first command asks for both values. IDs use `RG-` + one uppercase category letter + three digits.
Collection codes use `DROP-` + three digits. A new collection is created if needed. The script creates
the standardized product album, updates the catalog and collection README, and leaves all commercial
specifications unknown. It does not create an actual physical sample. RG-H001 is already reserved.

### Add a campaign

```powershell
.\scripts\new-campaign.ps1
.\scripts\new-campaign.ps1 -CampaignCode CAM-002-PROTOTYPE-STORY
```

Use `CAM-` + three digits + an uppercase hyphenated name. The number cannot be reused with another name.
New campaigns use a clean version of the CAM-001 framework. Past approvals and performance are not copied.
The script registers the campaign and adds one unscheduled draft brief to the content calendar.

### Inventory assets

```powershell
.\scripts\inventory-assets.ps1
.\scripts\inventory-assets.ps1 -IncludeHashes
```

Reports are timestamped in ignored `.local/reports/`. They contain relative paths, sizes, extensions,
optional SHA-256 hashes and Git tracking status. Maintain owners and backup evidence in the
[asset register](10-OPERATIONS/asset-register.csv). UNKNOWN backup means unverified, including OneDrive files.
Private storage and reparse-point folders are excluded. No uploads occur.

### Audit the headquarters

```powershell
.\scripts\audit-workspace.ps1
```

The audit checks the manifest, folders, local Markdown file/heading links, CSV headers/row widths,
and product/campaign indexes. It exits nonzero on errors and writes a new local report.
It does not check external URLs, legal compliance, garment quality or live accounts.

## Safe collaboration and recovery

Only one founder should run onboarding scripts at a time. A local lock blocks concurrent script runs;
it cannot coordinate two OneDrive computers. Let sync finish, nominate one writer, and resolve conflicts
before further edits. Script index backups and transaction journals live in `.local/transactions/`.
If an operation fails, stop and inspect the reported journal before retrying. Created assets are never deleted
to conceal a failure. Follow [recovery guidance](scripts/README.md).

An empty local Git repository is initialized on branch `main`; no files are staged or committed and no remote is configured.
Before any first commit review `git status --short` and `.gitignore`, invite exactly
the founder-approved people to a PRIVATE repository, and obtain explicit authorization before remote creation
or push. Git is not a media backup. See [asset management](10-OPERATIONS/asset-management.md).

## Related files

[dashboard](00-HQ/dashboard.md) | [README](scripts/README.md) | [collaboration and approval rules](10-OPERATIONS/collaboration-and-approval-rules.md)
