"""Private calendar export (.ics) → JSON for Typst: birthdays and name days only.

Reads a Google Calendar export, expands yearly repeats into the date range and keeps events titled
  "🎂 <name> ma urodziny"  → birthdays
  "🎉 <name> ma imieniny"  → namedays
Everything else is ignored. Names are stored without emoji; the booklet decides how to mark them.

Output: one entry per day in the range, keyed "YYYY-MM-DD", written next to the input (same name, .json):
  {"2027-09-14": {"birthdays": ["…"], "namedays": []}, ...}
A missing input still writes the file with empty days, so booklets compile on a fresh clone.

Usage: uv run tools/calendar_private.py --from 2026-12-01 --to 2028-01-31 data/private/family_calendar.ics
"""

import argparse
import json
import re
import sys
from datetime import date, datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

import icalendar
import recurring_ical_events

WARSAW = ZoneInfo("Europe/Warsaw")
KINDS = {"urodziny": "birthdays", "imieniny": "namedays"}
TITLE = re.compile(r"^\W*(?P<name>.+?)\s+ma\s+(?P<kind>urodziny|imieniny)\W*$")


def events(ics: Path, start: date, end: date):
    """(date, kind, name) for every matching occurrence in [start, end]."""
    cal = icalendar.Calendar.from_ical(ics.read_bytes())
    for ev in recurring_ical_events.of(cal).between(start, end + timedelta(days=1)):
        m = TITLE.match(str(ev.get("SUMMARY", "")))
        if not m:
            continue
        d = ev["DTSTART"].dt
        if isinstance(d, datetime):
            d = d.astimezone(WARSAW).date()
        yield d, KINDS[m["kind"]], m["name"].strip()


def calendar(ics: Path, start: date, end: date) -> dict[str, dict[str, list[str]]]:
    out = {}
    d = start
    while d <= end:
        out[d.isoformat()] = {"birthdays": [], "namedays": []}
        d += timedelta(days=1)
    if ics.exists():
        for d, kind, name in events(ics, start, end):
            out[d.isoformat()][kind].append(name)
    else:
        print(f"warning: {ics} not found, writing empty days", file=sys.stderr)
    for day in out.values():  # stable output, independent of event order in the export
        for names in day.values():
            names.sort()
    return out


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--from", dest="start", type=date.fromisoformat, required=True)
    p.add_argument("--to", dest="end", type=date.fromisoformat, required=True)
    p.add_argument("ics", type=Path)
    a = p.parse_args()
    data = calendar(a.ics, a.start, a.end)
    out = a.ics.with_suffix(".json")
    out.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    n = sum(len(v) for day in data.values() for v in day.values())
    print(f"→ {out}: {len(data)} days, {n} events")


if __name__ == "__main__":
    main()
