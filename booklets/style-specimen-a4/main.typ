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

// =====================================================================
// E · line weights: is each step of the scale visibly different?
// =====================================================================
// Black only (grey prints as a checkered halftone). Weights are whole printer dots: a laser
// draws a line as N dots (600 dpi, 1 dot = 0.12 pt), so steps between dot counts are what exist.
// Print it at each driver quality (300 / 600 / 1200 dpi) and from more than one PDF app: where the
// ladder stops changing is the real floor of that print path.
#let dot-w = 72pt / 600
#let dw(n) = n * dot-w
#let ladder = (1, 2, 3, 4, 5, 6, 8, 10, 12, 16)
#let wlabel(n) = [#n #if n == 1 [dot] else [dots] #pt(dw(n))]
// the library's named weights, as the nearest dot count, to place them on the ladder
#let named-at(n) = weights.pairs().filter(((k, v)) => calc.round(v / dot-w) == n).map(((k, v)) => [#k #pt(v)])

#pagebreak()
#code-counter.update(0)
#sheet("E", "Line weights", [Which steps can you tell apart? Pick a scale (quiet · regular · strong) whose levels separate at a glance. Black only; weights in printer dots (600 dpi). Note the print quality and app you used.])

#subhead[1 · ladder: tick the weights you would use]
#for n in ladder {
  grid(columns: (52mm, 1fr), align: horizon,
    tag(next-code("E"), (wlabel(n), ..named-at(n))),
    line(length: 100%, stroke: dw(n) + black))
  v(2.2mm)
}

#subhead[2 · neighbours on the ladder, interleaved: tick if the two read as different]
#let interleave(a, b) = stack(spacing: 2.2mm, ..range(6).map(i => line(length: 100%, stroke: dw(if calc.even(i) { a } else { b }) + black)))
#grid(columns: (1fr,) * 3, column-gutter: 6mm, row-gutter: 4mm,
  ..range(ladder.len() - 1).map(i => {
    let (a, b) = (ladder.at(i), ladder.at(i + 1))
    swatch(next-code("E"), ([#a vs #b dots], [#pt(dw(a)) / #pt(dw(b))]), 12mm, pad(top: 0.5mm, interleave(a, b)))
  }))

#subhead[3 · three-level scales on a table: tick the one where you see three levels]
// frame + header = strong, before the weekend = regular, rows and columns = quiet
#let scales = ((2, 4, 8), (2, 5, 10), (2, 6, 12), (3, 6, 12), (2, 4, 12), (3, 5, 8), (4, 8, 16), (2, 5, 8))
#grid(columns: (1fr,) * 4, column-gutter: 5mm, row-gutter: 4mm,
  ..scales.map(((q, r, st)) => block(breakable: false, {
    tag(next-code("E"), ([#q · #r · #st dots],))
    v(1mm)
    week-table(dw(st) + black, dw(r) + black, dw(q) + black)
  })))
#txt(sizes.tiny)[Now in `lib/style.typ`: hairline 0.25 pt ≈ 2 dots · thin 0.4 pt ≈ 3 · regular 0.6 pt = 5 · strong 1 pt ≈ 8 · heavy 1.5 pt ≈ 12.]

// =====================================================================
// F · faint tables
// =====================================================================
#pagebreak()
#code-counter.update(0)
#sheet("F", "Faint tables", [How faint can a table go and still read? Left: hierarchy by weight, all one grey. Right: hierarchy by grey, light weights.])
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

#subhead[named sizes]
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
    place(dots(step: step, dot: dot-sizes.s)) // the chosen grid dot (B2/B18)
    place(dx: step, dy: 2 * step - lift, text(font: font, size: size, top-edge: "baseline", bottom-edge: "baseline", body))
  })
}
#for s in (steps.standard, steps.weeks) {
  subhead[#step-name(s) step]
  for font in (fonts.text, fonts.hand) {
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
