# Notes & Reminders App — Project Roadmap

Companion to `notes-reminders-architecture.md` (data model) and `system-architecture.mermaid` (system diagram). This doc is the sequencing: what to do, in what order, and how to know each stage is actually done before moving on.

**Guiding principles for the whole build:**
- Single-user, non-commercial → don't build for scale you don't have yet.
- Offline-first → the app should always work; sync is an enhancement, never a dependency.
- One person building this → optimize for momentum and things you can actually finish, not architectural purity.

---

## System architecture, in one paragraph

Each Flutter client (phone, desktop, tablet) holds a full local SQLite database via `drift` and works completely offline. When reachable, clients sync with a small API running on your MacBook Pro M1 Max over Tailscale, using record-level last-write-wins. Photos upload to the server like any other synced data; videos never leave the device that recorded them — only a thumbnail and metadata sync, with the actual file transferable peer-to-peer on demand later. The server also bridges to CalDAV/Google Calendar for reminders, and the app itself talks to Siri (App Intents) and Gemini (AppFunctions) directly on-device. See `system-architecture.mermaid` for the full picture.

---

## A few technical decisions this plan assumes (flag now if you'd rather change them)

| Decision | Pick | Why |
|---|---|---|
| State management | **Riverpod** | Plays well with `drift`'s reactive streams (a query auto-updates the UI), and is straightforward to test in isolation — useful since you're building solo with no one else to catch regressions. |
| Routing | **go_router** | The current standard for Flutter; handles deep links cleanly, which you'll want for widget taps and Siri/Gemini intents jumping straight to a specific note. |
| Server language | **Dart** (via `shelf` or `dart_frog`) | Lets you share model/serialization classes between client and server — one language for the whole project, no context-switching, no duplicate type definitions to keep in sync by hand. |
| Repo layout | **Monorepo**: `/app` (Flutter client), `/server` (sync API), `/packages/models` (shared Dart types) | Keeps client and server schema changes atomic in one commit instead of coordinating across repos. |

---

## Phase 0 — Design foundations
*Goal: know what you're building before you build it.*

- [ ] Export your actual Notion structure (Notion → `···` → Export → Markdown & CSV) and reconcile it against the `items`/`folders`/`tags` schema — this is the one piece still based on a generic guess.
- [ ] Sketch the core navigation model: sidebar (folders) + search + backlinks panel — rough wireframes are enough, doesn't need to be pretty yet.
- [ ] Decide the "home" views you actually need day-to-day (e.g. Today, Upcoming, All Notes, a given folder) — this drives your routing structure in Phase 2.
- [ ] (Optional) Use Claude Design to explore visual direction — colors, typography, dark mode, empty states — as a reference to translate into Flutter, not a direct handoff.

**Checkpoint:** you can describe, in a sentence each, what happens when you open the app, create a note, and create a reminder.

---

## Phase 1 — System design
*Goal: no major structural decisions left once code starts.*

- [ ] Finalize the `drift` schema from `notes-reminders-architecture.md` against your real Notion export from Phase 0.
- [ ] Define the sync API contract: `POST /push` (client → server changes), `GET /pull?since=<timestamp>` (server → client changes), auth (a single long-lived token per device is enough behind Tailscale — no need for full OAuth for a private single-user server).
- [ ] Decide the video on-demand transfer mechanism (can stay "manual for now," per your earlier call — just confirm that's still fine before it's a Phase 7 blocker).
- [ ] Write out the module structure for `/app` (e.g. `data/`, `sync/`, `features/notes/`, `features/reminders/`, `widgets/`).

**Checkpoint:** you could hand this doc + the architecture doc to another developer and they'd know what to build without asking you questions.

---

## Phase 2 — Environment setup
*Goal: able to run a blank app on every target device.*

- [x] Install Flutter SDK + Xcode + Android Studio toolchains on the MacBook. *(Flutter + Xcode installed; Android Studio deferred — Android emulator not yet verified)*
- [x] `flutter create` the project; confirm it runs on iOS simulator, Android emulator, and macOS desktop. *(Verified on iOS simulator, macOS desktop, and web; Android pending Android Studio install)*
- [x] Set up Tailscale on the MacBook; confirm you can reach it by hostname from your phone off wifi (cellular data), not just on the same network. *(Tailscale already connected on this Mac; phone-off-wifi check still needs to be done manually)*
- [x] Scaffold `/server` (empty `shelf`/`dart_frog` project, one health-check endpoint) and get it running as a `launchd` service so it survives reboots/logouts. *(Running as a per-user LaunchAgent — see server/README.md)*
- [x] Init git; first commit.

**Checkpoint:** blank Flutter app runs on 2+ platforms, and your phone can hit the server's health-check endpoint over Tailscale from outside your home wifi.

---

## Phase 3 — Milestone 1: local data layer
*Goal: the app works fully offline, no sync yet.*

- [ ] Implement the `drift` schema (`items`, `item_status_log`, `saved_views`, `templates`, `folders`, `tags`, `item_tags`, `links`, `attachments`) exactly as finalized in Phase 1.
- [ ] Build the repository layer (CRUD for items/folders/tags; status changes always append to `item_status_log` rather than just overwriting `items.status`).
- [ ] Wire up FTS5 search.
- [ ] Basic tests on the data layer (create/update/soft-delete an item, tag it, search for it, log a status change).

