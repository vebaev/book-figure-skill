# Book Figure visual biological-object atlas

Date: 2026-07-28
Status: approved architecture, awaiting written-spec review
Scope: replace the uncommitted SVG and text-card pilots with a versioned visual-reference atlas built from five user-supplied biological-object panels

## 1. Goal

Book Figure will use a visual atlas of biological-object panels as a direct ImageGen reference system.

When a requested figure contains an object present in the atlas, the skill will select and supply the corresponding visual reference. When an object is absent, the skill will select the nearest references from the same biological and interaction class and ask ImageGen to construct the missing object in the shared atlas and Book Figure style.

The atlas must be:

- scientifically controlled;
- visually consistent;
- searchable by biological name and synonym;
- independent of duplicated or incorrect printed `Bio-###` labels;
- upgradeable by adding new panels without rewriting the core skill;
- portable with the `book-figure` package;
- usable in source-figure, text-to-figure, `ref`, `genereg`, and `detailed` workflows.

## 2. Why a visual atlas

The five supplied panels contain a broad, coherent visual vocabulary: nucleic acids, viruses, enzymes, RNA-silencing complexes, chromatin, regulatory proteins, organelles, membranes, plant structures, viroid biology, transport, symptoms, and gene-regulatory mechanisms.

They provide richer and more biologically plausible shapes than the rejected geometric SVG pilot. They also give ImageGen direct examples of:

- protein silhouette and domain modeling;
- RNA/DNA topology;
- molecular binding and overlap;
- organelle and membrane rendering;
- highlights, shading, outlines, and palette;
- the intended degree of textbook simplification.

The panels are visual references, not scientific authorities. Their labels, IDs, and depicted mechanisms must be indexed and reviewed rather than copied blindly.

## 3. Selected architecture

Use **full immutable panels + indexed regions + rebuildable object crops + one runtime reference montage**.

### Stored assets

The package stores:

1. the five original PNG panels, byte-for-byte unchanged;
2. a versioned manifest describing each panel and each visible object;
3. rebuildable object-only crops derived from manifest coordinates;
4. a global Book Figure style reference;
5. scripts for validation, crop rebuilding, selection, and montage generation.

The crops are visual references only. They are not canonical drawings to be pasted or composed into finished figures.

### Runtime behavior

For each figure request:

1. extract the scientific entities and relationships;
2. match requested entities to stable atlas object IDs or aliases;
3. prioritize an exact interaction/complex reference over separate component references;
4. create one temporary montage containing only the most relevant crops;
5. supply the montage and global style reference to ImageGen;
6. supply a user source image only when the active mode allows it;
7. instruct ImageGen to redraw the requested science rather than reproduce the panel grid, captions, or `Bio-###` labels.

## 4. Panel inventory

The initial atlas contains five user-supplied panels.

| Stable panel ID | Stored filename | Dimensions | Primary content |
| --- | --- | --- | --- |
| `atlas.mirna-silencing.001` | `panel-001-mirna-silencing.png` | 1024 × 1024 | pri-/pre-miRNA, Dicer, AGO/miRISC/piRISC, target RNA, silencing, chromatin AGO, exosome |
| `atlas.plant-cell.001` | `panel-002-plant-cell-structures.png` | 1024 × 1024 | plant cell wall, membranes, plasmodesma, nucleus, chloroplast, organelles, cytoskeleton |
| `atlas.gene-regulation.001` | `panel-003-chromatin-gene-regulation.png` | 1024 × 1024 | nucleosomes, chromatin, promoters, regulators, Mediator, HAT/HDAC, DNMT, splicing, polymerases |
| `atlas.virus-rnai.001` | `panel-004-virus-rnai-core.png` | 1024 × 1024 | virus forms, ss/ds nucleic acids, methylation, RDR, Dicer, HEN1, AGO, RISC, RdDM |
| `atlas.viroid-biology.001` | `panel-005-viroid-biology.png` | 2048 × 2048 | viroid structures, replication, transport, silencing, plant symptoms, transmission, evolution |

