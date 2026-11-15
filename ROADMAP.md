# Roadmap

Small, agreed steps. Status: ✅ done · ⏭️ current · (blank) planned.

## Principles

- **Good enough tooling.** Use tools as they are; effort goes into booklet design, not infrastructure.
- **Small steps.** Discuss → agree → implement → commit.

## Decisions so far

- Stack: Typst (pinned via mise), tinymist preview, Taskfile, uv for Python.
- Printing: home duplex printer, A4 paper, sheets folded in half → page count always a multiple of 4.
- Page size: **A6-class, trim model**. Print 4-up on A4 (cut and stack), sew, and trim the 3 open edges.
  Final page ≈ 97 × 137 mm, with 3 mm bleed so content can reach the edge. Needed working area: 85 × 135 mm.
  Binding: likely sewn.
- Long-term notes live in `docs/` (see `docs/printing.md`).
- Data: `data/public/` committed, `data/private/` gitignored.

## Phase 0 — Foundation

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 0.1 | Folder layout, `.gitignore`, `README.md`                      | ✅ |
| 0.2 | Tooling: mise + `mise.toml` (typst, tinymist, task, uv)       | ✅ |
| 0.3 | Preview loop: `Taskfile.yml` + throwaway `booklets/hello/`    | ✅ |
| 0.4 | First commit, pushed to GitHub                                | ✅ |

## Phase 1 — Learn the physical format

| #   | Step                                                                                   | Status |
|-----|----------------------------------------------------------------------------------------|--------|
| 1.1 | Discussion: home print mechanics — A4 duplex, fold, A5 vs A6, page order, multiple of 4 | ✅ |
| 1.2 | Discussion: margins → trim model (trim, bleed, safe zone), see `docs/printing.md`      | ✅ |
| 1.3 | `lib/formats.typ`: trim model as the first format (trim computed from physics) + docs diagram | ✅ |
| 1.4 | Print test sheet: measure dead zone, check page order/flip, fix exact trim size        | deferred |

## Phase 2 — The library

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 2.1 | `lib/theme.typ`: design tokens (colors, fonts, spacing)       | ⏭️ |
| 2.2 | Theme overrides per booklet (`merge` helper in `util.typ`)    | |
| 2.3 | `lib/template.typ`: booklet show-rule (format + theme)        | |
| 2.4 | `lib/lib.typ`: single entry point                             | |
| 2.5 | Fonts: pick, vendor into `fonts/`                             | |

## Phase 3 — Components

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 3.1 | `gallery/`: preview page rendering components in isolation    | |
| 3.2 | First component (e.g. month calendar)                         | |
| 3.3 | More components as designs need them                          | |

## Phase 4 — Data

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 4.1 | Root `pyproject.toml` (uv), `tools/booklet_tools/` package    | |
| 4.2 | Holidays generator → `data/public/`, `task data`              | |
| 4.3 | Load JSON in Typst, show in calendar component                | |

## Phase 5 — First real booklet

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 5.1 | `booklets/<name>/` with `config.toml`: library + data + format | |
| 5.2 | Print, fold, review, iterate                                  | |

## Phase 6 — Imposition

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 6.1 | Learn pdfjam                                                  | |
| 6.2 | `task impose`: reading-order PDF → print-ready sheets         | |

## Later / open

- Private data: Google Calendar → `data/private/`.
- CI that builds every booklet.
