# Architectural Decision Records

Key architectural decisions and their rationale.

## Template

```markdown
## ADR-[Number]: [Decision Title]
**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded

### Context
[What situation prompted this decision]

### Decision
[What was decided]

### Consequences
- **Positive:** [Benefits]
- **Negative:** [Drawbacks]
```

---

## Decisions

## ADR-001: Figma MCP — View-only token, no write-back
**Date:** 2026-04-26
**Status:** Accepted

### Context
Figma MCP was connected to enable design-to-code workflow. Attempted to set up write-back (create files, upload assets) but Figma's free Starter plan does not allow API tokens with file-write scopes.

### Decision
Use Figma MCP in read-only mode. Primary tools: `get_design_context`, `get_screenshot`, `get_variable_defs`. Write-back tools (`create_new_file`, `upload_assets`, `generate_diagram`) are unavailable until plan is upgraded.

### Consequences
- **Positive:** Design-to-Flutter workflow works fine — read access is all that's needed for implementation.
- **Negative:** Cannot push generated diagrams or updated designs back to Figma from Claude.

---

## ADR-003: ValueNotifier for cross-screen reactive state (no Riverpod)
**Date:** 2026-04-26
**Status:** Accepted

### Context
`IndexedStack` keeps all tab screens alive but doesn't trigger rebuilds on sibling screens. Hardcoded badge counts (`count: 3`) didn't update when notification state changed elsewhere.

### Decision
Use `ValueNotifier<T>` on the `DataService` singleton for any state that must reactively update across multiple screens (e.g. `unreadNotifier`). Screens wrap with `ValueListenableBuilder`. No Riverpod introduced.

### Consequences
- **Positive:** Zero new dependencies, works with plain StatefulWidgets, updates any listener instantly regardless of widget tree position.
- **Negative:** Manual — each cross-screen reactive value needs its own notifier. Riverpod would handle this more elegantly at scale.

---

## ADR-004: Supabase messages.receiver_id is nullable
**Date:** 2026-04-26
**Status:** Accepted

### Context
The `messages` table FK `receiver_id → profiles.id` blocked all inserts because mock players don't have real Supabase profiles (profiles requires auth.users row).

### Decision
Made `receiver_id` nullable and kept FK as a nullable reference (migration: `make_receiver_id_nullable`). Flutter omits `receiver_id` until real player profiles exist. Authenticated sender's profile was inserted manually.

### Consequences
- **Positive:** Messages can be persisted to Supabase immediately even before full player onboarding.
- **Negative:** `receiver_id` will be null for all messages until real players sign up. Queries filtering by receiver won't work yet.
- **How to apply:** When real player onboarding is built, populate `receiver_id` and it will backfill correctly due to nullable FK.

---

## ADR-002: Secret scripts go in .gitignore
**Date:** 2026-04-26
**Status:** Accepted

### Context
`test_figma.ps1` was committed with a hardcoded Figma personal access token. GitHub's push protection blocked the push.

### Decision
- Local test/secret scripts (`test_figma.ps1`, `export_prototype_components.ps1`) are added to `.gitignore`.
- Secrets must use environment variables (`$env:FIGMA_TOKEN`), never hardcoded strings.
- Revoke and regenerate any token that was committed, even if the push was blocked.

### Consequences
- **Positive:** No secrets leak to remote; GitHub push protection satisfied.
- **Negative:** Test scripts must be re-configured locally after a fresh clone.

---

## ADR-005: matches.player2_id is nullable uuid with no FK enforcement during dev
**Date:** 2026-05-09
**Status:** Accepted

### Context
The `matches` table insert uses `player2_id` for the opponent, but mock player IDs are short strings (`'p1'`, `'p2'`), not UUIDs. A strict FK constraint `player2_id → profiles.id` would reject every insert until all players have real Supabase profiles — the same problem that occurred with `messages.receiver_id` (see ADR-004).

### Decision
`player2_id` is `uuid` but nullable, with a FK to `profiles.id`. For guest/mock opponents, `player2_id` is sent as `null`; opponent identity is stored in `opponent_name` (text) and `opponent_phone` (text) instead. Once real player onboarding is complete, `player2_id` can be populated retroactively by matching on phone number.

### Consequences
- **Positive:** Inserts succeed immediately in dev/testing; guest match results are stored with enough data to link later.
- **Negative:** No referential integrity on opponent until real profiles exist. Queries joining matches → profiles on `player2_id` return null for guest rows.
- **How to apply:** When real onboarding is built, populate `player2_id` by querying `profiles` by phone number at insert time.

---

## ADR-006: Phone number as unregistered opponent identifier
**Date:** 2026-05-15
**Status:** Accepted

### Context
Users need to log match results against opponents who don't use the app. A free-text name alone is not a reliable identifier. Phone number is unique and stable, and when the opponent eventually registers with the same number their historic match results can be retroactively linked.

### Decision
Unregistered opponents are identified by phone number (minimum 10 digits, digits-only). Name is optional. Both are stored in `matches.opponent_phone` and `matches.opponent_name`. `player2_id` is null for these rows. Phone is not yet stored in `profiles`; linking is future work.

### Consequences
- **Positive:** Consistent unique key for future retroactive linking. Simple UX — just enter a number.
- **Negative:** Relies on phone being unique per person (not enforced at DB level). No real-time validation that the number belongs to any real person.
- **How to apply:** Future signup flow should collect phone → store in `profiles.phone` → on match insert, query profiles by phone to auto-populate `player2_id`.

---

## ADR-007: Onboarding overlay — custom implementation over third-party package
**Date:** 2026-05-15
**Status:** Accepted

### Context
New users needed per-tab guidance on what each page does. Options considered: third-party packages (`showcaseview`, `tutorial_coach_mark`), a full-screen intro carousel, and a custom `Stack`-based overlay card.

### Decision
Custom `Stack`-based overlay rendered inside `Scaffold.body`, managed in `MainShell`. No third-party onboarding package introduced. Seen-state stored in `shared_preferences` (already a transitive dep, promoted to direct). Overlay is a semi-transparent backdrop + centered card (icon + title + bullets + dismiss button). `BottomNavigationBar` lives in `Scaffold.bottomNavigationBar` so it is never obscured.

### Consequences
- **Positive:** Zero new UI dependencies; fits existing `flutter_animate` + `StatefulWidget + setState` patterns; fully controllable styling.
- **Negative:** Overlay points at the page as a whole, not at specific UI elements. If per-element coach marks are needed later, a package like `showcaseview` would require adding `GlobalKey`s to target widgets.
- **How to apply:** To reset onboarding in development, clear the `onboarding_seen` SharedPreferences key. To add a new tab, append an entry to `kTabOnboardingContent` in `onboarding_overlay.dart` and increase `List.filled(5, ...)` to the new count.

---

<!-- Add new ADRs above this line -->