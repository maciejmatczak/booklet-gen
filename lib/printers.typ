// Printer profiles: print-only calibration, used by imposition (task print).
// Nothing here affects page design; formats.typ holds what the design needs.
// Background: docs/printing.md

// back-shift: vertical correction for back sides (duplex, flip on long edge).
//   Positive moves back-side content down. Measure: on one leaf, compare the working-area
//   frame of a front page and the page behind it (both upright); if the back is X mm higher,
//   use X mm.

// Brother DCP-L2532DW, A4, duplex long edge.
// Back side printed 3 mm higher than front (2026-11-15). Fixed in the printer itself:
// maintenance mode 45 → Y Adjust → DX = -30 (see docs/printing.md), so no software shift.
// If the printer is reset, either redo that, or set back-shift: 3mm here.
#let brother-dcp-l2532dw = (
  name: "Brother DCP-L2532DW",
  back-shift: 0mm,
)

// No correction.
#let ideal = (name: "ideal", back-shift: 0mm)

#let printers = (
  "brother-dcp-l2532dw": brother-dcp-l2532dw,
  "ideal": ideal,
)

#let default-printer = brother-dcp-l2532dw
