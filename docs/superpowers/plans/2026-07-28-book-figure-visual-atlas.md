# Book Figure Visual Atlas Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Subagents are not authorized for this repository task.

**Goal:** Replace the rejected SVG/text-object pilots with a local, searchable five-panel visual atlas that selects and crops biological references for ImageGen and exposes an `atlas-debug` diagnostic mode.

**Architecture:** Store the five original PNG panels unchanged, index their biological tiles using stable semantic IDs and normalized bounding boxes, and derive object-only PNG crops plus a bounded runtime montage. A dependency-free Ruby selector matches exact IDs, names, aliases, complexes, and category fallbacks; `book-figure` uses the montage as a form/style reference while retaining control of scientific content, typography, composition, and mode behavior.

**Tech Stack:** Markdown, YAML, Ruby standard library (`yaml`, `digest`, `zlib`, `optparse`, `fileutils`, `tmpdir`), PNG assets, Minitest.

## Global Constraints

- Do not commit, push, merge, or open a pull request.
- Do not modify `/Users/baev/.codex/skills/book-figure` until the repository package passes every validator and test.
- Preserve each supplied panel byte-for-byte and verify it with SHA-256.
- Use stable semantic IDs; printed `Bio-###` values are non-unique annotations only.
- Exclude source captions and printed IDs from ImageGen reference crops.
- Treat unreviewed panels as visual references, not scientific authorities.
- Keep `genereg + detailed` as the default figure mode.
- Preserve Inter for ordinary text, Roboto Mono for nucleotide sequences, and the current Book Figure text-color contract.
- In `ref` mode, never pass the user source image to ImageGen.
- Add no external runtime dependency.
- Remove only files created for the rejected uncommitted library pilot; preserve unrelated user changes.

---

### Task 1: Replace the rejected pilot contract with failing atlas tests

**Files:**
- Create: `book-figure/tests/test_atlas_foundation.rb`
- Create: `book-figure/tests/test_atlas_selection.rb`
- Create: `book-figure/tests/atlas-selection-cases.yml`
- Later delete after atlas tests are red: `book-figure/tests/test_library_foundation.rb`
- Later delete after atlas tests are red: `book-figure/tests/test_library_rendering.rb`
- Later delete after atlas tests are red: `book-figure/tests/object-contracts.yml`
- Later delete after atlas tests are red: `book-figure/tests/composition-cases.yml`
- Later delete after atlas tests are red: `book-figure/tests/fixtures/pilot-composition.yml`

**Interfaces:**
- Consumes: no new implementation.
- Produces: executable acceptance contract for `AtlasSupport.validate`, `AtlasSupport.select`, crop generation, montage generation, and the `atlas-debug` CLI.

- [ ] **Step 1: Write the failing foundation tests**

```ruby
class AtlasFoundationTest < Minitest::Test
  def test_manifest_registers_five_immutable_panels
    manifest = YAML.safe_load(File.read(MANIFEST))
    assert_equal "1.0.0", manifest.fetch("atlas_version")
    assert_equal 5, manifest.fetch("panels").length
  end

  def test_all_panels_match_declared_sha256_and_dimensions
    errors, summary = BookFigure::AtlasSupport.validate(ATLAS_ROOT)
    assert_empty errors
    assert_equal 5, summary.fetch(:panel_count)
    assert_operator summary.fetch(:object_count), :>=, 110
  end

  def test_printed_ids_may_repeat_but_stable_ids_must_be_unique
    objects = BookFigure::AtlasSupport.objects(ATLAS_ROOT)
    assert_operator objects.group_by { |o| o["printed_id"] }.values.count { |v| v.length > 1 }, :>, 0
    assert_equal objects.length, objects.map { |o| o.fetch("object_id") }.uniq.length
  end
end
```

- [ ] **Step 2: Write the failing selector/debug tests**

