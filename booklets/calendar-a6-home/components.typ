// Components for calendar-a6-home: a day list on the library grid.
//
// Three layers, kept apart:
//   paginate()       which days go on which page (dates only, no drawing)
//   day-row()        how one day looks
//   day-list-page()  one page: grid, title, rows
// Presets (style.typ) carry every number that differs between variants.
#import "/lib/lib.typ": *
#import "style.typ": *

// ==== dates and pages ====

// Every day from `from` to `to`, inclusive.
#let days-between(from, to) = range(int((to - from).days()) + 1).map(i => from + duration(days: i))

// Split an array into runs of n.
#let chunks(xs, n) = range(0, xs.len(), step: n).map(i => xs.slice(i, calc.min(i + n, xs.len())))

// Days per page, derived from the format and the preset; fails the build if it doesn't fit.
#let days-per-page(preset, fmt) = {
  assert(calc.rem(preset.rows-per-day, preset.rows-per-line) == 0,
    message: "rows-per-day must be a whole number of lines")
  let rows = calc.floor(work-box(fmt, true).height / preset.step + 1e-6)
  let n = calc.floor((rows - preset.header-rows) / preset.rows-per-day)
  assert(n >= 7, message: "preset fits only " + str(n) + " days per page; needs at least a week")
  n
}

// Pages of days. Each page is an array of datetimes; an empty array is a spare page.
//   rolling: days just continue, page after page
//   month:   each month starts on a new spread (spare page added after odd page counts)
// The first page must be a left page, so spreads stay together.
#let paginate(from, to, per-page, paging: "rolling") = {
  assert(paging in pagings, message: "paging must be one of " + pagings.join(", "))
  let days = days-between(from, to)
  if paging == "rolling" { return chunks(days, per-page) }
  let months = ()
  for d in days {
    if months.len() == 0 or months.last().last().month() != d.month() { months.push((d,)) }
    else { months.last().push(d) }
  }
  let pages = ()
  for m in months {
    let ps = chunks(m, per-page)
    if calc.odd(ps.len()) { ps.push(()) }
    pages += ps
  }
  pages
}

// ==== text helpers ====

// Text whose box is its baseline: place it at y and the baseline sits on y.
#let on-baseline(size, body, font: auto, ..style) = text(
  font: if font != auto { font } else if size <= small-threshold { fonts.small } else { fonts.text },
  size: size, top-edge: "baseline", bottom-edge: "baseline", ..style, body)

// Place at (x, y): left edge (default) or right edge at x. `width` = container width.
#let put(x, y, body, width: none, right: false) = if right {
  place(top + std.right, dx: x - width, dy: y, body)
} else {
  place(top + left, dx: x, dy: y, body)
}

// "1 – 12 stycznia 2027", "28 stycznia – 8 lutego 2027", "28 grudnia 2026 – 8 stycznia 2027"
#let date-range(a, b) = {
  let day-month(d) = str(d.day()) + " " + months-gen.at(d.month() - 1)
  if a.year() != b.year() { day-month(a) + " " + str(a.year()) + " – " + day-month(b) + " " + str(b.year()) }
  else if a.month() != b.month() { day-month(a) + " – " + day-month(b) + " " + str(b.year()) }
  else { str(a.day()) + " – " + day-month(b) + " " + str(b.year()) }
}

// ==== one day ====

