# Book Figure design tokens

Version: 1.2.0

These values are authoritative. Apply them to every figure unless the user explicitly supplies different production dimensions or typography. For another canvas size, multiply all pixel values by `s = min(width / 1600, height / 900)`.

## Baseline canvas

| Token | Value |
| --- | --- |
| Landscape canvas | 1600 × 900 px |
| Portrait canvas | 1200 × 1600 px |
| Background | `#FCF7ED`; permitted paper alternate `#FFFDF8` |
| Outer safe margin | 64 px |
| Inter-panel gap | 48 px |
| Internal panel padding | 32 px |
| Minimum unrelated-object gap | 24 px |
| Object-to-label gap | 12 px |
| Minimum text clearance | 12 px |
| Base spacing unit | 8 px |

Use whitespace as the default panel separator. If a divider is scientifically or compositionally necessary, use a 1.25 px `#C7C9C8` line. Do not add card backgrounds merely to fill space.

## Typography

| Role | Typeface | Weight | Baseline size |
| --- | --- | --- | --- |
| Panel letter | Inter | SemiBold 600 | 34 px |
| Panel heading | Inter | SemiBold 600 | 28 px |
| Molecular label | Inter | Medium 500 | 22 px |
| Process/annotation | Inter | Regular 400 | 18 px |
| Polarity mark outside a sequence | Inter | Regular 400 | 18 px |
| Displayed nucleotide sequence | Roboto Mono | Medium 500 | 20 px |

Use Inter for all visible English and Bulgarian text except displayed nucleotide sequences and sequence-only motifs, which use Roboto Mono. Render every visible text glyph in pure black `#000000`, including labels printed inside colored biological objects and all Roboto Mono sequence characters, punctuation, hyphens, and 5′/3′ markers. Keep text horizontal unless a vertical genomic track makes rotation essential. Use sentence case. Never reduce visible text below 16 px at the baseline canvas; rebalance the layout instead.

## Lines and contours

| Token | Value |
| --- | --- |
| Primary object outline | 2.5 px |
| Secondary/internal contour | 1.5 px |
| DNA/RNA strand | 3 px |
| Duplex rung | 1.5 px |
| Process arrow shaft | 2.5 px |
| Neutral connector | 2 px |
| Cleavage mark | 2 px |
| Membrane contour | 2.5 px |
| Double-membrane gap | 10 px |
| Line cap/join | Round |

Use dark slate-blue `#203B57` for active outlines and connectors, not for text; use `#42586B` for secondary structure and `#C7C9C8` for neutral transitions.

## Arrows and inhibition

| Token | Value |
| --- | --- |
| Standard arrowhead | 12 px long × 10 px wide |
| Compact arrowhead | 10 px long × 8 px wide |
| Minimum arrow terminal clearance | 8 px |
| Inhibition terminal bar | 18 px wide, same stroke as connector |
| Minimum process-arrow length | 48 px |

Arrowheads and inhibition bars must terminate at the controlled object or interaction surface. Do not leave ambiguous gaps.

## Shapes and highlights

| Token | Value |
| --- | --- |
| Small module radius | 10 px |
| Large grouping radius | 24 px |
| Protein highlight | `#FFFDF8`, 70% opacity |
| Maximum highlight area | 8% of the object |
| Shadow | None |

Use one restrained highlight at most per biological object. Do not use gradients, glossy lighting, texture, or volumetric shadows.

## Density rules

- Use no more than seven active semantic fill colors in one panel.
- Keep at least 20% of the canvas as negative space.
- Reuse identical geometry and token values for the same entity repeated across panels.
- Align peer panels and repeated stages to the 8 px spacing grid.
- Prefer a larger canvas over shrinking labels or compressing molecular interactions.

## Prompt hand-off

Include the following line in every generation prompt:

```text
Design system: Book Figure tokens v1.2.0. Baseline 1600 × 900 px; 64 px outer margin; 48 px panel gap; 2.5 px primary outlines; 3 px nucleic-acid strands; Inter labels; Roboto Mono nucleotide sequences; all visible text #000000. Scale all pixel tokens proportionally for another requested canvas.
```
