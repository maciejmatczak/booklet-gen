// Recurring-chore tracker (Alastair method): one row per chore, a name field, then one mark position per
// week or month. A spread is a name field on the left page, the time columns after it; when they don't fit
// on the right page, the first months move to the left page beside the names, so the fold falls on a
// month (quarter) boundary.
//
// Two styles share this geometry and differ only in roles (style.typ): classic (a table) and modern
// (a grey field per chore flowing into the chore's axis).
#import "/lib/lib.typ": *
#import "/lib/components/day-list.typ": in-role, months-nom

// ==== dates ====

// Mondays of a year (each starts a week column).
#let mondays(year) = {
  let d = datetime(year: year, month: 1, day: 1)
  d = d + duration(days: calc.rem(8 - d.weekday(), 7))
  let out = ()
  while d.year() == year {
    out.push(d)
    d = d + duration(days: 7)
  }
  out
}

#let month-short(m) = months-nom.at(m - 1).clusters().slice(0, 3).join() // "sty", "paź"

// Time columns: top = label above (month or quarter), sub = label on the column, strong = boundary on its left.
#let week-cols(ds) = ds.enumerate().map(((j, d)) => {
  let new-month = j == 0 or ds.at(j - 1).month() != d.month()
  (top: if new-month { month-short(d.month()) } else { none }, sub: str(d.day()), strong: new-month)
})
#let month-cols() = range(1, 13).map(m => {
  let q = calc.rem(m - 1, 3) == 0
  (top: if q { "Q" + str(int((m - 1) / 3) + 1) } else { none }, sub: month-short(m), strong: q)
})

// ==== drawing helpers (coordinates in the working area) ====

#let _h(x, y, l, s) = place(top + left, dx: x, dy: y, line(length: l, stroke: s))
#let _v(x, y, l, s) = place(top + left, dx: x, dy: y, line(length: l, angle: 90deg, stroke: s))
#let _dot(cx, cy, d) = place(top + left, dx: cx - d.size / 2, dy: cy - d.size / 2,
  circle(radius: d.size / 2, fill: d.paint, stroke: none))

// Label on grid row r (from the top), sized from the grid; anchor: left | center | right of x.
#let _label(st, s, r, x, body, anchor: left) = {
  let t = in-role(st.label, body, size: grid-size(s, st.label.font))
  let y = (r + 1) * s - grid-baseline-lift(s, st.label.font)
  if anchor == left { place(top + left, dx: x, dy: y, t) }
  else if anchor == center { place(top + left, dx: x - 10mm, dy: y, box(width: 20mm, align(center, t))) }
  else { place(top + left, dx: x - 30mm, dy: y, box(width: 30mm, align(right, t))) }
}

// Modern name field: a rounded rectangle whose right end tapers to a point on the chore's axis.
#let _field(x0, xe, cy, hh, nf) = {
  let (r, lt, t) = (nf.radius, nf.taper, 0.05mm)
  let xb = xe - lt
  let (y1, y2) = (cy - hh, cy + hh)
  place(top + left, curve(fill: nf.paint, stroke: nf.at("stroke", default: none),
    curve.move((x0 + r, y1)),
    curve.line((xb, y1)),
    curve.cubic((xb + lt * 0.55, y1), (xe - lt * 0.45, cy - t), (xe, cy - t)),
    curve.line((xe, cy + t)),
    curve.cubic((xe - lt * 0.45, cy + t), (xb + lt * 0.55, y2), (xb, y2)),
    curve.line((x0 + r, y2)),
    curve.quad((x0, y2), (x0, y2 - r)),
    curve.line((x0, y1 + r)),
    curve.quad((x0, y1), (x0 + r, y1)),
    curve.close(),
  ))
}

// ==== geometry ====

// g: the shared geometry of one spread.
#let _geometry(preset, cols, cw, box) = {
  let s = preset.step
  let n-cols = calc.floor(box.width / s + 1e-6)
  let rows = calc.floor(box.height / s + 1e-6)
  let chores = calc.floor((rows - preset.header-rows) / preset.rows-per-chore)
  // fewest columns moved to the left page, cut at a strong boundary
  let cuts = cols.enumerate().filter(((j, c)) => c.strong).map(((j, c)) => j)
  let a = cuts.find(a => (cols.len() - a) * cw <= n-cols * s + 0.001mm)
  assert(a != none, message: "time columns don't fit on the right page")
  let field = box.width - a * cw
  assert(field >= preset.min-name, message: "name field " + repr(field) + " is below " + repr(preset.min-name))
  let pitch = preset.rows-per-chore * s
  (s: s, w: box.width, a: a, field: field, chores: chores, pitch: pitch,
   y0: preset.header-rows * s, y-end: preset.header-rows * s + chores * pitch)
}
#let _row-y(g, r) = g.y0 + r * g.pitch + g.pitch / 2

