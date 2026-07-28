# Book Figure Design System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add authoritative design tokens, semantic colors, and sustainable versioned validation to `book-figure`.

**Architecture:** Keep operational rules in `SKILL.md` and move exact design-system contracts into two directly linked references. Add a dependency-free Ruby validator and machine-readable contract fixtures so packaging and future releases can be checked deterministically.

**Tech Stack:** Markdown, YAML, Ruby standard library, PNG asset, GitHub.

## Global Constraints

- Preserve default `genereg + detailed` behavior and all existing modes.
- Preserve Noto Serif labels and Noto Sans Mono nucleotide sequences.
- Do not add external runtime dependencies.
- Keep `SKILL.md` under 500 lines.
- Keep the full-resolution bundled PNG.

---

### Task 1: Add the failing package validator

**Files:**
- Create: `book-figure/scripts/validate_skill.rb`

- [ ] Check required references, version file, fixture file, metadata, and PNG integrity.
- [ ] Run `ruby book-figure/scripts/validate_skill.rb`.
- [ ] Confirm failure because the new contract files do not yet exist.

### Task 2: Add authoritative design references

**Files:**
- Create: `book-figure/references/design-tokens.md`
- Create: `book-figure/references/semantic-colors.md`
- Modify: `book-figure/SKILL.md`

- [ ] Define one baseline coordinate system and proportional scaling rule.
- [ ] Define exact typography, spacing, stroke, arrow, radius, and highlight tokens.
- [ ] Define unique semantic color roles and precedence rules.
- [ ] Make both references mandatory before prompt construction.

### Task 3: Add sustainable package metadata and regression fixtures

**Files:**
- Create: `book-figure/VERSION`
- Create: `book-figure/tests/contract-cases.yml`
- Create: `CHANGELOG.md`
- Modify: `README.md`

- [ ] Set version `1.1.0`.
- [ ] Add representative gene regulation, RNA processing, and compartment cases.
- [ ] Document repository layout, validation, and release discipline.

### Task 4: Validate and publish

- [ ] Restore the full-resolution bundled PNG in the local package copy.
- [ ] Run the Ruby validator and confirm PASS.
- [ ] Run independent prompt-contract validation against the revised skill.
- [ ] Mirror the validated package to the installed skill.
- [ ] Publish changed text files to GitHub and verify the remote paths.