**Checkpoint:** you can create, edit, tag, and search notes/reminders on one device, fully offline, with nothing else built yet.

---

## Phase 4 — Milestone 2: core UI & navigation
*Goal: it's actually usable day-to-day on one device.*

- [ ] Notes tab and Reminders tab as two queries over `items` (`body != ''` / `is_task = 1`) — not two separate data sources.
- [ ] Saved views: build/edit a filter as a real AND/OR condition tree (§3b), not just a flat filter list; pin/reorder views; "Today" shipped as the default pinned view.
- [ ] `display_mode` toggle (list ↔ calendar) on any saved view — confirm this is still the intended design (open question in the architecture doc) before building it.
- [ ] Item editor (title, markdown body, `is_task` toggle, scheduled window, recurrence, tags, pin).
- [ ] "In progress, unscheduled" view (the floating-card case — active items with no schedule).
- [ ] Backlinks panel.
- [ ] Search UI.
- [ ] Template picker on item creation (stretch — fine to ship Phase 4 with just an "Empty" default and add real templates once you know which ones you actually reuse).

**Checkpoint:** you'd genuinely rather use this than Notion for a day, on your main device.

---

## Phase 5 — Milestone 3: sync
*Goal: multiple devices agree with each other.*

- [ ] Implement `/push` and `/pull` on the server, LWW merge logic, soft-delete handling.
- [ ] Implement the client-side sync engine: queue local changes, push/pull on connectivity change, apply incoming changes to local `drift` DB.
- [ ] Manual multi-device test: edit on phone offline, edit on desktop offline, reconnect both, confirm the newer edit wins and nothing crashes.

**Checkpoint:** create a note on your phone, see it appear on desktop within a few seconds of both being online.

---

## Phase 6 — Milestone 4: reminders & calendar
- [ ] Local notifications for `remind_at` (independent of `scheduled_start`).
- [ ] Recurrence handling via an RRULE package, generating occurrences from `recurrence_rule`.
- [ ] Marking an occurrence done writes to `item_status_log` (keyed by `occurrence_date`), not just `items.status` — this is what keeps a recurring series' history correct.
- [ ] Auto-`missed` job: when a scheduled window closes with nothing logged done, flip status to `missed` and log it. Confirm you still want this automatic before building it (open question in the architecture doc).
- [ ] CalDAV or Google Calendar bridge on the server, keyed off `calendar_event_id`.

**Checkpoint:** a recurring reminder created in the app shows up correctly on your phone's actual calendar, and completing this week's occurrence doesn't affect next week's.

---

## Phase 7 — Milestone 5: analysis & summary
*Goal: the data you've been logging since Phase 6 becomes visible.*

- [ ] Weekly/monthly rollups from `item_status_log`: completion rate, missed count, by tag.
- [ ] A simple summary view — doesn't need to be fancy, a few numbers and a list of what slipped is enough to start.

**Checkpoint:** you can answer "how many things did I actually finish this week" without manually counting.

---

## Phase 8 — Milestone 6: media
- [ ] Photo capture/upload → server, per the schema.
- [ ] Video capture stays local; thumbnail generation + metadata sync only.
- [ ] "Video available on [device]" placeholder on other devices.
- [ ] (Optional, can defer) On-demand peer-to-peer video pull between devices.

**Checkpoint:** a note with a photo looks the same on every device; a note with a video shows a placeholder everywhere except where it was shot.

---

## Phase 9 — Milestone 7: platform integrations
- [ ] Home screen widgets (WidgetKit / Glance) reading from the local cache.
- [ ] Siri via `flutter_app_intents`.
- [ ] Gemini via `flutter_intents` (Android AppFunctions).
- [ ] Deep links from widget taps / assistant actions into the right item via `go_router`.

**Checkpoint:** "Hey Siri, add a reminder to [app name]" actually creates one, and a widget on your home screen shows real, current data.

---

## Phase 10 — Hardening
- [ ] Confirm Time Machine (or equivalent) is actually backing up the server's data — do a real test restore, not just "it's configured."
- [ ] Offline edge cases: airplane mode mid-edit, server unreachable on launch, empty states.
- [ ] Performance check with a realistic volume of notes (import your real Notion data, don't test on 10 fake items).

**Checkpoint:** you'd trust this with your actual data, unattended, for a month.

---

## Phase 11 — Migrate & daily-drive
- [ ] Import real data from your Notion export.
- [ ] Use it as your only notes/reminders app for a week.
- [ ] Keep a running list of friction points — that becomes your v0.3 backlog, not more upfront design.

---

## Suggested working rhythm

Build and use Phases 3–4 (local-only) before touching sync at all — it's tempting to build sync early since it's "core," but you can't properly test sync logic without real usage patterns to sync, and a working offline app is already useful on its own. Treat each phase checkpoint as a hard gate: if you can't honestly check it off, that's a signal to stay in that phase rather than layering the next one on top of something shaky.
