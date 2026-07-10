# Notes & Reminders App — Architecture & Data Model (v0.2)

Based on: cross-platform, offline-first with sync, core data model + navigation as the first milestone, calendar integration, widgets, and Siri/Gemini assistant integration.

**v0.2 revision:** Notes and Reminders are now confirmed as one `items` entity, with "Notes" and "Reminders" as two *filtered views* over the same data rather than two linked-but-separate rows. Scheduling, status, saved views/filters, and templates were also fleshed out based on your actual Notion usage patterns.

---

## 1. Recommended stack

| Layer | Pick | Why |
|---|---|---|
| App framework | **Flutter** | Single Dart codebase → iOS, Android, macOS, Windows, Linux, and Web. It's currently the only cross-platform framework with mature, actively maintained packages for *both* Siri/App Intents and Android AppFunctions (what Gemini uses to call into apps) from one codebase. |
| Local database | **SQLite via `drift`** | Type-safe Dart ORM over sqlite3. Same DB file format on every platform. Supports FTS5 for instant full-text search. |
| Sync | **Custom record-level last-write-wins sync** (not PowerSync/ElectricSQL) | Matches the model you described ("last edited/modified local version wins"), and for a single-user app across a handful of devices, running a full sync-engine + Postgres stack is more infrastructure than the problem needs. See §2. |
| Server hardware | **MacBook Pro M1 Max (spare)**, reachable via **Tailscale** (not port-forwarding) | Single-user, non-commercial app — one machine is an acceptable single point of failure as long as it's backed up (Time Machine or a second drive) and the app is offline-first, so a server outage just delays cross-device sync rather than breaking the app. Revisit if this ever becomes multi-user/commercial. |
| Media storage | **Photos**: uploaded to the server, treated like the rest of synced data. **Videos**: stay device-local only — never uploaded | Keeps video playback fully local (no streaming/transcoding to worry about) and keeps sync payloads small. Only a thumbnail + metadata row for videos travels through sync — see §3. |
| Calendar sync | CalDAV (Apple Calendar, most others) or Google Calendar API | Both consume the same iCalendar `RRULE` format, which is why the schema stores recurrence that way directly. |
| Home screen widgets | Native per platform: WidgetKit (iOS), Glance/RemoteViews (Android), read from a small cache the Flutter app writes | Widgets always render outside the Flutter engine on both platforms — there's no way around some native code here, but it's a thin read-only view, not app logic. |
| Assistant integration | `flutter_app_intents` (Siri, Shortcuts, Spotlight) + `flutter_intents` (Android AppFunctions → Gemini) | Both let you declare actions in Dart and generate the native Swift/Kotlin glue. |

**Why not PowerSync / ElectricSQL / Zero:** these are excellent if you outgrow "one person, a few devices" — e.g. if this ever becomes multi-user or real-time collaborative. Right now they'd add a Postgres instance, a sync service, and a conflict-resolution model (CRDTs) you don't need yet. Worth revisiting if scope changes; not worth the setup cost for v0.1.

---

## 2. Sync model

Record-level **last-write-wins**, exactly matching what you described:

- Every `items` row has `updated_at` (UTC) and `updated_by_device_id`.
- On reconnect, each device pushes any row where `updated_at` is newer than the last successful sync.
- The server keeps whichever version has the newest `updated_at` and discards the other.
- Deletes are **soft deletes** (`deleted_at` timestamp, row kept) — this way a delete on one device and an edit on another resolve through the same timestamp comparison, no special-casing needed.

**Honest tradeoff:** if you edit the same item offline on two devices before either syncs, the older edit is silently discarded — this is the fundamental limitation of LWW vs. a CRDT. For a personal notes app that's usually a non-issue (rare, low-stakes, and you're the only editor). If it ever actually bites you, the cheap incremental fix is storing prior `body` snapshots per item (lightweight version history) rather than migrating to a full CRDT sync engine.

---

## 3. Core data model

See the attached ER diagram (`data-model-erd.mermaid`) for the visual, entities below.

### `items` — one entity; Notes and Reminders are views over it, not separate rows

Every note, task, and hybrid of the two is a row in `items`. Two independent, derived facts decide where it shows up — no manual "type" picker, no risk of the two getting out of sync with the actual content:

