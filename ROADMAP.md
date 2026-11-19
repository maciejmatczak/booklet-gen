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
- Style = shared library of named options (`lib/style.typ`); booklets pick and apply. Booklet-only styles go in `booklets/<name>/style.typ`. One font for now: Literata.
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
| 1.4 | Print `format-test`: dead zone ≈ 4 mm sides, ≈ 2.5 mm bottom (inside our 5 / 6.75 mm margins, no change); found 3 mm vertical duplex offset → 5.3 | ✅ |

## Phase 2 — The library

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 2.1 | `lib/template.typ`: format → page + mirrored margins, pad to multiple of 4, `is-right()` / `current-work-box()` | ✅ |
| 2.2 | `task setup` (`setup:tools`, `setup:python`, `setup:fonts`): pinned Geist, Geist Mono, Literata downloaded into gitignored `fonts/` | ✅ |
| 2.3 | `lib/style.typ` (black-only library): font roles (Literata / Literata 7pt), named sizes, line weights + dashes (`pen`), grid steps (5, 3.55), dot sizes, `dots`/`lines`/`squares` utilities | ✅ |
| 2.4 | `lib/lib.typ`: single entry point                                                      | ✅ |
| 2.5 | `format-test` → 12-page print specimen: grid kinds/steps, dot sizes, lines/dashes/grey, tables, fonts, text on grid rows, spread across the fold | ✅ |
| 2.6 | After printing the specimen: per-grid base text sizes (+ role sizes derived from them), grey yes/no | needs print (1.4); future work |

## Phase 3 — First real booklet

The real booklet stress-tests Typst with the actual design ideas. Components are built when it needs them,
locally first (see README → Components).

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 3.1 | Choose the first booklet and sketch its spreads               | ⏭️ |
| 3.2 | `booklets/<name>/` with its own `components.typ` / `style.typ` as needed | |
| 3.3 | Print, fold, review, iterate                                  | |
| 3.4 | Promote a component to `lib/components/` only when a second booklet needs it | later |

## Phase 4 — Data: Polish calendar days

Python only for knowledge Typst doesn't have; days, weeks, months and grids are computed in Typst (`datetime`).
Range: 2026-12-01 → 2028-01-31 (the 2027 booklet plus one month either side). All names in Polish.

Output, one entry per day in the range (committed, so builds don't need Python):

```json
"2027-02-14": { "holidays": [], "observances": ["Walentynki"] }
```

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 4.1 | Python skeleton: root `pyproject.toml` (not a package, `package = false`), `.python-version`, `uv.lock`; dependency `holidays`. `task setup:python` picks it up | |
| 4.2 | `tools/calendar_pl.py --from 2026-12-01 --to 2028-01-31` → `data/public/calendar-pl-2027.json`. **holidays**: days off from the `holidays` library (`PL`, Polish names). **observances**: our own rule list — fixed (Dzień Babci, Dzień Dziadka, Walentynki, Dzień Kobiet, Prima Aprilis, Dzień Matki, Dzień Dziecka, Dzień Ojca, Andrzejki, Mikołajki), Easter-relative (Tłusty Czwartek, Ostatki, Popielec, Niedziela Palmowa, Wielki Czwartek, Wielki Piątek, Wielka Sobota), clock changes (last Sunday of March / October) | |
| 4.3 | `task data`: runs the generator, skipped when up to date (Taskfile `sources` / `generates`) | |
| 4.4 | `lib/data.typ`: load the file, look a day up by date; use it in the booklet | |

## Phase 5 — Imposition

| #   | Step                                                          | Status |
|-----|---------------------------------------------------------------|--------|
| 5.1 | Typst-level imposition (`lib/impose.typ`), cut and stack, 4 pages per A4 side (chosen over pdfjam: no TeX, geometry from the format) | ✅ (done early, needed for 1.4) |
| 5.2 | `task print -- <booklet>` → `build/<booklet>-print.pdf`, page count read from the template | ✅ |
| 5.3 | Duplex offset (back printed 3 mm higher): measured with `task calibration`, **fixed in the printer** (maintenance 45, Y Adjust DX = −30); `back-shift` back to 0 mm. Remaining skew ≈ ±0.5 mm, mechanical, accepted | ✅ |

## Later / open

- Private data: Google Calendar → `data/private/`.
- Name days (imieniny): skipped for now. There's no open dataset, and full lists are too long for an A6 day cell.
- CI that builds every booklet.
