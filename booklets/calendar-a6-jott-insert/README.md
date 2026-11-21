# calendar-a6-jott-insert

Calendar 2027 as a day list to write in: every day is a date box and four rows of dot grid. Weekends and
public holidays have a stippled date column. Secondary notes sit on the right, one grid row each: the week
number (T1, T2, …) on top, then the month name and holidays; birthdays (cake) and name days (tulip) at the
bottom, in handwriting, from the private family calendar.

Format: `a6-jott-insert: insert for a Leuchtturm1917 Jottbook Pocket A6 (85 × 148.5, 5 mm punched corners)`. Working area 77 × 135 mm; page titles at 12 pt.

## Options

Pass them as Typst inputs: `INPUTS="--input <name>=<value> …"`.

| Input    | Values                  | Default   | What it does                                                                 |
|----------|-------------------------|-----------|------------------------------------------------------------------------------|
| `grid`   | `3.55mm`                | ✓         | 3.55 mm dot grid (Hobonichi Weeks); a day is 4 rows: write over 2 rows a line (9 days a page) |
|          | `5mm`                   |           | 5 mm dot grid, 2 rows a day (12 days a page). **Not implemented yet**: the build stops |
| `paging` | `rolling`               | ✓         | Days just continue from page to page                                         |
|          | `month`                 |           | Each month starts a new spread (a spare page fills odd months)               |

Pages: `3.55mm` 44 rolling / 52 by month.

```bash
task preview -- calendar-a6-jott-insert
task preview INPUTS="--input paging=month" -- calendar-a6-jott-insert
task print -- calendar-a6-jott-insert
```

**Look:** every style choice (fonts, sizes, weights, lines, fills, grey levels) is one `theme` in
[style.typ](style.typ), named by role. The values per grid are the presets in the same file; the pieces are in
[/lib/components/day-list.typ](../../lib/components/day-list.typ).