```ruby
def test_exact_alias_composite_and_fallback_selection
  dicer = BookFigure::AtlasSupport.select(ATLAS_ROOT, ["Dicer"]).first
  assert_equal "protein.dicer", dicer.fetch("object_id")
  assert_equal "exact", dicer.fetch("match_type")

  mirisc = BookFigure::AtlasSupport.select(ATLAS_ROOT, ["AGO-containing RISC"]).first
  assert_equal "complex.mirisc", mirisc.fetch("object_id")
  assert_equal "composite", mirisc.fetch("match_type")

  helicase = BookFigure::AtlasSupport.select(ATLAS_ROOT, ["DNA helicase"]).first
  assert_equal "fallback", helicase.fetch("match_type")
  assert_operator helicase.fetch("references").length, :>=, 2
end
```

- [ ] **Step 3: Run the tests and verify they fail for missing atlas code**

Run:

```bash
ruby book-figure/tests/test_atlas_foundation.rb
ruby book-figure/tests/test_atlas_selection.rb
```

Expected: FAIL because `book-figure/atlas/manifest.yml` and `BookFigure::AtlasSupport` do not exist.

- [ ] **Step 4: Remove only the rejected pilot tests and fixtures**

Use `apply_patch` to delete the five pilot-specific test/fixture files listed above. Do not delete `tests/contract-cases.yml`.

- [ ] **Step 5: Re-run the new tests**

Expected: the same missing-atlas failures, with no failures from the deleted SVG pilot.

---

### Task 2: Store and validate the five immutable panels

**Files:**
- Create: `book-figure/assets/object-atlas/panels/panel-001-mirna-silencing.png`
- Create: `book-figure/assets/object-atlas/panels/panel-002-plant-cell-structures.png`
- Create: `book-figure/assets/object-atlas/panels/panel-003-chromatin-gene-regulation.png`
- Create: `book-figure/assets/object-atlas/panels/panel-004-virus-rnai-core.png`
- Create: `book-figure/assets/object-atlas/panels/panel-005-viroid-biology.png`
- Create: `book-figure/atlas/VERSION`
- Create: `book-figure/atlas/schema.yml`
- Create: `book-figure/atlas/manifest.yml`
- Create: `book-figure/scripts/atlas_support.rb`
- Create: `book-figure/scripts/validate_atlas.rb`

**Interfaces:**
- `BookFigure::AtlasSupport.load_manifest(root) -> Hash`
- `BookFigure::AtlasSupport.panel_records(root) -> Array<Hash>`
- `BookFigure::AtlasSupport.validate(root) -> [Array<String>, Hash]`
- `ruby scripts/validate_atlas.rb --root atlas -> exit 0/1`

- [ ] **Step 1: Copy the originals under stable names**

Copy, without re-encoding:

```text
Gemini_Generated_Image_pe1nexpe1nexpe1n.png -> panel-001-mirna-silencing.png
Gemini_Generated_Image_lc3nyjlc3nyjlc3n.png -> panel-002-plant-cell-structures.png
Gemini_Generated_Image_5xnl2m5xnl2m5xnl.png -> panel-003-chromatin-gene-regulation.png
Gemini_Generated_Image_dt8gfrdt8gfrdt8g.png -> panel-004-virus-rnai-core.png
Gemini_Generated_Image_aqfcz2aqfcz2aqfc.png -> panel-005-viroid-biology.png
```

- [ ] **Step 2: Declare the exact immutable checksums**

