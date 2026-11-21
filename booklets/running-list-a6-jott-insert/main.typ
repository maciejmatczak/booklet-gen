// Recurring-chore tracker for the Jottbook insert (Alastair method): weekly (half a year per spread) and
// monthly (the year on one spread).
//
// Choices (defaults below; all options: README.md in this folder), from the command line:
//   task build -- running-list-a6-jott-insert
//   task build INPUTS="--input style=modern" -- running-list-a6-jott-insert
//   style: classic (table, dot per week) | classic-lines (table, lines between weeks) | modern (grey fields, axes)
//   year:  2027
//   calibrate: true → instead of the tracker, a calibration sheet for the modern style (calibration.typ)
#import "/lib/lib.typ": *
#import "style.typ": preset, styles, cover
#import "components.typ": *
#import "calibration.typ": calibration-pages

#let style-choice = sys.inputs.at("style", default: "classic")
#assert(style-choice in styles, message: "style must be one of: " + styles.keys().join(", "))
#let st = styles.at(style-choice)
#let year = int(sys.inputs.at("year", default: "2027"))
#let calibrate = sys.inputs.at("calibrate", default: "false") == "true"

#let fmt = a6-jott-insert
#let s = preset.step
#let weeks = mondays(year)
#let weekly-heads = (name: "co", interval: "ile", sub: "pon. →")

#show: booklet.with(format: fmt)

#if calibrate {
  calibration-pages(preset, styles.modern)
} else [

// Page 1 (right): cover. The spreads start on page 2, a left page.
#cover-page(year, cover)

// Weekly: January–June, then July–December (names copied once, in July).
#pagebreak()
#tracker-spread(week-cols(weeks.filter(d => d.month() <= 6)), s, preset, st, weekly-heads)
#pagebreak()
#tracker-spread(week-cols(weeks.filter(d => d.month() >= 7)), s, preset, st, weekly-heads)

// Monthly: the whole year, 2 grid steps per month.
#pagebreak()
#tracker-spread(month-cols(), 2 * s, preset, st, (name: "co miesiąc", interval: "ile", sub: none))
]
