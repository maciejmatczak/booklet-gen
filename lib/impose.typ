// Imposition: booklet pages (reading order) → printed sheets for duplex printing.
//
// The format says what the page is; its layout (format.imposition, see formats.typ) says
// how pages go onto the sheet. Each page sits in a cell of the sheet's grid, against the
// fold; a page narrower than its cell leaves waste at the outer side, marked with crop
// ticks. A page that fills its cell (a6-home) is placed edge to edge, no ticks.
// Print at 100 % / actual size, duplex, flip on the LONG edge.
// After printing (cut-stack): cut every sheet across the middle, put the pile of top halves
// on the pile of bottom halves, trim at the trim ticks (if any), fold each half, nest in order.
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

// Reading order: for sheets that are not cut or folded (test prints, calibration). Pages sit as the
// booklet's spreads, in order: 2|3 4|5 on the front, 6|7 8|1 on the back (the last page pairs with page 1),
// so related pages sit together and every spread keeps its left/right margins.
#let reading-order(n) = {
  assert(calc.rem(n, 4) == 0, message: "page count must be a multiple of 4, got " + str(n))
  let spreads = range(2, n, step: 2).map(p => (p, p + 1)) + ((n, 1),)
  range(0, spreads.len(), step: 2).map(i => (top: spreads.at(i), bottom: spreads.at(i + 1)))
}
#let orders = (cut-stack: cut-stack-order, reading: reading-order)

// Cell size and page offset inside the cell, from the format and its layout.
// Left pages (column 0) sit against the fold on their right, right pages (column 1) on their left.
#let _geometry(fmt) = {
  let lay = fmt.imposition
  assert(lay.order == "cut-stack" and lay.grid == (cols: 2, rows: 2) and lay.align == "fold",
    message: "impose: only the cut-stack 2 × 2 layout aligned to the fold is implemented")
  let cell = (width: lay.sheet.width / lay.grid.cols, height: lay.sheet.height / lay.grid.rows)
  let (width: pw, height: ph) = fmt.page
  assert(pw <= cell.width and ph <= cell.height, message: "impose: page is larger than its cell")
  assert(ph == cell.height, message: "impose: trimming top/bottom is not implemented (page height must fill the cell)")
  (sheet: lay.sheet, cell: cell, page: fmt.page, waste: cell.width - pw)
}

// Small marks inside the printable area, to guide cutting, trimming and folding.
#let _marks(fmt) = {
  let g = _geometry(fmt)
  let (width: cw, height: ch) = g.cell
  let st = 0.3pt + black
  let d = fmt.dead-zone + 0.5mm // just inside the printable area
  let len = 3mm
  // cut line, at both sheet sides
  place(dx: d, dy: ch, line(length: len, stroke: st))
  place(dx: 2 * cw - d - len, dy: ch, line(length: len, stroke: st))
  // fold line, at top and bottom of the sheet, and on both sides of the cut, so each half
  // keeps a tick at both ends after cutting (the middle is not a sheet edge: no dead zone there)
  place(dx: cw, dy: d, line(length: len, angle: 90deg, stroke: st))
  place(dx: cw, dy: ch - len, line(length: len, angle: 90deg, stroke: st))
  place(dx: cw, dy: ch, line(length: len, angle: 90deg, stroke: st))
  place(dx: cw, dy: 2 * ch - d - len, line(length: len, angle: 90deg, stroke: st))
  // trim ticks: short vertical lines on the trim line, where the fold ticks are (sheet top and bottom,
  // both sides of the cut), so each half shows its trim line at both ends. Vertical only: a horizontal
  // tick would read as "cut across here".
  if g.waste > d {
    for x in (g.waste, 2 * cw - g.waste) {
      for y in (d, ch - len, ch, 2 * ch - d - len) {
        place(dx: x, dy: y, line(length: len, angle: 90deg, stroke: st))
      }
    }
  }
}

// pdf: bytes of the booklet PDF; n: its page count; format: the booklet's format.
// printer: calibration profile (printers.typ); its back-shift moves back sides vertically.
// order: auto (the format's layout: cut-stack) or "reading" (uncut test sheets, pages in order).
#let impose(pdf, n, format: a6-home, printer: default-printer, marks: true, order: auto) = {
  let order-fn = if order == auto { cut-stack-order } else {
    assert(order in orders, message: "impose: order must be one of " + orders.keys().join(", "))
    orders.at(order)
  }
  let g = _geometry(format)
  let (width: pw, height: ph) = g.page
  let (width: cw, height: ch) = g.cell
  set page(width: g.sheet.width, height: g.sheet.height, margin: 0pt)
  // Each page is clipped to its own trim box, so a shift never spills over a cut.
  let put(x, y, p, shift) = place(dx: x, dy: y, box(width: pw, height: ph, clip: true,
    place(dy: shift, image(pdf, page: p, width: pw, height: ph))))
  for (i, side) in order-fn(n).enumerate() {
    if i > 0 { pagebreak() }
    let shift = if calc.odd(i) { printer.back-shift } else { 0mm } // sides alternate front, back
    for (row, pair) in ((0, side.top), (1, side.bottom)) {
      if pair != none {
        put(cw - pw, row * ch, pair.at(0), shift) // left page: right edge on the fold
        put(cw, row * ch, pair.at(1), shift)      // right page: left edge on the fold
      }
    }
    // marks move with the side, so front and back marks land on the same spot of paper
    if marks { place(dy: shift, box(_marks(format))) }
  }
}
