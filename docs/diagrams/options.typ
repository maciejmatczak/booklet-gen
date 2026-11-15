// Decision record: three approaches considered (A, B, C), to scale. C was chosen.
// Standalone (not driven by lib/formats.typ): it compares hypothetical setups.
#let k = 0.55          // drawing scale
#let u(x) = x * k * 1mm
#let d = 5             // dead zone
#let colw = 128        // panel width in drawing mm
#let c-dead = rgb("#d9d9d9")
#let c-bleed = rgb("#f6c9c4")
#let c-print = rgb("#fff3c4")
#let c-knife = rgb("#c62828")
#let c-spine = rgb("#2e7d32")
#let c-trim = rgb("#1f5fa8")
#let c-typst = rgb("#7b1fa2")
#let tframe = (paint: c-typst, thickness: 1.8pt)

#set page(width: 3 * colw * 1mm + 20mm, height: 330mm, margin: 10mm, fill: white)
#set text(size: 8pt)

#let at(ox, oy, x, y, body) = place(top + left, dx: ox + u(x), dy: oy + u(y), body)
#let r(ox, oy, x, y, w, h, ..a) = at(ox, oy, x, y, rect(width: u(w), height: u(h), ..a))
#let hl(ox, oy, x, y, len, st) = at(ox, oy, x, y, line(length: u(len), stroke: st))
#let vl(ox, oy, x, y, len, st) = at(ox, oy, x, y, line(length: u(len), angle: 90deg, stroke: st))
#let knife = (paint: c-knife, thickness: 1.2pt, dash: "dashed")
#let spine = (paint: c-spine, thickness: 1pt, dash: "dash-dotted")

#let grid(ox, oy, x, y, w, h, step: 5) = {
  r(ox, oy, x, y, w, h, fill: c-print, stroke: none)
  for i in range(1, int(w / step)) { vl(ox, oy, x + i * step, y, h, 0.2pt + luma(170)) }
  for j in range(1, int(h / step)) { hl(ox, oy, x, y + j * step, w, 0.2pt + luma(170)) }
}

// p: (bleed, trimmed) ; trim size derived
#let panel(ox, oy, title, b, g, trimmed, notes) = {
  let tw = (210 - 2 * d - 2 * b) / 2
  let th = (297 - 2 * d - 4 * b - 2 * g) / 2
  at(ox, oy, 0, -14, text(size: 12pt, weight: "bold", title))
  // sheet
  r(ox, oy, 0, 0, 210, 297, fill: c-dead, stroke: 0.6pt + black)
  r(ox, oy, d, d, 210 - 2 * d, 297 - 2 * d, fill: white, stroke: none)
  for y in (d + b, 297 - d - b - th) {
    if g > 0 { r(ox, oy, 0, 148.5 - g, 210, 2 * g, fill: c-dead.lighten(40%), stroke: none) }
    if b > 0 { r(ox, oy, d, y - b, 210 - 2 * d, th + 2 * b, fill: c-bleed, stroke: none) }
    grid(ox, oy, 105 - tw, y, 2 * tw, th)
    if trimmed {
      r(ox, oy, 105 - tw, y, 2 * tw, th, stroke: knife)
    }
  }
  hl(ox, oy, 0, 148.5, 210, knife)
  vl(ox, oy, 105, 0, 297, spine)
  // Typst page frames
  for y in (d + b, 297 - d - b - th) {
    for x in (105 - tw, 105) {
      if trimmed {
        let fx = if x < 105 { x - b } else { x }
        r(ox, oy, fx, y - b, tw + b, th + 2 * b, stroke: tframe)
      } else {
        let cy = if y < 148.5 { 0 } else { 148.5 }
        let cx = if x < 105 { 0 } else { 105 }
        r(ox, oy, cx + 0.6, cy + 0.6, 105 - 1.2, 148.5 - 1.2, stroke: tframe)
      }
    }
  }

  // finished spread
  let sy = 310
  at(ox, oy, 0, sy - 10, text(size: 9pt, weight: "bold")[finished spread])
  let (pw, ph) = if trimmed { (tw, th) } else { (105, 148.5) }
  r(ox, oy, 0, sy, 2 * pw, ph, fill: white, stroke: 0.8pt + c-trim)
  if trimmed {
    grid(ox, oy, 0, sy, 2 * pw, ph)
  } else {
    // printable part: 5 mm border on outer edges; cut edge (here: bottom of a top-half sheet) has none
    grid(ox, oy, d, sy + d, 2 * pw - 2 * d, ph - 2 * d)
  }
  vl(ox, oy, pw, sy - 3, ph + 6, spine)
  for px in (0, pw) {
    if trimmed {
      let fx = if px == 0 { -b } else { pw }
      r(ox, oy, fx, sy - b, pw + b, ph + 2 * b, stroke: tframe)
    } else {
      r(ox, oy, px + 0.6, sy + 0.6, pw - 1.2, ph - 1.2, stroke: tframe)
    }
  }
  at(ox, oy, 0, sy + ph + 4, block(width: u(210), {
    set par(spacing: 0.8em)
    text(size: 10pt, weight: "bold")[page #calc.round(pw, digits: 1) × #calc.round(ph, digits: 1) mm]
    parbreak()
    let (tpw, tph) = if trimmed { (tw + b, th + 2 * b) } else { (pw, ph) }
    text(size: 10pt, weight: "bold", fill: c-typst)[Typst page #calc.round(tpw, digits: 1) × #calc.round(tph, digits: 1) mm]
    parbreak()
    notes
  }))
}

#let gap = colw * 1mm
#panel(0mm, 10mm, "A · bleed + trim", 3, 0, true, [
  + print with 3 mm bleed
  + cut A4, fold, sew
  + *trim* the 3 open edges
  Grid exactly to the edge, even if the knife is off. Smallest page.
])
#panel(gap, 10mm, "B · no bleed, no gap, trim", 0, 0, true, [
  + print up to the dead zone
  + cut A4, fold, sew
  + *trim* off the 5 mm dead-zone strip
  Printed right up to the cut line and the dead zone; the trim removes the blank strips. Biggest trimmed page. If the trim is off: hairline white or a clipped grid line, so stop the grid ~2 mm short.
])
#panel(2 * gap, 10mm, "C · no bleed, gap at cut, no trim", 0, 5, false, [
  + print up to the dead zone
  + cut A4, fold, sew. *Done.*
  Full A6 paper. The same 5 mm blank border on top, bottom and outside of every page, whichever half it came from. Nothing at the spine.
])

// legend
#let sw(c, stroke: none) = box(width: 4mm, height: 3mm, fill: c, stroke: stroke, baseline: 20%)
#let ln(st) = box(width: 6mm, line(length: 6mm, stroke: st))
#place(bottom + left, [
  #sw(c-dead) printer dead zone #h(6mm) #sw(c-dead.lighten(40%)) gap at the cut (left blank) #h(6mm)
  #sw(c-bleed) bleed (cut off) #h(6mm)
  #sw(c-print) printed page area #h(6mm)
  #ln(knife) knife cut #h(6mm)
  #ln(spine) spine / fold #h(6mm) #ln(tframe) Typst page #h(6mm)
  all to scale, dead zone assumed 5 mm
])
