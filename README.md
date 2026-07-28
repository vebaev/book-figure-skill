# Book Figure

`book-figure` is a reusable Codex skill for redrawing or creating biology, molecular-biology, genomics, plant, and regulatory schematics in one consistent minimalist editorial style.

Current version: **1.1.0**

## Install

Copy the `book-figure` folder into your Codex skills directory:

```bash
cp -R book-figure ~/.codex/skills/
```

Then invoke it in a request with `$book-figure`.

## Use

### Redraw a supplied figure

```text
$book-figure redraw this figure
```

The source provides the panels, labels, entities, relationships, and reading order. By default, the result uses `genereg + detailed` rendering.

### Create a new figure from text

```text
$book-figure create detailed style showing canonical animal miRNA biogenesis—miRNA gene → RNA polymerase II → pri-miRNA → Drosha → pre-miRNA inside a pore-containing double-membrane nucleus, followed by export through a nuclear pore → cytoplasmic Dicer → mature miRNA → a single AGO-containing RISC bound to target RNA
```

![Book Figure example: canonical animal miRNA biogenesis](docs/images/miRNA-biogenesis.png)

Provide the intended entities, exact labels, relationships, and panel order. The skill builds the layout from the description.

## Modes

| Mode | When to use it | Result |
| --- | --- | --- |
| `genereg` | Default | Uses the bundled reference image as the visual language: warm ivory background, flat pastel fills, fine slate-blue outlines, and airy editorial layout. |
| `detailed` | Default | Adds scientifically precise 2D conventions for RNA/DNA, proteins, genes, motifs, modules, and compartments without 3D or cartoon rendering. |
| `ref` | When the source must provide facts only | Inspects the supplied figure for scientific content and labels, but does not use its visual design. Only the bundled reference is passed to image generation. |
| `standard` | Only on explicit request | Generates without the bundled `genereg` reference. |
| `simplified` | Only on explicit request | Uses a less structurally detailed schematic treatment. |

Modes can be requested in plain language, for example: `use ref mode` or `without detailed`.

## Typography

- Use **Noto Serif** for headings, labels, annotations, panel letters, and English or Bulgarian text.
- Use **Noto Sans Mono** only for displayed nucleotide sequences and sequence-only motifs, including their nucleotide letters, hyphens, and 5′/3′ markers.

## Included asset

`book-figure/assets/genereg-reference.png` is the bundled style-only reference. Keep it with the skill when copying, packaging, or installing it.

## Design system and maintenance

- `book-figure/references/design-tokens.md` defines the authoritative geometry and typography.
- `book-figure/references/semantic-colors.md` defines stable biological-role color assignments.
- `book-figure/tests/contract-cases.yml` contains representative consistency cases.
- `book-figure/scripts/validate_skill.rb` checks package integrity without external dependencies.
- `book-figure/VERSION` follows semantic versioning.
- `CHANGELOG.md` records user-visible releases.

Validate the package before publishing:

```bash
ruby book-figure/scripts/validate_skill.rb
```

When changing a design token or semantic role, update the relevant reference, bump `VERSION`, add a changelog entry, run the validator, and forward-test at least one contract case.
