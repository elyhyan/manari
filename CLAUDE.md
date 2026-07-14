# CLAUDE.md

Read `docs/project-roadmap.md` first — it defines the current phase and the
checklist for what to build next. Read `docs/notes-reminders-architecture.md`
before touching schema, sync, or scheduling code.

## Project

Personal, offline-first notes/reminders app. Flutter clients + a Dart sync
server running on a home Mac over Tailscale. Single user, non-commercial —
do not add multi-user/collaboration infrastructure unless explicitly asked.

## Stack

- Client: Flutter + `drift` (SQLite) + Riverpod + `go_router`
- Server: Dart (`shelf` or `dart_frog`), shares types with the client via `packages/models`
- Sync: record-level last-write-wins on `updated_at` — not CRDTs, not PowerSync/ElectricSQL

## Core data model — do not violate these without asking

- One `items` table. Notes and Reminders are **filtered views** over it
  (`body != ''` vs `is_task = 1`), not separate tables or linked rows.
  Never reintroduce a separate reminders/notes table.
- Status changes append to `item_status_log`. Don't just overwrite
  `items.status` for recurring items — "done" applies to one occurrence.
- `scheduled_start`/`scheduled_end` are a soft window, not a hard due date.
  Both may be null.
- `saved_views.filter_definition` is a JSON AND/OR condition tree — keep
  filter logic capable of nesting, not a flat list.
- Videos never upload to the server; only thumbnail + metadata sync.

## Workflow

- One small branch per roadmap checklist item (`feature/...`), merged via PR.
- Conventional commit prefixes: `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`.
- Tag `main` at each roadmap phase checkpoint (see `phase0-1-design-complete`
  for the naming pattern).
- Check off completed items in `docs/project-roadmap.md` in the same PR that
  finishes them, so the roadmap stays a true source of status.

## Current status

Phase 2 (environment setup) mostly done: Flutter app scaffolded and verified
on iOS simulator/macOS/web; server scaffolded and running as a launchd
LaunchAgent, health-check reachable over Tailscale. Remaining before Phase 3:
Android Studio toolchain + emulator verification, and confirming the server
is reachable from your phone off wifi.
