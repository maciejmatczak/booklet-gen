// Booklet styles for calendar-a6-home, on top of /lib/style.typ.
#import "/lib/lib.typ": *

// Day-list presets: the only place the variants differ. Everything else is derived
// (days per page from the format's working height, see components.typ).
//   step:          library grid the page sits on (anchored at the spine)
//   rows-per-line: grid rows per handwritten line
//   rows-per-day:  grid rows per day (a whole number of lines)
//   header-rows:   grid rows above the list, for the page title
//   tab-steps:     date tab width (day number + weekday), in grid steps
//   num-width:     right edge of the day number, from the tab's left edge
//   hand-size:     handwriting size for printed entries, fits one line
#let presets = (
  b5: (
    label: "B5 · 5 mm",
    step: steps.standard,
    rows-per-line: 1,
    rows-per-day: 2,
    header-rows: 3,
    tab-steps: 3,
    num-width: 5mm,
    hand-size: 10pt,
  ),
  bw: (
    label: "B·w · 3,55 mm",
    step: steps.weeks,
    rows-per-line: 2,
    rows-per-day: 4,
    header-rows: 2,
    tab-steps: 3,
    num-width: 4.6mm,
    hand-size: 13pt,
  ),
)

// Paging options (see paginate in components.typ).
#let pagings = ("rolling", "month")

// Weekend date tab: a fine stipple, prints as light grey on a black-only laser.
#let weekend-fill = tiling(size: (0.8mm, 0.8mm), place(dx: 0.31mm, dy: 0.31mm, circle(radius: 0.09mm, fill: black, stroke: none)))

// Rules between days.
#let rules = (
  top: pen("regular"),   // under the page title
  day: pen("hairline"),  // between days
  week: pen("regular"),  // after Sunday
  month: pen("strong"),  // above the first day of a month
)

// Grid dots to write against.
#let grid-dot = dot-sizes.s

// Polish names.
#let months-nom = ("styczeń", "luty", "marzec", "kwiecień", "maj", "czerwiec",
  "lipiec", "sierpień", "wrzesień", "październik", "listopad", "grudzień")
#let months-gen = ("stycznia", "lutego", "marca", "kwietnia", "maja", "czerwca",
  "lipca", "sierpnia", "września", "października", "listopada", "grudnia")
#let weekdays-short = ("Pn", "Wt", "Śr", "Cz", "Pt", "So", "Nd") // datetime.weekday(): 1 = Monday