```yaml
atlas_version: 1.0.0
panels:
  - panel_id: atlas.mirna-silencing.001
    sha256: fe279902b7a66227cecec80d9e576f3ee87acb9427c7480e92b990247b9ea6a7
    width: 1024
    height: 1024
  - panel_id: atlas.plant-cell.001
    sha256: 92b8aa6cf160a87d311a1add7ed2cc744161bfac5ee58797c7b670d01afa9d60
    width: 1024
    height: 1024
  - panel_id: atlas.gene-regulation.001
    sha256: 016802cdaf3f36e26e4dfdcbf1ce9ff7b76174d4f35c0293192f3760f1fd09e1
    width: 1024
    height: 1024
  - panel_id: atlas.virus-rnai.001
    sha256: fb360f7ac2b3b6a7781ed5bfe3fcfd319a6ec2401927bcd1693f0b25ee8f1556
    width: 1024
    height: 1024
  - panel_id: atlas.viroid-biology.001
    sha256: 8514a8e48bb7e3beb6ed0544328f3efe42529086944ac23f7e0e8e9bafc21295
    width: 2048
    height: 2048
```

- [ ] **Step 3: Implement dependency-free PNG header inspection**

In `atlas_support.rb`, parse the PNG signature and IHDR width/height without decoding image pixels:

```ruby
def png_dimensions(path)
  File.open(path, "rb") do |io|
    raise AtlasError, "invalid PNG signature" unless io.read(8) == PNG_SIGNATURE
    length = io.read(4).unpack1("N")
    type = io.read(4)
    raise AtlasError, "PNG must begin with IHDR" unless type == "IHDR" && length == 13
    width, height = io.read(8).unpack("NN")
    [width, height]
  end
end
```

- [ ] **Step 4: Implement checksum, schema, and path validation**

Reject missing files, path traversal, bad checksums, dimension drift, duplicate stable panel IDs, non-semantic versions, and unknown lifecycle statuses.

- [ ] **Step 5: Run the panel tests**

Run:

```bash
ruby book-figure/tests/test_atlas_foundation.rb
ruby book-figure/scripts/validate_atlas.rb --root book-figure/atlas
```

Expected: panel assertions pass; the test still fails only because object indexes are not yet present.

---

### Task 3: Index the visible biological objects

**Files:**
- Create: `book-figure/atlas/panels/panel-001.yml`
- Create: `book-figure/atlas/panels/panel-002.yml`
- Create: `book-figure/atlas/panels/panel-003.yml`
- Create: `book-figure/atlas/panels/panel-004.yml`
- Create: `book-figure/atlas/panels/panel-005.yml`
- Modify: `book-figure/atlas/manifest.yml`
- Modify: `book-figure/scripts/atlas_support.rb`
- Modify: `book-figure/tests/test_atlas_foundation.rb`

**Interfaces:**
- `BookFigure::AtlasSupport.objects(root) -> Array<Hash>`
- `BookFigure::AtlasSupport.object_index(root) -> Hash<String, Hash>`
- Each object record exposes `object_id`, `printed_id`, `printed_label`, `aliases`, `category`, `scientific_status`, `reference_role`, `object_bbox`, `tile_bbox`, `interaction_tags`, and `visual_tags`.

- [ ] **Step 1: Add one panel-index file per original panel**

Use normalized bounding boxes:

```yaml
panel_id: atlas.mirna-silencing.001
objects:
  - object_id: protein.dicer
    printed_id: Bio-077
    printed_label: Cytoplasmic Dicer complex
    aliases: [Dicer, DCL, Dicer-like]
    category: protein
    scientific_status: visual-only
    reference_role: primary-form
    object_bbox: [0.045, 0.220, 0.205, 0.125]
    tile_bbox: [0.000, 0.195, 0.250, 0.185]
    interaction_tags: [rna-processing, duplex-cleavage]
    visual_tags: [lavender, multidomain, upper-left-highlight]
```

- [ ] **Step 2: Index every labeled visual tile intended for selection**

Index at least 110 semantic entries across the five panels. Reused printed Bio IDs remain allowed. When two tiles represent the same semantic object, reuse the stable `object_id` and give each reference a unique `reference_id`, for example `protein.repressor/blue` and `protein.repressor/magenta`.

- [ ] **Step 3: Add the required exact and composite entries**

The indexes must include:

