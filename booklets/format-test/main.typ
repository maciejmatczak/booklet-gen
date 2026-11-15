// Print specimen for the a6-home format and the shared style.
// Shows the physical model (margins, spine, rulers) and tests what the printer can do:
// grids, dot sizes, line weights, dashes, grey, tables, fonts, text sized to grid rows.
// Black only (laser printer).
#import "/lib/lib.typ": *

#let fmt = a6-home
#let P = fmt.page
#let m = fmt.physical
#let W = P.width - m.inside - m.outside // working area
#let H = P.height - m.top - m.bottom

#let mm(x) = str(calc.round(x.mm(), digits: 2))
#let pt(x) = str(calc.round(x.pt(), digits: 2)) + "pt"
#let pct(x) = str(calc.round(x / 1%)) + "%"
#let at(x, y, body) = place(top + left, dx: x, dy: y, body)
#let label(body) = txt(sizes.tiny, body)

// =====================================================================
// Page background: physical model, on every page
// =====================================================================
#let s-tick = 0.4pt + black
#let hatch = tiling(size: (2mm, 2mm), place(line(start: (0mm, 2mm), end: (2mm, 0mm), stroke: 0.25pt + black)))

// Rulers: ticks every 1 mm from the page edge inward, within the physical margin.
// After printing, the first tick you can see = the real dead zone.
#let ruler(edge, right) = {
  if edge == "top" { place(dx: P.width / 2 - 4mm, dy: 0mm, rect(width: 8mm, height: m.top, fill: white)) }
  if edge == "bottom" { place(dx: P.width / 2 - 4mm, dy: P.height - m.bottom, rect(width: 8mm, height: m.bottom, fill: white)) }
  if edge == "outside" {
    let x = if right { P.width - m.outside } else { 0mm }
    place(dx: x, dy: P.height / 2 - 4mm, rect(width: m.outside, height: 8mm, fill: white))
  }
  let depth = if edge == "outside" { m.outside } else { m.top }
  for i in range(int(depth / 1mm) + 1) {
    let len = if calc.rem(i, 5) == 0 { 4mm } else { 2mm }
    let d = i * 1mm
    if edge in ("top", "bottom") {
      let y = if edge == "top" { d } else { P.height - d }
      place(dx: P.width / 2 - len / 2, dy: y, line(length: len, stroke: s-tick))
      if i == 5 { place(dx: P.width / 2 + 2.5mm, dy: y - 1.3mm, text(size: 4.5pt)[#i]) }
    } else {
      let x = if right { P.width - d } else { d }
      place(dx: x, dy: P.height / 2 - len / 2, line(length: len, angle: 90deg, stroke: s-tick))
      if i == 5 { place(dx: x - 1mm, dy: P.height / 2 + 2.5mm, text(size: 4.5pt)[#i]) }
    }
  }
}

#let page-background = context {
  let right = is-right()
  let c = current-work-box()
  place(rect(width: P.width, height: P.height, fill: hatch, stroke: none))
  place(dx: c.x, dy: c.y, rect(width: c.width, height: c.height, fill: white, stroke: 0.8pt + black))
  for edge in ("top", "bottom", "outside") { ruler(edge, right) }
  let sx = if right { 0mm } else { P.width - m.inside }
  place(dx: sx, dy: P.height / 2 - 8mm, box(width: m.inside, height: 16mm, fill: white,
    align(center + horizon, rotate(-90deg, reflow: true, text(size: 5pt, weight: "bold", tracking: 1pt)[SPINE]))))
}

#show: booklet.with(format: fmt, background: page-background)
#set par(spacing: 0.9em)

// Page header: number, side, title. Occupies the top 9 mm of the working area.
#let header-h = 9mm
#let header(title) = context {
  let p = here().page()
  let side = if calc.odd(p) { "right" } else { "left" }
  at(1.5mm, 1.5mm, box(fill: white, inset: 0.5mm)[
    #txt(sizes.large)[*#p*] #h(1mm) #label[#side page · #title]
  ])
}
#let body-y = header-h + 1mm

// Labelled frame with something drawn inside it.
#let sample(x, y, w, h, name, body) = {
  at(x, y, label(name))
  at(x, y + 2.5mm, box(width: w, height: h, stroke: pen("thin"), clip: true, body))
}

// =====================================================================
// 1 · cover
// =====================================================================
#v(1fr)
#align(center)[
  #txt(sizes.title)[*Print specimen*] \
  #txt(sizes.large)[a6-home · black only]
  #v(3mm)
  #table(
    columns: 2, stroke: none, align: (right, left), inset: 1.2mm,
    [page], [#mm(P.width) × #mm(P.height) mm],
    [sheet], [A4, 4 pages per side],
    [dead zone], [#mm(fmt.dead-zone) mm (estimate)],
    [spine], [#mm(fmt.spine) mm],
    [top / bottom], [#mm(m.top) mm],
    [working area], [#mm(W) × #mm(H) mm],
    [font], [#fonts.text / #fonts.small],
  )
  #v(2mm)
  #label[page 1 · right page]
]
#v(1fr)

// =====================================================================
// 2 · legend
// =====================================================================
#pagebreak()
#header[legend]
#at(1.5mm, body-y + 2mm, block(width: W - 3mm)[
  #set text(size: sizes.small)
  #let sw(body) = box(width: 9mm, height: 4mm, baseline: 25%, body)
  #grid(
    columns: (10mm, 1fr), row-gutter: 3mm, align: horizon,
    sw(rect(width: 9mm, height: 4mm, fill: hatch, stroke: none)),
    [*physical margin*: no content. Outside #mm(m.outside) mm (dead zone), top/bottom #mm(m.top) mm (dead zone / gap at the cut), inside #mm(m.inside) mm (binding).],
    sw(rect(width: 9mm, height: 4mm, stroke: 0.8pt + black)),
    [*working area*: everything a design may use, #mm(W) × #mm(H) mm.],
    sw(align(center + horizon, stack(dir: ttb, spacing: 0.8mm, ..range(3).map(_ => line(length: 2mm, stroke: s-tick))))),
    [*rulers*: ticks every 1 mm from the page edge, on top, bottom and outside. The first tick that printed = the real dead zone.],
    sw(align(center + horizon, text(size: 5pt, weight: "bold", tracking: 1pt)[SPINE])),
    [*spine*: the fold. Inside edge: left on right pages, right on left pages.],
  )
  #v(4mm)
  *Pages* \
  3 grid kinds · 4 dot sizes · 5 lines, dashes, grey · 6 tables · 7 fonts · 8–9 text on grid rows · 10–11 spread across the fold · 12 checklist
])

// =====================================================================
// 3 · grid kinds × steps
// =====================================================================
#pagebreak()
#header[grid kinds × steps]
#{
  let cw = (W - 6mm) / 2
  let ch = 32mm
  let cols = (("standard 5 mm", steps.standard), ("weeks 3.55 mm", steps.weeks))
  let kinds = (
    ("dots", s => dots(step: s)),
    ("lines", s => lines(step: s)),
    ("squares", s => squares(step: s)),
  )
  for (i, (cname, s)) in cols.enumerate() {
    for (j, (kname, draw)) in kinds.enumerate() {
      sample(2mm + i * (cw + 2mm), body-y + j * (ch + 6mm), cw, ch, [#kname · #cname], draw(s))
    }
  }
}

// =====================================================================
// 4 · dot sizes
// =====================================================================
#pagebreak()
#header[dot sizes × steps]
#{
  let cw = (W - 6mm) / 2
  let ch = 23mm
  let cols = (("5 mm", steps.standard), ("3.55 mm", steps.weeks))
  for (i, (cname, s)) in cols.enumerate() {
    for (j, (dname, d)) in dot-sizes.pairs().enumerate() {
      sample(2mm + i * (cw + 2mm), body-y + j * (ch + 6mm), cw, ch, [#dname #mm(d) mm · #cname], dots(step: s, dot: d))
    }
  }
}

// =====================================================================
// 5 · line weights, dashes, grey
// =====================================================================
#pagebreak()
#header[line weights · dashes · grey]
#{
  let x = 2mm
  let len = W - 30mm
  let rows = ()
  rows.push(("title", [*weights*]))
  for (name, w) in weights.pairs() { rows.push(("line", [#name #pt(w)], pen(name))) }
  rows.push(("title", [*dashes* (thin)]))
  for name in dashes.keys() { rows.push(("line", name, pen("thin", dash: name))) }
  rows.push(("title", [*grey test*: clean or grainy?]))
  for g in (40%, 60%, 80%) { rows.push(("line", [grey #pct(g) thin], (paint: luma(100% - g), thickness: weights.thin))) }
  for g in (40%, 60%) { rows.push(("line", [grey #pct(g) regular], (paint: luma(100% - g), thickness: weights.regular))) }
  let y = body-y + 2mm
  for r in rows {
    if r.at(0) == "title" {
      y += 2mm
      at(x, y, txt(sizes.small, r.at(1)))
    } else {
      at(x, y, label(r.at(1)))
      at(x + 24mm, y + 1mm, line(length: len, stroke: r.at(2)))
    }
    y += 5mm
  }
  at(x, y, label[grey 60% dots, 3.55 mm])
  at(x + 24mm, y, box(width: len, height: 14mm, stroke: pen("thin"), clip: true,
    layout(sz => for xx in range(int(sz.width / steps.weeks) + 1) {
      for yy in range(int(sz.height / steps.weeks) + 1) {
        place(dx: xx * steps.weeks - 0.2mm, dy: yy * steps.weeks - 0.2mm, circle(radius: 0.2mm, fill: luma(40%), stroke: none))
      }
    })))
}

// =====================================================================
// 6 · tables mixing line weights
// =====================================================================
#pagebreak()
#header[tables · mixed line weights]
#let days = ("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")
#let week-table(inner, section) = {
  set text(size: sizes.small)
  table(
    columns: (10mm, 1fr, 7mm),
    rows: 5mm,
    align: horizon,
    inset: (x: 1.5mm),
    stroke: none,
    table.vline(x: 0, stroke: pen("strong")),
    table.vline(x: 1, stroke: inner),
    table.vline(x: 2, stroke: inner),
    table.vline(x: 3, stroke: pen("strong")),
    table.hline(stroke: pen("strong")),
    table.header([*Day*], [*Plan*], [*✓*]),
    table.hline(stroke: pen("strong")),
    ..for (i, d) in days.enumerate() {
      let row = (d, [], [])
      if i == 5 { (table.hline(stroke: section), ..row) } // weekend section
      else if i > 0 { (table.hline(stroke: inner), ..row) }
      else { row }
    },
    table.hline(stroke: pen("strong")),
  )
}
#at(2mm, body-y + 1mm, block(width: W - 4mm)[
  #label[A · frame + header strong, inner hairline, weekend separated by regular]
  #week-table(pen("hairline"), pen("regular"))
  #v(2mm)
  #label[B · frame + header strong, inner thin dotted, weekend separated by thin]
  #week-table(pen("thin", dash: "dotted"), pen("thin"))
])

// =====================================================================
// 7 · fonts
// =====================================================================
#pagebreak()
#header[fonts]
#at(2mm, body-y + 1mm, block(width: W - 4mm)[
  #txt(sizes.small)[*named sizes* (Literata 7pt used at ≤ 7.5pt automatically)]
  #v(1mm)
  #for (name, s) in sizes.pairs() [
    #label[#name #pt(s)] \
    #txt(s)[Notes, plans & 0123456789]
    #v(0.5mm)
  ]
  #v(2mm)
  #txt(sizes.small)[*Literata vs Literata 7pt* at small sizes]
  #v(1mm)
  #table(
    columns: (9mm, 1fr, 1fr), stroke: none, inset: (x: 0mm, y: 1mm),
    label[size], label[Literata], label[Literata 7pt],
    ..for s in (5pt, 5.5pt, 6pt, 6.5pt, 7pt) {
      (label[#pt(s)], text(font: fonts.text, size: s)[Mon 14 · 09:30 call], text(font: fonts.small, size: s)[Mon 14 · 09:30 call])
    }
  )
])

// =====================================================================
// 8–9 · text sized to grid rows
// =====================================================================
// Each sample: a label, then two text rows with baselines on the grid rows,
// like handwriting on the paper's grid. Cap height is shown as % of the row.
#let rows-page(step, sizes-to-try) = {
  let gy = body-y + 1mm
  at(0mm, gy, dots(width: W, height: H - gy, step: step, dot: dot-sizes.s))
  let row = 1
  for s in sizes-to-try {
    let font = if s <= small-threshold { fonts.small } else { fonts.text }
    let line-at(r, body) = at(step, gy + r * step, {
      set text(font: font, size: s, top-edge: "baseline", bottom-edge: "baseline")
      body
    })
    at(step, gy + row * step - 2.3mm, box(fill: white, inset: 0.3mm, context {
      let caps = measure(text(font: font, size: s, top-edge: "cap-height", bottom-edge: "baseline")[H]).height
      label[#pt(s) · caps #mm(caps) mm = #calc.round(caps / step * 100)% of row · #font]
    }))
    line-at(row + 1)[Call the dentist at 14:30, buy bread]
    line-at(row + 2)[Mon 14 · Tue 15 · Wed 16 · 0123456789]
    row += 4
  }
}

#pagebreak()
#header[text on 5 mm rows]
#rows-page(steps.standard, (7pt, 8pt, 9pt, 10pt, 11pt))

#pagebreak()
#header[text on 3.55 mm rows (Weeks)]
#rows-page(steps.weeks, (5pt, 5.5pt, 6pt, 6.5pt, 7pt, 7.5pt))

// =====================================================================
// 10–11 · spread: grid continuous across the fold
// =====================================================================
// Dots sit at whole steps from the fold, so the grid continues across the spread
// (the 2 × 5 mm spine margin is not a multiple of the step).
#let spread-page = context {
  let right = is-right()
  let step = steps.weeks
  let ph = phase-from(m.inside, step)
  at(0mm, 0mm, dots(width: W, height: H, step: step, dot: dot-sizes.s,
    anchor-x: if right { left } else { right }, phase: (ph, 0mm)))
}

#pagebreak()
#spread-page
#header[3.55 mm dots, aligned to the fold]

#pagebreak()
#spread-page
#header[3.55 mm dots, aligned to the fold]

// =====================================================================
// 12 · checklist
// =====================================================================
#pagebreak()
#header[after printing, check]
#at(2mm, body-y + 2mm, block(width: W - 4mm)[
  #set text(size: sizes.small)
  + *Dead zone:* read the rulers on the sheet edges; update `dead-zone` in `lib/formats.typ`.
  + *Cut line:* rulers at the cut print fully (mid-sheet).
  + *Page order & duplex:* 1–12 in order after folding; backs upright.
  + *Spine:* SPINE labels at the fold on every page.
  + *Grids (3):* which kinds and steps feel right to write on?
  + *Dot sizes (4):* smallest dot that prints cleanly and still guides?
  + *Lines (5):* is hairline visible but quiet? Do dashes look even?
  + *Grey (5):* clean or grainy? Decides if grey joins the style.
  + *Tables (6):* does the strong/hairline hierarchy read clearly?
  + *Fonts (7):* smallest comfortable size; Literata 7pt vs regular.
  + *Text on rows (8–9):* pick one size per grid; it becomes that grid's base text size.
  + *Spread (10–11):* does the 3.55 grid continue across the fold?
])