The five files total approximately 12.3 MB before derived crops.

### Provenance record

Each panel record stores:

- original source filename;
- stable stored filename;
- SHA-256 checksum;
- pixel dimensions;
- date added;
- source type: `user-provided`;
- creation note: `Gemini-generated image supplied by the user`;
- authorization note: `user requested storage inside book-figure`;
- panel version and lifecycle status.

Original panels are never overwritten. A corrected panel becomes a new panel version.

## 5. Stable object identity

Printed `Bio-###` values are retained only as source annotations. They are not unique identifiers because several panels reuse the same printed number for different objects.

Examples of duplicated printed values include `Bio-003`, `Bio-004`, `Bio-007`, `Bio-008`, `Bio-010`, `Bio-011`, `Bio-027`, `Bio-028`, `Bio-031`, `Bio-033`, `Bio-037`, `Bio-053`, `Bio-054`, `Bio-055`, and `Bio-056`.

Every indexed object receives a unique semantic ID, for example:

- `rna.pri-mirna`;
- `rna.pre-mirna`;
- `rna.sirna-duplex`;
- `protein.dicer`;
- `protein.drosha-dgcr8`;
- `protein.argonaute`;
- `complex.mirisc`;
- `complex.rdrm`;
- `chromatin.nucleosome`;
- `compartment.nucleus`;
- `organelle.chloroplast`;
- `membrane.plasma`;
- `plant.symptom.leaf-curling`;
- `virus.capsid.icosahedral`;
- `viroid.circular-rna`.

Stable IDs are immutable. A later improved visual example is registered as another reference for the same object ID.

## 6. Atlas manifest

The authoritative manifest is YAML.

```yaml
atlas_version: 1.0.0
panels:
  - panel_id: atlas.mirna-silencing.001
    file: assets/object-atlas/panels/panel-001-mirna-silencing.png
    sha256: ...
    width: 1024
    height: 1024
    status: active
    objects:
      - object_id: protein.dicer
        printed_id: Bio-077
        printed_label: Cytoplasmic Dicer complex
        aliases: [Dicer, DCL, Dicer-like]
        category: protein
        scientific_status: needs-review
        reference_role: primary-form
        object_bbox: [0.05, 0.22, 0.19, 0.14]
        tile_bbox: [0.02, 0.20, 0.25, 0.22]
        interaction_tags: [rna-processing, duplex-cleavage]
        visual_tags: [lavender, multidomain, upper-left-highlight]
        notes: Protein form reference only; use the requested species/context.
```

### Coordinate conventions

- bounding boxes use normalized `[x, y, width, height]` values from 0 to 1;
- `object_bbox` contains the biological drawing only;
- `tile_bbox` contains the object plus its original printed caption for human review;
- runtime ImageGen crops use `object_bbox` with 4–8% visual padding;
- source captions and Bio numbers are excluded from runtime references.

### Required object fields

- stable object ID;
- printed ID and printed label;
- aliases;
- panel and bounding boxes;
- biological category;
- interaction tags;
- visual tags;
- reference role;
- scientific-review status;
- notes describing limitations or contextual use.

## 7. Reference roles and scientific status

### Reference roles

- `primary-form`: preferred example for the object's shape and rendering;
- `secondary-form`: acceptable variation or another state;
- `interaction`: preferred example of binding, cleavage, transport, or assembly;
- `style-only`: useful for palette or rendering but not anatomy;
- `avoid`: indexed for completeness but excluded from automatic selection.

### Scientific status

- `unreviewed`: transcription/indexing complete but biology not checked;
- `visual-only`: may guide style but not scientific anatomy;
- `reviewed`: anatomy and label reviewed;
- `verified`: suitable as the primary scientific and visual reference;
- `deprecated`: retained for history but never selected automatically.

Initial objects are `unreviewed` or `visual-only`. The references may influence appearance immediately, but unreviewed labels and mechanisms must not override the user brief or established biology.

## 8. Selection strategy

