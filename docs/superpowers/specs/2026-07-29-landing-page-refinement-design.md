# Landing page refinement design

## Scope

Refine the Book Figure landing page in `docs/` without changing its information architecture.

## Changes

- Add a **Download ZIP** action immediately after **Author CV**. It links to the immutable `v1.3.0` source archive:
  `https://github.com/vebaev/book-figure-skill/archive/refs/tags/v1.3.0.zip`.
- Rename the first capability heading from **Redraw figures** to **Redraw and edit figures**.
- Retain the DNA methyltransferase illustration for card 1. Replace card 4's chloroplast with a labeled Polycomb Repressive Complex illustration, using the labels PRC1, PRC2, and H3K27me3.
- Scale all four decorative card illustrations through one shared CSS rule so that they have the same allocated visual footprint, aligned top-right and retaining the subtle hover glow. Any different aspect ratios are contained rather than stretched.
- Reduce vertical section padding at desktop and mobile breakpoints to make the page more compact while preserving readable separation.
- Extend the static site tests to cover the download URL, updated heading, Polycomb asset, and responsive card-art rule.

## Validation

- Run `node --test tests/site-content.test.mjs`.
- Confirm the four card images have an alpha channel.
- Verify the uploaded paths and text through GitHub after the commit.
