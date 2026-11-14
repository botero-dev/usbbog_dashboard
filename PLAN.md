# PLAN — usbbog_dashboard

A glanceable personal dashboard ("tablero") for phone, tablet, or spare screen: one scrollable
home page assembled from independent cards — time, daily Pokémon, photo gallery, to-do list.
Spanish UI, single user.

**Design source of truth:** Figma *Tablero* (file key `scjsoLRlPRoRtvTiT5HzU8`), page `0:1`.
Screens are 412×917 with 20 px page padding.

---

## 1. Scope

### In scope (v1)

| # | Screen | Figma node | Notes |
|---|--------|-----------|-------|
| 1 | Dashboard | `1:4` | scrollable card stack + empty state |
| 2 | Add widget | `1:50` | 4 widget types |
| 3 | Select account | `9:60` | saved accounts + "Add Account" |
| 4 | Add account | `9:85` | Server / User / Pass → Connect (validates) |
| 5 | Select list | `9:102` | albums for the chosen account |
| 6 | Pokedex | `1:49` | Pokémon detail |

### Out of scope (v1)

| Thing | Decision |
|-------|----------|
| Settings screen | Gear stays in the header but is a no-op. No content was designed. |
| "Reloj del sistema" `1:51`, "Calendario del sistema" `1:52` | Not screens. Tapping the clock/mini-calendar opens the **OS** apps via `url_launcher`. |
| Widget reorder / delete | Not designed. Stretch goal: long-press → delete. |
| Multiple photo backends, OAuth | Immich email + password only. |
| Localization, tablet/desktop layouts, image caching | Deferred. |

### Backends

| Card | Source | Auth | Status |
|---|---|---|---|
| Fecha/Hora | device clock + `url_launcher` | — | decided |
| Pokemon del dia | PokeAPI (`https://pokeapi.co/api/v2`) | none | decided |
| Galeria Immich | Immich REST | email + password | **deferred to M5** |
| Lista de Tareas | **CalDAV** (VTODO) | username + password | decided |

Accounts are backend-agnostic — the design's `Server / User / Pass` form serves CalDAV and Immich
alike; an `AccountKind` field says which.

---

## 2. Architecture: MVVM, one folder per module

```
views/ ──► view_models/ ──► services/ ──► outside world (HTTP, SharedPreferences, secure storage)
   │            │
   └────────────┴──► models/
```

| Folder | Contains | Must not contain |
|--------|----------|------------------|
| `models/` | Immutable data classes + hand-written `fromJson` / `toJson`. Pure Dart. | Flutter imports, HTTP, storage |
| `services/` | One class per integration: HTTP calls, JSON parsing, persistence, error translation. Returns models. | Widgets, `ChangeNotifier` |
| `view_models/` | `ChangeNotifier` holding UI state (`isLoading`, `error`, data), formatting (`"Lunes, Noviembre 16"`, `"123 cm"`), and command methods (`load`, `refresh`, `toggle`). | `BuildContext`, widgets |
| `views/` | Widgets. Layout, `ListenableBuilder`, tap callbacks, and visibility branches only. | HTTP, JSON, business rules |

- **State management:** `ChangeNotifier` + `ListenableBuilder` (both built into Flutter). No state-management package.
- **Navigation:** `Navigator.push` with typed results — the add-widget flow returns a `WidgetConfig` via `Navigator.pop(config)`. No router package, no global state.
- **Dependency wiring:** plain constructor injection in `app.dart`. No DI container.
- **Errors:** services throw `ApiException` / `StorageException`; view models `try/catch` and expose an error message to the view. No `Result<T>` type.

---

## 3. Folder structure

