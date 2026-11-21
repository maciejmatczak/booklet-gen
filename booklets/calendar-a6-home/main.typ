// Calendar 2027: a day list for writing in, one row per day on the library grid.
//
// Choices (defaults below), from the command line:
//   task build -- calendar-a6-home
//   task build INPUTS="--input variant=bw --input paging=month" -- calendar-a6-home
//   variant: b5 (5 mm grid, 2 rows a day) | bw (3.55 mm grid, 4 rows a day)
//   paging:  rolling (days just continue) | month (each month starts a new spread)
#import "/lib/lib.typ": *
#import "style.typ": presets
#import "components.typ": *

#let variant = sys.inputs.at("variant", default: "b5")
#let paging = sys.inputs.at("paging", default: "rolling")
#assert(variant in presets, message: "variant must be one of: " + presets.keys().join(", "))
#let preset = presets.at(variant)

#let fmt = a6-home
#let from = datetime(year: 2027, month: 1, day: 1)
#let to = datetime(year: 2027, month: 12, day: 31)

#show: booklet.with(format: fmt)

// Page 1 (right): title. The day list starts on page 2, a left page, so spreads stay together.
#title-page(preset, paging, 2027)

#for days in paginate(from, to, days-per-page(preset, fmt), paging: paging) {
  pagebreak()
  day-list-page(days, preset)
}
