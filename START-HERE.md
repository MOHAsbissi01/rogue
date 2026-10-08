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


## Create a Higgsfield production record

Read the [handbook](04-CREATIVE-STUDIO/ai-creation/higgsfield/HIGGSFIELD-HANDBOOK.md) and the
[first-hoodie intake checklist](04-CREATIVE-STUDIO/ai-creation/higgsfield/04-VIDEO-PRODUCTIONS/HV-001-FIRST-HOODIE/first-production-checklist.md).
The first package HV-001 already contains three unapproved proposals. Select and develop one before creating duplicates.

```powershell
.\scripts\new-higgsfield-production.ps1
.\scripts\new-higgsfield-production.ps1 -ProductionName 'Detail Study' -ProductionId HV-002 -ProductSku RG-H001 -CampaignId CAM-001-FIRST-DROP -Platform 'Instagram+TikTok' -ContentType Organic -Objective 'Product launch'
```

The first command asks seven questions: name, HV ID, registered product SKU/base ID, registered campaign, platform,
Organic/Paid/Hybrid type and objective. A base product ID allows planning but leaves commercial SKU approval unresolved.
The script creates the standard production folder, registers its main proposed deliverable, adds an unscheduled
content-calendar row and registers the generation-log schema. New state is always IDEA. No provider is called.

IDs: HV- plus three digits. Name: 1-60 ASCII letters/numbers/spaces/apostrophes/hyphens. Platforms: Instagram, TikTok,
Instagram+TikTok, Website, Multi-platform. Objectives: Brand awareness, Product launch, Emotional storytelling,
Organic engagement, Paid advertising, Product conversion. Use exact displayed capitalization.

Optional `-WorkspaceRoot 'C:\path with spaces\rogue'` targets another prepared workspace. Duplicate IDs, existing
folders, unknown product/campaign references and incompatible CSV headers are rejected. Updates use the existing
local lock, backups and recovery journal. On failure, inspect the journal; new folders are retained, not overwritten
on retry. Coordinate one writer across OneDrive machines. Run the workspace audit after editing records.

Next: fill references/story/motion/audio/finishing plan, verify capabilities/costs, then obtain explicit generation
authorization. A completed local brief is not permission to generate, upload, spend or publish.

Git state note, 2026-10-08 continuation: local inspection now shows existing Git history and a configured origin
remote. The earlier empty-repository note describes initial setup. This extension preserves the current history
and remote and performs no commit or push. Repository visibility and invite permissions were not checked online.

## Browse and import visual assets

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-dashboard.ps1
.\scripts\build-asset-gallery.ps1
.\scripts\audit-workspace.ps1
```

The launcher builds the local index and opens http://127.0.0.1:8765/. Python 3 is required; no network or packages.
Keep the terminal open and stop with Ctrl+C. Reload index in the browser after a rebuild. Do not double-click the
HTML file or serve the whole repository with a generic server.

Start with [the five hoodie intake instructions](12-ASSET-LIBRARY/import-workflow.md). Original filenames remain
unchanged; display names are separate. Use import-assets.ps1 to register existing canonical media in place or
explicitly copy an accessible source to a chosen canonical folder. Existing destinations and identical content are
rejected. Edit review metadata in [asset-manifest.csv](12-ASSET-LIBRARY/asset-manifest.csv); edit owner/backup
evidence in the existing operations register. An imported file is never automatically approved or published.

See [dashboard requirements and limitations](dashboard/README.md) and [review checklist](12-ASSET-LIBRARY/media-rights-and-provenance.md).
