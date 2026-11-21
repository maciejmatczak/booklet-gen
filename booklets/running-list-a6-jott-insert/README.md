# running-list-a6-jott-insert

A tracker for recurring chores, Alastair method: write a chore with its interval (`odkurzanie 2w`), put a dot
where it is next due, cross it when done, then put the next dot one interval later. Two sections: **weekly**
(the year as weeks) and **monthly** (the year as months). Daily chores are not tracked here; the weekly planner
covers them.

Format: `a6-jott-insert` (85 × 148.5, 5 mm punched corners). Working area 77 × 135 mm: 21 columns of the
3.55 mm grid, anchored at the spine.

Pages: cover, weekly Jan–Jun, weekly Jul–Dec, monthly (7 + 1 blank = 8). Design studio (true-scale mockups):
https://claude.ai/artifact/B6mt7G6jXwKcYwh1KQMxeg

## Options

Pass them as Typst inputs: `INPUTS="--input <name>=<value> …"`.

| Input   | Values          | Default | What it does                                                        |
|---------|-----------------|---------|---------------------------------------------------------------------|
| `style` | `classic`       | ✓       | Table, black only: row rule per chore, a dot per week               |
|         | `classic-lines` |         | Table, black only: row rule per chore, lines between weeks          |
|         | `modern`        |         | Grey name field per chore flowing into its grey axis, dots on it    |
| `year`  | e.g. `2027`     | `2027`  | Year of the dates (weeks start on the year's Mondays)               |
| `calibrate` | `true`      |         | Instead of the tracker: a calibration sheet for the modern style ([calibration.typ](calibration.typ)) |

```bash
task preview -- running-list-a6-jott-insert
task preview INPUTS="--input style=modern" -- running-list-a6-jott-insert
task print:variants -- running-list-a6-jott-insert   # classic and modern, see variants
task print INPUTS="--input calibrate=true --input order=reading" -- running-list-a6-jott-insert
```

Outputs are named by their inputs: `build/running-list-a6-jott-insert-style-modern-print.pdf`,
`…-style-classic-print.pdf`, `…-calibrate-true-order-reading-print.pdf`.

**Calibration sheet** (8 pages, one A4 sheet, the booklet's own format; print from SumatraPDF). One aspect per
page. Related roles are judged together, so the others are shown at a *fitting* value (`fit` in
calibration.typ: axis 20 % grey 0.2 pt, dot 0.24 mm), never varied: pick the axis, then the dot (or the other way round),
update `fit`, print again. Three rows per value, the value printed in the first field (labels in English).
`order=reading` puts the pages on the sheet as the booklet's spreads in order (2|3 4|5 front, 6|7 8|1 back),
not the booklet imposition, so each row of the A4 is one spread (no cutting needed). Current sheet: month lines.

| Side  | Top                                                  | Bottom                                                   |
|-------|------------------------------------------------------|----------------------------------------------------------|
| front | 2–3 real weekly spread, month lines grey 50 % 0.2 pt | 4–5 real weekly spread, month lines grey 30 % 0.3 pt     |
| back  | 6–7 real weekly spread, month lines black 0.12 pt    | 8 \| 1 ladders: grey 0.3 \| 0.48 pt and black 0.12 – 0.25 \| grey 0.2 pt |

Goal: the faintest look that still prints well, unless the layout needs clear separation. Chosen on paper:
name field 4 % fill, no contour; axis 20 % grey 0.2 pt; dot 0.24 mm black (all in style.typ).

**Look:** every style choice is a role in [style.typ](style.typ) (one dictionary per style); the geometry
(grid, rows, header rows, interval width, minimum name field) is the `preset` in the same file. The drawing is
in [components.typ](components.typ). The build fails if the name field drops below 45 mm or the time columns
don't fit.

## Design

### The rule

**What you track sits next to where you track it.** A chore's name, its interval and its marks are on one row,
read along one line. Everything else follows from that.

### Layout

One row per chore, 7.1 mm high (2 rows of 3.55: the handwriting line). 18 chores per spread. Dated with month
names and the Monday date of each week (ISO weeks; 2027 has 52, the first Monday is 4 January).

- **Name field:** the chore name, then a narrow interval field (`2w`, `3m`), at least 45 mm together.
- **Time:** after the name field, one mark position per week (3.55 mm) or per month (7.1 mm).
- **The fold falls on a month boundary.** A month is never split across the spine.

**Weekly: half a year per spread.** 26 weeks don't fit on one 77 mm page, so the first months move to the left
page beside the names:

| Spread | Left page              | Right page | Name field |
|--------|------------------------|------------|------------|
| H1     | names + Jan–Feb (8 wk) | Mar–Jun (18 wk) | 48.6 mm |
| H2     | names + Jul–Aug (9 wk) | Sep–Dec (17 wk) | 45.05 mm |

Names are copied once a year, in July.

**Monthly: the whole year on one spread.** The same build with 7.1 mm month columns and the quarter boundaries
as the strong lines: names + Q1 on the left (name field 55.7 mm), Apr–Dec on the right.

### Two styles, one geometry

Both styles share the layout exactly (name width, rows, mark positions, fold); only the drawing roles change.

**Classic: a table, black only.** Name and interval as table rows; each chore's row rule runs on through the
weeks, with a dot per week where the mark goes. Strong month lines. Variant **Lines**: faint lines between the
weeks instead of the dots.

**Modern: no table.** Each chore's name sits in a soft grey field with rounded corners. Its right end tapers
smoothly to a point, and from there the chore's grey axis runs through the weeks, with a dot per week on it.
Month lines are very faint; there are no week lines. The axes run through the inside margin to the spine edge of both pages, so each chore reads across the fold; on the right page they continue to the outer edge of the working area.

**Right page, both styles:** the time columns are centred on the page (the empty strip after the last month is
split between the spine and the outer edge).

### Style roles

Every line, dot and fill is drawn by a named role. These are starting values, to be tuned with test prints
(greys become stipple on the black-only printer). In Typst: widths map to library weights where close
(`hairline` 0.25 pt, `thin` 0.4 pt), dots to `dot-sizes.s` (classic) and 0.6 mm (modern).

| Style   | Role            | Kind   | Width (mm)   | Black | Where |
|---------|-----------------|--------|--------------|-------|-------|
| Classic | `header-rule`   | line   | 0.15         | 100%  | under the date header |
| Classic | `row-rule`      | line   | 0.088        | 100%  | one per chore, across names and weeks |
| Classic | `interval-rule` | dotted | 0.11         | 100%  | between name and interval |
| Classic | `month-line`    | line   | 0.15         | 100%  | month (quarter) boundaries |
| Classic | `week-dot`      | dot    | r 0.17       | 100%  | Dots: one per week per chore |
| Classic | `week-line`     | line   | 0.06         | 100%  | Lines: between weeks |
| Modern  | `name-field`    | fill   | –            | 8%    | rounded field per chore, tapers to a point |
| Modern  | `chore-axis`    | line   | 0.1          | 40%   | from the field's tip to the page edge |
| Modern  | `week-dot`      | dot    | r 0.3        | 40%   | on the axis, one per week |
| Modern  | `month-line`    | line   | 0.15         | 20%   | month (quarter) boundaries |

### Worth keeping in mind: quarter blocks (Q4)

An interesting alternative layout for the weekly section: the name on the left, and beside it the year folded
into **four rows of 13 weeks** (one row per quarter), so a chore's whole year sits next to its name on one
page. 3.55 mm mark cells, names written once a year, 8 chores per page. It keeps the core rule while showing
the whole year at once; on 77 mm the name field gets 28.4 mm.

## How we got here

1. **Brief:** recurring chores on weekly and monthly horizons, Alastair-style dots and crosses, dated (months
   + Mondays), on the Jottbook insert.
2. **Limits first:** hard limits were set before comparing layouts: a 7.1 mm writing line, mark cells ≥ 3 mm,
   printed text ≥ 5.5 pt, name field ≥ 45 mm, ≤ 1 name rewrite a year, ≥ 16 chores per spread, dated, and the
   name on the same row as its marks. Each layout was drawn at true scale on the real format and checked
   against them.
3. **Layout:** the half-year table (T26) matched the rule and the limits best; the fold on a month boundary
   decided which months go to the left page. The monthly section reuses the same build.
4. **After the name field the page changes character:** the name is a table row, but the time part is about
   where marks go, so it moved from cells towards a per-chore axis with a dot per week.
5. **Two styles:** that idea became Classic (table) and Modern (grey field flowing into the axis), with grey
   levels set by eye and the styling split into named roles for test prints.

## Later

- Running lists (FVP-style buckets, blank pages, a tag column): for now the notebook itself is used for these;
  revisit later.
