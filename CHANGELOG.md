# Changelog

## 1.4.0 — 2026-07-29

- Added two immutable user-provided visual-atlas panels for microbiology laboratory workflows and NGS/metagenomics workflows.
- Indexed 50 new references: culture and handling equipment, microbial cells and envelopes, sequencing-library preparation, sequencing instruments, and analysis visual forms.
- Added exact aliases and category fallbacks for microbiology, laboratory equipment, sequencing, and data-visualization requests.
- Bumped the compatible atlas content version to 1.1.0.

## 1.3.0 — 2026-07-28

- Added a visual biological-object atlas with five immutable reference panels and 136 indexed biological forms, complexes, processes, compartments, and plant structures.
- Added stable semantic IDs, curated aliases, scientific/reference statuses, normalized crop bounds, interaction tags, and duplicate printed-ID handling.
- Added dependency-free PNG crop and montage generation plus exact, composite, alias, and missing-object fallback selection.
- Added `atlas-debug` for selection reports and ImageGen reference montages without consuming a generation request.
- Replaced the rejected canonical SVG pilot with atlas-first ImageGen guidance.
- Updated the README with corrected miRNA-biogenesis and causal-SNP source-redraw examples.

## 1.2.1 — 2026-07-28

- Required pure black `#000000` for every visible text glyph, including Inter labels and Roboto Mono nucleotide sequences.
- Reserved slate blue `#203B57` for non-text outlines, arrows, connectors, cleavage marks, and other process linework.
- Bumped the design-token contract to v1.2.0 and the semantic-color contract to v1.1.0.
- Added validator and contract-fixture checks for the visible-text color.

## 1.2.0 — 2026-07-28

- Changed the default figure typeface from Noto Serif to Inter for all ordinary English and Bulgarian text.
- Changed the nucleotide-sequence typeface from Noto Sans Mono to Roboto Mono.
- Bumped the design-token contract to v1.1.0.
- Added validator and contract-fixture checks for the typography assignments.

## 1.1.0 — 2026-07-28

- Added authoritative geometry, spacing, typography, arrow, and highlight tokens.
- Added a semantic color system with stable biological-role assignments.
- Added semantic versioning through `book-figure/VERSION`.
- Added contract fixtures and a dependency-free package validator.
- Documented the maintainable repository structure and release workflow.

## 1.0.0

- Initial `book-figure` release with `genereg`, `detailed`, `ref`, `standard`, and `simplified` modes.
- Added the bundled full-resolution editorial reference.
- Added Noto Serif labels and Noto Sans Mono nucleotide sequences.
