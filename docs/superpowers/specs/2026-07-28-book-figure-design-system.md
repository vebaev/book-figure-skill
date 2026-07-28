# Book Figure Design System Specification

## Goal

Make figures produced across one textbook visually compatible by enforcing one versioned token system, one semantic color vocabulary, and one maintainable skill package.

## Scope

This revision implements:

1. Authoritative design tokens for canvas, spacing, typography, strokes, arrows, radii, highlights, and export scale.
2. Authoritative semantic colors for nucleic acids, proteins, regulatory elements, compartments, and process states.
3. Sustainable packaging with versioning, validation, contract fixtures, release notes, and progressive-disclosure references.

It does not add a vector renderer, object library, layout engine, or automated image comparison.

## Architecture

- `SKILL.md` remains the short operating workflow.
- `references/design-tokens.md` is the single source of truth for geometry and typography.
- `references/semantic-colors.md` is the single source of truth for color-role assignments.
- `tests/contract-cases.yml` defines representative scientific briefs and expected semantic roles.
- `scripts/validate_skill.rb` validates package structure and stable design contracts without external dependencies.
- `VERSION` follows semantic versioning; repository-level `CHANGELOG.md` records releases.

## Compatibility rules

- Existing modes remain: default `genereg + detailed`, plus `ref`, `standard`, and `simplified`.
- Inter is the default family for labels and all ordinary English or Bulgarian text.
- Roboto Mono is limited to displayed nucleotide sequences and sequence-only motifs.
- Every visible text glyph is pure black `#000000`; slate blue `#203B57` remains reserved for outlines, arrows, and connectors.
- The bundled full-resolution `assets/genereg-reference.png` remains mandatory.
- Exact numerical tokens scale proportionally for non-baseline canvas sizes.

## Success criteria

- Independent agents derive the same palette and geometry values from the skill.
- The validator detects missing references, an undersized/corrupt reference image, stale metadata, invalid versioning, and missing contract cases.
- Future design-system changes require a version bump and changelog entry.
