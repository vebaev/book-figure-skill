---
name: book-figure
description: Use when redrawing a biology, molecular biology, genomics, plant, or regulatory schematic from a raster source, creating one from a written scientific description, or requesting `genereg`, `detailed`, or `ref` mode, in a consistent editorial textbook or review-article style with a warm pastel palette, accurate labels, and precise biological-object rendering.
---

# Book Figure

Create a new, non-destructive editorial redraw or text-to-figure schematic. Preserve supplied facts and use the bundled minimalist reference as the defined visual grammar so unrelated figures look like one coherent book.

## Required design-system references

Before planning or generating any figure, read these files completely:

1. `references/design-tokens.md` — authoritative canvas, spacing, typography, stroke, arrow, radius, highlight, and scaling values.
2. `references/semantic-colors.md` — authoritative biological-role color assignments and state-encoding rules.

Treat those references as the single source of truth. If a summary elsewhere in this skill conflicts with them, the reference files win. Include the required design-system and semantic-role prompt lines from both references in every generation prompt.

## Default style and input mode

Use **`genereg` + `detailed` by default** for every request. The bundled `assets/genereg-reference.png` is therefore a style-only reference unless the user explicitly asks for **standard mode**, **without genereg**, or **without the bundled reference**. Apply detailed molecular conventions unless the user explicitly asks for **simplified**, **without detailed**, or a deliberately schematic-only figure.

- **Source-figure mode:** use when the user supplies a raster figure. Preserve its facts, text, layout logic, and relationships.
- **`ref` mode:** use only when the user explicitly requests `ref`, says to take only the scientific content from the source, or says not to use the source for design. `ref` takes precedence over source-figure mode and combines with the default `genereg` + `detailed` modes. Inspect the source to extract facts, labels, entities, and causal relationships, then treat the resulting extraction exactly like a text-to-figure brief. Do not use the source's palette, line treatment, object forms, typography, spatial composition, panels, or other visual decisions.
- **Text-to-figure mode:** use when the user supplies a written description, outline, caption, or list of required elements. Convert the description into a compact panel plan before generating; do not require a source image.
- **Standard mode:** use only when the user explicitly asks for standard mode or says “without genereg”. It supports either source-figure or text-to-figure input without the retained template reference.
- **Simplified mode:** use only when the user explicitly asks for simplified, without detailed, or a deliberately schematic-only figure. Otherwise use `detailed` automatically with default `genereg`.

For text-to-figure mode, identify: canvas orientation, panels (if any), entities, required labels, directional relationships, and reading order. If an essential scientific relationship, exact label, or layout choice is absent, ask one concise question. Otherwise make the simplest defensible composition; do not invent mechanisms or entities merely to fill space.

In `ref` mode, extract the same scientific brief but do not preserve the source layout unless the user independently states a layout requirement in words. Derive the new layout, hierarchy, palette, and object rendering entirely from this skill and its bundled reference.

## Default `genereg` mode

Use the bundled genereg reference as an additional visual reference without changing it:

1. Resolve `assets/genereg-reference.png` relative to this skill directory. It is bundled with `book-figure` and must travel with the skill.
2. Supply that PNG to `image_gen` as a style-only reference. If a source figure exists, supply it as the content/edit target; otherwise generate from the user's text-derived panel plan.
3. Preserve the bundled reference's minimalist 2D editorial hierarchy: warm paper treatment, modular composition, flat pastel fills, fine slate-blue contours, one restrained highlight per object, sparse double-membrane boundaries, and clean typography. Combine these with the Book Figure semantic palette and biological-object treatment below.
4. Do not modify, move, overwrite, or present the bundled PNG as the finished figure. The user-provided facts determine content; the bundled reference determines visual language only.

## `ref` mode — source as facts only

Use this mode when visual independence from a supplied source is required.

1. Inspect the source with `view_image` and transcribe its readable labels, entities, topology, arrow directions, causal relationships, and necessary state changes. Do not copy its visual style or layout.
2. Convert the extraction into a standalone text-to-figure panel plan. Use only the user's stated scientific elements and labels; derive orientation, panel geometry, placement, typography, color, and molecular forms from the Book Figure grammar.
3. Pass **only** `assets/genereg-reference.png` to `image_gen` as a reference image. Do **not** pass the user source as an input, edit target, style reference, compositional reference, or second image.
4. State this constraint explicitly in the prompt. Treat any source-specific visual feature as prohibited unless the user explicitly repeats it as a scientific requirement in text.

Required `ref` generation hand-off:

```text
Scientific brief: [the extracted facts, labels, and relationships in words]
Input images passed to image_gen: [book-figure/assets/genereg-reference.png only]
```

The source path must not appear in the `image_gen` image list. Its extracted content belongs only in `Scientific brief`.

Use this prompt line in `ref` mode:

```text
Mode: ref. The supplied figure is a facts-only source: use it solely to recover the stated biology, labels, and relationships. Do not use, imitate, or infer its visual design, layout, palette, typography, object shapes, or composition. Generate from the extracted text brief using only the bundled Book Figure reference for visual language. Input images passed to image_gen: bundled Book Figure reference only.
```

