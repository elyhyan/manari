# Notes & Reminders

Personal, offline-first notes/reminders app — Flutter clients, synced via a small
Dart server running on a home Mac over Tailscale. Built to replace a Notion setup
with features Notion doesn't support: flexible "do" scheduling instead of hard due
dates, saved views with real AND/OR filter logic, and a single unified item model
where a task and its notes are the same row instead of two linked ones.

## Start here

- [`docs/notes-reminders-architecture.md`](docs/notes-reminders-architecture.md) — data model, stack, sync model
- [`docs/project-roadmap.md`](docs/project-roadmap.md) — phased build plan with checkpoints
- [`docs/system-architecture.mermaid`](docs/system-architecture.mermaid) — clients, server, integrations
- [`docs/data-model-erd.mermaid`](docs/data-model-erd.mermaid) — entity relationships
- [`docs/product-flow.mermaid`](docs/product-flow.mermaid) — Notes/Reminders as views over one table
- [`docs/sync-flow.mermaid`](docs/sync-flow.mermaid) — device-to-device sync sequence

## Layout

```
app/              Flutter client (iOS, Android, macOS, Windows, Linux)
server/           Dart sync server (shelf/dart_frog), runs on the home Mac
packages/models/  Shared Dart types, used by both app/ and server/
docs/             Architecture, roadmap, diagrams — read before touching code
```

## Status

Design phase complete (roadmap Phases 0–1). Next: Phase 2, environment setup —
see `docs/project-roadmap.md`.
