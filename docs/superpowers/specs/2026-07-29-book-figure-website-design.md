# Book Figure website design

Date: 2026-07-29  
Status: approved design; pending implementation plan

## Goal

Publish a modern, minimal GitHub Pages landing page for Book Figure at `https://vebaev.github.io/book-figure-skill/`. The page should introduce the Codex skill quickly, showcase images already in the repository, and provide direct paths to the GitHub repository and Prof. Vesselin Baev's CV.

## Audience and success criteria

Primary visitors are researchers, educators, and Codex users evaluating the skill. Within one screen, they should understand what Book Figure does and find both the repository and author profile.

Success means:
- fast, responsive static page with no build requirement;
- consistent visual language with the book-figure artwork;
- image examples load from repository assets;
- clear calls to action for GitHub and CV;
- accessible, readable content on mobile and desktop.

## Architecture

Use a standalone static site under `docs/` with:
- `docs/index.html` for semantic content;
- `docs/assets/site.css` for design tokens, layout, responsiveness, and effects;
- `docs/assets/site.js` only for progressive-enhancement interactions;
- existing images referenced from `../docs/images/` or copied into a dedicated static asset directory when needed.

Configure GitHub Pages to deploy from the `main` branch and the `/docs` directory. No framework, dependency installation, or server-side functionality is required.

## Visual direction

Editorial minimalism: warm ivory surface, pale lavender and soft cyan ambient gradients, charcoal text, and restrained slate-blue accents. Use Inter for interface text and headings. The design should echo the textbook illustration style without imitating a book page literally.

Effects must remain subtle:
- low-opacity ambient gradient blobs;
- cards lift 2–4 px with a soft shadow on hover;
- buttons gain a small translate and accent glow;
- sections fade and rise into view when JavaScript is available;
- honor `prefers-reduced-motion`.

## Page sections

1. **Hero**
   - Full-width cover image.
   - Title: “Textbook Figure Codex Skill”.
   - One-sentence value statement.
   - Primary button: “View on GitHub” linking to `https://github.com/vebaev/book-figure-skill`.
   - Secondary button: “Author CV” linking to `https://vebaev.github.io/CV/`.

2. **What it does**
   - Four compact cards: Redraw figures, Create from text, Scientific visual atlas, English and Bulgarian labels.
   - Short descriptions based on README claims only.

3. **Featured examples**
   - Responsive gallery using existing repository images: transcription-factor source, transcription-factor redraw, and miRNA-biogenesis.
   - Each tile opens the image in a lightweight modal or in a new tab, with descriptive alt text.

4. **How it works**
   - Three steps: describe or upload, select visual mode, receive a textbook-ready figure.
   - Include a short `$book-figure` invocation example.

5. **Citation and license**
   - DOI link, version, author name, and ORCID sourced from `CITATION.cff`.
   - CC BY-NC-ND 4.0 statement with a link to `LICENSE`.

6. **Footer**
   - Prof. Vesselin Baev, Department of Molecular Biology, Faculty of Biology, Paisii Hilendarski University of Plovdiv.
   - GitHub and CV links.

## Accessibility and quality

- Proper heading hierarchy and landmark elements.
- All images have meaningful alt text.
- Sufficient contrast; focus indicators are visible.
- Navigation works with keyboard.
- No essential behavior depends on JavaScript.
- Test at 360 px, 768 px, and 1440 px widths.
- Verify all internal paths after GitHub Pages deployment.

## Explicit non-goals

- No user accounts, analytics, contact form, CMS, or backend.
- No custom illustration generation within the site.
- No complex animation, auto-playing media, or dependencies.
