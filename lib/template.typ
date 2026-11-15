// Booklet template: turns a physical format into Typst page setup.
//
// Usage (top of a booklet):
//   #import "/lib/template.typ": booklet
//   #show: booklet.with(format: a6-home)
#import "formats.typ": a6-home, work-box

// Format of the current booklet, readable by components.
#let current-format = state("booklet-format", a6-home)

// Is the current page a right-hand page? (Page 1 is the cover: right.)
// Must be called inside `context`.
#let is-right() = calc.odd(here().page())

// Working area of the current page, in page coordinates; use inside `context`.
// Handy for page backgrounds that anchor to the spine (e.g. grids).
#let current-work-box() = work-box(current-format.get(), is-right())

#let booklet(format: a6-home, background: none, body) = {
  // `set page` must come before any content, or Typst starts an extra page.
  set page(
    width: format.page.width,
    height: format.page.height,
    margin: format.physical, // inside/outside: mirrored on left/right pages
    background: background,
  )
  current-format.update(format)
  body
  // Pad with blank pages to a multiple of 4 (each folded sheet = 4 pages).
  // The marker pins "last content page"; asking the padding's own location
  // instead makes the layout oscillate.
  [#metadata(none) <booklet-content-end>]
  context {
    let n = locate(<booklet-content-end>).page()
    let missing = calc.rem(4 - calc.rem(n, 4), 4)
    for _ in range(missing) { pagebreak() }
  }
}
