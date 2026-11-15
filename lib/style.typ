// Shared style: a library of named options. Booklets pick and apply them.
// Black only (laser printer): lightness comes from thinner lines, smaller dots and
// dashes, not from grey. Booklet-specific styles go in booklets/<name>/style.typ.

// ---- fonts, by role (all Literata for now) ----
#let fonts = (
  text: "Literata",
  small: "Literata 7pt", // optical size drawn for small text
)
// Below this size, use the small optical size.
#let small-threshold = 7.5pt

// Text in a given size, with the right optical size picked automatically.
#let txt(size, body) = text(font: if size <= small-threshold { fonts.small } else { fonts.text }, size: size, body)

// ---- named text sizes (clean-design line) ----
#let sizes = (
  tiny: 5.5pt,
  small: 6.5pt,
  body: 8pt,
  large: 10pt,
  title: 14pt,
)

// ---- lines ----
#let weights = (
  hairline: 0.25pt, // ≈ 2 printer dots at 600 dpi
  thin: 0.4pt,
  regular: 0.6pt,
  strong: 1pt,
  heavy: 1.5pt,
)
#let dashes = (
  solid: none,
  dotted: "dotted",
  dashed: "dashed",
  loose-dotted: "loosely-dotted",
)
// A stroke from named options: pen("hairline"), pen("thin", dash: "dotted").
#let pen(weight, dash: "solid") = (paint: black, thickness: weights.at(weight), dash: dashes.at(dash))

// ---- grids ----
#let steps = (
  standard: 5mm,
  weeks: 3.55mm, // Hobonichi Weeks
)
#let dot-sizes = (
  xs: 0.2mm,
  s: 0.3mm,
  m: 0.4mm,
  l: 0.5mm,
)

// Grid positions along one axis of a given length.
// anchor: where counting starts (left/top, or right/bottom for the far side).
// phase: offset of the first position from the anchor, e.g. to align a grid to the fold.
#let _ticks(length, step, anchor, phase) = {
  let n = int((length - phase) / step)
  range(n + 1).map(i => {
    let d = phase + i * step
    if anchor in (left, top) { d } else { length - d }
  })
}

// Grid utilities: each fills the space it is given (e.g. a block or a placed box).
// anchor-x: left or right. Usually the spine side, so grids line up across a spread.
#let _grid-area(width, height, draw) = box(width: width, height: height, layout(sz => draw(sz.width, sz.height)))

#let dots(width: 100%, height: 100%, step: steps.standard, dot: dot-sizes.s, anchor-x: left, phase: (0mm, 0mm)) = {
  _grid-area(width, height, (w, h) => {
    for x in _ticks(w, step, anchor-x, phase.at(0)) {
      for y in _ticks(h, step, top, phase.at(1)) {
        place(dx: x - dot / 2, dy: y - dot / 2, circle(radius: dot / 2, fill: black, stroke: none))
      }
    }
  })
}

#let lines(width: 100%, height: 100%, step: steps.standard, stroke: pen("hairline"), phase: 0mm) = {
  _grid-area(width, height, (w, h) => {
    for y in _ticks(h, step, top, phase) { place(dx: 0mm, dy: y, line(length: w, stroke: stroke)) }
  })
}

#let squares(width: 100%, height: 100%, step: steps.standard, stroke: pen("hairline"), anchor-x: left, phase: (0mm, 0mm)) = {
  _grid-area(width, height, (w, h) => {
    for y in _ticks(h, step, top, phase.at(1)) { place(dx: 0mm, dy: y, line(length: w, stroke: stroke)) }
    for x in _ticks(w, step, anchor-x, phase.at(0)) { place(dx: x, dy: 0mm, line(length: h, angle: 90deg, stroke: stroke)) }
  })
}

// Phase that puts grid points at whole steps from a reference line (e.g. the fold),
// given the distance from that line to the area's edge.
#let phase-from(distance, step) = {
  let r = calc.rem(distance / step, 1)
  if r == 0 { 0mm } else { (1 - r) * step }
}