// g: page geometry from day-list-page (x(i), width, n-steps); y0: top of the day.
#let day-row(d, preset, g, y0, first-on-page: false) = {
  let s = preset.step
  let pitch = preset.rows-per-line * s
  let lines = int(preset.rows-per-day / preset.rows-per-line)
  let baseline(i) = y0 + (i + 1) * pitch - 1.3mm
  let wd = d.weekday() // 1 = Monday
  let weekend = wd >= 6
  let info = day-info(d)
  let family = day-family(d)
  let bold-day = wd == 7 or info.holidays.len() > 0
  let x-tab = (g.x)(0)
  let x-write = (g.x)(preset.tab-steps) + 1mm
  let x-end = (g.x)(g.n-steps)

  // date tab: number right-aligned, weekday on the same baseline, stipple on weekends
  if weekend { put(x-tab, y0, rect(width: preset.tab-steps * s, height: pitch, fill: weekend-fill, stroke: none)) }
  put(x-tab + preset.num-width, baseline(0), on-baseline(sizes.body, weight: if bold-day { "bold" } else { "regular" },
    str(d.day())), width: g.width, right: true)
  put(x-tab + preset.num-width + 0.9mm, baseline(0), on-baseline(sizes.tiny, tracking: 0.3pt,
    weight: if weekend { "bold" } else { "regular" }, upper(weekdays-short.at(wd - 1))))

  // right side of the first line: month start, holidays, observances, week number
  let right = ()
  if d.day() == 1 { right.push(on-baseline(sizes.tiny, weight: "bold", tracking: 0.3pt, upper(months-nom.at(d.month() - 1)))) }
  for h in info.holidays { right.push(on-baseline(sizes.tiny, style: "italic", h)) }
  for o in info.observances { right.push(on-baseline(sizes.tiny, style: "italic", o)) }
  if wd == 1 { right.push(on-baseline(sizes.tiny, "tydz. " + d.display("[week_number repr:iso padding:none]"))) }
  if right.len() > 0 { put(x-end, baseline(0), right.join(on-baseline(sizes.tiny, "  ·  ")), width: g.width, right: true) }

  // important dates, printed as if written in: one per line, the rest share the last line
  let entries = family.birthdays.map(n => n + " – urodziny") + family.namedays.map(n => n + " – imieniny")
  if entries.len() > lines { entries = entries.slice(0, lines - 1) + (entries.slice(lines - 1).join(", "),) }
  for (i, e) in entries.enumerate() {
    put(x-write, baseline(i), on-baseline(preset.hand-size, font: fonts.hand, e))
  }

  // rules: heavy above a new month (not at a page top), weekly after Sunday
  let y1 = y0 + preset.rows-per-day * s
  put(x-tab, y1, line(length: x-end - x-tab, stroke: if wd == 7 { rules.week } else { rules.day }))
  if d.day() == 1 and not first-on-page { put(x-tab, y0, line(length: x-end - x-tab, stroke: rules.month)) }
}

// ==== one page ====

#let day-list-page(days, preset) = context {
  let s = preset.step
  let box = current-work-box()
  let right-page = is-right()
  let n-steps = calc.floor(box.width / s + 1e-6)
  let n-rows = calc.floor(box.height / s + 1e-6)
  // grid anchored at the spine: right pages count from the left edge, left pages from the right
  let x(i) = if right-page { i * s } else { box.width - (n-steps - i) * s }
  let g = (x: x, width: box.width, n-steps: n-steps)
  let y-list = preset.header-rows * s

  block(width: 100%, height: 100%, {
    place(top + left, dy: y-list, dots(width: box.width + 0.01mm, height: (n-rows - preset.header-rows) * s + 0.01mm,
      step: s, dot: grid-dot, anchor-x: if right-page { left } else { std.right }))
    if days.len() > 0 {
      let title = on-baseline(sizes.title, date-range(days.first(), days.last()))
      if right-page { put(x(n-steps), y-list - 1.6mm, title, width: box.width, right: true) }
      else { put(x(0), y-list - 1.6mm, title) }
      put(x(0), y-list, line(length: x(n-steps) - x(0), stroke: rules.top))
      for (k, d) in days.enumerate() {
        day-row(d, preset, g, y-list + k * preset.rows-per-day * s, first-on-page: k == 0)
      }
    }
  })
}

// ==== title page ====

#let title-page(preset, paging, year) = {
  set align(center + horizon)
  block(spacing: 0pt, {
    text(size: 28pt, str(year))
    v(4mm)
    text(size: sizes.large, "kalendarz")
  })
  place(bottom + center, txt(sizes.tiny, preset.label + "  ·  " + (if paging == "rolling" { "dni ciągłe" } else { "miesiącami" })))
}
