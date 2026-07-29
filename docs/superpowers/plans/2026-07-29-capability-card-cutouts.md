# Capability-Card Biological Cutouts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add four transparent biological cutouts from the Book Figure cover to the capability cards with subtle hover glow.

**Architecture:** Four transparent PNG assets live in `docs/images/card-cutouts/`. The existing static landing page references one decorative asset per card, while `site.css` defines common sizing, positioning, glow, responsive behavior, and reduced-motion-safe movement. The existing Node static test is extended to cover the new assets and selectors.

**Tech Stack:** Built-in image generation and local alpha cleanup, semantic HTML5, CSS3, Node.js built-in `node:test`.

## Global Constraints

- Use DNA methyltransferase, zinc-finger protein, chromosome territory, and the visible `TGAC` motif from the cover.
- Assets must be individual transparent PNG files with no rectangular background.
- Use `alt=""` and `aria-hidden="true"` for decorative card art.
- Use only a restrained cyan/slate-blue glow and 1–2 px hover shift.
- Preserve the existing accessibility, keyboard focus, and `prefers-reduced-motion` behavior.

---

### Task 1: Produce cutouts and integrate them into capability cards

**Files:**
- Create: `docs/images/card-cutouts/dna-methyltransferase.png`
- Create: `docs/images/card-cutouts/zinc-finger.png`
- Create: `docs/images/card-cutouts/chromosome-territory.png`
- Create: `docs/images/card-cutouts/tgac-motif.png`
- Modify: `docs/index.html`
- Modify: `docs/assets/site.css`
- Modify: `tests/site-content.test.mjs`

**Interfaces:**
- Consumes: `upload/01-cover.png` as the source image.
- Produces: four `<img class="card-cutout" ... alt="" aria-hidden="true">` elements and matching transparent PNG assets.

- [ ] **Step 1: Write the failing static test**

Append this test to `tests/site-content.test.mjs`:

```js
test("capability cards include four decorative biological cutouts with glow styling", () => {
  for (const asset of [
    "card-cutouts/dna-methyltransferase.png",
    "card-cutouts/zinc-finger.png",
    "card-cutouts/chromosome-territory.png",
    "card-cutouts/tgac-motif.png",
  ]) assert.match(html, new RegExp(asset.replace(".", "\\.")));
  assert.equal((html.match(/class="card-cutout" alt="" aria-hidden="true"/g) ?? []).length, 4);
  assert.match(css, /\.card-cutout/);
  assert.match(css, /\.card:hover \.card-cutout/);
  assert.match(css, /drop-shadow/);
});
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `node --test tests/site-content.test.mjs`  
Expected: FAIL because no cutout paths or cutout CSS rules exist.

- [ ] **Step 3: Create transparent cutouts**

Use the cover as an edit target. Generate four separate biological-object assets on a flat `#ff00ff` chroma-key background, then remove the chroma key with the installed alpha-cleanup helper. Keep the motif text `TGAC` readable. Save the cleaned PNG files at the four paths listed above.

- [ ] **Step 4: Integrate cutouts in HTML and CSS**

For each `.card`, add its cutout image before `.card-number`, with exactly:

```html
<img class="card-cutout" src="images/card-cutouts/dna-methyltransferase.png" alt="" aria-hidden="true">
```

Add CSS that positions `.card-cutout` at the card's upper-right, sets `width: clamp(4rem, 7vw, 5.5rem)`, keeps pointer events disabled, adds a low-opacity cyan/slate-blue `drop-shadow`, and applies `transform: translateY(-2px)` only on `.card:hover .card-cutout`.

- [ ] **Step 5: Run tests to verify the implementation**

Run: `node --test tests/site-content.test.mjs`  
Expected: PASS with five passing tests.

- [ ] **Step 6: Verify image alpha**

Run:

```bash
identify -format '%f: %[channels]\n' docs/images/card-cutouts/*.png
```

Expected: each file reports an alpha channel.

- [ ] **Step 7: Commit**

```bash
git add docs/index.html docs/assets/site.css docs/images/card-cutouts tests/site-content.test.mjs
git commit -m "feat: add biological cutouts to capability cards"
```
