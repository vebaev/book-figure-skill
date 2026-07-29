# Book Figure visual biological-object atlas

Atlas version: 1.1.0

The atlas gives ImageGen direct references for biological form, contact, palette, and rendering. It never supplies final layout, captions, identifiers, typography, or scientific authority.

## Assets

- `atlas/manifest.yml` registers seven immutable panels.
- `atlas/panels/*.yml` indexes 186 visual references, including microbiology laboratory, microbial-form, NGS, and metagenomics forms.
- `assets/object-atlas/panels/` contains the unchanged originals.
- `assets/object-atlas/crops/` contains rebuildable object-only references.
- `scripts/atlas_debug.rb` explains selection without calling ImageGen.

Printed `Bio-###` values are non-unique source annotations. Selection uses stable semantic IDs, names, aliases, categories, and interaction tags.

## Selection order

1. Stable semantic object ID.
2. Exact preferred name.
3. Curated alias.
4. Exact composite or interaction.
5. Same-category and interaction fallback.

Prefer a bound complex over disconnected component references. Exact object and interaction references are limited to the eight most useful crops.

## Scientific status

| Status | Automatic use |
| --- | --- |
| `verified` | Form and scientific anatomy |
| `reviewed` | Form and reviewed context |
| `visual-only` | Style/form guidance; user brief controls anatomy |
| `unreviewed` | Excluded automatically |
| `deprecated` | Excluded automatically |

## Debugging selection

```bash
ruby scripts/atlas_debug.rb \
  --root atlas \
  --entities "pri-miRNA,Dicer,AGO-containing RISC,target mRNA,DNA helicase" \
  --output-dir /absolute/output/path
```

The report records `exact`, `composite`, or `fallback` for each query. The montage contains no captions or printed identifiers.

## Missing objects

For a missing object:

- select two same-category form references;
- add one reference with related molecular-contact geometry;
- state the required scientific anatomy in words;
- request an original object in the shared atlas and Book Figure style;
- do not merge the exemplar identities or invent a mechanism.

## Adding a panel

1. Add the original image under a new stable filename.
2. Record checksum, dimensions, provenance, and a new immutable panel ID.
3. Add semantic IDs, aliases, categories, normalized object/tile boxes, tags, roles, and scientific status.
4. Rebuild crops.
5. Run atlas, selection, rendering, and package tests.
6. Increment atlas minor version for compatible new content.

Corrected panels receive a new version. Never replace an existing original silently.

## Validation

```bash
ruby scripts/validate_atlas.rb --root atlas
ruby scripts/build_atlas_crops.rb --root atlas --output-dir assets/object-atlas/crops
ruby tests/test_atlas_foundation.rb
ruby tests/test_atlas_rendering.rb
ruby tests/test_atlas_selection.rb
```

The validator checks panel hashes and dimensions, unique stable reference IDs, normalized bounds, categories, roles, statuses, and duplicate printed-ID reporting.
