# Capability-card biological cutouts design

Date: 2026-07-29  
Status: approved design; pending implementation plan

## Goal

Add one small biological visual from the Book Figure cover to each capability card on the GitHub Pages site. The visuals should make the four cards feel connected to the skill's scientific atlas while preserving a minimal editorial interface.

## Asset selection

| Card | Existing heading | Cover object | Notes |
| --- | --- | --- | --- |
| 01 | Redraw figures | DNA methyltransferase bound to double-stranded DNA | Emphasizes figure redrawing and molecular structure. |
| 02 | Create from text | Zinc-finger protein | A compact, distinct protein-form example. |
| 03 | Visual atlas | Chromosome territory | Represents the atlas's broader biological vocabulary. |
| 04 | English & Bulgarian | Transcription-factor binding motif with `TGAC` | Keeps the readable sequence text visible. |

## Asset treatment

Create four individual PNG files with alpha transparency, cropped or cleanly isolated from the cover. Each object retains the cover's muted blue, teal, ochre, violet, and coral palette. No white or pastel rectangle may remain around an object.

Place each object at the top-right of its capability card. It must not overlap headings or paragraphs and should remain decorative, with the card text still fully readable. Use a compact intrinsic width of 4.5–5.5rem on desktop and 4rem on small screens.

## Interaction and accessibility

- Decorative cutouts use empty alt text and `aria-hidden="true"`.
- Cards keep their existing keyboard focus and hover behavior.
- On card hover, the cutout gets a restrained cyan/slate-blue glow plus a 1–2 px upward shift.
- The `prefers-reduced-motion` block disables the movement.

## Verification

Static tests must assert four image paths, four decorative image attributes, and CSS rules for transparent asset sizing, hover glow, and mobile sizing. The full existing site test suite must stay green.