### Exact match

Match in this order:

1. stable object ID;
2. exact normalized name;
3. curated alias;
4. interaction tag plus category;
5. nearest visual exemplar in the same category.

Ambiguous aliases require context from the scientific brief. For example, `DCL` may map to a Dicer-like plant enzyme, while `Dicer` may use the general Dicer reference.

### Composite preference

When an exact composite exists, prefer it over separate parts:

- `complex.mirisc` before generic AGO plus free duplex;
- `complex.rdrm` before polymerase plus AGO plus DNA;
- `complex.drosha-dgcr8-pri-mirna` before separate Drosha and pri-miRNA;
- `complex.transcription-elongation` before generic polymerase and DNA.

This preserves credible molecular contact.

### Missing-object fallback

If an object is absent:

1. use the global Book Figure style reference;
2. select up to two references from the closest biological class;
3. select one reference with the closest interaction geometry;
4. describe the missing object's required scientific anatomy in the prompt;
5. explicitly state that the result is a new object in the same style, not a copy or hybrid of the exemplars.

Example: a missing helicase may use one multidomain processing enzyme reference, one nucleic-acid-binding complex reference, and the global style reference.

## 9. Runtime montage

Passing an entire panel for every request introduces irrelevant objects and captions. The selector therefore builds one temporary montage.

### Montage rules

- include exact requested objects first;
- include exact complexes before isolated components;
- include at most eight object crops;
- if more than eight requested entities are present, keep all unusual objects and reduce repeated/common categories to one exemplar;
- arrange crops on warm paper without captions or `Bio-###` text;
- use consistent padding and no additional decoration;
- preserve original crop pixels without repainting;
- destroy or overwrite only the temporary montage, never the source panels.

The prompt includes a text mapping of the montage order to the requested entities, but instructs ImageGen not to reproduce the montage layout.

### ImageGen input budget

Use:

- source-figure mode: user source + atlas montage + global Book Figure style reference;
- text-to-figure mode: atlas montage + global style reference;
- `ref` mode: atlas montage + global style reference only; never pass the user source;
- missing-object mode: fallback montage + global style reference.

## 10. Style precedence

The atlas and the core skill have separate responsibilities.

### Atlas controls

- biological-object form;
- domain silhouette;
- nucleic-acid construction;
- molecular contact and overlap;
- object palette and two-/three-tone modeling;
- highlights, internal contours, and degree of simplification.

### Book Figure controls

- scientific content and requested labels;
- figure layout and reading order;
- panels, spacing, arrows, inhibition, and process flow;
- Inter and Roboto Mono typography;
- final text color and label hierarchy;
- canvas dimensions and margins;
- source-figure versus `ref` behavior.

The original panel captions, grid layouts, headings, Bio IDs, and typography are never copied into the finished figure unless explicitly requested as scientific content.

When an atlas object conflicts with a scientifically explicit user brief, the brief wins. When an atlas panel conflicts with the global Book Figure layout system, Book Figure wins.

## 11. File layout

```text
book-figure/
  assets/
    object-atlas/
      panels/
        panel-001-mirna-silencing.png
        panel-002-plant-cell-structures.png
        panel-003-chromatin-gene-regulation.png
        panel-004-virus-rnai-core.png
        panel-005-viroid-biology.png
      crops/
        ...
      atlas-style-reference.png
  references/
    object-atlas.md
  atlas/
    schema.yml
    manifest.yml
  scripts/
    validate_atlas.rb
    build_atlas_crops.rb
    select_atlas_references.rb
    build_atlas_montage.rb
  tests/
    atlas-selection-cases.yml
    test_atlas.rb
```

Crops are derived artifacts and may be rebuilt from panels plus manifest coordinates.

## 12. Adding new panels

A panel upgrade is append-only.

1. copy the new original image under a new stable panel filename;
2. calculate checksum and dimensions;
3. create a new panel manifest entry;
4. assign stable object IDs or link to existing object IDs;
5. record printed labels, aliases, bounding boxes, tags, and review status;
6. rebuild object crops;
7. validate manifest uniqueness and crop bounds;
8. run selection regression tests;
9. increment the atlas minor version for new compatible content;
10. update the atlas inventory documentation.

