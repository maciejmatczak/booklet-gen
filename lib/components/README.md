# Shared components

A component lives in its booklet (`booklets/<name>/components.typ`) and moves here only when a
second booklet needs it ("promote on second use"). See the README → Conventions → Components.

| Component      | What                                                                 | Used by                                         |
|----------------|----------------------------------------------------------------------|-------------------------------------------------|
| `day-list.typ` | Day list on the library grid: pagination, day row, page, title page   | `calendar-a6-home`, `calendar-a6-jott-insert`   |

Numbers that differ per grid or format live in presets in each booklet's `style.typ`.
