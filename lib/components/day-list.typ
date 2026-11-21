// Day list on the library grid: one row block per day, for writing in.
// Used by calendar-a6-home and calendar-a6-jott-insert.
//
// Three layers, kept apart:
//   paginate()       which days go on which page (dates only, no drawing)
//   day-row()        how one day looks
//   day-list-page()  one page: grid, title, rows
// The booklet's style.typ holds the presets (numbers that differ between grids) and the theme
// (every look choice by role: fonts, sizes, weights, lines, fills). This file has no style of its own.
// The booklet's format gives the page (work box) the list is drawn in.
#import "/lib/lib.typ": *

// ==== styles ====

// Paging options (see paginate below).
#let pagings = ("rolling", "month")

// Icons for printed important dates: line drawings, black only, sized to the handwriting.
#let _icon(paths) = bytes("<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='black' "
  + "stroke-width='1.7' stroke-linecap='round' stroke-linejoin='round'>" + paths + "</svg>")
#let icons = (
  // cake with a candle
  birthday: _icon("<path d='M3 21h18'/><path d='M5 21v-8h14v8'/><path d='M5 16.5c1.2 1.2 2.3 1.2 3.5 0s2.3-1.2 3.5 0 2.3 1.2 3.5 0 2.3-1.2 3.5 0'/>"
    + "<path d='M12 13v-4'/><path d='M12 7c-1.1-1-1.1-2.4 0-4 1.1 1.6 1.1 3 0 4z' fill='black'/>"),
  // tulip
  nameday: _icon("<path d='M12 22v-11'/><path d='M12 18c-3.5 0-5.5-2-5.5-4.5 3.5 0 5.5 2 5.5 4.5z'/>"
    + "<path d='M7.5 3.5l2.2 2.2 2.3-3.2 2.3 3.2 2.2-2.2v4a4.5 4.5 0 0 1-9 0z'/>"),
)
// An icon standing on the baseline, cap-height tall at the given text size. Its box has no height,
// so it doesn't raise the line (text placed with on-baseline keeps its baseline where it was put).
#let icon(name, size) = {
  let h = 0.72 * size
  box(width: h, height: 0pt, place(bottom + left, image(icons.at(name), format: "svg", height: h)))
}

// Polish names.
#let months-nom = ("styczeń", "luty", "marzec", "kwiecień", "maj", "czerwiec",
  "lipiec", "sierpień", "wrzesień", "październik", "listopad", "grudzień")
#let months-gen = ("stycznia", "lutego", "marca", "kwietnia", "maja", "czerwca",
  "lipca", "sierpnia", "września", "października", "listopada", "grudnia")
#let weekdays-short = ("Pn", "Wt", "Śr", "Cz", "Pt", "So", "Nd") // datetime.weekday(): 1 = Monday


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

// Text in a theme role: a dictionary of text settings (font, size, weight, style, tracking …).
// size overrides the role's size (text on grid rows is sized from the grid); extra settings
// override the role (e.g. weight on days off). baseline: false for text in normal flow.
#let in-role(role, body, size: auto, baseline: true, ..extra) = {
  let style = role + extra.named()
  let sz = style.remove("size", default: auto)
  if size != auto { sz = size }
  let edges = if baseline { (top-edge: "baseline", bottom-edge: "baseline") } else { (:) }
  text(size: sz, ..edges, ..style, body)
}

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

// Day off: weekend or public holiday.
#let is-off(d) = d.weekday() >= 6 or day-info(d).holidays.len() > 0