Existing panel files are never silently replaced. Corrected images receive a new panel version and the old panel becomes deprecated.

### Upgrade versioning

- patch: metadata correction that does not change selection meaning;
- minor: new panel, object, alias, or compatible reference;
- major: manifest-schema or selection-contract change.

The core `SKILL.md` does not need object-specific edits when a new panel follows the existing schema.

## 13. Implementation migration

The current uncommitted graphical-object pilot and the later text-card proposal are superseded.

During implementation:

1. review the dirty worktree and identify files belonging only to the rejected pilots;
2. remove or replace only those task-owned files;
3. retain useful generic validation patterns where they serve the atlas;
4. replace library-first composition with atlas-first reference selection;
5. keep unrelated user changes untouched;
6. do not commit, push, merge, or synchronize the installed skill until the user explicitly asks.

## 14. Validation

### Asset validation

- every stored panel exists and matches its checksum and dimensions;
- original panel files are not modified;
- every crop lies within its panel bounds;
- every crop can be rebuilt deterministically;
- no runtime crop contains the printed caption unless explicitly requested for review;
- stable panel IDs and stable object IDs are unique;
- duplicate printed Bio IDs are allowed and reported.

### Manifest validation

- schema and version are valid;
- aliases do not resolve ambiguously without a declared context rule;
- each object has category, tags, reference role, and scientific status;
- `avoid`, `deprecated`, and unreviewed anatomy references are excluded from scientific-primary selection;
- coordinates are normalized and non-zero;
- every object links to at least one active panel.

### Selection tests

Test exact matches, aliases, composites, missing objects, and ambiguous names, including:

- Dicer/DCL;
- pre-miRNA;
- mature miRISC;
- nucleus and nuclear pore context;
- chloroplast;
- chromatin/nucleosome;
- RNA polymerase II;
- target RNA cleavage;
- viroid;
- an absent helicase fallback.

### Prompt-contract tests

- montage references are explicitly style/form references;
- captions, Bio IDs, and panel layouts are prohibited in final output;
- source-figure and `ref` input lists follow their contracts;
- selected objects keep stable palette and form guidance;
- missing-object prompts describe new anatomy without inventing a mechanism;
- Inter/Roboto Mono and Book Figure layout rules are present.

### Visual verification

Generate at least three test figures:

1. a miRNA-biogenesis pathway using several exact atlas objects;
2. a plant-cell or chloroplast mechanism using compartment and membrane references;
3. a pathway containing one absent object to test stylistic extrapolation.

Review:

- molecular contact;
- nucleic-acid continuity;
- correct object identity;
- consistent highlight direction;
- atlas palette consistency;
- absence of copied grid/captions/IDs;
- scientific order and label accuracy.

## 15. Acceptance criteria

The visual-atlas system is accepted when:

- all five original panels are stored unchanged with checksums;
- every visible object intended for automatic use has a stable semantic ID, searchable aliases, bounding boxes, tags, and status;
- exact object requests select the correct visual crop;
- composite interactions are preferred where available;
- missing objects are extrapolated using category and interaction exemplars;
- ImageGen receives a bounded montage rather than irrelevant full panels;
- new panels can be added through manifest data and crop rebuilding without changing core skill logic;
- the three test figures match the shared atlas and Book Figure style;
- duplicate printed Bio IDs cannot corrupt selection;
- no source artwork is overwritten;
- nothing is committed, pushed, installed, or synchronized without later user authorization.

## 16. Explicit non-goals

- treating printed Bio IDs as globally unique;
- copying panel captions, layout, or typography into final figures;
- using the panels as unquestioned scientific evidence;
- pasting crops directly into final artwork;
- guaranteeing pixel-identical generated objects;
- indexing additional panels during the initial five-panel implementation;
- committing or publishing during this stage.
