// Format test booklet: shows the physical model of a format on real pages.
// Black only (laser printer): line styles, hatching and dots, no grey fills.
#import "/lib/formats.typ": a6-home
#import "/lib/template.typ": booklet, is-right, current-work-box

#let fmt = a6-home
#let P = fmt.page
#let m = fmt.physical

#let mm(x) = str(calc.round(x.mm(), digits: 1))

// ---- styles (shared by pages and legend) ----
#let s-work = 0.8pt + black
#let s-tick = 0.4pt + black
#let hatch = tiling(size: (2mm, 2mm), place(line(start: (0mm, 2mm), end: (2mm, 0mm), stroke: 0.25pt + black)))

// ---- grids, anchored to the spine side and top of the working area ----
#let step = 5mm
#let dot-grid(c, right) = {
  let nx = int(c.width / step)
  let ny = int(c.height / step)
  for i in range(nx + 1) {
    for j in range(ny + 1) {
      let x = if right { c.x + i * step } else { c.x + c.width - i * step }
      place(dx: x - 0.25mm, dy: c.y + j * step - 0.25mm, circle(radius: 0.25mm, fill: black, stroke: none))
    }
  }
}
#let line-grid(c, right, vertical: true) = {
  let st = 0.2pt + black
  for j in range(1, int(c.height / step) + 1) {
    place(dx: c.x, dy: c.y + j * step, line(length: c.width, stroke: st))
  }
  if vertical {
    for i in range(1, int(c.width / step) + 1) {
      let x = if right { c.x + i * step } else { c.x + c.width - i * step }
      place(dx: x, dy: c.y, line(length: c.height, angle: 90deg, stroke: st))
    }
  }
}

// ---- rulers: ticks every 1 mm from the page edge inward ----
// After printing, the first tick you can see = the real dead zone.
#let ruler(edge, right) = {
  let n = 10
  // white backing over the hatched margin so ticks stay readable
  if edge == "top" { place(dx: P.width / 2 - 4mm, dy: 0mm, rect(width: 8mm, height: m.top, fill: white)) }
  if edge == "bottom" { place(dx: P.width / 2 - 4mm, dy: P.height - m.bottom, rect(width: 8mm, height: m.bottom, fill: white)) }
  if edge == "outside" {
    let x = if right { P.width - m.outside } else { 0mm }
    place(dx: x, dy: P.height / 2 - 4mm, rect(width: m.outside, height: 8mm, fill: white))
  }
  for i in range(n + 1) {
    let len = if calc.rem(i, 5) == 0 { 4mm } else { 2mm }
    let d = i * 1mm
    if edge == "top" or edge == "bottom" {
      let cx = P.width / 2
      let y = if edge == "top" { d } else { P.height - d }
      place(dx: cx - len / 2, dy: y, line(length: len, stroke: s-tick))
      if i == 5 or i == 10 {
        place(dx: cx + 2.5mm, dy: y - 1.3mm, text(size: 4.5pt)[#i])
      }
    } else {
      // outside edge
      let cy = P.height / 2
      let x = if right { P.width - d } else { d }
      place(dx: x, dy: cy - len / 2, line(length: len, angle: 90deg, stroke: s-tick))
      if i == 5 or i == 10 {
        place(dx: x - 1mm, dy: cy + 2.5mm, text(size: 4.5pt)[#i])
      }
    }
  }
}

// ---- what each page shows (by page number) ----
#let grid-for = (
  "3": "dots", "4": "lines", "5": "squares", "6": "dots", "7": "squares",
)

#let page-background = context {
  let p = here().page()
  let right = is-right()
  let c = current-work-box()

  // physical margins: hatched
  place(rect(width: P.width, height: P.height, fill: hatch, stroke: none))
  place(dx: c.x, dy: c.y, rect(width: c.width, height: c.height, fill: white, stroke: none))

  // sample grids
  let g = grid-for.at(str(p), default: none)
  if g == "dots" { dot-grid(c, right) }
  if g == "lines" { line-grid(c, right, vertical: false) }
  if g == "squares" { line-grid(c, right) }

  // working area outline
  place(dx: c.x, dy: c.y, rect(width: c.width, height: c.height, stroke: s-work))

  // rulers on the three edges that touch the sheet edge or the cut
  for edge in ("top", "bottom", "outside") { ruler(edge, right) }

  // spine label in the inside margin
  let sx = if right { 0mm } else { P.width - m.inside }
  place(dx: sx, dy: P.height / 2 - 8mm, box(width: m.inside, height: 16mm, fill: white,
    align(center + horizon, rotate(-90deg, reflow: true, text(size: 5pt, weight: "bold", tracking: 1pt)[SPINE]))))
}

#show: booklet.with(format: fmt, background: page-background)
#set text(size: 7pt)
#set par(spacing: 0.9em)

// label box so text stays readable over grids
#let tag(body) = box(fill: white, inset: 1.2mm, body)

#let page-label = context {
  let p = here().page()
  let side = if calc.odd(p) { "right" } else { "left" }
  let g = grid-for.at(str(p), default: none)
  let desc = if g == none { "" } else { (dots: "dot grid", lines: "lines", squares: "squared").at(g) }
  align(if calc.odd(p) { right } else { left }, tag[
    #text(size: 14pt, weight: "bold")[#p] \
    #side page #if desc != "" [· #desc 5 mm]
  ])
}

