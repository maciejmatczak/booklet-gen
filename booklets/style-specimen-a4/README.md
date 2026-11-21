# style-specimen-a4

Style choices on paper: one A4 sheet per decision, printed as is (no imposition, nothing to cut),
so one sheet can be tweaked and reprinted on its own. Physical checks (cutting, folding, spine)
are in `format-test-a6-jott-insert`.

| Sheet | Decides |
|-------|---------|
| A | What to write on: grid kind × step, at one fixed calm style |
| B | Dots: dot size × grey, per step |
| C | Lines: weight × grey, per step |
| D | Squares: weight × grey, per step |
| E | Line weights: weight × grey, dashes × weight (rules for pages and tables) |
| F | Faint tables: how faint a table can go (hierarchy by weight vs by grey) |
| G | Fonts: named sizes, every font and style in use, Literata vs Literata 7pt |
| H | Text on grid rows: x-height share of the step (`grid-x-share`), per font |

Every sample has a tick box, a code (`B7`) and its values from `lib/style.typ`: tick, then report the codes.

```bash
task build -- style-specimen-a4   # → build/style-specimen-a4.pdf, print at 100 %
```

No inputs.
