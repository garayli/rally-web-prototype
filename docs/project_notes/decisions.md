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

<!-- Add new ADRs above this line -->