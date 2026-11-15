# Printing at home

How the physical side works and how it constrains the design.

Our setup: home duplex printer, A4 paper, cutting knife, sewn binding (likely).
Target: **A6-class booklet, 4 pages per A4 side, trimmed after binding**. The final page is a bit smaller than A6
(≈ 97 × 137 mm, exact size fixed after measuring the printer). See [Page model](#page-model-trim-bleed-safe-zone).

## Page model: trim, bleed, safe zone

We print slightly bigger than the final page and trim the bound booklet's three open edges with a knife. This lets
content (e.g. a grid) run to the very edge, like commercial notebooks. Trimming also evens out cut-and-stack height
differences, creep and some duplex offset.

| Concept       | Meaning                                                                   | Concern of      |
|---------------|---------------------------------------------------------------------------|-----------------|
| **Trim size** | Final physical page after trimming (≈ 97 × 137 mm)                        | design          |
| **Bleed**     | Backgrounds extend ~3 mm past the trim edges; cut off when trimming        | design          |
| **Safe zone** | Text and important content stay ~2–3 mm inside the trim (knife isn't exact) | design        |
| **Margins**   | Pure design choice, can be 0 (grids). Inside/outside matter for text near the spine | design |
| **Dead zone** | Printer can't print ~4–5 mm at A4 edges                                   | imposition only |

No bleed at the spine: the two pages of a sheet are joined there.

![One A4 side, 4-up cut and stack, to scale](img/a4-sheet.svg)

The diagram is generated from `lib/formats.typ` by `task docs`, so it always shows the current numbers.

**Typst page = trim + bleed.** The design never sees the A4 sheet or the dead zone. Placing pages onto the sheet is
imposition's job. The format (`lib/formats.typ`) holds the physical facts; margins are a design choice and live in
the template/theme.

### Trim size math (A4, 4-up, cut and stack)

With dead zone `d` and bleed `b`, the printable A4 area is `(210 − 2d) × (297 − 2d)`:

- width: `2 × W + 2 × b ≤ 210 − 2d`
- height: `2 × H + 4 × b ≤ 297 − 2d`

For `d = 5`, `b = 3`: **W ≤ 97, H ≤ 137.5**. For `d = 4`: W ≤ 98, H ≤ 138.5.

### Requirement

Working area needed: **85 × 135 mm**, from the Moleskine pocket (90 × 140 mm) currently in use. In that notebook,
the spine side loses ~5 mm, and its grid is often printed offset by ~2.5 mm at top and bottom; what's left is the
real working area. With trim 97 × 137.5, width has room to spare. Height is tight: 135 mm reaches into the 3 mm safe
zone. That's fine for a grid and handwriting; printed text keeps the safe zone.

## The folded sheet

A sheet folded in half gives 4 pages: 2 on the front, 2 on the back.

```
   FRONT (outside)            BACK (inside)
┌───────────┬───────────┐   ┌───────────┬───────────┐
│  page 4   │  page 1   │   │  page 2   │  page 3   │
│  (back)   │  (cover)  │   │           │           │
└───────────┴───────────┘   └───────────┴───────────┘
              ↑ fold = spine
```

- **Page count is always a multiple of 4.** Each sheet adds exactly 4 pages.
  Short content is padded with blank pages at the end.
- **Sheets nest inside each other.** The outer sheet carries the first and last pages.
  For 8 pages (2 sheets):

  | Sheet     | Front | Back  |
  |-----------|-------|-------|
  | 1 (outer) | 8 · 1 | 2 · 7 |
  | 2 (inner) | 6 · 3 | 4 · 5 |

- Reordering pages onto sheets is **imposition**, a separate step done by a tool (pdfjam).
  Design always happens on pages in reading order: 1, 2, 3…

## Paper sizes

| Size | mm          | Relation                 |
|------|-------------|--------------------------|
| A4   | 210 × 297   | our paper                |
| A5   | 148 × 210   | A4 folded/cut in half    |
| A6   | 105 × 148   | A5 folded/cut in half    |

A folded A4 sheet gives an **A5** booklet with no cutting. An **A6** booklet needs a cut.

## A6 from A4

A6 sheets are A5-sized (two A6 pages per side). One A4 side holds two of them, one above the other:

```
A4 side (portrait)
┌───────────┬───────────┐
│  A6 page  │  A6 page  │  ← A5 sheet "top"
├ ─ ─ ─ ─ ─ ┼ ─ ─ ─ ─ ─ ┤  ← CUT (knife), 148.5 mm
│  A6 page  │  A6 page  │  ← A5 sheet "bottom"
└───────────┴───────────┘
            ↑ fold (after cutting)
```

Print duplex → cut A4 in half → fold each half → nest → bind.

What goes into the two halves is a choice:

1. **Two copies.** Both halves get the same sheet, so one print run gives 2 identical booklets.
   This is the simplest imposition: impose the A6 booklet onto A5 sheets, then print each A5 sheet twice on A4.
2. **Cut and stack.** The halves hold different sheets of the same booklet, so it uses half the paper.
   The page order gets more complex, but it's still a tool's job.
3. **A5 paper directly**, if the printer accepts it. Same as an A5 booklet from A4, just one size down.
   Worth checking the printer's supported paper sizes.

(A fourth, classic option is folding A4 twice ("quarto") and cutting the top folds. It has 8 pages per sheet and half
of them print upside down. That's more complex, so it's not pursued for now.)

## Things that affect the design

### Alignment tolerances

Nothing lines up perfectly. The error sources are:

| Error                                                   | Size (rough) | A6 on A4 (cut & stack) | A6 on A5 paper |
|---------------------------------------------------------|--------------|------------------------|----------------|
| Front/back offset of the duplex print                   | 1–2 mm       | yes                    | yes            |
| Hand fold not exactly centred                           | ~1 mm        | yes                    | yes            |
| Knife cut off or crooked → sheets differ in height      | ~1 mm        | **yes**                | no             |

Design rule: **never depend on precise edges.** Avoid thin frames or lines close to the page edge, elements that must
meet exactly across the spine, and tight outer margins (uneven white strips become visible). Generous margins hide
all of these. Trimming the bound booklet's edges fixes cut differences and creep.

### Unprintable border

Home printers can't print to the paper edge: there's roughly 3–5 mm of blank at every sheet edge (to be measured for
our printer). Which page edges that hits depends on where the page sat on the A4 sheet:

- **Spine (fold):** the middle of the sheet, so it is printable and content may cross it.
- **Cut line:** also the middle of the A4 sheet, so it is printable.
- **A4 outer edges:** unprintable.

With the trim model, the dead zone is handled during imposition: the trimmed pages plus bleed are placed inside the
printable area, so the design never has to think about it. (Without trimming, every outer page edge would need a
≥ 5 mm white frame.)

### Bleed

Bleed means printing *beyond* the final cut line so a color or image reaches the edge cleanly after trimming.

- It only matters if something should touch a page edge **and** that edge gets trimmed afterwards.
- On the knife-cut edge: a knife cut is not perfectly precise. Either keep content away from the cut, or run color
  across the cut line on purpose (that is bleed).
- Trimming the finished booklet's open edge (after binding) is possible with a knife too, and also fixes creep.
  It is optional.

### Inside (spine) margin

Pages near the spine curve into the binding, so the inside margin needs extra room. Margins are **mirrored**: the
inside is on the left for right-hand pages and on the right for left-hand pages. Design on the real page size with
asymmetric margins (`inside`/`outside` in Typst). Don't shrink the page. Details: Phase 1.2.

### Duplex flip direction

For sheets folded along the long side, the printer must flip on the **short edge**. The wrong setting puts every back
side upside down. Check this once with a test print.

### Creep

With many nested sheets, the inner ones stick out at the open edge because of paper thickness. It's negligible up to
about 8–10 sheets (32–40 pages). It can be fixed by trimming after binding.

### Binding

- **Sewing** (likely): a pamphlet stitch through 3 or 5 holes along the fold. It needs a needle, an awl and thread.
  It's well suited to A6.
- **Stapling** needs a long-reach stapler to reach the fold.

## Open questions

- Our printer's unprintable border, in mm (measure in the 1.3 experiment). It fixes the exact trim size.
- Trimming a sewn booklet with a knife: how clean is it in practice?
- A6 imposition variant: two copies vs. cut-and-stack (leaning: cut-and-stack).

## Our printer

Brother DCP-L2532DW. The tray accepts A4, Letter, A5, A5 (long edge), A6 and Executive. **Automatic duplex: A4 only.**
Other sizes can be duplexed manually (print the fronts, flip the stack, print the backs). A4 stays the default: it
supports auto duplex and is the easiest paper to buy.
