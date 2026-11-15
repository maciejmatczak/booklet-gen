# Roadmap

Small, agreed steps. Status: ✅ done · ⏭️ current · (blank) planned.

## Principles

- **Good enough tooling.** Use tools as they are; effort goes into booklet design, not infrastructure.
- **Small steps.** Discuss → agree → implement → commit.

## Decisions so far

- Stack: Typst (pinned via mise), tinymist preview, Taskfile, uv for Python.
- Printing: home duplex printer, A4 paper, sheets folded in half → page count always a multiple of 4.
- Page model: **true A6 (105 × 148.5), physical margins in Typst** (5 mm outside for the dead zone, 6.75 mm
  top/bottom for the dead zone and the cut gap, 5 mm inside for the spine). No bleed. Trimming optional. Print 4-up on A4, cut and stack.
  Working area 95 × 135 (minimum needed: 85 × 135). Binding: likely sewn. Printer is black only.
- Fonts: Geist, Geist Mono, Literata (open licenses), downloaded by `task setup:fonts`, not committed.
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
| 1.2 | Discussion: page model → true A6 with physical margins (option C), see `docs/printing.md` | ✅ |
| 1.3 | `lib/formats.typ` (`a6-home`) + docs diagrams + `booklets/format-test`                  | ✅ |
| 1.4 | Print `format-test`: measure dead zone, check page order/flip (needs imposition)       | deferred |

## Phase 2 — The library

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 2.1 | `lib/template.typ`: format → page + mirrored margins, pad to multiple of 4, `is-right()` / `current-work-box()` | ✅ |
| 2.2 | `task setup` (`setup:tools`, `setup:python`, `setup:fonts`): pinned Geist, Geist Mono, Literata downloaded into gitignored `fonts/` | ✅ |
| 2.3 | `lib/theme.typ` (minimal, black-only): fonts + sizes, line weights + dash styles, grid steps (5, 3.55 Weeks) + dot sizes; per-booklet overrides | ⏭️ discuss first |
| 2.4 | `lib/lib.typ`: single entry point                                                      | |
| 2.5 | `format-test` → print specimen (12 pages): grid steps/dot sizes, line weights/dashes, fonts, mixed-weight table | discuss first |

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
