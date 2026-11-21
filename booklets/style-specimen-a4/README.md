# style-specimen-a4

Style choices on paper: one A4 sheet per decision, printed as is (no imposition, nothing to cut),
so one sheet can be tweaked and reprinted on its own.

Decided so far (2026-11-21): grid dots 0.3 mm black (B2/B18); grey prints as a checkered halftone at
every level, so lightness comes from weight and size; small text in Literata, not Literata 7pt. Physical checks (cutting, folding, spine)
are in `format-test-a6-jott-insert`.

| Sheet | Decides |
|-------|---------|
| A | What to write on: grid kind × step, at one fixed calm style |
| B | Dots: dot size × grey, per step |
| C | Lines: weight × grey, per step |
| D | Squares: weight × grey, per step |
| E | Line weights: is each step visibly different? Ladder in printer dots, neighbours interleaved, three-level scales on a table (black only) |
| F | Faint tables: how faint a table can go (hierarchy by weight vs by grey) |
| G | Fonts: named sizes, every font and style in use |
| H | Text on grid rows: x-height share of the step (`grid-x-share`), per font |

Every sample has a tick box, a code (`B7`) and its values from `lib/style.typ`: tick, then report the codes.

```bash
task build -- style-specimen-a4   # → build/style-specimen-a4.pdf, print at 100 %
```

No inputs.
