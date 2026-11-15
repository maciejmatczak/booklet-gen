// Duplex calibration sheet: one A4 sheet, front + back.
// Measures the RAW printer: no imposition, no printer profile.
// Print at 100 % / actual size, duplex, flip on long edge.
//
// How to read:
// - Front/back alignment: hold the sheet against light, front facing you. Where the BACK's
//   long lines cross the FRONT's rulers is the offset of the back relative to the front.
//   Three rulers per direction show whether the offset is the same everywhere (else: skew).
// - Centering of each side: every side has lines meant to be exactly 10 mm from each paper
//   edge. Measure them with a physical ruler; uneven values = that side is off-centre.
#set page(width: 210mm, height: 297mm, margin: 0mm)
#set text(font: "Literata", size: 7pt)

#let W = 210mm
#let H = 297mm
#let cx = W / 2
#let cy = H / 2
#let at(x, y, body) = place(top + left, dx: x, dy: y, body)
#let hair = 0.25pt + black

// Ruler measuring vertical offset, centred on (x, cy). Positive = above centre.
#let v-ruler(x) = {
  for i in range(-16, 17) { // 0.5 mm steps, ±8 mm
    let d = i * 0.5mm
    let len = if calc.rem(i, 2) == 0 { 3mm } else { 1.5mm }
    at(x - len / 2, cy - d, line(length: len, stroke: hair))
    if calc.rem(i, 4) == 0 and i != 0 {
      at(x + 2.5mm, cy - d - 1.2mm, text(size: 5pt)[#if i > 0 [+]#(i / 2)])
    }
  }
  at(x - 4mm, cy, line(length: 8mm, stroke: 0.6pt + black)) // zero mark
  at(x + 2.5mm, cy - 1.2mm, text(size: 5pt, weight: "bold")[0])
}

// Ruler measuring horizontal offset, centred on (cx, y). Positive = right of centre (seen from front).
#let h-ruler(y) = {
  for i in range(-16, 17) {
    let d = i * 0.5mm
    let len = if calc.rem(i, 2) == 0 { 3mm } else { 1.5mm }
    at(cx + d, y - len / 2, line(length: len, angle: 90deg, stroke: hair))
    if calc.rem(i, 8) == 0 and i != 0 { // labels every 4 mm (tighter would collide)
      at(cx + d - 1.2mm, y + 2.5mm, text(size: 5pt)[#if i > 0 [+]#(i / 2)])
    }
  }
  at(cx, y - 4mm, line(length: 8mm, angle: 90deg, stroke: 0.6pt + black))
  at(cx - 0.6mm, y + 2.5mm, text(size: 5pt, weight: "bold")[0])
}

// Lines that should be exactly 10 mm from each paper edge (checks centering of this side).
#let edge-lines(side) = {
  let e = 10mm
  let st = 0.4pt + black
  at(cx - 20mm, e, line(length: 40mm, stroke: st))
  at(cx - 20mm, H - e, line(length: 40mm, stroke: st))
  at(e, cy + 20mm, line(length: 40mm, angle: 90deg, stroke: st)) // below the centre rulers
  at(W - e, cy + 20mm, line(length: 40mm, angle: 90deg, stroke: st))
  at(cx + 22mm, e - 1.2mm, [#side: 10 mm from top?])
  at(cx + 22mm, H - e - 1.2mm, [#side: 10 mm from bottom?])
}

#let xs = (30mm, cx, W - 30mm) // where the vertical rulers / back lines sit
#let ys = (60mm, cy, H - 60mm) // where the horizontal rulers / back lines sit

// ---------------- FRONT ----------------
#for x in xs { v-ruler(x) }
#for y in ys { h-ruler(y) }
#edge-lines("front")
#at(25mm, 25mm, block(width: 160mm)[
  #text(size: 12pt, weight: "bold")[Duplex calibration · FRONT] \
  Print at 100 % (actual size), duplex, flip on long edge. Hold against light, this side facing you.
  - *Vertical rulers* (3, across the width): where the back's horizontal line crosses = how much the back is
    *higher (+)* or *lower (−)* than the front, in mm.
  - *Horizontal rulers* (3, down the page): where the back's vertical line crosses = back shifted *right (+)*
    or *left (−)*, seen from the front.
  - Same reading on all three = pure offset; different readings = skewed sheet.
  - *Edge lines* (both sides): measure with a ruler; all should be 10 mm from the paper edge.
])

// ---------------- BACK ----------------
#pagebreak()
#for x in xs { at(x - 15mm, cy, line(length: 30mm, stroke: 0.6pt + black)) } // crosses the front's vertical rulers
#for y in ys { at(cx, y - 15mm, line(length: 30mm, angle: 90deg, stroke: 0.6pt + black)) }
#edge-lines("back")
#at(25mm, 25mm, block(width: 160mm)[
  #text(size: 12pt, weight: "bold")[Duplex calibration · BACK] \
  Reference lines for the rulers on the front. Measure the edge lines on this side too.
])
