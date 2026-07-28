---
name: book-figure
description: Use when redrawing or creating biology, molecular-biology, genomics, plant, viroid, RNA-silencing, chromatin, or regulatory schematics from an image or written scientific description, including requests for genereg, detailed, ref, or atlas-debug mode.
---

# Book Figure

Create a new non-destructive editorial scientific figure in the shared Book Figure style. Use the bundled visual atlas to give ImageGen direct biological-form and molecular-contact references without copying the atlas panels, captions, grid, or printed identifiers.

## Required references

Before planning, debugging, or generating a figure, read completely:

1. `references/design-tokens.md` — canvas, spacing, typography, line, arrow, radius, and scaling contracts.
2. `references/semantic-colors.md` — stable biological-role colors and state encoding.
3. `references/object-atlas.md` — atlas selection, montage, fallback, upgrade, and QA contracts.

The reference files are authoritative. If this summary conflicts with them, the references win.

## Defaults

Use **visual atlas + `genereg` + `detailed`** by default.

- **Visual atlas:** select biological objects or complexes from `atlas/manifest.yml`; build a bounded object-only montage for ImageGen.
- **`genereg`:** use `assets/genereg-reference.png` as the global editorial style reference.
- **`detailed`:** render credible nucleic-acid topology, multidomain proteins, molecular contacts, regulatory elements, and compartments.

Use standard or simplified behavior only when explicitly requested.

## Input modes

### Source-figure mode

Use when the user supplies a figure and wants a redraw. Extract every readable label, entity, arrow, state, panel, and relationship. Preserve scientific content and requested reading order. The user source may be passed as the content/edit target together with the atlas montage and global style reference.

### Text-to-figure mode

Use when the user supplies a description, caption, list, or pathway. Convert it into a concise scientific brief with orientation, panels, exact labels, entities, relationships, and reading order. Do not require a source image.

### `ref` mode

Use when the user says the source should provide facts only, asks not to use its design, or explicitly requests `ref`.

1. Inspect the source and extract its scientific brief.
2. Do not pass the user source to ImageGen.
3. Pass only the selected atlas montage and `assets/genereg-reference.png`.
4. Derive layout, palette, object form, and typography from Book Figure.

Required prompt line:

```text
Mode: ref. The supplied source was used only to extract scientific facts, labels, entities, states, and relationships. It was not passed to image generation and must not influence layout, palette, typography, object shapes, or composition.
```

### `atlas-debug` mode

Use when the user wants to inspect reference selection before consuming an ImageGen request.

Run:

```bash
ruby scripts/atlas_debug.rb \
  --root atlas \
  --entities "comma-separated biological entities" \
  --output-dir /absolute/output/path
```

Return:

- `atlas-selection-report.yml`;
- `atlas-reference-montage.png`.

Do not call ImageGen in `atlas-debug` mode.

## Atlas workflow

1. Extract the requested biological entities and interactions.
2. Run atlas selection by stable ID, exact name, alias, composite, then category fallback.
3. Prefer exact complexes over disconnected component-only references.
4. Use only `reviewed`, `verified`, or `visual-only` references; the last category guides appearance but never overrides scientific anatomy.
5. Build one montage with no more than eight object-only crops.
6. Do not include the source captions or printed `Bio-###` values.
7. If an object is missing, select up to two same-category forms and one related interaction example.
8. Describe the missing object's required anatomy in the prompt and ask ImageGen to draw a new object in the shared style.
9. After generation, inspect the output against the selected objects' scientific identities and interaction geometry.

Required atlas prompt line:

```text
Visual atlas: use the supplied atlas montage only as a biological-form, molecular-contact, palette, and rendering reference. Redraw the requested entities in the Book Figure composition. Do not reproduce the atlas grid, Bio identifiers, captions, typography, or unrelated objects.
```

## Visual hierarchy

The atlas controls:

- biological-object silhouettes;
- protein domain modeling;
- nucleic-acid construction;
- molecular contact and overlap;
- organelle and membrane appearance;
- pastel object palette, restrained highlight, and basal shade.

Book Figure controls:

