import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const html = await readFile(new URL("../docs/index.html", import.meta.url), "utf8");
const css = await readFile(new URL("../docs/assets/site.css", import.meta.url), "utf8");

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

test("stylesheet provides responsive and reduced-motion rules", () => {
  assert.match(css, /@media \(max-width: 768px\)/);
  assert.match(css, /@media \(prefers-reduced-motion: reduce\)/);
  assert.match(css, /:focus-visible/);
  assert.match(css, /--ink:/);
  assert.match(css, /--accent:/);
});

test("site declares its GitHub Pages target and has no Jekyll processing", async () => {
  const pagesReadme = await readFile(new URL("../docs/README.md", import.meta.url), "utf8");
  await readFile(new URL("../docs/.nojekyll", import.meta.url), "utf8");
  assert.match(pagesReadme, /https:\/\/vebaev\.github\.io\/book-figure-skill\//);
  assert.match(pagesReadme, /main branch.*docs directory/is);
});

test("capability cards include four decorative biological cutouts with glow styling", () => {
  for (const asset of [
    "card-cutouts/dna-methyltransferase.png",
    "card-cutouts/pre-mirna-dicer.png",
    "card-cutouts/curled-leaf.png",
    "card-cutouts/chloroplast.png",
  ]) assert.match(html, new RegExp(asset.replace(".", "\\.")));
  assert.equal((html.match(/<img class="card-cutout"[^>]*alt=""[^>]*aria-hidden="true">/g) ?? []).length, 4);
  assert.match(css, /\.card-cutout/);
  assert.match(css, /\.card:hover \.card-cutout/);
  assert.match(css, /drop-shadow/);
});
