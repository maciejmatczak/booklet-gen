// Physical formats: how a booklet exists on paper.
//
// A format holds physical facts only (sheet, printer limits, trim, bleed, safe zone).
// Margins and layout are design choices and live elsewhere.
// Background and reasoning: docs/printing.md

#let a4 = (width: 210mm, height: 297mm)

// Largest trim size when cutting a sheet into two halves, each folded into
// two pages (4 pages per sheet side, "cut and stack").
//   width:  2 pages side by side, bleed on the two outer edges (none at the spine)
//   height: 2 halves stacked, bleed above and below each
#let trim-4up(sheet, dead-zone, bleed) = (
  width: (sheet.width - 2 * dead-zone - 2 * bleed) / 2,
  height: (sheet.height - 2 * dead-zone - 4 * bleed) / 2,
)

#let make-format(sheet: a4, dead-zone: 5mm, bleed: 3mm, safe: 3mm) = (
  sheet: sheet,         // paper we print on
  dead-zone: dead-zone, // printer can't print this close to the sheet edge
  bleed: bleed,         // printed beyond the trim on open edges, cut off
  safe: safe,           // keep text/important content this far inside the trim
  trim: trim-4up(sheet, dead-zone, bleed), // final physical page
)

// Size of the Typst page: trim + bleed on the open edges
// (top, bottom, outside; no bleed at the spine).
#let page-size(fmt) = (
  width: fmt.trim.width + fmt.bleed,
  height: fmt.trim.height + 2 * fmt.bleed,
)

// A6-class booklet from A4 on the home printer, trimmed after binding.
// dead-zone is an estimate until measured (ROADMAP 1.4).
#let a6-trimmed = make-format()