- requested scientific content;
- labels and terminology;
- canvas, panels, spacing, and reading order;
- arrows, inhibition, cleavage, and state transitions;
- Inter and Roboto Mono typography;
- visible text color;
- source/ref mode behavior.

The user brief wins over an atlas panel when scientific content conflicts. The atlas is a visual reference, not scientific evidence.

## Detailed biological rendering

### RNA and DNA

- Draw every duplex with two continuous backbones.
- Make every base-pair rung touch both backbones.
- Show credible loops, internal loops, bulges, mismatches, and overhangs only when appropriate.
- Keep circular molecules fully closed.
- Add 5′/3′ polarity when it carries scientific meaning.
- Use a clear double helix or genomic track at gene scale.

### Proteins and complexes

- Use compact asymmetric multidomain silhouettes.
- Show a binding groove, catalytic cleft, channel, or docking face when the mechanism requires contact.
- Make RNA/DNA visibly pass through or occupy the interaction surface.
- Use related but distinguishable subunit tones.
- Do not use single featureless blobs, Pac-Man shapes, mascot forms, or photorealistic surfaces.

### Genes and regulation

- Keep promoter, enhancer, silencer, insulator, motif, gene body, and terminator ordered on a continuous DNA track.
- Make loops terminate exactly at the controlled element.
- Attach motifs to the parent nucleic acid.
- Use contact or a connector to assert interaction; proximity alone is insufficient.

### Compartments

- Use plausible double membranes and integrated pores.
- Make transport arrows cross an open pore or transporter.
- Use partial membrane arcs when they communicate the compartment more clearly than a rounded panel.
- Add only factual internal structures.

## Typography and semantic colors

- Use Inter for every ordinary English or Bulgarian label, heading, panel letter, annotation, and external polarity marker.
- Use Roboto Mono only for displayed nucleotide sequences and sequence-only motifs.
- Apply the current visible-text color in `references/design-tokens.md`.
- Use exact semantic colors from `references/semantic-colors.md`.
- Keep the same entity color in every panel and encode state with arrows, inhibition bars, cleavage, fragmentation, occupancy, or opacity.

## ImageGen hand-off

Use a structured prompt:

```text
Use case: scientific-educational
Asset type: editorial textbook/review-article schematic
Mode: [source-figure | text-to-figure | ref], visual atlas + genereg + detailed
Scientific brief: [exact entities, labels, states, relationships, panels, and reading order]
Input images: [user source only when allowed] + selected atlas montage + bundled genereg reference
Visual atlas: use the montage only for biological form, contact, palette, and rendering; do not copy its grid, captions, Bio IDs, typography, or unrelated objects.
Typography: Inter for ordinary text; Roboto Mono only for nucleotide sequences; use the current Book Figure text-color contract.
Design system: apply the current exact tokens from references/design-tokens.md.
Semantic colors: list every entity and its role assignment from references/semantic-colors.md.
Constraints: preserve all supplied facts and exact requested text; add no mechanism, molecule, panel, or legend not requested.
```

Generate a new PNG and never overwrite the source or an atlas panel.

## Quality gate

Before delivery, confirm:

- all exact labels and polarity marks are readable;
- no source caption, atlas caption, `Bio-###`, or atlas grid leaked into the output;
- selected objects are recognizable in the requested context;
- DNA/RNA strands are continuous and paired rungs contact both backbones;
- protein binding, cleavage, loading, and transport use real contact geometry;
- arrows terminate at the correct object or interaction surface;
- repeated entities keep the same form family and colors;
- typography and semantic colors follow the authoritative references;
- `ref` mode did not pass the user source to ImageGen;
- the source and all atlas panels remain unchanged;
- the result has a distinct output path.

## Common mistakes

- Do not pass an entire atlas panel when a bounded montage is available.
- Do not reproduce atlas captions, grid positions, or Bio IDs.
- Do not treat visual-only references as scientific proof.
- Do not select generic AGO plus free RNA when an exact AGO–RNA complex exists.
- Do not invent a missing object's mechanism merely because a same-category form was selected.
- Do not omit a readable source label, motif, bracket, arrow, or state.
- Do not shrink labels below the documented minimum; rebalance the layout.
