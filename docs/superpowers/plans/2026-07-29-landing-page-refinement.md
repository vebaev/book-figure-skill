# Landing Page Refinement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a release-download action and refine the capability-card artwork, copy, and vertical rhythm of the Book Figure landing page.

**Architecture:** The static landing page remains a single HTML document with styles in `docs/assets/site.css`. A transparent Polycomb illustration is stored beside the existing card cutouts, and the Node static-content test validates copy, links, asset references, and the shared responsive art rule.

**Tech Stack:** HTML5, CSS3, Node.js built-in test runner, PNG with alpha channel.

## Global Constraints

- Link the Download ZIP action to `https://github.com/vebaev/book-figure-skill/archive/refs/heads/main.zip`.
- Place Download ZIP immediately after Author CV.
- Use the heading `Redraw and edit figures`.
- Use one shared CSS sizing rule for all capability-card illustrations; do not stretch them.
- Card 4 uses a transparent Polycomb Repressive Complex illustration with the labels PRC1, PRC2, and H3K27me3.
- Preserve the existing subtle card-art hover glow and reduced-motion support.

---

### Task 1: Establish content regression coverage

**Files:**
- Modify: `tests/site-content.test.mjs`

**Interfaces:**
- Consumes: `docs/index.html` and `docs/assets/site.css` as UTF-8 strings.
- Produces: a test asserting the release archive URL, revised heading, Polycomb asset path, and shared card-art CSS properties.

- [ ] **Step 1: Write the failing test**

Add a test named `landing page exposes refined actions and capability-card content` that asserts:

```js
assert.match(html, /archive\/refs\/heads\/main\.zip/);
assert.match(html, /Author CV[\s\S]*Download ZIP/);
assert.match(html, /Redraw and edit figures/);
assert.match(html, /card-cutouts\/polycomb-repressive-complex\.png/);
assert.match(css, /\.card-cutout \{[^}]*width: clamp\(5rem, 8vw, 6\.5rem\)/s);
assert.match(css, /\.section \{ padding-block: clamp\(3\.5rem, 7vw, 6rem\); \}/);
```

- [ ] **Step 2: Run test to verify it fails**

Run: `node --test tests/site-content.test.mjs`

Expected: the new test fails because the page does not yet include the Download ZIP action, new heading, or Polycomb asset.

- [ ] **Step 3: Keep the test as the regression contract**

Do not loosen the assertions; later tasks must make the real page and stylesheet satisfy them.

- [ ] **Step 4: Commit**

Commit with the production changes in Task 3 so the test and implementation stay atomic.

### Task 2: Create and validate the Polycomb illustration

**Files:**
- Create: `docs/images/card-cutouts/polycomb-repressive-complex.png`

**Interfaces:**
- Consumes: the existing cover illustration as visual style reference.
- Produces: an RGBA PNG referenced by `docs/index.html`.

- [ ] **Step 1: Generate the source image**

Create a compact hand-drawn cutout on a flat chroma-key background. It must show PRC2 and PRC1 protein assemblies over a nucleosome, a clearly labeled H3K27me3 mark, and the exact labels `PRC1`, `PRC2`, and `H3K27me3`.

- [ ] **Step 2: Remove the chroma-key background**

Run the image helper with automatic border key detection, soft matte, and despill, writing the final file to `docs/images/card-cutouts/polycomb-repressive-complex.png`.

- [ ] **Step 3: Verify transparency**

Run:

```bash
identify -format '%f: %[channels]\\n' docs/images/card-cutouts/polycomb-repressive-complex.png
```

Expected: `polycomb-repressive-complex.png: srgba`.

- [ ] **Step 4: Inspect the rendered asset**

Open the PNG visually and confirm that all three labels remain legible at card scale.

### Task 3: Implement page and stylesheet refinements

**Files:**
- Modify: `docs/index.html`
- Modify: `docs/assets/site.css`
- Modify: `tests/site-content.test.mjs`
- Create: `docs/images/card-cutouts/polycomb-repressive-complex.png`

**Interfaces:**
- Consumes: the four card PNG files in `docs/images/card-cutouts/`.
- Produces: a compact responsive page with the new action and balanced card artwork.

- [ ] **Step 1: Add the release action and revise copy**

In `docs/index.html`, add directly after the Author CV link:

```html
<a class="button button-secondary" href="https://github.com/vebaev/book-figure-skill/archive/refs/heads/main.zip">Download ZIP <span aria-hidden="true">↓</span></a>
```

Replace `Redraw figures` with `Redraw and edit figures`.

- [ ] **Step 2: Replace the fourth card asset**

Set card 4 to:

```html
<img class="card-cutout" src="images/card-cutouts/polycomb-repressive-complex.png" alt="" aria-hidden="true">
```

- [ ] **Step 3: Balance the card art and section rhythm**

In `docs/assets/site.css`:
- change `.section` padding to `clamp(3.5rem, 7vw, 6rem)`;
- set `.card` right padding to accommodate `6.5rem` artwork without text overlap;
- set the shared `.card-cutout` width to `clamp(5rem, 8vw, 6.5rem)`, retain `object-fit: contain`, and set a matching `max-height`;
- adjust the 768px card-art width and right padding proportionally;
- keep the current hover `drop-shadow` and reduced-motion behavior.

- [ ] **Step 4: Run the complete test suite**

Run: `node --test tests/site-content.test.mjs`

Expected: all tests pass.

- [ ] **Step 5: Upload as one main-branch commit**

Create blobs for the four changed text/image paths, build a tree from the latest `main` commit, create a commit titled `Refine landing page actions and card art`, and fast-forward `main` without force.

### Task 4: Verify remote state

**Files:**
- Verify: `docs/index.html`
- Verify: `docs/assets/site.css`
- Verify: `docs/images/card-cutouts/polycomb-repressive-complex.png`
- Verify: `tests/site-content.test.mjs`

**Interfaces:**
- Consumes: GitHub's default `main` branch.
- Produces: confirmed remote blob hashes for the upload.

- [ ] **Step 1: Fetch the four uploaded paths from `main`**

Confirm the HTML exposes Download ZIP and the revised heading, CSS contains the shared 6.5rem art rule and reduced section padding, and the PNG blob SHA matches the uploaded file.

- [ ] **Step 2: Record validation result**

Report the commit link, the test result, and confirmation that the Polycomb PNG has an alpha channel.
