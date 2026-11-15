// Entry document for `task print`: imposes a built booklet PDF onto A4 sheets.
//   typst compile --root . --input pdf=/build/<name>.pdf --input pages=<n> [--input printer=<key>] lib/print.typ out.pdf
#import "impose.typ": impose
#import "printers.typ": printers, default-printer

#let pdf-path = sys.inputs.at("pdf", default: none)
#let pages = sys.inputs.at("pages", default: none)
#assert(pdf-path != none and pages != none, message: "use `task print -- <booklet>`")

#let printer-key = sys.inputs.at("printer", default: none)
#let printer = if printer-key == none { default-printer } else {
  assert(printer-key in printers, message: "unknown printer '" + printer-key + "', known: " + printers.keys().join(", "))
  printers.at(printer-key)
}

#impose(read(pdf-path, encoding: none), int(pages), printer: printer)
