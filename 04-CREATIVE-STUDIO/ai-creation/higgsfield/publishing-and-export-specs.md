# Publishing and export planning

Owner: Creative lead (cofounder assignment pending)  
Status: PROPOSAL - not approved; no production executed  
Last reviewed: 2026-10-08

Provider and destination platform requirements have not been verified. The values below are PROPOSED internal
delivery targets, not claims about current Instagram, TikTok, advertising or website limits.

| Destination | Proposed review deliverable | Must verify before final export/publication |
| --- | --- | --- |
| Instagram Reels | Vertical 9:16 master; proposed 1080 x 1920; full mixed sound; cover still | Current supported length/codec/size, crop/UI safe areas and music usage |
| Instagram Stories | Separately paced vertical variant with legible CTA | Current segment length, link/CTA features, overlay areas and rights |
| TikTok | Separately reviewed vertical version, native-feeling opening | Current upload/ad limits, disclosure, music rights and account access |
| Paid advertising | Placement-specific variants and an accurate offer | Actual placement specs, eligibility, landing page and paid-use rights |
| Website | Product-faithful concise video plus poster image | Real player support, bandwidth, audio/autoplay behavior and accessible alternative |

PROPOSAL working export: MP4 with H.264 video and AAC audio if supported by the chosen delivery route; choose a
consistent timeline frame rate after inspecting sources, avoiding unexplained mixed-rate motion. These are internal
choices requiring verification, not confirmed Higgsfield output controls. Never invent mandatory bitrates or platform
loudness thresholds. The editor chooses/test-records settings against current requirements and actual content.

Inspect actual exported stream metadata, full-duration playback, sound start/end, captions, small-screen legibility,
CTA, framing and reference fidelity. Listen through headphones and a phone speaker. Test each variant independently.
Suggested filename: HV-001-A_instagram-reels_v01_review.mp4, then a version-specific approved export after signoff.
Approval state belongs in the register; a filename cannot approve an asset. Keep raw/project media out of Git.

09-APPROVED-EXPORTS holds channel delivery references/manifests by default, linking canonical final-exports files to
avoid duplicate binaries. If a distributor needs a copy, record source hash, copy path and backup. Publishing remains
a separate explicitly authorized action. No exports or uploads were produced in this setup.

## Related records

[HIGGSFIELD HANDBOOK](HIGGSFIELD-HANDBOOK.md) | [product fidelity rules](product-fidelity-rules.md)
