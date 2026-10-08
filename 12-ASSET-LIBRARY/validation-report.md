# Visual archive validation record

Owner: Workspace maintainer; founder media reviewers unassigned  
Status: Executed local technical checks; no commercial asset approval  
Last reviewed: 2026-10-08

## Executed integration checks

The temporary-workspace suite completed **42 checks successfully** on 2026-10-08, using Windows PowerShell 5.1,
Python 3, local test images and a browser-recorded test WebM. Synthetic test media stayed in disposable temporary
folders; none was imported into the real ROGUE product/studio/campaign records. Paths containing spaces were exercised.

- build-asset-gallery.ps1: empty index, fresh-clone JSON regeneration, deterministic indexing, image dimensions,
  versioned thumbnails, no recursive thumbnail ingestion, excluded private/sensitive paths, manual metadata retention,
  ownership mirroring, unavailable-source retention and invalidation of approvals after source bytes change.
- import-assets.ps1: all five intake slots, unchanged filename and matching source/destination hashes, source retention,
  registration in place, unknown permissions, refusal of destination collisions, duplicate content and path traversal.
- audit-workspace.ps1 with gallery-audit.ps1: rejected incomplete approval evidence in the isolated fixture.
- serve-dashboard.py: frontend access, private/Git/traversal denial, hostile Host/Origin refusal, HEAD, partial-content
  video requests and invalid range rejection. A real test video played in Chromium.
- Frontend: all six navigation sections, correct local-media counts, search, type filter, combined product/platform
  filtering, full-size image loading, alphabetical sort, safe text rendering of HTML-like metadata, no uncaught JS errors,
  and no horizontal overflow at a 390-pixel mobile viewport.
- Desktop (1440 pixels) and mobile screenshots were generated and visually inspected. They use clearly temporary
  fixture data. Screenshots and detailed results remain local under .local/reports, not brand assets.

During development, test-harness issues with JavaScript fixture syntax, hidden-element selectors and CSP-incompatible
test polling were corrected. Browser security was not weakened. The final suite ran to completion.

An additional **14 delivery checks passed**: all 26 earlier CSV schemas and the original operations-register rows
were preserved; Costas scenarios remained separate; Git HEAD/origin remained unchanged; generated/inbox data is
ignored while selected canonical stills remain eligible for deliberate Git review; the PowerShell launcher rebuilt
and served the real workspace successfully; real counts and five unresolved records were correct; mobile layout
and the unavailable-source dialog were verified. The temporary launcher/server was stopped after testing.

Final workspace audit: **738 local links, 27 CSV schemas, 0 errors, 0 warnings**. All **12 PowerShell scripts** parsed
successfully; JavaScript syntax and Python compilation checks passed. No real photos or paid-service actions were
needed for these checks.

## Real workspace state and limits

The real scan found **0 accessible media files** and retained **5 unresolved first-hoodie intake records**. The gallery
also reads the existing product, campaign, Higgsfield production and deliverable records. No physical photo import,
creator identity, usage permission, garment test, commercial approval, live post audit or backup restoration is claimed.

Python 3, Windows PowerShell and browser tooling are available here. Optional ffprobe/ffmpeg were not found on PATH;
video duration/dimensions therefore stay unknown in the generated manifest. Playback still works for browser-supported
formats. Video posters/transcoding are not implemented; video cards open the original stream. Unsupported images use
an explicit fallback. Thumbnails are browsing aids, not product/color accuracy evidence.

Editing review metadata directly in the browser is intentionally not implemented: use the editable CSV/Markdown
records and rebuild. No upload, external-account connection, media generation, publication, Git commit/push or remote
configuration change is part of this extension. No network access is needed for normal local gallery operation.

## Safe repeat-validation procedure

1. Use a separate temporary prepared copy, with a path containing spaces. Exclude real media, .git, .local and private
   records; keep test values visibly labeled TEST and out of the working catalog/asset manifests.
2. Generate or use nonsensitive sample raster images and a short browser-compatible video only in that copy.
3. Run build-asset-gallery.ps1 with WorkspaceRoot pointing at the copy. Import one image with a preserved filename;
   check original hashes, attempt the same import again, and confirm a refusal rather than replacement.
4. Edit safe review notes, rebuild and verify they persist. Change test bytes after a test-only approval and confirm
   REVIEW/UNKNOWN rather than stale approval. Test a missing file and a restricted path.
5. Start the temporary server on an unused port. Exercise navigation, search, all filters, previews, video seeking,
   keyboard dialog close and a narrow browser viewport. Keep the server bound to 127.0.0.1; stop after testing.
6. Run the workspace audit in the real workspace after authorized structural/metadata changes. Record actual errors,
   warnings and remaining limitations; do not infer media correctness or permissions from a technical pass.

Related: [dashboard guide](../dashboard/README.md), [script guide](../scripts/README.md),
[import workflow](import-workflow.md), [review checklist](media-rights-and-provenance.md).
