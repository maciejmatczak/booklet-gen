// Entry document for `task print`: imposes a built booklet PDF onto A4 sheets.
//   typst compile --root . --input pdf=/build/<name>.pdf --input pages=<n> lib/print.typ out.pdf
#import "impose.typ": impose

#let pdf-path = sys.inputs.at("pdf", default: none)
#let pages = sys.inputs.at("pages", default: none)
#assert(pdf-path != none and pages != none, message: "use `task print -- <booklet>`")

#impose(read(pdf-path, encoding: none), int(pages))