- **`is_task = true`** → appears in the **Reminders** view.
- **non-empty `body`** → appears in the **Notes** view.

Both can be true at once — that's your Linux example (`W1.D5 Linux: Pipes, redirection & search`): one row, `is_task = true`, with a growing markdown body as you learn. It shows up in Reminders because it's schedulable/actionable, and in Notes because there's real content — the same row, not two connected ones. A pure idea-dump has `is_task = false` and only ever shows in Notes. A bare "buy milk" reminder has `is_task = true` and an empty body — it shows in Reminders only, and doesn't clutter Notes with a title-only entry. "Turn this note into a task" is just flipping `is_task`; "turn this task into a note" is just typing in the body — no conversion step, no data migration.

Nested "levels" inside a note (sub-pages, sub-databases) are child `items` via `parent_id` — already in the schema, now with a concrete job.

### `item_status_log`
Append-only log of status changes. This exists for two reasons: it's what the analysis/summary view queries against (completion rate over a week/month, by tag), and it's what makes "done" mean *this Thursday's occurrence*, not *the whole recurring series* — see §3a.

### `saved_views`
User-created, nameable, pinnable, reorderable filtered views — "Today" ships as a built-in default, pinned first. Each view stores its filter as a small JSON logic tree so conditions can nest with AND/OR rather than being a flat list — see §3b.

### `templates`
Backs the template picker you screenshotted — name, icon, whether it pre-sets `is_task`, default tags, and a starter markdown body, plus a manual position for drag-to-reorder and an `is_default` marker.

### `folders`
Nested folders/notebooks. Kept in the schema, but secondary — tags + saved views are the primary way you navigate, per your "flatter" call earlier; folders are there if you occasionally want a light manual grouping, not a required hierarchy.

### `tags` + `item_tags`
Labels, many-to-many with items — your primary grouping mechanism, including AI-suggested tags on creation later (an integration detail on top of this table, not a schema change).

### `links`
Item-to-item references, back to their original job now that notes/reminders aren't separate rows: connecting genuinely *different* items — e.g. a task referencing an unrelated note for context. Powers a "linked to N other items" panel.

### `attachments`
Files/images attached to an item — but **not all attachment data is synced the same way**:

- **Photos** behave like everything else in the schema: uploaded to the server, `file_path` points at the server copy, visible/loadable on every device.
- **Videos** are treated differently on purpose. Only a small "always synced" row travels through sync (thumbnail, duration, file size, and which device actually holds the file); the video file itself stays on whichever device recorded/holds it and is never uploaded. This means opening a note with a video on a *different* device shows a "video available on [device]" placeholder rather than either silently missing it or trying to stream a multi-GB file through the server. Pulling the actual file to another device (if you ever want that) is a separate, explicit, on-demand transfer — ideally peer-to-peer between devices over Tailscale, not routed through the server.

### 3a. Scheduling — "do" time, not "due" time

Replaces a single `due_at` with a soft window plus an independent notification time:

- **`scheduled_start` / `scheduled_end`** (both nullable) — a window, not a deadline. A one-off task at a fixed time sets both to the same instant. "Do this Thursday–Saturday" sets a window; combined with `recurrence_rule`, that window repeats weekly rather than generating three separate Thu/Fri/Sat instances.
- **`remind_at`** — when to actually notify, independent of the window (e.g. remind an hour before `scheduled_start`, or not at all).
- **Both null** — perfectly valid. Something you're actively working on "on and off" with no schedule simply has `is_task = true`, `status = in_progress`, no dates. It won't appear in Today/Upcoming (nothing to schedule against), but it appears in an **"In progress, unscheduled"** view — the floating card you described — so it doesn't get lost just because it isn't dated.
- **Missed, by default:** if a scheduled window closes with no `done` logged, it auto-flips to `missed` and a row is appended to `item_status_log`. This is a default, not a hard rule — flag it if you'd rather that transition stay fully manual.
- **Recurring completion:** "done" is logged per-occurrence in `item_status_log` (via `occurrence_date`), not by overwriting `items.status`. So marking this Thursday done doesn't mark next Thursday done — the series just keeps generating fresh occurrences from `recurrence_rule`, each tracked independently.