```text
rna.pri-mirna
complex.drosha-dgcr8-pri-mirna
rna.pre-mirna
protein.dicer
rna.mirna-duplex
protein.argonaute
complex.mirisc
rna.target-mrna
complex.rdrm
compartment.nucleus
organelle.chloroplast
chromatin.nucleosome
protein.rna-polymerase-ii
rna.viroid.circular
plant.symptom.leaf-curling
```

- [ ] **Step 4: Implement index validation**

Validate:

- unique `reference_id`;
- stable-ID syntax;
- normalized positive boxes inside `[0,1]`;
- supported categories, roles, and statuses;
- non-empty aliases/tags where required;
- known panel link;
- duplicate printed IDs reported but not rejected.

- [ ] **Step 5: Run the foundation tests**

Expected: PASS with five panels, at least 110 references, unique stable reference IDs, and reported duplicate printed IDs.

---

### Task 4: Build dependency-free crops and montages

**Files:**
- Create: `book-figure/scripts/png_support.rb`
- Create: `book-figure/scripts/build_atlas_crops.rb`
- Create: `book-figure/scripts/build_atlas_montage.rb`
- Create: `book-figure/assets/object-atlas/crops/.gitkeep`
- Create: `book-figure/tests/test_atlas_rendering.rb`

**Interfaces:**
- `BookFigure::PngImage.read(path) -> PngImage`
- `PngImage#crop(x:, y:, width:, height:) -> PngImage`
- `PngImage.blank(width:, height:, rgba:) -> PngImage`
- `PngImage#paste(image, x:, y:) -> self`
- `PngImage#write(path) -> path`
- `AtlasSupport.build_crops(root:, output_dir:) -> Array<String>`
- `AtlasSupport.build_montage(root:, selections:, output:) -> String`

- [ ] **Step 1: Write PNG round-trip and crop tests**

Use the 8-bit RGBA non-interlaced atlas panels and assert:

```ruby
image = BookFigure::PngImage.read(panel_path)
assert_equal [1024, 1024], [image.width, image.height]
crop = image.crop(x: 0, y: 0, width: 128, height: 96)
assert_equal [128, 96], [crop.width, crop.height]
crop.write(output)
assert_equal [128, 96], BookFigure::AtlasSupport.png_dimensions(output)
```

- [ ] **Step 2: Implement PNG decoding**

Support PNG bit depth 8, color type 6 (RGBA), compression/filter method 0, and non-interlaced input. Concatenate IDAT data, inflate with `Zlib`, and reverse PNG filters 0–4 per scanline.

- [ ] **Step 3: Implement PNG encoding**

Write signature, IHDR, filter-0 scanlines, compressed IDAT, and IEND. Compute CRC with `Zlib.crc32`.

- [ ] **Step 4: Generate object-only crops**

Convert normalized `object_bbox` to pixel coordinates, apply 6% padding bounded by the panel, and write deterministic files named from `reference_id`. Never include `tile_bbox` captions in runtime crops.

- [ ] **Step 5: Generate the bounded montage**

Create a warm `#FFF9EF` RGBA canvas, scale crops proportionally into a maximum two-row grid, preserve at least 24 px padding, and include no text or Bio IDs.

- [ ] **Step 6: Run rendering tests**

Expected: deterministic PNG hashes on repeat builds, valid dimensions, no crop outside source bounds, and a montage containing at most eight references.

---

### Task 5: Implement selection and `atlas-debug`

**Files:**
- Create: `book-figure/scripts/select_atlas_references.rb`
- Create: `book-figure/scripts/atlas_debug.rb`
- Modify: `book-figure/scripts/atlas_support.rb`
- Modify: `book-figure/tests/test_atlas_selection.rb`
- Modify: `book-figure/tests/atlas-selection-cases.yml`

**Interfaces:**
- `AtlasSupport.normalize_term(value) -> String`
- `AtlasSupport.select(root, terms, limit: 8) -> Array<Hash>`
- `AtlasSupport.write_selection_report(selections, path) -> String`
- CLI:

