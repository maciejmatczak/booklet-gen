// Imposition: booklet pages (reading order) → A4 sheets for duplex printing.
//
// Layout: 4 pages per sheet side ("cut and stack"). Each Typst page is exactly
// one quarter of the sheet, so pages are placed 1:1, no scaling, no offsets.
// Print at 100 % / actual size, duplex, flip on the LONG edge.
// After printing: cut every sheet across the middle, put the pile of top halves
// on the pile of bottom halves, fold each half, nest in order.
// Background: docs/printing.md
#import "formats.typ": a6-home
#import "printers.typ": default-printer

// Sheet sides in print order. Each side: (top: (left, right), bottom: (left, right) or none).
// n: page count, a multiple of 4.
#let cut-stack-order(n) = {
  assert(calc.rem(n, 4) == 0, message: "page count must be a multiple of 4, got " + str(n))
  let halves = int(n / 4) // folded small sheets, outermost first
  let sheets = calc.ceil(halves / 2) // A4 sheets
  // small sheet k (1 = outermost)
  let front(k) = (n - 2 * k + 2, 2 * k - 1)
  let back(k) = (2 * k, n - 2 * k + 1)
  let sides = ()
  for j in range(1, sheets + 1) {
    let lower = j + sheets // top halves: sheets 1..A, bottom halves: the rest
    sides.push((top: front(j), bottom: if lower <= halves { front(lower) } else { none }))
    sides.push((top: back(j), bottom: if lower <= halves { back(lower) } else { none }))
  }
  sides
}

// Small marks inside the physical margins (printable area), to guide cutting and folding.
#let _marks(fmt) = {
  let (width: pw, height: ph) = fmt.page
  let st = 0.3pt + black
  let d = fmt.dead-zone + 0.5mm // just inside the printable area
  let len = 3mm
  // cut line, at both sheet sides
  place(dx: d, dy: ph, line(length: len, stroke: st))
  place(dx: 2 * pw - d - len, dy: ph, line(length: len, stroke: st))
  // fold line, at top and bottom of the sheet
  place(dx: pw, dy: d, line(length: len, angle: 90deg, stroke: st))
  place(dx: pw, dy: 2 * ph - d - len, line(length: len, angle: 90deg, stroke: st))
}

// pdf: bytes of the booklet PDF; n: its page count.
// printer: calibration profile (printers.typ); its back-shift moves back sides vertically.
#let impose(pdf, n, format: a6-home, printer: default-printer, marks: true) = {
  let (width: pw, height: ph) = format.page
  set page(width: format.sheet.width, height: format.sheet.height, margin: 0pt)
  // Each page is clipped to its own quarter, so a shift never spills over the cut.
  let put(x, y, p, shift) = place(dx: x, dy: y, box(width: pw, height: ph, clip: true,
    place(dy: shift, image(pdf, page: p, width: pw, height: ph))))
  for (i, side) in cut-stack-order(n).enumerate() {
    if i > 0 { pagebreak() }
    let shift = if calc.odd(i) { printer.back-shift } else { 0mm } // sides alternate front, back
    for (row, pair) in ((0, side.top), (1, side.bottom)) {
      if pair != none {
        put(0mm, row * ph, pair.at(0), shift)
        put(pw, row * ph, pair.at(1), shift)
      }
    }
    // marks move with the side, so front and back marks land on the same spot of paper
    if marks { place(dy: shift, box(_marks(format))) }
  }
}