// ---- page 1: cover ----
#v(1fr)
#align(center, tag[
  #text(size: 13pt, weight: "bold")[Format test] \
  #text(size: 9pt)[a6-home]
  #v(3mm)
  #table(
    columns: 2,
    stroke: none,
    align: (right, left),
    inset: 1.2mm,
    [page], [#mm(P.width) × #mm(P.height) mm],
    [sheet], [A4, 4 pages per side],
    [dead zone], [#mm(fmt.dead-zone) mm],
    [spine], [#mm(fmt.spine) mm],
    [working area], [#mm(P.width - m.inside - m.outside) × #mm(P.height - m.top - m.bottom) mm],
  )
  #v(2mm)
  page 1 · right page
])
#v(1fr)

#pagebreak()
// ---- page 2: legend ----
#page-label
#v(2mm)
#tag[
  #set text(size: 7pt)
  #text(size: 9pt, weight: "bold")[Legend]
  #v(1mm)
  #let sw(body) = box(width: 9mm, height: 4mm, baseline: 25%, body)
  #grid(
    columns: (10mm, 1fr),
    row-gutter: 2.5mm,
    align: horizon,
    sw(rect(width: 9mm, height: 4mm, fill: hatch, stroke: none)),
    [*physical margin*: no content. Outside, top, bottom #mm(m.outside) mm (printer dead zone / gap at the cut). Inside #mm(m.inside) mm (binding).],
    sw(rect(width: 9mm, height: 4mm, stroke: s-work)),
    [*working area*: everything a design may use, #mm(P.width - m.inside - m.outside) × #mm(P.height - m.top - m.bottom) mm.],
    sw(align(center + horizon, stack(dir: ttb, spacing: 0.8mm, ..range(3).map(_ => line(length: 2mm, stroke: s-tick))))),
    [*rulers*: ticks every 1 mm from the page edge, on top, bottom and outside. The first tick that printed = the real dead zone.],
    sw(align(center + horizon, text(size: 5pt, weight: "bold", tracking: 1pt)[SPINE])),
    [*spine*: the fold. Always on the inside: left on right pages, right on left pages.],
  )
  #v(1mm)
  Grids on pages 3–7 start at the spine side and the top, so they continue straight across a spread.
]

// ---- pages 3–7: grid samples ----
#for _ in range(5) {
  pagebreak()
  page-label
}

#pagebreak()
// ---- page 8: back cover / checklist ----
#page-label
#v(2mm)
#tag[
  #text(size: 9pt, weight: "bold")[After printing, check]
  #v(1mm)
  + *Dead zone:* read the rulers on the sheet edges. Update `dead-zone` in `lib/formats.typ`.
  + *Cut line:* rulers at the cut should print fully (it's mid-sheet).
  + *Page order:* 1 to 8 after cutting, folding and nesting.
  + *Duplex:* backs upright, page numbers line up front to back.
  + *Spine:* SPINE labels sit at the fold, on every page.
  + *Spreads:* grids continue across the fold.
  + *Working area:* comfortable to write in, nothing lost at the spine.
]
