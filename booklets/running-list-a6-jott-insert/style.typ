// Booklet styles for running-list-a6-jott-insert, on top of /lib/style.typ.
#import "/lib/lib.typ": *

// Tracker geometry: the same for every style (only the roles below change).
//   step:           library grid the page sits on (anchored at the spine)
//   rows-per-chore: grid rows per chore (one handwritten line)
//   header-rows:    grid rows above the chores: month (or quarter) labels, then dates
//   interval-steps: width of the interval field ("2w"), in grid steps
//   min-name:       name field (name + interval) must be at least this wide; the build fails otherwise
// The number of chores per page comes from the format's working height.
#let preset = (
  step: steps.weeks,
  rows-per-chore: 2,
  header-rows: 2,
  interval-steps: 2,
  min-name: 45mm,
)

// ---- styles (input `style`): every look choice by role ----
// Starting values, to be tuned with test prints. Grey is printed by the laser as a fine halftone.
// Text roles are text settings; text on grid rows has no size: it comes from the grid (grid-size).
#let label = (font: fonts.small)  // printed labels: months, dates, column heads

// Classic: a table, black only.
#let classic = (
  kind: "classic",
  label: label,
  header-rule: pen("thin"),                    // under the date header, across names and weeks
  row-rule: pen("hairline"),                   // one per chore, across names and weeks
  interval-rule: pen("thin", dash: "dotted"),  // between name and interval
  month-line: pen("thin"),                     // month (quarter) boundaries
  weeks: "dots",                               // dots | lines
  week-dot: (size: dot-sizes.s, paint: black), // dots: one per week per chore
  week-line: (paint: black, thickness: 0.17pt), // lines: between weeks (below hairline: check on paper)
  center-right: true, // right page: time columns centred
)

// Modern: no table. A grey field per chore flowing into the chore's axis.
#let modern = (
  kind: "modern",
  label: label,
  name-field: (paint: ink(4%), radius: 1.2mm, gap: 1mm, taper: 4mm), // rounded field, tapers to a point; 4%, no contour (chosen on paper)
  chore-axis: (paint: ink(20%), thickness: 0.2pt),                    // from the field's tip to the page edge (chosen on paper)
  week-dot: (size: 0.24mm, paint: black),                             // on the axis, one per week (chosen on paper)
  month-line: (paint: ink(20%), thickness: 0.2pt),                    // month (quarter) boundaries (chosen)
  center-right: true, // right page: time columns centred; axes run edge to edge
)

#let styles = (
  "classic": classic,
  "classic-lines": classic + (weeks: "lines"),
  "modern": modern,
)

// Cover page.
#let cover = (
  label: (font: fonts.small, size: sizes.tiny, weight: "bold", tracking: 2.5pt),
  year: (font: fonts.text, size: 40pt, weight: "light"),
  span: (font: fonts.small, size: sizes.small, style: "italic"),
  rule: pen("strong"),
)
