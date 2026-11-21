// Shared style: a library of named options. Booklets pick and apply them.
// Black toner only (laser printer): lightness comes from thinner lines, smaller dots and dashes,
// or from grey, which the printer makes as a fine halftone (check it on paper).
// Booklet-specific styles go in booklets/<name>/style.typ (a calendar keeps them in one `theme`).

// ---- fonts, by role ----
#let fonts = (
  text: "Literata",
  small: "Literata 7pt", // optical size drawn for small text
  hand: "Caveat", // handwriting: printed entries that should read as written in
)
// Font proportions per em, measured from the font files: cap height, x-height, descender depth.
#let font-metrics = (
  "Literata": (cap: 0.7, x: 0.507, desc: 0.23),
  "Literata 7pt": (cap: 0.7, x: 0.519, desc: 0.23),
  "Caveat": (cap: 0.61, x: 0.4, desc: 0.245),
)

// Text set on a grid row takes its size from the grid, not from a fixed size:
// its lowercase (x-height) is this share of the grid step, whatever the font,
// so different fonts on one grid look the same size (3.55 mm → Literata 7pt ≈ 5.4 pt, Caveat ≈ 7.1 pt).
#let grid-x-share = 0.28
#let grid-size(step, font) = step * grid-x-share / font-metrics.at(font).x
// Baseline of grid text, measured up from the row's bottom line: text sits on the line like
// writing does, descenders just clear of it (it would look afloat if centred in the row).
#let grid-baseline-lift(step, font) = grid-size(step, font) * font-metrics.at(font).desc + 0.1mm

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

// skip: none, or (i, j) => bool to leave out the dot in column i (counted from anchor-x)
// and row j (from the top), e.g. where a rule or a box edge is drawn over the grid.
#let dots(width: 100%, height: 100%, step: steps.standard, dot: dot-sizes.s, paint: black, anchor-x: left, phase: (0mm, 0mm), skip: none) = {
  _grid-area(width, height, (w, h) => {
    for (i, x) in _ticks(w, step, anchor-x, phase.at(0)).enumerate() {
      for (j, y) in _ticks(h, step, top, phase.at(1)).enumerate() {
        if skip == none or not skip(i, j) {
          place(dx: x - dot / 2, dy: y - dot / 2, circle(radius: dot / 2, fill: paint, stroke: none))
        }
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