### 3b. Saved views & filter logic

`saved_views.filter_definition` is a JSON condition tree, so views support real AND/OR/grouped logic rather than a flat list of filters:

```json
{
  "and": [
    { "field": "tag", "op": "in", "value": ["work"] },
    {
      "or": [
        { "field": "status", "op": "eq", "value": "in_progress" },
        { "field": "scheduled_start", "op": "is_null" }
      ]
    }
  ]
}
```

That example is exactly your "work stuff that's either in progress or has no schedule yet" floating card. `scope` (`reminders` / `notes` / `both`) decides which top-level area a view lives under; `display_mode` (`list` / `calendar`) is a separate, independent choice from the filter itself — so any saved view can be looked at as a table or dropped onto a weekly/monthly calendar without being a fundamentally different view. **Flag it if you actually wanted Timeline/Calendar to be one fixed, separate screen instead of a display toggle on any view** — that's a real fork in how the UI gets built, worth nailing down before Phase 4.

---

## 4. SQL schema (SQLite, drift-compatible)

```sql
CREATE TABLE folders (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  parent_id TEXT REFERENCES folders(id),
  position INTEGER NOT NULL DEFAULT 0,
  color TEXT,
  icon TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT
);

CREATE TABLE items (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL DEFAULT '',
  body TEXT NOT NULL DEFAULT '',              -- markdown; non-empty => appears in Notes view
  is_task INTEGER NOT NULL DEFAULT 0,         -- true => appears in Reminders view
  status TEXT NOT NULL DEFAULT 'not_started', -- not_started | in_progress | on_hold | done | missed | archived
  priority INTEGER NOT NULL DEFAULT 0,        -- 0 none, 1 low, 2 med, 3 high
  scheduled_start TEXT,                       -- ISO8601, nullable — soft "do" window start
  scheduled_end TEXT,                         -- ISO8601, nullable — window end (= start for a single instant)
  remind_at TEXT,                             -- ISO8601, when to notify (independent of the window)
  recurrence_rule TEXT,                       -- RRULE, e.g. 'FREQ=WEEKLY;BYDAY=TH,FR,SA'
  parent_id TEXT REFERENCES items(id),        -- nested notes / sub-items / sub-databases
  folder_id TEXT REFERENCES folders(id),      -- optional light grouping, secondary to tags/views
  position INTEGER NOT NULL DEFAULT 0,
  calendar_event_id TEXT,                     -- external UID once synced to a calendar
  is_pinned INTEGER NOT NULL DEFAULT 0,       -- "this task grew into a note that matters"
  template_id TEXT,                           -- which template this was created from, if any
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  updated_by_device_id TEXT NOT NULL,
  deleted_at TEXT
);

-- Append-only status history — powers analysis/summary, and makes "done"
-- apply to one occurrence of a recurring item rather than the whole series.
CREATE TABLE item_status_log (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL REFERENCES items(id),
  occurrence_date TEXT,       -- which occurrence this refers to; NULL for non-recurring items
  status TEXT NOT NULL,
  changed_at TEXT NOT NULL
);

-- User-defined filtered/pinned views, e.g. "Today", "Work — in progress or unscheduled".
-- filter_definition is a JSON condition tree (see architecture doc §3b) supporting nested AND/OR.
CREATE TABLE saved_views (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  scope TEXT NOT NULL DEFAULT 'both',         -- reminders | notes | both
  filter_definition TEXT NOT NULL,            -- JSON
  display_mode TEXT NOT NULL DEFAULT 'list',  -- list | calendar
  is_pinned INTEGER NOT NULL DEFAULT 0,
  position INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon TEXT,
  target_is_task INTEGER NOT NULL DEFAULT 0,  -- pre-sets is_task on the new item
  default_tag_ids TEXT,                       -- JSON array of tag ids
  body_scaffold TEXT,                         -- starter markdown content
  is_default INTEGER NOT NULL DEFAULT 0,
  position INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

CREATE TABLE tags (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  color TEXT
);

CREATE TABLE item_tags (
  item_id TEXT NOT NULL REFERENCES items(id),
  tag_id TEXT NOT NULL REFERENCES tags(id),
  PRIMARY KEY (item_id, tag_id)
);

CREATE TABLE links (
  from_item_id TEXT NOT NULL REFERENCES items(id),
  to_item_id TEXT NOT NULL REFERENCES items(id),
  created_at TEXT NOT NULL,
  PRIMARY KEY (from_item_id, to_item_id)
);

CREATE TABLE attachments (
  id TEXT PRIMARY KEY,
  item_id TEXT NOT NULL REFERENCES items(id),
  type TEXT NOT NULL,               -- image | video | file | audio
  created_at TEXT NOT NULL,

  -- Always synced (small) — safe for every attachment type
  file_path TEXT,                   -- server copy path; set for photos/files, NULL for video
  thumbnail_path TEXT,              -- poster-frame/preview image; synced even for video
  duration_seconds INTEGER,         -- video/audio only
  file_size_bytes INTEGER,
  origin_device_id TEXT,            -- which device holds the actual video file

  -- Device-local only — never leaves the device, meaningless on other devices
  local_uri TEXT
);

-- Full-text search over title + body
CREATE VIRTUAL TABLE items_fts USING fts5(
  title, body, content='items', content_rowid='rowid'
);

-- Keep the FTS index in sync with items
CREATE TRIGGER items_ai AFTER INSERT ON items BEGIN
  INSERT INTO items_fts(rowid, title, body) VALUES (new.rowid, new.title, new.body);
END;

CREATE TRIGGER items_ad AFTER DELETE ON items BEGIN
  INSERT INTO items_fts(items_fts, rowid, title, body) VALUES('delete', old.rowid, old.title, old.body);
END;

CREATE TRIGGER items_au AFTER UPDATE ON items BEGIN
  INSERT INTO items_fts(items_fts, rowid, title, body) VALUES('delete', old.rowid, old.title, old.body);
  INSERT INTO items_fts(rowid, title, body) VALUES (new.rowid, new.title, new.body);
END;
```

