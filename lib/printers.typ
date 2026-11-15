// Printer profiles: print-only calibration, used by imposition (task print).
// Nothing here affects page design; formats.typ holds what the design needs.
// Background: docs/printing.md

// back-shift: vertical correction for back sides (duplex, flip on long edge).
//   Positive moves back-side content down. Measure: on one leaf, compare the working-area
//   frame of a front page and the page behind it (both upright); if the back is X mm higher,
//   use X mm.

// Brother DCP-L2532DW, A4, duplex long edge. Measured 2026-11-15: back 3 mm higher than front.
#let brother-dcp-l2532dw = (
  name: "Brother DCP-L2532DW",
  back-shift: 3mm,
)

// No correction.
#let ideal = (name: "ideal", back-shift: 0mm)

#let printers = (
  "brother-dcp-l2532dw": brother-dcp-l2532dw,
  "ideal": ideal,
)

#let default-printer = brother-dcp-l2532dw