Use this prompt line by default:

```text
Mode: genereg. Use the bundled minimalist antiviral-RNA schematic as the primary style-only reference; preserve its flat 2D editorial visual language while applying the Book Figure palette and biological-object grammar.
```

## Default `detailed` mode

Use this mode by default so molecular structures have scientific specificity while retaining the minimalist editorial 2D style. Treat any user-provided detailed reference figure as style-only unless the user also names it as a content source. Omit this layer only in explicit simplified mode.

- **RNA and DNA:** draw base-paired duplexes with two distinct strands, evenly spaced base-pair rungs, and plausible hairpin loops, bulges, stems, single-stranded overhangs, or circular topology only when factually required. At gene scale, use a clear DNA double helix or genomic track with directed gene arrows, promoter blocks, and transcription machinery; do not replace all nucleic acid with generic wavy lines.
- **Proteins and complexes:** use compact, asymmetric 2D domain silhouettes, modest subunit boundaries, binding grooves, RNA-binding channels, or catalytic notches when supported by the brief. Use flat pastel fill, a thin dark outline, and one restrained white or pale highlight; no 3D molecular surface, glossy mascot-like face, or amorphous balloon form.
- **Motifs, genes, and regulatory modules:** distinguish motifs with short sequence/rung segments, recognition sites, and compact brackets. Draw promoters, enhancers, silencers, insulators, coding regions, and terminators as proportionate ordered elements on a DNA track; retain labels and directional arrows. Encode interaction with contact, alignment, or a clear connector—not proximity alone.
- **Compartments and pathways:** use a clean thin double membrane arc or rounded boundary, one lightly tinted interior, and only essential pores or markers. Make process arrows terminate at the relevant molecular surface or module; use structured subpanels rather than decorative background shapes.
- **Restraint:** do not add atomic structures, residues, 3D ribbon proteins, electron-microscopy texture, or molecular components that the user did not supply. Detailed means more precise schematic convention, not more invented biology.

Add this prompt line in `detailed` mode:

```text
Mode: detailed. Retain the Book Figure minimalist 2D palette and rendering, but render nucleic acids, proteins, motifs, genes, regulatory modules, and compartment boundaries as precise scientific schematic objects with credible structural cues; avoid cartoon-like blobs, 3D surface texture, and generic clip-art.
```

## Workflow

1. In source-figure mode, inspect the source with `view_image`. Extract every panel, label, arrow direction, grouping bracket, entity, and relationship. Transcribe all text verbatim; never paraphrase a source label. If any text is unreadable, ask for a higher-resolution source or the exact text—never infer it. In `ref` mode, extract only the science, labels, and relationships, then create a new panel plan without retaining the source's visual decisions. In text-to-figure mode, turn the supplied description into a concise panel plan and list its exact requested text.
2. Use the built-in `image_gen` tool. In source-figure mode, treat the source as the **content/edit target**. In `ref` mode, generate from the extracted panel plan; the `image_gen` reference-image list must contain exactly one path: `assets/genereg-reference.png`. Put all source-derived material into the text prompt's `Scientific brief`, never into the image list. In text-to-figure mode, generate from the panel plan. By default, provide the bundled reference as a style-only reference and include the detailed-mode prompt line. If provided, use the user's detailed reference as a style-only reference, except in `ref` mode where no user source or reference may influence the design. Omit the bundled reference only in explicit standard mode; omit detailed conventions only in explicit simplified mode. Treat this specification and any prior approved book-figure examples as style references only.
3. State in the prompt that the output must retain all supplied facts and requested text exactly; do not add mechanisms, molecules, panels, legends, or decorative claims.
4. Add a compact role-to-color map for every biological entity using `references/semantic-colors.md`. Repeated entities must keep identical assignments across panels.
5. Generate a new PNG; never overwrite the source. Inspect the result for semantic order, label spelling, cropped features, arrow direction, palette consistency, and token compliance. Iterate once if a defect affects meaning or legibility.
6. Save the selected version as a sibling or in `outputs/`, then report its path, built-in generation mode, and Book Figure version from `VERSION`.

## Editorial visual grammar

### Canvas, layout, and typography

- Apply the exact baseline, scaling, spacing, typography, stroke, arrow, radius, and highlight tokens in `references/design-tokens.md`.
- Use a warm ivory paper field, airy modular panels, generous negative space, and the documented 8 px spacing grid.
- Use Noto Serif for English and Bulgarian text and Noto Sans Mono only for displayed nucleotide sequences, exactly as defined in the token reference.
- Avoid pure black, hard card fills, undersized labels, and ad hoc line weights.

### Palette

Use the role assignments and precedence rules in `references/semantic-colors.md`. DNA, RNA polarity, protein roles, regulatory modules, and compartments each have a stable fill/outline pair. Preserve entity colors across panels; encode state with connectors, inhibition bars, cleavage, fragmentation, saturation, or opacity. Do not use neon, glossy gradients, texture, 3D molecular surfaces, or unrelated rainbow colors.

