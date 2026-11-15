// To-scale diagram of one A4 side, 4-up cut and stack. Rendered by `task docs`.
// Driven by lib/formats.typ, so it stays in sync with the real numbers.
#import "/lib/formats.typ": a6-trimmed

#let fmt = a6-trimmed
#let (width: W, height: H) = fmt.sheet
#let d = fmt.dead-zone
#let b = fmt.bleed
#let s = fmt.safe
#let (width: tw, height: th) = fmt.trim
#let pad = 12mm

#let mm(x) = str(calc.round(x.mm(), digits: 1))

#let c-dead = rgb("#d9d9d9")
#let c-bleed = rgb("#f6c9c4")
#let c-trim = rgb("#1f5fa8")
#let c-spine = rgb("#2e7d32")
#let c-cut = rgb("#c62828")

#set page(width: W + 2 * pad + 62mm, height: H + 2 * pad, margin: 0pt, fill: white)
#set text(size: 8pt)

#let at(x, y, body) = place(top + left, dx: pad + x, dy: pad + y, body)
#let box-at(x, y, w, h, ..args) = at(x, y, rect(width: w, height: h, ..args))

// sheet and dead zone
#box-at(0mm, 0mm, W, H, fill: c-dead, stroke: 0.8pt + black)
#box-at(d, d, W - 2 * d, H - 2 * d, fill: white, stroke: none)

// pages: trim origin + which side the spine is on
#for y in (d + b, H - d - b - th) {
  for (x, label, spine) in ((W / 2 - tw, "left page", right), (W / 2, "right page", left)) {
    let bx = if spine == left { x } else { x - b }
    box-at(bx, y - b, tw + b, th + 2 * b, fill: c-bleed, stroke: none)
    box-at(x, y, tw, th, fill: rgb("#eef4fb"), stroke: 1pt + c-trim)
    box-at(x + s, y + s, tw - 2 * s, th - 2 * s, stroke: (paint: c-trim, thickness: 0.5pt, dash: "dashed"))
    at(x + s + 3mm, y + s + 3mm, text(size: 9pt, weight: "bold", fill: c-trim)[
      #label \ trim #mm(tw) × #mm(th)
    ])
  }
}

// spine (fold) and cut line
#at(W / 2, 0mm, line(length: H, angle: 90deg, stroke: (paint: c-spine, thickness: 1.2pt, dash: "dash-dotted")))
#at(0mm, H / 2, line(length: W, stroke: (paint: c-cut, thickness: 1.2pt, dash: "dashed")))

// legend
#let sw(c, stroke: none) = box(width: 4mm, height: 3mm, fill: c, stroke: stroke, baseline: 20%)
#let ln(c, dash, t: 1.2pt) = box(width: 4mm, line(length: 4mm, stroke: (paint: c, thickness: t, dash: dash)))
#at(W + 8mm, 6mm, block(width: 54mm, {
  set par(spacing: 1.1em)
  [*A4 sheet, one side* (to scale, mm)]
  parbreak()
  [#sw(c-dead) dead zone #mm(d): printer can't reach]
  parbreak()
  [#sw(c-bleed) bleed #mm(b): printed, then trimmed off]
  parbreak()
  [#sw(rgb("#eef4fb"), stroke: 1pt + c-trim) trim: the final page]
  parbreak()
  [#ln(c-trim, "dashed", t: 0.5pt) safe zone #mm(s) inside trim]
  parbreak()
  [#ln(c-spine, "dash-dotted") spine / fold: no bleed]
  parbreak()
  [#ln(c-cut, "dashed") cut the sheet in half]
  v(4mm)
  [*Typst page* = trim + bleed \ = #mm(tw + b) × #mm(th + 2 * b)]
  parbreak()
  [*A6 cell* = #mm(W / 2) × #mm(H / 2) \ the leftover always faces the sheet edge: it is the dead zone]
}))
