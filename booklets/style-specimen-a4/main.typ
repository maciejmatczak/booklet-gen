// Style specimen: one A4 sheet per style decision, printed as is (no imposition, nothing to cut).
// Every sample has a tick box, a code (B7) and its exact values, read from /lib/style.typ:
// tick the ones you like, then come back with the codes.
//   task build -- style-specimen-a4   → print build/style-specimen-a4.pdf at 100 %, one sheet at a time
// Physical checks (dead zone, cutting, folding, spine) are in booklets/format-test-a6-jott-insert.
#import "/lib/lib.typ": *

#set page(paper: "a4", margin: (x: 12mm, top: 12mm, bottom: 14mm),
  footer: context txt(sizes.tiny)[
    style-specimen-a4 #h(1fr) values from `lib/style.typ` · tick the box next to what you choose, note the code #h(1fr) #here().page()
  ])
#set text(font: fonts.text, size: sizes.body)
#set par(spacing: 0.8em)

// ---- helpers ----
#let mm(x) = str(calc.round(x.mm(), digits: 2)) + " mm"
#let pt(x) = str(calc.round(x.pt(), digits: 2)) + " pt"
#let pct(x) = str(calc.round(x / 1%)) + " %"
#let step-name(s) = if s == steps.standard { "5 mm" } else { "3.55 mm" }

// Tick box + code + values: the mark you make on paper.
#let tickbox = box(width: 2.8mm, height: 2.8mm, stroke: 0.5pt + black, baseline: 0.5mm)
#let tag(id, vals) = box(txt(sizes.small)[#tickbox #h(0.8mm) *#id* #h(0.6mm) #txt(sizes.tiny, vals.join(" · "))])

// A labelled sample: tag above, then the drawing at a fixed height.
#let swatch(id, vals, height, body) = block(width: 100%, breakable: false, spacing: 0mm, {
  tag(id, vals)
  v(1.2mm)
  box(width: 100%, height: height, clip: true, body)
})

#let sheet(code, title, question) = block(width: 100%, below: 4mm, {
  grid(columns: (auto, 1fr), column-gutter: 4mm, align: horizon,
    text(size: 30pt, weight: "bold")[#code],
    [#txt(sizes.title)[*#title*] \ #txt(sizes.body)[#question]],
  )
  v(1mm)
  line(length: 100%, stroke: pen("thin"))
})
#let subhead(body) = block(above: 3mm, below: 2mm, txt(sizes.body)[*#body*])

// Codes count up per sheet: B1, B2, …
#let code-counter = counter("code")
#let next-code(letter) = { code-counter.step(); context [#letter#code-counter.get().first()] }

// =====================================================================
// A · what to write on
// =====================================================================
// Kind and step only: every grid drawn at one calm default, so the style doesn't decide for you.
#let A-dot = dot-sizes.s
#let A-grey = greys.mid
#let A-weight = "hairline"
#code-counter.update(0)
#sheet("A", "What to write on", [Which grid kind and step? Write a few lines in each field. Style is fixed here: dots #mm(A-dot) at #pct(A-grey), lines #A-weight #pt(weights.at(A-weight)) at #pct(A-grey); sheets B–D choose it.])
#grid(
  columns: (1fr, 1fr), column-gutter: 6mm, row-gutter: 6mm,
  ..for (kind, draw) in (
    ("dots", s => dots(step: s, dot: A-dot, paint: ink(A-grey))),
    ("lines", s => lines(step: s, stroke: pen(A-weight, grey: "mid"))),
    ("squares", s => squares(step: s, stroke: pen(A-weight, grey: "mid"))),
  ) {
    for s in (steps.standard, steps.weeks) {
      (swatch(next-code("A"), (kind, step-name(s)), 68mm, draw(s)),)
    }
  }
)