### Biological-object treatment

- **RNA and DNA:** use clean 2D paths with a thin dark outline and flat pastel fill. Show a single strand as one fine curve; show a duplex as two crisp parallel strands with evenly spaced rungs. Circular RNA is a precise closed ring. Use only a slight organic curvature, never a fuzzy or textured molecular surface.
- **Cleavage sites and motifs:** use small crisp cut marks, compact structured hairpins, or tiny rounded modules on the strand. Use a darker edge and one pale highlight only when it improves legibility.
- **Proteins / transcription factors / enzymes:** use compact asymmetric 2D domain silhouettes, flat pastel fills, a narrow outline, and one small pale highlight. Labels sit centered inside or directly below without covering the interaction surface. Do not use volume rendering, grain, surface bumps, or heavy shadow.
- **Genes and regulatory elements:** use clean DNA tracks, rounded rectangles, or gently tapered arrows. Keep promoter modules compact and visibly ordered. Encode identity primarily by labeled position, then color—not color alone.
- **Membranes, cell compartments, and plant tissues:** use a pale desaturated flat fill bounded by one or two thin contours. Add only factual internal features; favor a simple cross-section or partial membrane arc over texture.
- **Connections and loops:** use single thin slate-blue curves with open spacing. Regulatory loops must terminate clearly at the controlled element.

## Prompt contract

Use a concise structured prompt containing:

```text
Use case: scientific-educational
Asset type: editorial textbook/review-article schematic
Input images: source = content/edit target (source-figure mode only); in ref mode = bundled `assets/genereg-reference.png` only; bundled genereg reference and prior approved redraws = style only
Primary request: redraw [figure] while retaining [panels, entities, causal order], OR create [panel plan] from text.
Text (verbatim): "[all source labels confirmed at readable resolution, or all labels supplied by the user]"
Style/medium: follow the Book Figure minimalist 2D editorial visual grammar.
Typography: Noto Serif for all visible English and Bulgarian text, including panel letters, headings, labels, RNA/DNA polarity marks, and annotations; use consistent weight and spacing across scripts. Use Noto Sans Mono only for nucleotide sequences and sequence-only motif strings, including their 5′/3′ end markers and hyphens.
Design system: apply the exact current tokens from `references/design-tokens.md`, scaled proportionally from the 1600 × 900 px baseline.
Semantic colors: list every depicted entity and its exact role-based fill/outline assignment from `references/semantic-colors.md`; keep repeated entities identical across panels.
Constraints: preserve facts, labels, arrows, grouping, and reading order; create a new version.
Avoid: extra scientific claims, invented objects, neon, photorealism, watermark, logo.
```

## Quality gate

Before handing off, confirm:

- All labels, panel letters, and DNA/RNA polarity signs are legible and spelled correctly; every text string has been copied from a readable source or supplied verbatim by the user.
- Every visible English and Bulgarian text element uses Noto Serif consistently, unless the user explicitly requested another typeface; nucleotide sequences and sequence-only motif strings use Noto Sans Mono, including their 5′/3′ end markers and hyphens.
- Canvas, margins, gaps, line weights, arrowheads, radii, highlights, and type sizes follow `references/design-tokens.md` without ad hoc substitutions.
- Every supplied relationship remains: arrows, loop direction, brackets, stage order, groups, and the requested reading order.
- Colors follow `references/semantic-colors.md`; repeated entities keep the same fill and outline across panels, and state is not communicated by recoloring identity.
- Biological objects use clean minimalist 2D contours, flat pastel fills, thin slate outlines, and at most one subtle highlight; no 3D molecular texture or heavy shadow.
- In `detailed` mode, nucleic-acid topology, protein interaction surfaces, gene-module order, and compartment boundaries use the requested precise schematic cues without invented molecular details.
- In `ref` mode, the generated image was based only on the extracted scientific brief and the bundled Book Figure reference; the user source was not passed to generation and contributed no visual design.
- The source is intact when one was supplied, and the result has a distinct output path.

## Common mistakes

- Do not simplify away a source label, bracket, motif, cut marker, or panel merely to make the composition cleaner.
- Do not add plausible-looking molecules or mechanisms to fill empty space.
- Do not render long text in tiny type; rebalance the layout instead.
- Do not mix sans-serif labels with Noto Serif headings, or substitute a Latin-only face for Bulgarian labels; use Noto Serif consistently for both scripts. The only default exception is Noto Sans Mono for the nucleotide characters and punctuation within a displayed sequence.
- Do not rely on color alone for scientific meaning; pair it with labels, position, or shape.
- Do not use `detailed` mode to turn every protein into a 3D render or every RNA into a decorative coil; retain only the structural features needed for the stated biology and keep the default minimalist 2D treatment.
- Do not pass a user source to `image_gen` in `ref` mode, even as a content/edit target or secondary reference; this violates the facts-only contract.
