// Calendar 2027 for the Jottbook insert: a day list for writing in, one row per day on the library grid.
//
// Choices (defaults below; all options: README.md in this folder), from the command line:
//   task build -- calendar-a6-jott-insert
//   task build INPUTS="--input paging=month" -- calendar-a6-jott-insert
//   grid:    3.55mm (3.55 mm grid, a day is 4 rows) | 5mm (5 mm grid, 2 rows a day: not implemented yet)
//   paging:  rolling (days just continue) | month (each month starts a new spread)
#import "/lib/lib.typ": *
#import "style.typ": presets, theme
#import "/lib/components/day-list.typ": *

#let grid-choice = sys.inputs.at("grid", default: "3.55mm")
#let paging = sys.inputs.at("paging", default: "rolling")
#assert(grid-choice in presets, message: "grid must be one of: " + presets.keys().join(", "))
#let preset = presets.at(grid-choice)

#let fmt = a6-jott-insert
#let from = datetime(year: 2027, month: 1, day: 1)
#let to = datetime(year: 2027, month: 12, day: 31)

#show: booklet.with(format: fmt)

// Page 1 (right): title. The day list starts on page 2, a left page, so spreads stay together.
#title-page(2027, theme)

#for days in paginate(from, to, days-per-page(preset, fmt), paging: paging) {
  pagebreak()
  day-list-page(days, preset, theme)
}