// =====================================================================
// B · dots
// =====================================================================
#pagebreak()
#code-counter.update(0)
#sheet("B", "Dots", [Which dot size and grey, for each step? The lightest that still guides your writing.])
#for s in (steps.standard, steps.weeks) {
  subhead[#step-name(s) step]
  grid(columns: (1fr,) * 4, column-gutter: 4mm, row-gutter: 4mm,
    ..for (gname, g) in greys.pairs() {
      for (dname, d) in dot-sizes.pairs() {
        (swatch(next-code("B"), ([dot #dname #mm(d)], [#gname #pct(g)]), 19mm,
          dots(step: s, dot: d, paint: ink(g))),)
      }
    })
}

// =====================================================================
// C · lines, D · squares
// =====================================================================
#let line-weights = ("hairline", "thin", "regular")
#let weight-sheet(letter, kind, draw) = {
  pagebreak()
  code-counter.update(0)
  sheet(letter, kind, [Which line weight and grey for a #lower(kind) grid, for each step?])
  for s in (steps.standard, steps.weeks) {
    subhead[#step-name(s) step]
    grid(columns: (1fr,) * 4, column-gutter: 4mm, row-gutter: 4mm,
      ..for w in line-weights {
        for (gname, g) in greys.pairs() {
          (swatch(next-code(letter), ([#w #pt(weights.at(w))], [#gname #pct(g)]), 29mm,
            draw(s, pen(w, grey: gname))),)
        }
      })
  }
}
#weight-sheet("C", "Lines", (s, st) => lines(step: s, stroke: st))
#weight-sheet("D", "Squares", (s, st) => squares(step: s, stroke: st))

// =====================================================================
// E · line weights (reference for rules)
// =====================================================================
#pagebreak()
#code-counter.update(0)
#sheet("E", "Line weights", [Rules for pages and tables: which weights and greys read as strong, regular, quiet? Three parallel rules, 3.55 mm apart.])
#let rules(st) = stack(spacing: steps.weeks - 0pt, ..range(3).map(_ => line(length: 100%, stroke: st)))
#subhead[weight × grey (solid)]
#grid(columns: (1fr,) * 4, column-gutter: 5mm, row-gutter: 5mm,
  ..for (w, wv) in weights.pairs() {
    for (gname, g) in greys.pairs() {
      (swatch(next-code("E"), ([#w #pt(wv)], [#gname #pct(g)]), 9mm, pad(top: 1mm, rules(pen(w, grey: gname)))),)
    }
  })
#subhead[dashes × weight (black)]
#grid(columns: (1fr,) * 3, column-gutter: 5mm, row-gutter: 5mm,
  ..for d in dashes.keys().filter(d => d != "solid") {
    for w in ("hairline", "thin", "regular") {
      (swatch(next-code("E"), (d, [#w #pt(weights.at(w))]), 9mm, pad(top: 1mm, rules(pen(w, dash: d)))),)
    }
  })

// =====================================================================
// F · faint tables
// =====================================================================
#pagebreak()
#code-counter.update(0)
#sheet("F", "Faint tables", [How faint can a table go and still read? Left: hierarchy by weight, all one grey. Right: hierarchy by grey, light weights.])
#let days = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
// roles: frame (outline + header rule), section (before the weekend), inner (rows, columns)
#let week-table(frame, section, inner) = {
  set text(size: sizes.small)
  table(
    columns: (10mm, 1fr, 7mm), rows: 4.6mm, align: horizon, inset: (x: 1.5mm), stroke: none,
    table.vline(x: 0, stroke: frame), table.vline(x: 1, stroke: inner),
    table.vline(x: 2, stroke: inner), table.vline(x: 3, stroke: frame),
    table.hline(stroke: frame),
    table.header([*Day*], [*Plan*], [*✓*]),
    table.hline(stroke: frame),
    ..for (i, d) in days.enumerate() {
      let row = (d, [], [])
      if i == 5 { (table.hline(stroke: section), ..row) }
      else if i > 0 { (table.hline(stroke: inner), ..row) }
      else { row }
    },
    table.hline(stroke: frame),
  )
}
#let role(name, w, g) = [#name #w #pt(weights.at(w)) #pct(greys.at(g))]
// left: strong / regular / hairline, the whole table in one grey
#let by-weight = greys.keys().map(g => (("strong", g), ("regular", g), ("hairline", g)))
// right: thin / thin / hairline, the hierarchy in grey
#let by-grey = (
  (("thin", "black"), ("thin", "mid"), ("hairline", "mid")),
  (("thin", "dark"), ("thin", "light"), ("hairline", "light")),
  (("thin", "mid"), ("hairline", "mid"), ("hairline", "light")),
  (("hairline", "mid"), ("hairline", "light"), ("hairline", "light")),
)
#grid(columns: (1fr, 1fr), column-gutter: 8mm, row-gutter: 6mm,
  ..range(8).map(k => if calc.even(k) { by-weight.at(int(k / 2)) } else { by-grey.at(int(k / 2)) }).map(t => {
    let ((fw, fg), (sw, sg), (iw, ig)) = t
    block(breakable: false, {
      tag(next-code("F"), ())
      v(0.5mm)
      txt(sizes.tiny)[#role("frame", fw, fg) · #role("section", sw, sg) · #role("inner", iw, ig)]
      v(1mm)
      week-table(pen(fw, grey: fg), pen(sw, grey: sg), pen(iw, grey: ig))
    })
  }))

// =====================================================================
// G · fonts
// =====================================================================
#pagebreak()
#code-counter.update(0)
#sheet("G", "Fonts", [Every font and style in use: which sizes are comfortable, which styles read well small?])
#let sample-text = [Notes, plans & 0123456789 · Środa, 11 listopada · żółć ĄĘŁŃŚŹ]
#let row(id, vals, body) = grid(columns: (58mm, 1fr), align: horizon, tag(id, vals), body)

#subhead[named sizes (Literata 7pt used at ≤ #pt(small-threshold) automatically)]
#for (name, s) in sizes.pairs() {
  row(next-code("G"), ([#name #pt(s)], if s <= small-threshold { fonts.small } else { fonts.text }), txt(s, sample-text))
  v(1.5mm)
}

#subhead[fonts and styles]
#for (font, size, styles) in (
  (fonts.text, sizes.body, (("regular", (:)), ("italic", (style: "italic")), ("bold", (weight: "bold")), ("light", (weight: "light")))),
  (fonts.small, sizes.small, (("regular", (:)), ("italic", (style: "italic")), ("bold", (weight: "bold")), ("bold tracked 0.3 pt", (weight: "bold", tracking: 0.3pt)))),
  (fonts.hand, 10pt, (("regular", (:)), ("bold", (weight: "bold")))),
) {
  for (sname, args) in styles {
    row(next-code("G"), (font, sname, pt(size)), text(font: font, size: size, ..args, sample-text))
    v(1.5mm)
  }
}

#subhead[Literata vs Literata 7pt at small sizes]
#for s in (5pt, 5.5pt, 6pt, 6.5pt, 7pt, 7.5pt) {
  grid(columns: (1fr, 1fr), column-gutter: 4mm, align: horizon,
    ..(fonts.text, fonts.small).map(f => grid(columns: (34mm, 1fr), align: horizon,
      tag(next-code("G"), (f, pt(s))), text(font: f, size: s)[Pon 14 · 09:30 dentysta, chleb]))
  )
  v(1.5mm)
}

// =====================================================================
// H · text on grid rows
// =====================================================================
// Text on a grid row takes its size from the step: x-height = share × step (lib/style.typ → grid-size).
// The share is the decision; it applies to every font at once.
#pagebreak()
#code-counter.update(0)
#sheet("H", "Text on grid rows", [Printed notes sitting on a grid row (holidays, birthdays): which x-height share of the step? Now: #grid-x-share.])
#let shares = (0.24, 0.28, 0.32)
#let on-row(step, font, share, body) = {
  let size = step * share / font-metrics.at(font).x
  let lift = size * font-metrics.at(font).desc + 0.1mm
  box(width: 100%, height: 2 * step + 0.01mm, {
    place(dots(step: step, dot: dot-sizes.s, paint: ink(greys.mid)))
    place(dx: step, dy: 2 * step - lift, text(font: font, size: size, top-edge: "baseline", bottom-edge: "baseline", body))
  })
}
#for s in (steps.standard, steps.weeks) {
  subhead[#step-name(s) step]
  for font in (fonts.small, fonts.text, fonts.hand) {
    for sh in shares {
      let size = s * sh / font-metrics.at(font).x
      grid(columns: (62mm, 1fr), align: bottom,
        pad(bottom: 0.6mm, tag(next-code("H"), ([share #sh], font, pt(size)))),
        on-row(s, font, sh)[Święto Niepodległości · Imieniny Marcina · T45 · LISTOPAD],
      )
      v(1mm)
    }
  }
}
