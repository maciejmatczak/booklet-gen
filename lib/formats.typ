// Physical formats: how a booklet exists on paper.
//
// A format is named by its purpose and how it's made (`a6-home`: A6 made with home
// equipment; `a6-jott-insert`: an insert for a Jottbook). Values are static; the comment
// above each format says where every number comes from.
//
// Fields:
//   name:       key, published by the booklet template so `task print` imposes with it
//   page:       the finished page you hold (the Typst page)
//   physical:   margins where paper and process don't allow content (inside/outside are
//               mirrored on left/right pages, Typst `inside`/`outside`)
//   dead-zone:  printer can't print this close to the sheet edge (marks stay inside it)
//   spine:      lost to the binding (fold curvature, sewing holes)
//   corner:     radius of the outer corners after punching, or none (square)
//   imposition: how pages are laid out on the printed sheet (a layout below)
// Design margins are a separate, per-booklet choice on top of the physical margins.
// Background and reasoning: docs/printing.md

#let a4 = (width: 210mm, height: 297mm)

// ---- imposition layouts: pages → printed sheets ----

// Cut and stack on A4: 2 × 2 cells (105 × 148.5), cut across the middle, fold each half.
// Pages sit against the fold inside their cell; whatever is left at the outer side is
// waste, trimmed off at the trim ticks. Page order: impose.typ → cut-stack-order().
#let cut-stack-a4 = (
  name: "cut-stack-a4",
  sheet: a4,
  grid: (cols: 2, rows: 2),
  order: "cut-stack",
  align: "fold",
)

// ---- formats ----

// True A6 (105 × 148.5) from A4 on the home printer: exactly one cell, no trimming.
//   outside 5:          printer dead zone (measured ≈ 4 mm at the sides, kept at 5)
//   top/bottom 6.75:    ≥ 5 mm dead zone on the sheet-edge side, the same gap on the cut
//                       side so both halves are identical; gives a 135 mm working height
//   inside 5:           binding
//   → working area 95 × 135
#let a6-home = (
  name: "a6-home",
  page: (width: 105mm, height: 148.5mm),
  physical: (inside: 5mm, outside: 5mm, top: 6.75mm, bottom: 6.75mm),
  dead-zone: 5mm,
  spine: 5mm,
  corner: none,
  imposition: cut-stack-a4,
)

// Insert for a Leuchtturm1917 Jottbook Pocket A6 (90 × 150, 5 mm rounded corners),
// opening on a hinge at the notebook's spine.
//   width 85:           90 − 5 mm hinge room at the spine
//   height 148.5:       half of A4 (297 / 2); top and bottom are not cut
//   corner 5:           outer corners punched with a 5 mm corner punch, like the notebook's
//   outside 3:          safety from the trim cut (the 20 mm waste strip takes the dead zone)
//   top/bottom 6.75:    as a6-home (same sheet halves)
//   inside 5:           binding
//   → working area 77 × 135; printed in an A4 cell with 20 mm waste at the outer side
#let a6-jott-insert = (
  name: "a6-jott-insert",
  page: (width: 85mm, height: 148.5mm),
  physical: (inside: 5mm, outside: 3mm, top: 6.75mm, bottom: 6.75mm),
  dead-zone: 5mm,
  spine: 5mm,
  corner: 5mm,
  imposition: cut-stack-a4,
)

// All formats by name (for `task print`).
#let formats = (
  "a6-home": a6-home,
  "a6-jott-insert": a6-jott-insert,
)

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