```
lib/
├── main.dart                      # runApp
├── app.dart                       # MaterialApp, theme, builds DashboardView + its view model
├── core/
│   ├── theme/app_theme.dart       # colors, text styles, card decoration
│   ├── network/api_client.dart    # http wrapper: GET/POST, headers, timeouts, throws ApiException
│   ├── storage/prefs.dart         # SharedPreferences helper (typed get/set JSON)
│   ├── storage/secure_store.dart  # flutter_secure_storage wrapper for passwords
│   └── utils/
│       ├── month_grid.dart        # pure: DateTime → weeks of days (Sunday-first)
│       ├── formatters.dart        # intl: "Lunes, Noviembre 16", "9:32"
│       └── system_apps.dart       # url_launcher: open OS clock / calendar
├── shared/
│   ├── widgets/
│   │   ├── surface_card.dart       # 24 px radius + 2 px white border card
│   │   ├── primary_button.dart     # the "Boton" component (332×87)
│   │   ├── wireframe_scaffold.dart # blue header + circular back (1:50, 9:60, 9:85, 9:102)
│   │   └── async_view.dart         # loading / error+retry — arrives with M3
│   └── views/
│       └── option_picker_view.dart # generic "Select List": title + options → pops one
└── modules/
    ├── dashboard/
    │   ├── models/widget_config.dart      # WidgetKind + sealed WidgetConfig (4 subclasses)
    │   ├── models/dashboard_item.dart     # id, order, config
    │   ├── services/dashboard_store.dart  # load/save list in SharedPreferences
    │   ├── view_models/dashboard_view_model.dart
    │   ├── widget_factory.dart            # WidgetKind + config → card widget (one switch)
    │   └── views/
    │       ├── dashboard_view.dart        # 1:4
    │       ├── add_widget_view.dart       # 1:50
    │       └── widgets/
    │           ├── greeting_header.dart   # "Hola, Andrés" + gear
    │           ├── add_widget_tile.dart   # the "+" card
    │           └── empty_dashboard.dart
    ├── clock/
    │   ├── view_models/clock_view_model.dart  # ticker + formatting + OS deep link
    │   └── views/
    │       ├── clock_card.dart                # clock + mini calendar + long date
    │       └── widgets/
    │           ├── mini_month_calendar.dart
    │           └── day_cell.dart
    ├── pokemon/
    │   ├── models/pokemon.dart
    │   ├── services/pokemon_service.dart      # PokeAPI
    │   ├── view_models/pokemon_view_model.dart
    │   └── views/
    │       ├── pokemon_card.dart              # dashboard tile
    │       └── pokedex_view.dart              # 1:49
    ├── photos/
    │   ├── models/album.dart
    │   ├── models/photo.dart
    │   ├── services/immich_service.dart       # login, albums, photo URLs
    │   ├── view_models/gallery_view_model.dart
    │   └── views/
    │       ├── gallery_card.dart              # dashboard tile (1:31)
    │       └── photo_view.dart                # fullscreen photo
    ├── tasks/
    │   ├── models/task.dart                   # id, summary, isDone, due
    │   ├── models/task_list.dart              # uid + displayName (a VTODO calendar)
    │   ├── services/caldav_service.dart       # connect, task lists, todos, complete
    │   ├── view_models/tasks_view_model.dart
    │   └── views/
    │       ├── tasks_card.dart                # 9:46
    │       └── widgets/checkbox_row.dart
    └── accounts/
        ├── models/account.dart                # id, kind (immich|caldav), label, server, user; no password
        ├── services/account_service.dart      # list/save/delete + secure password storage
        ├── view_models/select_account_view_model.dart
        ├── view_models/add_account_view_model.dart
        └── views/
            ├── select_account_view.dart       # 9:60
            └── add_account_view.dart          # 9:85
```

~38 files. `add_widget` has no module of its own: picking a type is one screen in `dashboard/`.
The "Select List" step is a generic picker in `shared/views/` because both photos (albums) and
tasks (VTODO calendars) need one.

**Skeleton status (done):** theme, `formatters`/`month_grid`/`system_apps`, the shared widgets,
all six screens, and the full navigation map. Cards still render demo data and each screen's
`ChangeNotifier` is only present where it already does work (`DashboardViewModel`,
`ClockViewModel`, `SelectAccountViewModel`, `AddAccountViewModel`). The services
(`pokemon_service`, `immich_service`, `caldav_service`), `async_view`, `photo_view` and the
per-card view models land with their milestones (M3–M5).

---

## 4. Data model and persistence

```dart
enum WidgetKind { clock, pokemon, gallery, tasks }

sealed class WidgetConfig {          // one file, four small subclasses
  WidgetKind get kind;
  Map<String, dynamic> toJson();
}

class ClockConfig extends WidgetConfig { ... }                                  // no fields
class PokemonConfig extends WidgetConfig { ... }                                // pokemonId (null = today's)
class GalleryConfig extends WidgetConfig { final String accountId, albumId; }   // + album label
class TasksConfig extends WidgetConfig { final String accountId, listId; }     // listId = CalDAV calendar uid, + list label
```

`DashboardItem { String id; int order; WidgetConfig config; }`

**SharedPreferences** key `dashboard.v1`. The stored `kind` is what tells `WidgetConfig.fromJson`
which subclass to build:

```json
[
  { "id": "e1", "order": 0, "kind": "clock",   "config": {} },
  { "id": "e2", "order": 1, "kind": "gallery", "config": { "accountId": "a1", "albumId": "alb1", "label": "Mis Fotos" } }
]
```

**Secure storage** (`flutter_secure_storage`): key `account.<id>.password` per account, plus
`accounts.v1` holding the non-secret account list `(id, kind, label, server, user)`. `kind`
(`immich` | `caldav`) selects which service validates the credentials when "Connect" is tapped.

