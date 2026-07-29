# Book Figure GitHub Pages Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a responsive, minimal GitHub Pages landing page for Book Figure at `https://vebaev.github.io/book-figure-skill/`.

**Architecture:** A dependency-free static site is served from the repository's `docs/` directory. `index.html` contains all semantic content and references existing repository artwork; `assets/site.css` owns all visual rules and progressive effects. Node's built-in test runner validates required page content and stylesheet constraints without a browser dependency.

**Tech Stack:** Semantic HTML5, CSS3, Node.js built-in `node:test`, GitHub Pages (main branch, `/docs` directory).

## Global Constraints

- Use no framework, package manager, build step, analytics, backend, or external font dependency.
- Use existing Book Figure images from `docs/images/`.
- Link the main calls to action to `https://github.com/vebaev/book-figure-skill` and `https://vebaev.github.io/CV/`.
- Cite DOI `https://doi.org/10.5281/zenodo.21669810`, ORCID `https://orcid.org/0000-0002-5224-9145`, and CC BY-NC-ND 4.0.
- Support 360 px, 768 px, and 1440 px viewports.
- Respect `prefers-reduced-motion`; JavaScript is not required for essential behavior.
- GitHub Pages deployment target is `main` / `docs`.

---

### Task 1: Create a testable semantic landing page

**Files:**
- Create: `docs/index.html`
- Create: `tests/site-content.test.mjs`

**Interfaces:**
- Consumes: `docs/images/codex-skill-book-figure-hq.jpg`, `docs/images/transcription-factor-regulatory-elements-source.png`, `docs/images/transcription-factor-regulatory-elements-atlas-dna.png`, `docs/images/miRNA-biogenesis.png`.
- Produces: `docs/index.html` with `hero`, `capabilities`, `examples`, `workflow`, `citation`, and `footer` landmark IDs.

- [ ] **Step 1: Write the failing content test**

Create `tests/site-content.test.mjs`:

```js
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const html = await readFile(new URL("../docs/index.html", import.meta.url), "utf8");

test("landing page exposes required calls to action and research metadata", () => {
  assert.match(html, /id="hero"/);
  assert.match(html, /https:\/\/github\.com\/vebaev\/book-figure-skill/);
  assert.match(html, /https:\/\/vebaev\.github\.io\/CV\//);
  assert.match(html, /10\.5281\/zenodo\.21669810/);
  assert.match(html, /CC BY-NC-ND 4\.0/);
});

test("landing page references the cover and three featured examples", () => {
  for (const asset of [
    "codex-skill-book-figure-hq.jpg",
    "transcription-factor-regulatory-elements-source.png",
    "transcription-factor-regulatory-elements-atlas-dna.png",
    "miRNA-biogenesis.png",
  ]) assert.match(html, new RegExp(asset.replace(".", "\\.")));
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `node --test tests/site-content.test.mjs`  
Expected: FAIL because `docs/index.html` does not exist.

- [ ] **Step 3: Implement the semantic page**

Create `docs/index.html` with:
- `<main>` containing hero, capability cards, example gallery, three-step workflow, citation/license block, and author footer;
- a hero cover image with descriptive alt text;
- external CTA links using `target="_blank"` and `rel="noreferrer"`;
- gallery images wrapped in links to their full files, also with descriptive alt text;
- `<link rel="stylesheet" href="assets/site.css">`;
- an accessible skip link and clear heading order beginning with one `h1`.

- [ ] **Step 4: Run the content test to verify it passes**

Run: `node --test tests/site-content.test.mjs`  
Expected: PASS with two passing tests.

- [ ] **Step 5: Commit**

```bash
git add docs/index.html tests/site-content.test.mjs
git commit -m "feat: add Book Figure landing page structure"
```

### Task 2: Add responsive editorial styling and accessible motion

**Files:**
- Create: `docs/assets/site.css`
- Modify: `tests/site-content.test.mjs`

**Interfaces:**
- Consumes: HTML class names `.hero`, `.capability-grid`, `.example-grid`, `.button`, `.site-footer`.
- Produces: responsive layout, design tokens, keyboard focus indicators, and reduced-motion overrides.

- [ ] **Step 1: Extend the failing style test**

Append to `tests/site-content.test.mjs`:

```js
const css = await readFile(new URL("../docs/assets/site.css", import.meta.url), "utf8");

