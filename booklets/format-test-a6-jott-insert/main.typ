// Print specimen for the a6-jott-insert format: trim, punch, fold and fit test (physical checks only;
// style choices are made on A4 with booklets/style-specimen-a4).
// Shows the page model on every page: working area with the 5 mm dot grid, the corner
// punch outline, and a ruler at the trimmed edge to check how accurate the cut was.
// After printing: cut, trim at the crop ticks, punch the 4 outer corners, fold, put it in
// the Jottbook and see if it closes nicely.
#import "/lib/lib.typ": *

#let fmt = a6-jott-insert
#let P = fmt.page
#let m = fmt.physical

#let mm(x) = str(calc.round(x.mm(), digits: 2))
#let at(x, y, body) = place(top + left, dx: x, dy: y, body)
#let label(body) = txt(sizes.tiny, body)
#let s-mark = 0.4pt + black

// Ruler at the trimmed (outer) edge: a tick every 1 mm from the page edge inward.
// After trimming, the ticks you can still see tell where the knife went:
// all of them = cut on the line; one missing = cut 1 mm into the page.
#let trim-ruler(right) = {
  let y0 = P.height / 2 - 6mm
  for i in range(int(m.outside / 1mm) + 1) {
    let x = if right { P.width - i * 1mm } else { i * 1mm }
    let len = if i == 0 { 12mm } else { 5mm }
    at(x, y0 + (12mm - len) / 2, line(length: len, angle: 90deg, stroke: 0.3pt + black))
  }
  let lx = if right { P.width - m.outside - 9mm } else { m.outside + 1mm }
  at(lx, y0 + 4.5mm, label[trim])
}

// Corner punch outline (quarter circle) at both outer corners.
#let punch-outline(right) = {
  let r = fmt.corner
  for top-corner in (true, false) {
    let x = if right { P.width - r } else { 0mm }
    let y = if top-corner { 0mm } else { P.height - r }
    // the circle's centre sits r inside the page; clip to the corner square
    let cx = if right { -r } else { 0mm }
    let cy = if top-corner { 0mm } else { -r }
    at(x, y, box(width: r, height: r, clip: true,
      place(dx: cx, dy: cy, circle(radius: r, stroke: (paint: black, thickness: 0.3pt, dash: "dashed")))))
  }
}

#let page-background = context {
  let right = is-right()
  let c = current-work-box()
  // 5 mm dot grid in the working area, anchored at the spine
  place(top + left, dx: c.x, dy: c.y, dots(width: c.width + 0.01mm, height: c.height + 0.01mm, step: steps.standard,
    anchor-x: if right { left } else { std.right }))
  place(top + left, dx: c.x, dy: c.y, rect(width: c.width, height: c.height, stroke: 0.6pt + black))
  trim-ruler(right)
  punch-outline(right)
  // spine label
  let sx = if right { 0mm } else { P.width - m.inside }
  place(top + left, dx: sx, dy: P.height / 2 - 8mm, box(width: m.inside, height: 16mm,
    align(center + horizon, rotate(-90deg, reflow: true, text(size: 4.5pt, weight: "bold", tracking: 1pt)[SPINE]))))
  // page number, bottom outer corner of the working area
  let nx = if right { c.x + c.width - 6mm } else { c.x + 1mm }
  place(top + left, dx: nx, dy: c.y + c.height + 1.5mm, label[#here().page()])
}

#show: booklet.with(format: fmt, background: page-background)

#let spec = table(
  columns: 2, stroke: none, inset: (x: 0pt, y: 1.2mm), column-gutter: 3mm,
  label[page], label[#mm(P.width) × #mm(P.height) mm],
  label[margins], label[inside #mm(m.inside) · outside #mm(m.outside) · top/bottom #mm(m.top)],
  label[working area], label[#mm(P.width - m.inside - m.outside) × #mm(P.height - m.top - m.bottom) mm],
  label[corners], label[#mm(fmt.corner) mm punch],
  label[printed as], label[#fmt.imposition.name, 20 mm waste at the outer side],
)

// page 1: what this is
#block(inset: 3mm)[
  #txt(sizes.large, strong[a6-jott-insert]) \
  #v(1mm)
  #label[Insert for a Jottbook Pocket A6 (90 × 150, 5 mm corners), hinged at its spine.]
  #v(3mm)
  #spec
]

// pages 2–7: the page model only (background), a spread in the middle (4–5)
#for _ in range(6) { pagebreak() }

// page 8: fit checklist
#pagebreak()
#block(inset: 3mm)[
  #txt(sizes.body, strong[After printing]) \
  #v(2mm)
  #set enum(spacing: 2.2mm)
  #label[
    + Cut each sheet in half, stack top halves on bottom halves.
    + Trim both outer strips at the crop ticks.
    + Read the trim rulers: how many ticks are left?
    + Punch the 4 outer corners: the dashed arcs show the cut.
    + Fold, nest: pages 1–8 in order, backs upright (duplex)?
    + SPINE labels sit at the fold on every page?
    + Spread 4–5: does the dot grid continue across the fold?
    + Put it into the Jottbook, 5 mm from its spine.
    + Does the book close nicely? Do the corners stay inside?
  ]
]