**Card order:** every card is an item, seeded in the design's order — `[clock] [pokemon] [gallery]
[tasks]` — under a fixed greeting header, with the "+" tile always last. M2 persists the whole
list to `dashboard.v1`.

---

## 5. Navigation map

From the prototype (flow "App" starts at `Dashboard`); `→` = push, `←` = pop.

```
Dashboard 1:4
├─ tap "9:32"          → url_launcher: OS clock        (design screen 1:51 dropped)
├─ tap mini calendar   → url_launcher: OS calendar     (design screen 1:52 dropped)
├─ tap Pokémon card    → Pokedex 1:49                  ← back
├─ tap "Tareas" rows   → toggles locally (stays)
├─ tap gear            → no-op in v1
└─ tap "+"             → Add widget 1:50               ← back

Add widget 1:50   (tap a type)
├─ Fecha/Hora      → ClockConfig      (no further steps)
├─ Pokemon del dia → PokemonConfig    (no further steps)
├─ Galería Immich  → Select account 9:60 → Select list 9:102 → GalleryConfig
└─ Lista de Tareas → Select account 9:60 → Select list 9:102 → TasksConfig

Select account 9:60
├─ saved account → Select list 9:102
├─ Add Account   → Add account 9:85 (Connect validates, then saves) → Select list 9:102
└─ back          ← Add widget

Select list 9:102 → albums (photos, Immich) or VTODO calendars (tasks, CalDAV)
└─ tapping one pops a GalleryConfig / TasksConfig back to Dashboard
```

Prototype gaps this plan closes: *Select list* was a dead end (it now pops a config back to the
dashboard), and *Pokemon del dia* had no link (it is now a one-step add).

---

## 6. Design tokens (from Figma)

**Dashboard**

| Token | Value |
|---|---|
| Background | linear gradient `#2B2917` → `#847F66`, top → bottom |
| Text | white, **Inter** |
| Type scale | 64 (clock), 32 (greeting, date, card titles), 16 (body, task rows), 12 (card eyebrow), 10 (weekday initials, semibold) |
| Card | radius 24, transparent fill, 2 px `#FFFFFF` border |
| Layout | 20 px page padding, 31 px between blocks |
| Gallery card | radius 24, image fill, 372×168 |

**Wireframe screens** (Add widget / Select account / Add account / Select list / Pokedex)

| Token | Value |
|---|---|
| Header bar | `#62B2EB`, 106 px tall |
| Body | `#FFFFFF` |
| Button ("Boton") | `#D8D8D8`, 332×87, 32 px padding, 32 px label |
| Primary action (Connect) | `#9FADFF` |
| Pokedex body / image placeholder | `#EF5DA8` / `#CEE6FF` |

The Figma file publishes only one variable (`--sds-color-icon-default-default` = `#FFFFFF`), so
every other value lives as a constant in `core/theme/app_theme.dart`.

Mini-calendar rule: **Sunday-first**, real dates (Nov 1 2026 is a Sunday, Nov 16 2026 a Monday —
matches the design).

---

## 7. Dependencies

```yaml
dependencies:
  http: ^1.2.0                  # PokeAPI + Immich
  caldav: ^1.5.0                # CalDAV: discovery, calendars, VTODO CRUD (brings dio)
  shared_preferences: ^2.3.0    # dashboard layout, account list
  flutter_secure_storage: ^9.2.0 # passwords
  url_launcher: ^6.3.0          # open OS clock / calendar
  intl: ^0.19.0                 # Spanish date/time formatting
```

No `go_router`, no `riverpod`/`bloc`, no `freezed`/`json_serializable`, no code generation.

`caldav` gives us `CalDavClient.connect()` (with `.well-known` discovery), `getCalendars()`,
`getTodos()`, `createTodo()`, `updateTodo()` and ETag `ConflictException` — so the whole task
backend is one dependency instead of hand-written WebDAV `PROPFIND`/`REPORT` + a VTODO parser.
It has low adoption (≈800 downloads), so pin it; if it misbehaves the fallback is `http` + `xml`
+ `icalendar_parser`, all confined to `tasks/services/caldav_service.dart`.

---

## 8. Build order