// ==== parts ====

// Name field on the left page, from the outer edge to x = g.field. heads: (name, interval, sub).
#let _names(g, preset, st, heads) = {
  let s = g.s
  let int-w = preset.interval-steps * s
  let r-head = preset.header-rows - 1
  if st.kind == "classic" {
    let name-w = g.field - int-w
    for k in range(g.chores + 1) {
      _h(0mm, g.y0 + k * g.pitch, g.field, if k == 0 { st.header-rule } else { st.row-rule })
    }
    _v(name-w, g.y0, g.chores * g.pitch, st.interval-rule)
    _label(st, s, r-head, 0mm, heads.name)
    if heads.sub != none { _label(st, s, r-head, name-w - 1mm, heads.sub, anchor: right) }
    _label(st, s, r-head, name-w + int-w / 2, heads.interval, anchor: center)
  } else {
    let nf = st.name-field
    let xb = g.field - nf.taper
    for r in range(g.chores) { _field(0mm, g.field, _row-y(g, r), g.pitch / 2 - nf.gap / 2, nf) }
    _label(st, s, r-head, 0.8mm, heads.name)
    if heads.sub != none { _label(st, s, r-head, xb - 4.4mm, heads.sub, anchor: right) }
    _label(st, s, r-head, xb - 1.6mm, heads.interval, anchor: center)
  }
}

// Time columns from x0. right: on the right page (modern centres them and runs the axes edge to edge).
#let _area(g, st, x0, cols, cw, right) = {
  let s = g.s
  let w = cols.len() * cw
  if st.center-right and right { x0 += (g.w - w) / 2 }
  for (j, c) in cols.enumerate() {
    let x = x0 + j * cw
    if c.top != none { _label(st, s, 0, x + 0.5mm, c.top) }
    _label(st, s, 1, x + cw / 2, c.sub, anchor: center)
    if c.strong { _v(x, 0mm, g.y-end, st.month-line) }
  }
  _v(x0 + w, 0mm, g.y-end, st.month-line)
  if st.kind == "classic" {
    for k in range(g.chores + 1) { _h(x0, g.y0 + k * g.pitch, w, if k == 0 { st.header-rule } else { st.row-rule }) }
    if st.weeks == "lines" {
      for (j, c) in cols.enumerate() { if not c.strong { _v(x0 + j * cw, s, g.y-end - s, st.week-line) } }
      return
    }
  } else {
    // axes run on to the spine edge of the page (through the inside margin), so a row reads across the fold;
    // on the right page they also run to the outer edge of the working area when the columns are centred
    let a0 = if right { -g.spine } else { x0 }
    let a1 = if right { if st.center-right { g.w } else { x0 + w } } else { x0 + w + g.spine }
    for r in range(g.chores) { _h(a0, _row-y(g, r), a1 - a0, st.chore-axis) }
  }
  for r in range(g.chores) {
    for j in range(cols.len()) { _dot(x0 + j * cw + cw / 2, _row-y(g, r), st.week-dot) }
  }
}

// ==== a spread ====

// One spread: left page (names + the first columns), pagebreak, right page (the rest).
// Must start on a left page. cw: column width (grid steps); heads: name-field labels.
#let tracker-spread(cols, cw, preset, st, heads) = {
  // spine: the inside margin, which the axes cross to reach the fold
  let geo() = _geometry(preset, cols, cw, current-work-box()) + (spine: current-format.get().physical.inside)
  context {
    let g = geo()
    _names(g, preset, st, heads)
    if g.a > 0 { _area(g, st, g.w - g.a * cw, cols.slice(0, g.a), cw, false) }
    else if st.kind == "modern" { // names reach the spine side: their axes still run on to the spine edge
      for r in range(g.chores) { _h(g.w, _row-y(g, r), g.spine, st.chore-axis) }
    }
  }
  pagebreak()
  context {
    let g = geo()
    _area(g, st, 0mm, cols.slice(g.a), cw, true)
  }
}

// ==== cover ====

#let cover-page(year, c) = {
  let t(role, body) = align(center, in-role(role, body, baseline: false))
  place(horizon + center, dy: -10mm, stack(dir: ttb, spacing: 0pt,
    t(c.label, upper("zadania cykliczne")), v(4mm),
    t(c.year, str(year)), v(3mm),
    align(center, line(length: 12mm, stroke: c.rule)), v(3.5mm),
    t(c.span, "tygodnie · miesiące"),
  ))
}