---

## 5. Fast-navigation notes

- **FTS5** (above) gives instant search-as-you-type over title + body, with no external search service, spanning notes and reminders at once since they're the same table.
- **Notes and Reminders as views, not screens with different data sources** — both are just `saved_views` scoped differently (`is_task = 1` vs `body != ''`), which means search, tags, and saved-view logic all work identically in both places for free.
- **`links`** table → a backlinks panel like Notion's ("3 items reference this") for genuinely separate items that reference each other.
- **`folder_id` + `parent_id`** stay separate: `parent_id` gives you nested sub-items/sub-databases *within* an item (your Linux-note-with-levels case), while `folder_id` is an optional flat grouping — not the primary nav, which is tags + saved views per your "flatter" call.
- Keep a small MRU list (last N opened item IDs) in local device prefs for an instant "recently viewed" — no need to put this in the synced schema at all.

---

## 6. Decisions made so far

- **Stack**: Flutter + SQLite/`drift` locally, record-level last-write-wins sync.
- **Server**: MacBook Pro M1 Max (spare), reachable via Tailscale, backed up via Time Machine/a second drive.
- **Media**: photos synced through the server; videos stay device-local only (thumbnail + metadata synced, file itself is not).
- **Notes/Reminders model**: one `items` entity; Notes and Reminders are filtered views (`body != ''` vs `is_task = 1`), not separate linked rows. Confirmed.
- **Scheduling**: soft `scheduled_start`/`scheduled_end` window + independent `remind_at`, not a single hard due date. Both nullable — unscheduled-but-active items surface via a dedicated view instead of a date field.
- **Navigation**: tags + saved views (with nested AND/OR filter logic) as primary; folders kept but secondary.

## 7. Open questions

1. **Timeline/Calendar** — confirm it's a `display_mode` toggle available on *any* saved view (per §3b), not a separate fixed screen. This changes how Phase 4 gets built.
2. **Auto-`missed` status** — confirmed as the default when a scheduled window closes with nothing marked done, or would you rather that transition stay fully manual?
3. **Your actual Notion export** — your written description in this conversation covers most of what I needed (properties, statuses, the templates screenshots); a raw export is now optional polish rather than a blocker, mainly useful for getting exact tag names right on migration.
4. **On-demand video transfer** — worth designing now, or fine to leave as "pull it manually for now" until it's actually needed?