// Secondary notes of a day, right-aligned on grid rows, as (row, content, font) triples.
//   top, from the first row down:     calendar markings on one line (week number on Mondays,
//                                     month name on the 1st: "T44 · LISTOPAD"), then holidays, observances
//   bottom, from the last row up:     birthdays and name days (icon + name), at most 2 rows
// When a side runs out of rows, its last row takes the rest, joined.
// Only for grids where a day has enough rows (3.55 mm: 4); 5 mm is not implemented yet.
#let day-notes(d, preset, theme) = {
  if preset.at("notes", default: none) != "rows" {
    panic("day notes: not implemented for this grid (" + repr(preset.step) + "); use grid=3.55mm")
  }
  let n = preset.rows-per-day
  let info = day-info(d)
  let family = day-family(d)
  // sized from the grid (lib/style.typ → grid-size), so every font looks the same size
  let note(role, body) = in-role(role, body, size: grid-size(preset.step, role.font))
  let sep(role) = note(role, theme.separator)
  let markings = ()
  if d.weekday() == 1 { markings.push("T" + d.display("[week_number repr:iso padding:none]")) }
  if d.day() == 1 { markings.push(upper(months-nom.at(d.month() - 1))) }
  let top = ()
  if markings.len() > 0 { top.push(note(theme.marking, markings.join(theme.separator))) }
  for h in info.holidays + info.observances { top.push(note(theme.holiday, h)) }
  let hs = grid-size(preset.step, theme.person.font)
  let person(kind, name) = note(theme.person, [#icon(kind, hs)#h(0.25em)#name])
  let people = family.birthdays.map(p => person("birthday", p)) + family.namedays.map(p => person("nameday", p))
  // fit a list into k rows: the last row takes the rest
  let fit(xs, k, s) = if xs.len() <= k { xs } else { xs.slice(0, k - 1) + (xs.slice(k - 1).join(s),) }
  people = fit(people, calc.min(2, n - 1), note(theme.person, ", "))
  top = fit(top, n - people.len(), sep(theme.holiday))
  (top.enumerate().map(((r, c)) => (r, c, theme.marking.font))
    + people.rev().enumerate().map(((i, c)) => (n - 1 - i, c, theme.person.font)))
}

// g: page geometry from day-list-page (x(i), width, n-steps); y0: top of the day; notes: from day-notes.
#let day-row(d, preset, theme, g, y0, notes, first-on-page: false) = {
  let s = preset.step
  let pitch = preset.rows-per-line * s
  let wd = d.weekday() // 1 = Monday
  let off = is-off(d)
  let x-tab = (g.x)(0)
  let tab-w = preset.tab-steps * s
  let x-end = (g.x)(g.n-steps)
  let row-baseline(r, font) = y0 + (r + 1) * s - grid-baseline-lift(s, font)

  // date column. Days off: filled from top to bottom, box included, so a weekend reads as one block.
  if off { put(x-tab, y0, rect(width: tab-w, height: preset.rows-per-day * s, fill: theme.day-off-fill, stroke: none)) }
  put(x-tab, y0, rect(width: tab-w, height: pitch, stroke: theme.date-box))
  // date box (tab-steps × one line). inline: number right-aligned, weekday on the same baseline;
  // stacked: number above weekday, both centred (for a square box too narrow for both side by side).
  let off-style = if off { theme.day-off } else { (:) }
  let num = in-role(theme.day-number, str(d.day()), ..off-style)
  let wday = in-role(theme.weekday, upper(weekdays-short.at(wd - 1)), ..off-style)
  if preset.date-layout == "stacked" {
    put(x-tab, y0 + pitch / 2 - 0.5mm, box(width: tab-w, align(center, num)))
    put(x-tab, y0 + pitch - 1.3mm, box(width: tab-w, align(center, wday)))
  } else {
    put(x-tab + preset.num-width, y0 + pitch - 1.3mm, num, width: g.width, right: true)
    put(x-tab + preset.num-width + preset.weekday-gap, y0 + pitch - 1.3mm, wday)
  }

  // secondary notes, right-aligned
  for (r, c, font) in notes { put(x-end, row-baseline(r, font), c, width: g.width, right: true) }

  // rules: heavy above a new month (not at a page top), weekly after Sunday
  let y1 = y0 + preset.rows-per-day * s
  put(x-tab, y1, line(length: x-end - x-tab, stroke: if wd == 7 { theme.rules.week } else { theme.rules.day }))
  if d.day() == 1 and not first-on-page { put(x-tab, y0, line(length: x-end - x-tab, stroke: theme.rules.month)) }
}

// ==== one page ====

#let day-list-page(days, preset, theme) = context {
  let s = preset.step
  let box = current-work-box()
  let right-page = is-right()
  let n-steps = calc.floor(box.width / s + 1e-6)
  let n-rows = calc.floor(box.height / s + 1e-6)
  // grid anchored at the spine: right pages count from the left edge, left pages from the right
  let x(i) = if right-page { i * s } else { box.width - (n-steps - i) * s }
  let g = (x: x, width: box.width, n-steps: n-steps)
  let y-list = preset.header-rows * s
  let rpd = preset.rows-per-day
  let n-day-rows = days.len() * rpd
  let offs = days.map(is-off)
  let notes = days.map(d => day-notes(d, preset, theme))

  // no dot under a rule, or in the date column of a box or a day off
  let skip(k, j) = {
    if days.len() == 0 or j > n-day-rows { return false }
    let r = calc.rem(j, rpd)
    if r == 0 { return true }
    let i = if right-page { k } else { n-steps - k } // dots count from the spine
    i <= preset.tab-steps and (r <= preset.rows-per-line or offs.at(int(j / rpd)))
  }

  block(width: 100%, height: 100%, {
    place(top + left, dy: y-list, dots(width: box.width + 0.01mm, height: (n-rows - preset.header-rows) * s + 0.01mm,
      step: s, dot: theme.grid-dot.size, paint: theme.grid-dot.paint, anchor-x: if right-page { left } else { std.right }, skip: skip))
    if days.len() > 0 {
      let title = in-role(theme.title, date-range(days.first(), days.last()))
      assert(measure(title).width <= box.width, message: "page title wider than the working area: "
        + date-range(days.first(), days.last()) + "; lower theme.title.size")
      if right-page { put(x(n-steps), y-list - 1.6mm, title, width: box.width, right: true) }
      else { put(x(0), y-list - 1.6mm, title) }
      put(x(0), y-list, line(length: x(n-steps) - x(0), stroke: theme.rules.top))
      for (k, d) in days.enumerate() {
        day-row(d, preset, theme, g, y-list + k * rpd * s, notes.at(k), first-on-page: k == 0)
      }
    }
  })
}

// ==== title page ====

// The cover page: what it is, the year large, the span; a little above the middle.
#let title-page(year, theme) = {
  let c = theme.cover
  let t(role, body) = align(center, in-role(role, body, baseline: false))
  place(horizon + center, dy: -10mm, stack(dir: ttb, spacing: 0pt,
    t(c.label, upper("kalendarz")), v(4mm),
    t(c.year, str(year)), v(3mm),
    align(center, line(length: 12mm, stroke: c.rule)), v(3.5mm),
    t(c.span, "styczeń – grudzień"),
  ))
}
