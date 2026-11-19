// Generated data (task data → data/public/). Background: tools/calendar_pl.py
// Typst can't parse date strings, so lookups go datetime → key, never back.

// Polish days off + recognizable days, 2026-12-01 → 2028-01-31, one entry per day.
#let calendar-pl = json("/data/public/calendar-pl-2027.json")

// datetime → "YYYY-MM-DD"
#let day-key(d) = d.display("[year]-[month]-[day]")

// (holidays: (..), observances: (..)) for a datetime; empty outside the range.
#let day-info(d) = calendar-pl.at(day-key(d), default: (holidays: (), observances: ()))
