// To-scale diagram of one A4 side with 4 pages. Rendered by `task docs`.
// Driven by lib/formats.typ, so it stays in sync with the real numbers.
#import "/lib/formats.typ": a6-home

#let fmt = a6-home
#let (width: W, height: H) = fmt.sheet
#let (width: pw, height: ph) = fmt.page
#let m = fmt.physical
#let pad = 12mm
#let mm(x) = str(calc.round(x.mm(), digits: 1))

#let c-phys = rgb("#d9d9d9")
#let c-page = rgb("#7b1fa2")
#let c-spine = rgb("#2e7d32")
#let c-cut = rgb("#c62828")

#set page(width: W + 2 * pad + 62mm, height: H + 2 * pad, margin: 0pt, fill: white)
#set text(size: 8pt)

#let at(x, y, body) = place(top + left, dx: pad + x, dy: pad + y, body)
#let box-at(x, y, w, h, ..args) = at(x, y, rect(width: w, height: h, ..args))

// four pages: physical margins (grey), working area (white), page frame (purple)
#for (cx, right) in ((0mm, false), (pw, true)) {
  for cy in (0mm, ph) {
    box-at(cx, cy, pw, ph, fill: c-phys, stroke: none)
    let ix = if right { cx + m.inside } else { cx + m.outside }
    box-at(ix, cy + m.top, pw - m.inside - m.outside, ph - m.top - m.bottom, fill: white, stroke: 0.6pt + black)
    box-at(cx, cy, pw, ph, stroke: 1.2pt + c-page)
    at(ix + 4mm, cy + m.top + 4mm, text(size: 9pt, weight: "bold")[
      #if right [right page] else [left page] \
      #text(weight: "regular")[page #mm(pw) × #mm(ph)]
    ])
  }
}

// spine (fold) and cut line
#at(W / 2, 0mm, line(length: H, angle: 90deg, stroke: (paint: c-spine, thickness: 1.4pt, dash: "dash-dotted")))
#at(0mm, H / 2, line(length: W, stroke: (paint: c-cut, thickness: 1.4pt, dash: "dashed")))

// legend
#let sw(c, stroke: none) = box(width: 4mm, height: 3mm, fill: c, stroke: stroke, baseline: 20%)
#let ln(c, dash, t: 1.2pt) = box(width: 5mm, line(length: 5mm, stroke: (paint: c, thickness: t, dash: dash)))
#at(W + 8mm, 6mm, block(width: 54mm, {
  set par(spacing: 1.1em)
  [*A4 sheet, one side* (to scale, mm)]
  parbreak()
  [#box(width: 4mm, height: 3mm, stroke: 1.2pt + c-page, baseline: 20%) *Typst page* = true A6 #mm(pw) × #mm(ph)]
  parbreak()
  [#sw(c-phys) *physical margins*: outside, top, bottom #mm(m.outside) (dead zone; same gap at the cut), inside #mm(m.inside) (binding)]
  parbreak()
  [#sw(white, stroke: 0.6pt + black) *working area* #mm(pw - m.inside - m.outside) × #mm(ph - m.top - m.bottom)]
  parbreak()
  [#ln(c-spine, "dash-dotted") spine / fold]
  parbreak()
  [#ln(c-cut, "dashed") cut the sheet in half]
}))