| Milestone | Deliverable | Done when |
|---|---|---|
| **M0** | Scaffold: folders, `app_theme.dart`, `app.dart`, empty `DashboardView` | `flutter run` shows the olive gradient with "Hola, …" |
| **M1** | Clock card: live time, mini calendar from `month_grid.dart`, long date, OS deep links | Tapping the clock opens the phone's clock app |
| **M2** | Persistence + add/remove: `dashboard.v1`, `Add widget` picker (the two account-free types enabled, the other two marked "próximamente"), long-press to delete | Layout survives app restart |
| **M3** | Pokémon: `pokemon_service.dart` (PokeAPI), card, Pokedex view | Card and detail show real Haunter data |
| **M4** | Accounts + Tasks: `account_service.dart` (secure storage), `add_account_view` (validates with `CalDavClient.connect`), `select_account_view`, task-list picker, `tasks_card` with `getTodos` / `updateTodo` | A real CalDAV task appears and checking it survives a refresh |
| **M5** | Photos (Immich, *deferred*): `immich_service.dart`, album picker, `gallery_card`, `photo_view` | A real album photo renders on the dashboard |
| **M6** | Polish: empty state, loading/error+retry on every card, spacing/typography pass, unit tests, README update | All 6 screens reachable; no red screens on airplane mode |

Each milestone is independently demoable and leaves the app runnable.

---

## 9. Testing

Small and targeted — this is a college project, not a QA suite.

| Test | Covers |
|---|---|
| `test/core/month_grid_test.dart` | month-start edge cases (Sunday and Saturday starts), Sunday-first alignment |
| `test/modules/dashboard/widget_config_test.dart` | JSON round-trip for all 4 config types |
| `test/modules/dashboard/dashboard_store_test.dart` | save → load → order preserved, unknown kind skipped |
| `test/modules/pokemon/pokemon_model_test.dart` | PokeAPI JSON → `Pokemon`, dm→cm / hg→g conversion |
| `test/modules/tasks/caldav_mapping_test.dart` | `CalendarTodo` → `Task` mapping, completed flag, no network |

Widget tests and golden tests: stretch goal only. Everything above is pure Dart — no server, no
mocking framework.

---

## 10. Deliberate simplifications

| Full reference architecture | This plan | Why |
|---|---|---|
| `model/ data/ view/` triad per module | `models/ services/ view_models/ views/` | Flat, no nesting, names say what they hold |
| Plugin registry + `DashboardWidgetModule` interface | `WidgetKind` enum + one `switch` in `widget_factory.dart` | ~20 lines instead of an SPI; add the registry only past ~8 widget types |
| DTO + mapper + API client + repository impl (4 files) | one `<x>_service.dart` + `fromJson` on the model | ~80 lines per integration instead of ~250 |
| Hand-written WebDAV XML + iCal/VTODO parsing | `caldav` package with `CalendarTodo` | The one place where a dependency is much cheaper than the code |
| `Result<T>` / `Either` | typed exceptions caught in view models | Fewer concepts to defend in a report |
| DI container | constructor arguments from `app.dart` | One wiring site, no framework |
| `go_router` | `Navigator.push` + `pop(result)` | No router config to learn; results type-check |
| Localization (`.arb`) | Spanish strings inline | Second language is out of scope |
| Clean's domain layer / use cases | none | There is no business logic to isolate — cards fetch and render |

If the project later grows (task sync, second photo backend), the upgrade path is local: add a
`Result<T>`, split a service into DTO+mapper+repository, or introduce the module interface —
nothing above blocks that.

---

## 11. Decisions and open questions

### Decided

1. **Tasks come from CalDAV** with username + password, via the `caldav` package. A "list" is a
   VTODO-capable calendar (`TaskList { uid, displayName }`); ticking a row calls
   `updateTodo(todo.copyWith(status: completed))`, so completion is stored on the server.
2. **Immich auth is deferred to M5** — not decided yet. `Add account` lands in M4 against
   CalDAV only, which de-risks the form; Immich then reuses the same screen with
   `AccountKind.immich`.
3. **Pokémon of the day:** `dayOfYear % dexCount` — deterministic, no backend.
4. **Pokémon image:** `sprites.other['official-artwork'].front_default`, falling back to
   `sprites.front_default` (the design's 131×131 placeholder).
5. **Empty dashboard:** not designed. v1 shows a centered "Agrega tu primer widget" card in the
   same "+" style.
6. **Figma nits:** the `Tareas` frame (`9:46`, 181 px) clips its 141 px content and the inner
   `Frame 3` (`1:21`) is 1070 px tall inside a 917 px screen — treated as intentional scrolling,
   so the card height follows its content. The gallery card's image is a placeholder, not an
   asset to extract.

### Still open

1. **Finding VTODO-capable calendars.** Prefer the advertised
   `supported-calendar-component-set`; if the package does not expose it, list every calendar and
   drop the ones whose `getTodos()` fails.
2. **HTTP demo server.** `caldav` refuses plain `http://` unless constructed with
   `allowInsecure: true`. Decide at M5 whether the demo runs against a local Radicale/Baïkal
   (flag on, development only) or a real HTTPS host.
3. **Due dates and priority.** `CalendarTodo` exposes both, but the design's rows are only a
   checkbox + title. v1 ignores them; adding a due-date line is a one-widget change if wanted.

