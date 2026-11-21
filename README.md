# booklet-gen

Exploration of printable booklet templates built with Typst.

## Getting started

```bash
mise install   # pinned tools: typst, tinymist, task, uv (see mise.toml)
task setup     # everything else: Python env, fonts; safe to re-run
task preview -- format-test-a6-home
task data      # regenerate data/ (after a new calendar export or a generator change)
```

## Layout

| Path            | Purpose                                                        |
|-----------------|----------------------------------------------------------------|
| `lib/`          | Shared Typst library: formats, template, style, data (`lib.typ` imports all) |
| `lib/components/` | Reusable design components                                   |
| `booklets/`     | Concrete booklets — one folder each, fixed physical format     |
| `data/public/`  | Generated data, committed (`calendar-pl-2027.json`: Polish holidays + observances) |
| `data/private/` | Personal data, gitignored: `family_calendar.ics` (Google Calendar export) → `.json` |
| `tools/`        | Python helpers that generate data                              |
| `fonts/`        | Fonts, downloaded by `task setup:fonts` (gitignored)           |
| `build/`        | Output (PDF/PNG), gitignored, safe to delete                   |
| `calibration/`  | Printer calibration sheets (`task calibration`)                 |
| `docs/`         | Long-term notes: printing, formats, decisions                  |

## Conventions

### Components

| Where                               | What                                                            |
|-------------------------------------|-----------------------------------------------------------------|
| `booklets/<name>/components.typ`    | The booklet's own pieces. **Default: start here.** (Grows into a `components/` folder if needed.) |
| `booklets/<name>/style.typ`         | The booklet's own styles, on top of `lib/style.typ`.             |
| `lib/components/`                   | Shared pieces, **only once a second booklet needs one** (promote on second use). |

`lib/style.typ` holds primitives (line weights, dashes, dot sizes, grid steps, font roles, grid fills);
components are composed, meaningful pieces built from them (week table, month calendar, …).

### Naming

Formats (`lib/formats.typ`) are named by purpose and how they're made: `a6-home` (A6 with home equipment),
`a6-jott-insert` (an insert for a Jottbook). Their values are static, with a comment saying where each number comes from.

Booklets are named `<content>-<format>`, with the full format name: `calendar-a6-home`,
`format-test-a6-jott-insert`. Each booklet has one fixed format (size drives design); another format is a new booklet
reusing the same components. Lowercase, hyphens. Settings such as the year or a layout variant are inputs, not names.

### General

- Booklet choices come in as Typst inputs (`sys.inputs`, with defaults in `main.typ`); each booklet's
  `README.md` lists its options:
  `task build INPUTS="--input grid=3.55mm" -- calendar-a6-home`.
- Typst is always run with the repo root as `--root`, so imports use
  root-relative paths: `#import "/lib/lib.typ": *`, `json("/data/public/…")`.
- Printing target: home duplex printer, A4 paper, folded booklets
  (page count is always a multiple of 4). Default page size A6.
  See [docs/printing.md](docs/printing.md).
