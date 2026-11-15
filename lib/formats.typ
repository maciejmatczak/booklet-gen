// Physical formats: how a booklet exists on paper.
//
// Typst page = the true physical page (one quarter of the sheet).
// Physical margins = where paper and process don't allow content:
//   outside, top, bottom: printer dead zone (and the same gap at the cut line,
//                         so every page is identical whichever half it came from)
//   inside:               binding (fold curvature, sewing holes)
// Margins are mirrored on left/right pages (Typst `inside`/`outside`).
// Design margins are a separate, per-booklet choice on top of these.
// Background and reasoning: docs/printing.md

#let a4 = (width: 210mm, height: 297mm)

// work-height: optional fixed working-area height; top/bottom margins are
// then set symmetrically to reach it (never below the dead zone).
#let make-format(sheet: a4, dead-zone: 5mm, spine: 5mm, work-height: none) = {
  // 4 pages per sheet side: cut in half, fold each half
  let page = (width: sheet.width / 2, height: sheet.height / 2)
  let vertical = if work-height == none { dead-zone } else { (page.height - work-height) / 2 }
  assert(vertical >= dead-zone, message: "work-height too large: top/bottom margins would fall inside the dead zone")
  (
    sheet: sheet,
    page: page,
    dead-zone: dead-zone, // printer can't print this close to the sheet edge
    spine: spine,         // lost to the binding
    physical: (inside: spine, outside: dead-zone, top: vertical, bottom: vertical),
  )
}

// Working area of a page, in page coordinates (origin: top-left of the page).
// right: true for right-hand (odd) pages, where the spine is on the left.
#let work-box(fmt, right) = {
  let m = fmt.physical
  (
    x: if right { m.inside } else { m.outside },
    y: m.top,
    width: fmt.page.width - m.inside - m.outside,
    height: fmt.page.height - m.top - m.bottom,
  )
}

// True A6 (105 × 148.5) from A4 on the home printer; working area 95 × 135.
// dead-zone is an estimate until measured with booklets/format-test.
#let a6-home = make-format(work-height: 135mm)
