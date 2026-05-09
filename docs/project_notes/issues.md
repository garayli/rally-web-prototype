# Work Log

Track completed work, tickets, and milestones.

## Template

```markdown
## YYYY-MM-DD
**Task:** [Brief description]
**Details:** [What was done]
```

---

## Entries

## 2026-05-09
**Task:** Open Lobby — Supabase insert + Match tab discovery UI
**Details:** `OpenLobbyScreen._submit()` now inserts into `lobbies` (sport, skill_level, date_time, court, notes, is_public, status='open', creator_id). Match screen loads open lobbies on init via `_loadLobbies()` and shows a horizontal `_LobbyCard` scroll section between filter chips and player list. Section is hidden when there are no open lobbies. "Lobi Oluştur" shortcut in section header navigates to `OpenLobbyScreen` and refreshes on return. Lobbies table RLS: anyone can select public+open rows; only creator can insert/update.

## 2026-05-09
**Task:** Fix "Bottom Overflowed by 3.0 pixels" on Match screen lobby cards
**Details:** Replaced `Spacer()` with `SizedBox(height: 8)` in `_LobbyCard`. `Spacer` inside a height-constrained horizontal ListView cross-axis causes overflow when content nearly fills the boundary.

## 2026-05-09
**Task:** Fix match request not writing to Supabase
**Details:** `_RequestSheetState._sendRequest()` now calls `supabase.from('matches').insert(...)`. Actual DB columns are `player1_id`, `player2_id` (nullable), `date_time`, `court`, `status`, `format`. Column name mismatch from original assumption caused inserts to fail. RLS policies added; `player2_id` made nullable (mock IDs are not UUIDs).

<!-- Add new entries above this line -->