test("stylesheet provides responsive and reduced-motion rules", () => {
  assert.match(css, /@media \(max-width: 768px\)/);
  assert.match(css, /@media \(prefers-reduced-motion: reduce\)/);
  assert.match(css, /:focus-visible/);
  assert.match(css, /--ink:/);
  assert.match(css, /--accent:/);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `node --test tests/site-content.test.mjs`  
Expected: FAIL because `docs/assets/site.css` does not exist.

- [ ] **Step 3: Implement the stylesheet**

Create `docs/assets/site.css` with:
- CSS custom properties for ivory surface, lavender and cyan ambient colors, charcoal ink, slate-blue accent, spacing, radius, and shadow;
- a centered page container with generous whitespace;
- desktop hero grid that becomes a single column at `max-width: 768px`;
- responsive capability and example grids;
- buttons, cards, and image tiles with restrained hover lift and shadow;
- visible `:focus-visible` outlines;
- a `prefers-reduced-motion: reduce` block disabling transforms, transitions, and smooth scroll;
- no external `@import` statements.

- [ ] **Step 4: Run the full test file to verify it passes**

Run: `node --test tests/site-content.test.mjs`  
Expected: PASS with three passing tests.

- [ ] **Step 5: Commit**

```bash
git add docs/assets/site.css tests/site-content.test.mjs
git commit -m "feat: style Book Figure landing page"
```

### Task 3: Prepare GitHub Pages deployment and verify static delivery

**Files:**
- Create: `docs/.nojekyll`
- Create: `docs/README.md`
- Modify: `tests/site-content.test.mjs`

**Interfaces:**
- Consumes: final `docs/index.html` and `docs/assets/site.css`.
- Produces: a documentation directory ready for GitHub Pages deployment from `main/docs`.

- [ ] **Step 1: Extend the failing deployment test**

Append to `tests/site-content.test.mjs`:

```js
test("site declares its GitHub Pages target and has no Jekyll processing", async () => {
  const pagesReadme = await readFile(new URL("../docs/README.md", import.meta.url), "utf8");
  await readFile(new URL("../docs/.nojekyll", import.meta.url), "utf8");
  assert.match(pagesReadme, /https:\/\/vebaev\.github\.io\/book-figure-skill\//);
  assert.match(pagesReadme, /main branch.*docs directory/is);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `node --test tests/site-content.test.mjs`  
Expected: FAIL because the Pages metadata files do not exist.

- [ ] **Step 3: Implement Pages metadata**

Create:
- empty `docs/.nojekyll`;
- `docs/README.md` stating that the public site is intended for `https://vebaev.github.io/book-figure-skill/` and should be enabled in GitHub repository settings under **Pages → Deploy from a branch → main → /docs**.

- [ ] **Step 4: Run all static tests**

Run: `node --test tests/site-content.test.mjs`  
Expected: PASS with four passing tests.

- [ ] **Step 5: Perform a manual responsive review**

Open `docs/index.html` in a browser or preview server and inspect at 360 px, 768 px, and 1440 px. Confirm that:
- no text or buttons overflow;
- the hero and grids reflow to a single column on mobile;
- buttons are keyboard-focusable;
- all four images open their full-file links;
- reduced motion is respected when the operating system preference is enabled.

- [ ] **Step 6: Commit**

```bash
git add docs/.nojekyll docs/README.md tests/site-content.test.mjs
git commit -m "chore: prepare GitHub Pages deployment"
```
