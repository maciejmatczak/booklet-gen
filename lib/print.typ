// Entry document for `task print`: imposes a built booklet PDF onto A4 sheets.
//   typst compile --root . --input pdf=/build/<name>.pdf --input pages=<n> --input format=<key> [--input printer=<key>] lib/print.typ out.pdf
#import "impose.typ": impose
#import "printers.typ": printers, default-printer
#import "formats.typ": formats

#let pdf-path = sys.inputs.at("pdf", default: none)
#let pages = sys.inputs.at("pages", default: none)
#assert(pdf-path != none and pages != none, message: "use `task print -- <booklet>`")

#let printer-key = sys.inputs.at("printer", default: none)
#let printer = if printer-key == none { default-printer } else {
  assert(printer-key in printers, message: "unknown printer '" + printer-key + "', known: " + printers.keys().join(", "))
  printers.at(printer-key)
}

#let format-key = sys.inputs.at("format", default: "a6-home")
#assert(format-key in formats, message: "unknown format '" + format-key + "', known: " + formats.keys().join(", "))

#impose(read(pdf-path, encoding: none), int(pages), format: formats.at(format-key), printer: printer)
