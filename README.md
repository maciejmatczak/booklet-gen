# booklet-gen

Exploration of printable booklet templates built with Typst.

## Getting started

```bash
mise install   # pinned tools: typst, tinymist, task, uv (see mise.toml)
task setup     # everything else: Python env, fonts; safe to re-run
task preview -- format-test
```

## Layout

| Path            | Purpose                                                        |
|-----------------|----------------------------------------------------------------|
| `lib/`          | Shared Typst library: formats, template, style (`lib.typ` imports all) |
| `lib/components/` | Reusable design components                                   |
| `booklets/`     | Concrete booklets — one folder each, fixed physical format     |
| `data/public/`  | Generated data, committed (e.g. holidays JSON)                 |
| `data/private/` | Personal data, gitignored (e.g. calendar exports)              |
| `tools/`        | Python helpers that generate data                              |
| `fonts/`        | Fonts, downloaded by `task setup:fonts` (gitignored)           |
| `build/`        | Output (PDF/PNG), gitignored, safe to delete                   |
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

### General

- Typst is always run with the repo root as `--root`, so imports use
  root-relative paths: `#import "/lib/lib.typ": *`, `json("/data/public/…")`.
- Printing target: home duplex printer, A4 paper, folded booklets
  (page count is always a multiple of 4). Default page size A6.
  See [docs/printing.md](docs/printing.md).
