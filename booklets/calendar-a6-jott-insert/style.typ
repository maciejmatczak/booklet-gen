// Booklet styles for calendar-a6-jott-insert, on top of /lib/style.typ.
#import "/lib/lib.typ": *

// Day-list presets, one per grid (input `grid`): the only place they differ. Everything else is derived
// (days per page from the format's working height, see /lib/components/day-list.typ).
//   step:          library grid the page sits on (anchored at the spine)
//   rows-per-line: grid rows per handwritten line
//   rows-per-day:  grid rows per day (a whole number of lines)
//   header-rows:   grid rows above the list, for the page title
//   tab-steps:     date box width (day number + weekday), in grid steps; one line high
//   date-layout:   inline (number, weekday on one baseline) | stacked (number above weekday)
//   num-width:     inline: right edge of the day number, from the box's left edge
//   weekday-gap:   inline: from the day number to the weekday
//   notes:         "rows": holidays, week number, birthdays on the right, one grid row each
//                  (none: not implemented yet, the build stops)
//                  (note sizes and baselines come from the grid: lib/style.typ → grid-size)
#let presets = (
  "5mm": (
    step: steps.standard,
    rows-per-line: 1,
    rows-per-day: 2,
    header-rows: 3,
    tab-steps: 2,
    date-layout: "inline",
    num-width: 5mm,
    weekday-gap: 0.9mm,
    notes: none, // 2 rows a day: no layout for notes yet
  ),
  "3.55mm": (
    step: steps.weeks,
    rows-per-line: 2,
    rows-per-day: 4,
    header-rows: 2,
    tab-steps: 2,
    date-layout: "stacked",
    notes: "rows",
  ),
)

// ---- theme: every look choice of this booklet, by role (the only place to change the look) ----
// Text roles are text settings (font, size, weight, style, tracking). Notes on grid rows have no
// size: it comes from the grid (lib/style.typ → grid-size), so they always fit their row.
// Grey is printed by the laser as a fine halftone: check dots and fills on paper.
#let theme = (
  // page title: date range above the list (12 pt: the longest range fits the 77 mm working width)
  title: (font: fonts.text, size: 12pt),
  // date box
  day-number: (font: fonts.text, size: sizes.body),
  weekday: (font: fonts.small, size: sizes.tiny),
  day-off: (weight: "bold"),                    // added to both on weekends and holidays
  // notes on the right, sized from the grid
  marking: (font: fonts.small, weight: "bold", tracking: 0.3pt), // calendar markings: "T44 · LISTOPAD"
  holiday: (font: fonts.small, style: "italic"),                  // holidays and observances
  person: (font: fonts.hand),                                      // birthdays, name days (+ icon)
  separator: "  ·  ",
  // lines
  rules: (
    top: pen("regular"),   // under the page title
    day: pen("hairline"),  // between days
    week: pen("regular"),  // after Sunday
    month: pen("strong"),  // above the first day of a month
  ),
  date-box: pen("hairline"), // same as the day rule: no bump where they meet
  // fills
  day-off-fill: luma(88%),                       // date column on weekends and holidays
  grid-dot: (size: dot-sizes.s, paint: black),     // 0.3 mm, black (specimen B2/B18)
  // title page
  cover: (
    label: (font: fonts.small, size: sizes.tiny, weight: "bold", tracking: 2.5pt), // KALENDARZ
    year: (font: fonts.text, size: 40pt, weight: "light"),
    span: (font: fonts.small, size: sizes.small, style: "italic"),               // styczeń – grudzień
    rule: pen("strong"),
  ),
)
