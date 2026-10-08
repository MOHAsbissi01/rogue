# Local Creative Archive dashboard

Owner: Brand/Growth cofounder (assignment pending); Product/Ops reviews garment fidelity  
Status: Local working system; commercial approvals remain UNKNOWN unless evidenced  
Last reviewed: 2026-10-08


## Start

Open PowerShell at the ROGUE workspace root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-dashboard.ps1
```

The launcher rebuilds the index, serves on http://127.0.0.1:8765/ and opens your browser. Keep the terminal open;
Ctrl+C stops it. Optional `-Port 8877`, `-NoBrowser` and `-SkipBuild` support an occupied port or an existing index.
Direct file:// is unsupported; no browser-security changes are needed. Do not use a generic whole-workspace HTTP
server: the bundled server exposes only specific frontend files, manifest-listed eligible media and selected text docs.

## Browse

Overview counts accessible images/videos, product records, pending review, approved campaign assets and indexed
local bytes. Unresolved intakes are displayed but excluded from media/storage counts. Asset gallery searches filenames,
display names, descriptions and tags; filters product, collection, type, platform and workflow state; sorts date/name/category.
Open a card for full image preview or video controls, path, provenance, dimensions, rights, approval notes and backup status.

Products show collections, canonical albums and prototype folders, with a filter for approved commercial references.
Creative Studio links storyboards and routes to raw/AI/edited/export files. Higgsfield displays production IDs, SKU,
briefs, local state, approvals and final export references. Campaigns keep organic and paid folders separate and show
recorded publication state. A missing reference is shown honestly. No external service is queried.

## Refresh and review

Run `scripts/build-asset-gallery.ps1` after adding files or editing metadata, then Reload index in the browser.
The browser is read-only; it cannot import, approve, modify source files or publish. Use
[the import workflow](../12-ASSET-LIBRARY/import-workflow.md) and [manifest schema](../12-ASSET-LIBRARY/metadata-schema.md).

## Requirements and fallbacks

- Required: Windows PowerShell 5.1, Python 3 standard library, a current browser; no third-party web dependencies.
- Optional: Git for observed tracking status. Git is read-only; no commit, push or remote edits.
- Windows System.Drawing produces JPEG thumbnails/dimensions for ordinary JPG/PNG/GIF/BMP. Unsupported or very large
  images use direct browser preview where supported, or an explicit source download. Source orientation/colors may
  differ in generated thumbnails; use full-size original and real sample for accuracy review.
- Optional ffprobe adds video duration/dimensions if installed. Without it the fields remain unknown. Browser codec
  support determines playback; MP4/WebM commonly work, while MOV/HEIC/TIFF/editing formats may need native apps.
  No transcoding or video poster extraction is required. A text card is the honest fallback, not a fake frame.
- Hashing every local eligible file binds approvals to bytes and can take time on large libraries. Offline files and
  reparse points are skipped deliberately. No remote hydration, external media fetching or base64 video embedding.

The server binds only 127.0.0.1, checks Host/Origin, blocks traversal/reparse/offline access, supports HEAD/range
requests for video seeking, and provides no write endpoints or directory listings. SVG/editing documents are offered
as downloads rather than embedded active documents. Do not expose this server to the LAN or internet.

Related: [asset library](../12-ASSET-LIBRARY/README.md), [safe validation report](../12-ASSET-LIBRARY/validation-report.md).