```bash
ruby scripts/atlas_debug.rb \
  --root atlas \
  --entities "pri-miRNA,Dicer,AGO-containing RISC,target mRNA,DNA helicase" \
  --output-dir /absolute/output
```

- [ ] **Step 1: Define selector fixtures**

```yaml
cases:
  - query: [Dicer]
    expected_ids: [protein.dicer]
    expected_match_types: [exact]
  - query: [AGO-containing RISC]
    expected_ids: [complex.mirisc]
    expected_match_types: [composite]
  - query: [DNA helicase]
    expected_match_types: [fallback]
```

- [ ] **Step 2: Implement exact-name and alias matching**

Normalize Unicode, case, punctuation, Greek symbols, hyphens, and whitespace. Rank stable ID, printed label, preferred name, and curated alias in that order.

- [ ] **Step 3: Implement composite preference**

If a composite matches the requested phrase, suppress its component-only crops unless the request explicitly asks to show the unbound components.

- [ ] **Step 4: Implement missing-object fallback**

Return up to two same-category exemplars plus one nearest interaction exemplar. Mark the selection `fallback` and preserve the missing requested name in the report.

- [ ] **Step 5: Implement the debug command**

Create:

```text
atlas-selection-report.yml
atlas-reference-montage.png
```

The report records query, match type, stable ID, panel, crop path, role, scientific status, and any fallback rationale.

- [ ] **Step 6: Run selector and CLI tests**

Expected: exact, alias, composite, and fallback cases pass; the command exits 0 and writes both artifacts.

---

### Task 6: Replace SVG-library behavior with atlas-first Book Figure behavior

**Files:**
- Modify: `book-figure/SKILL.md`
- Modify: `book-figure/agents/openai.yaml`
- Modify: `book-figure/scripts/validate_skill.rb`
- Modify: `book-figure/tests/contract-cases.yml`
- Create: `book-figure/references/object-atlas.md`
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Keep: `book-figure/VERSION` at `1.3.0`
- Delete with `apply_patch`: `book-figure/library/**`
- Delete with `apply_patch`: `book-figure/references/object-library.md`
- Delete with `apply_patch`: `book-figure/scripts/build_catalog.rb`
- Delete with `apply_patch`: `book-figure/scripts/build_contact_sheet.rb`
- Delete with `apply_patch`: `book-figure/scripts/compose_figure.rb`
- Delete with `apply_patch`: `book-figure/scripts/library_support.rb`
- Delete with `apply_patch`: `book-figure/scripts/validate_library.rb`
- Delete with `apply_patch`: `book-figure/assets/previews/**`
- Delete with `apply_patch`: `book-figure/assets/reference-sheets/library-pilot-contact-sheet.svg`

**Interfaces:**
- The skill reads `references/object-atlas.md`, `atlas/manifest.yml`, and only the indexes/crops selected for the current figure.
- `atlas-debug` is an explicit diagnostic mode that does not call ImageGen.

- [ ] **Step 1: Update the default workflow**

The workflow must:

1. extract entities;
2. run atlas selection;
3. build a bounded montage;
4. pass montage plus `genereg-reference.png` as style/form references;
5. retain all source/ref mode rules;
6. run the atlas QA checks after generation.

- [ ] **Step 2: Add the required prompt contract**

```text
Visual atlas: use the supplied atlas montage only as a biological form, molecular-contact, palette, and rendering reference. Redraw the requested entities in the Book Figure composition. Do not reproduce the atlas grid, Bio identifiers, captions, typography, or unrelated objects.
```

- [ ] **Step 3: Document `atlas-debug`**

Add the invocation and the two generated diagnostic artifacts to `README.md` and `references/object-atlas.md`.

- [ ] **Step 4: Replace package validation**

