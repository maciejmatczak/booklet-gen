"""Polish calendar days → JSON for Typst.

Typst computes dates, weekdays and grids itself; this only adds what it can't know:
  holidays     days off (the `holidays` library, Polish names)
  observances  recognizable days that are not days off (our own rules below)

Output: one entry per day in the range, keyed "YYYY-MM-DD":
  {"2027-02-14": {"holidays": [], "observances": ["Walentynki"]}, ...}

Usage: uv run tools/calendar_pl.py --from 2026-12-01 --to 2028-01-31 --out data/public/calendar-pl-2027.json
"""

import argparse
import json
from datetime import date, timedelta
from pathlib import Path

import holidays
from dateutil.easter import easter

# (month, day) → name
FIXED = [
    ((1, 21), "Dzień Babci"),
    ((1, 22), "Dzień Dziadka"),
    ((2, 14), "Walentynki"),
    ((3, 8), "Dzień Kobiet"),
    ((4, 1), "Prima Aprilis"),
    ((5, 26), "Dzień Matki"),
    ((6, 1), "Dzień Dziecka"),
    ((6, 23), "Dzień Ojca"),
    ((10, 31), "Halloween"),
    ((11, 29), "Andrzejki"),  # the evening before St Andrew (30.11)
    ((12, 6), "Mikołajki"),
]

# days relative to Easter Sunday → name
EASTER_RELATIVE = [
    (-52, "Tłusty Czwartek"),
    (-47, "Ostatki"),
    (-46, "Popielec"),
    (-7, "Niedziela Palmowa"),
    (-3, "Wielki Czwartek"),
    (-2, "Wielki Piątek"),
    (-1, "Wielka Sobota"),
]


def last_sunday(year: int, month: int) -> date:
    last = date(year + month // 12, month % 12 + 1, 1) - timedelta(days=1)
    return last - timedelta(days=(last.weekday() + 1) % 7)


def observances(year: int) -> dict[date, list[str]]:
    days: dict[date, list[str]] = {}

    def add(d: date, name: str) -> None:
        days.setdefault(d, []).append(name)

    for (month, day), name in FIXED:
        add(date(year, month, day), name)
    e = easter(year)
    for offset, name in EASTER_RELATIVE:
        add(e + timedelta(days=offset), name)
    add(last_sunday(year, 3), "Zmiana czasu na letni")
    add(last_sunday(year, 10), "Zmiana czasu na zimowy")
    return days


def calendar(start: date, end: date) -> dict[str, dict[str, list[str]]]:
    years = range(start.year, end.year + 1)
    days_off = holidays.country_holidays("PL", years=years, language="pl")
    obs: dict[date, list[str]] = {}
    for y in years:
        obs.update(observances(y))
    out = {}
    d = start
    while d <= end:
        out[d.isoformat()] = {
            "holidays": days_off.get_list(d),
            "observances": obs.get(d, []),
        }
        d += timedelta(days=1)
    return out


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--from", dest="start", type=date.fromisoformat, required=True)
    p.add_argument("--to", dest="end", type=date.fromisoformat, required=True)
    p.add_argument("--out", type=Path, required=True)
    a = p.parse_args()
    data = calendar(a.start, a.end)
    a.out.parent.mkdir(parents=True, exist_ok=True)
    a.out.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"→ {a.out}: {len(data)} days")


if __name__ == "__main__":
    main()
