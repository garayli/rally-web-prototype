# Key Facts

Project configuration, credentials, and constants.

## Supabase Configuration

| Key | Value |
|-----|-------|
| `supabaseUrl` | (fill in) |
| `supabaseAnon` | (fill in) |
| Redirect URL | `io.supabase.rallly://login-callback/` |

## Build Configuration

| Item | Value |
|------|-------|
| Flutter Project | `rallly_flutter/` |
| Min Android SDK | 21 |
| Target Android SDK | 34 |

## External Resources

| Resource | URL |
|----------|-----|
| InstrumentSerif Font | Google Fonts |
| Plus Jakarta Sans | Google Fonts |

## Figma MCP

| Key | Value |
|-----|-------|
| Account | leyla.garayli@gmail.com |
| Team | Lei La's team (Starter plan) |
| Seat | View (read-only) |
| Token scope | Read only — write-back unavailable on free plan |
| Token storage | Environment variable `$env:FIGMA_TOKEN` in local scripts only — never commit |

## Connected Devices

| Device | ID |
|--------|----|
| SM A566B (Android 16) | `R5CY41DEJZZ` |

---

## Supabase Table Schemas

### `matches`
| Column | Type | Notes |
|--------|------|-------|
| `id` | uuid | PK, default `gen_random_uuid()` |
| `player1_id` | uuid | Requester — FK → `auth.users` |
| `player2_id` | uuid | Opponent — nullable (mock IDs not UUIDs, see ADR-005) |
| `date_time` | timestamptz | NOT NULL — app sends `DateTime.now()+7days` as placeholder |
| `court` | text | NOT NULL |
| `status` | enum | `'pending'` \| `'confirmed'` \| `'completed'` \| `'cancelled'` |
| `format` | enum | `'singles'` \| `'doubles'` |
| `winner_id` | uuid | nullable — set on match completion |
| `sets` | jsonb | nullable — set scores |
| `rating_delta` | real | nullable |
| `created_at` | timestamptz | auto |
| `updated_at` | timestamptz | auto |

### `lobbies`
| Column | Type | Notes |
|--------|------|-------|
| `id` | uuid | PK, default `gen_random_uuid()` |
| `creator_id` | uuid | FK → `auth.users`, NOT NULL |
| `sport` | text | `'Tenis'` \| `'Padel'` \| `'Badminton'` \| `'Squash'` |
| `skill_level` | text | `'Her seviye'` \| `'Başlangıç'` \| `'Orta Seviye'` \| `'İleri Seviye'` |
| `date_time` | timestamptz | NOT NULL |
| `court` | text | NOT NULL |
| `notes` | text | nullable |
| `is_public` | bool | NOT NULL, default true |
| `status` | text | `'open'` \| `'full'` \| `'cancelled'`, default `'open'` |
| `created_at` | timestamptz | auto |
RLS: anyone can SELECT where `is_public=true AND status='open'`; only `creator_id=auth.uid()` can INSERT/UPDATE.

### `messages`
| Column | Type | Notes |
|--------|------|-------|
| `id` | uuid | PK |
| `sender_id` | uuid | FK → `profiles.id` |
| `receiver_id` | uuid | Nullable FK → `profiles.id` (see ADR-004) |
| `text` | text | |
| `timestamp` | timestamptz | |
| `is_read` | bool | default false |

---

## Notes

- Update this file when configuration changes
- Never commit actual credentials to version control