`validate_skill.rb` must require the atlas manifest, five panels, atlas reference docs, crop/selector/debug scripts, and atlas tests. It must call `AtlasSupport.validate` and print panel/reference counts.

- [ ] **Step 5: Remove the rejected pilot implementation**

Delete only the task-owned SVG library, composer, previews, and their documentation/tests. Verify `git status` before and after deletion.

- [ ] **Step 6: Run package validation**

Run:

```bash
ruby book-figure/scripts/validate_atlas.rb --root book-figure/atlas
ruby book-figure/tests/test_atlas_foundation.rb
ruby book-figure/tests/test_atlas_rendering.rb
ruby book-figure/tests/test_atlas_selection.rb
ruby book-figure/scripts/validate_skill.rb
```

Expected: PASS with five panels and at least 110 indexed visual references.

---

### Task 7: Produce and inspect local diagnostic artifacts

**Files:**
- Generate: `/Users/baev/Documents/Codex/2026-07-28/w/outputs/book-figure-atlas-debug/atlas-selection-report.yml`
- Generate: `/Users/baev/Documents/Codex/2026-07-28/w/outputs/book-figure-atlas-debug/atlas-reference-montage.png`

**Interfaces:**
- Consumes the implemented `atlas_debug.rb` command.
- Produces user-inspectable local evidence without using an ImageGen request.

- [ ] **Step 1: Run the mixed exact/fallback diagnostic**

```bash
ruby book-figure/scripts/atlas_debug.rb \
  --root book-figure/atlas \
  --entities "pri-miRNA,Dicer,AGO-containing RISC,target mRNA,DNA helicase" \
  --output-dir /Users/baev/Documents/Codex/2026-07-28/w/outputs/book-figure-atlas-debug
```

- [ ] **Step 2: Inspect the YAML report**

Confirm exact selections for pri-miRNA, Dicer, miRISC, and target mRNA; confirm `DNA helicase` is marked `fallback`.

- [ ] **Step 3: Inspect the montage visually**

Confirm:

- no printed captions or Bio IDs;
- no unrelated panel tiles;
- consistent crop padding;
- valid molecular drawings;
- no crop truncates the biological object.

- [ ] **Step 4: Correct manifest boxes and rebuild once if defects are visible**

Change only the affected normalized `object_bbox`, rebuild crops and montage, and rerun all atlas tests.

---

### Task 8: Verify the package and synchronize the local installed skill

**Files:**
- Modify after approval/escalation: `/Users/baev/.codex/skills/book-figure/**`
- Update: `/Users/baev/Documents/Codex/2026-07-28/w/AGENT_HANDOFF.md`
- Update: `/Users/baev/Documents/Codex/2026-07-28/w/CHANGELOG_AGENT.md`

**Interfaces:**
- Installed `$book-figure` package mirrors the validated repository package.

- [ ] **Step 1: Run the complete verification suite**

```bash
ruby book-figure/tests/test_atlas_foundation.rb
ruby book-figure/tests/test_atlas_rendering.rb
ruby book-figure/tests/test_atlas_selection.rb
ruby book-figure/scripts/validate_atlas.rb --root book-figure/atlas
ruby book-figure/scripts/validate_skill.rb
git diff --check
```

- [ ] **Step 2: Confirm repository safety**

Verify:

- no commits relative to the starting HEAD;
- no push or merge;
- no original Downloads image changed;
- only rejected pilot files were removed;
- all five repository panels match the source checksums.

- [ ] **Step 3: Synchronize the installed skill**

After filesystem approval, replace the installed `book-figure` package with the validated repository package while preserving unrelated installed-only files such as `.DS_Store`.

- [ ] **Step 4: Validate the installed package**

Run the installed `validate_skill.rb` and installed `atlas-debug` command against a temporary output directory.

- [ ] **Step 5: Update coordination records**

Record implementation results, tests, generated artifacts, installed-package status, unresolved scientific-review items, and the continued no-commit/no-push state.
