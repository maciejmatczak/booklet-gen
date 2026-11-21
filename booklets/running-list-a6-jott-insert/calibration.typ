// Calibration sheet for the modern style, printed on the booklet's own format (8 pages, one A4 sheet).
//   (print from SumatraPDF)
//
// One aspect per page. Related roles are judged together, so each page shows the others at a fitting
// value (fit below), never at varying ones: dots on the fitting axis, axes with the fitting dot.
// Pick the axis, then the dot (or the other way round), update fit, print again. Lines are black from
// 0.12 pt (thinnest that prints distinguishably); month lines also in grey. Three rows per value, the
// value printed in the first field.
//   front:  2–3 weekly spread, month lines grey 50% 0.2 pt
//           4–5 weekly spread, month lines grey 30% 0.3 pt
//   back:   6–7 weekly spread, month lines black 0.12 pt
//           8 | 1 ladders: grey 0.3 | 0.48 pt and black | grey 0.2 pt
// Goal: the faintest look that still prints well, unless the layout needs clear separation.
// Print as spreads in order (not the booklet imposition), so each row of the sheet is one spread:
//   task print INPUTS="--input calibrate=true --input order=reading" -- running-list-a6-jott-insert
#import "/lib/lib.typ": *
#import "components.typ": _field, _h, _v, _dot, _label, tracker-spread, week-cols, mondays

#let _line(w, dash: none, paint: black) = (paint: paint, thickness: w, dash: dash)
// Fitting values shown with whatever is under test (change after a print, then print again).
#let fit = (axis-pt: 0.2, axis-grey: 20, dot-mm: 0.24)
#let _pt(x) = str(x) + " pt"
#let _mm(x) = str(x) + " mm"

// One page. groups: array of (label, (row, row, row)); a row is (field, axis, dot): the name-field
// dictionary, a stroke or none, a dot (size, paint) or none, or an array of dots (one per week column).
// months: (label, stroke) per line, or none; lines sit on week-column boundaries like real month lines.
// cols: labels above the week columns (e.g. dot sizes), or none.
#let _cal-page(preset, st, title, groups, sub: none, months: none, cols: none) = context {
  let box = current-work-box()
  let s = preset.step
  let (w, field) = (box.width, preset.min-name)
  let pitch = preset.rows-per-chore * s
  let y0 = preset.header-rows * s
  let y-end = y0 + 3 * groups.len() * pitch
  let n-dots = calc.floor((w - field) / s + 1e-6)
  _label(st, s, 0, 0mm, title)
  if sub != none { _label(st, s, 1, 0mm, sub) }
  if months != none {
    for (i, m) in months.enumerate() {
      if m == none { continue } // gap between two ladders
      let (lbl, stroke) = m
      let x = field + (i + 1) * s
      _v(x, 0mm, y-end, stroke)
      _label(st, s, calc.rem(i, 2), x, lbl, anchor: center) // alternate rows: neighbours don't collide
    }
  }
  if cols != none {
    for (j, lbl) in cols.enumerate() { _label(st, s, calc.rem(j, 2), field + j * s + s / 2, lbl, anchor: center) }
  }
  for (gi, (lbl, rows)) in groups.enumerate() {
    for (k, (nf, axis, dot)) in rows.enumerate() {
      let r = 3 * gi + k
      let cy = y0 + r * pitch + pitch / 2
      _field(0mm, field, cy, pitch / 2 - nf.gap / 2, nf)
      if axis != none { _h(field, cy, w - field, axis) }
      if dot != none {
        for j in range(n-dots) {
          let d = if type(dot) == array { dot.at(j, default: none) } else { dot }
          if d != none { _dot(field + j * s + s / 2, cy, d) }
        }
      }
      if k == 0 { _label(st, s, preset.header-rows + 2 * r, 1.2mm, lbl) }
    }
  }
}

#let calibration-pages(preset, modern) = {
  // locked on paper: 4% fill, no contour; axis 20% 0.2 pt; dot 0.24 mm black (style.typ = fit)
  let nf = modern.name-field
  let dot(d) = (size: d * 1mm, paint: black)
  let three(row) = (row, row, row)
  let grey(p, w) = _line(w * 1pt, paint: ink(p * 1%))
  let (ax, dt) = (grey(fit.axis-grey, fit.axis-pt), dot(fit.dot-mm))
  let fit-text = "axis " + str(fit.axis-grey) + "% " + _pt(fit.axis-pt) + " · dot " + _mm(fit.dot-mm)
  let fit-rows = range(6).map(i => (if i == 0 { fit-text } else { "" }, three((nf, ax, dt))))
  let short(x) = str(x).trim("0", at: start)

  // the real weekly spread (Jan – Jun), one month-line candidate each; label above the names
  let weeks = week-cols(mondays(2027).filter(d => d.month() <= 6))
  let heads = (name: "co", interval: "ile", sub: "pon. →")
  let spread(label, stroke) = {
    context _label(modern, preset.step, 0, 0mm, label)
    tracker-spread(weeks, preset.step, preset, modern + (month-line: stroke), heads)
  }
  // ladders, one week column apart, across rows at the chosen axis and dot (pages 1 and 8: one spread)
  let ladder-a = () => _cal-page(preset, modern, "1 · month lines: black | grey 0.2 pt", fit-rows,
    months: (0.12, 0.15, 0.2, 0.25).map(x => (short(x), _line(x * 1pt))) + (none,)
      + (20, 30, 40, 50).map(p => (str(p) + "%", grey(p, 0.2))))
  let ladder-b = () => _cal-page(preset, modern, "8 · month lines: grey 0.3 pt | grey 0.48 pt", fit-rows,
    months: (15, 20, 30, 40).map(p => (str(p) + "%", grey(p, 0.3))) + (none,)
      + (10, 15, 20, 30).map(p => (str(p) + "%", grey(p, 0.48))))
  ladder-a()
  pagebreak()
  spread("2–3 · month lines: grey 50% 0.2 pt", grey(50, 0.2))
  pagebreak()
  spread("4–5 · month lines: grey 30% 0.3 pt", grey(30, 0.3))
  pagebreak()
  spread("6–7 · month lines: black 0.12 pt", _line(0.12pt))
  pagebreak()
  ladder-b()
}
