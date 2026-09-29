# symmetry-emr

> Home Health EMR module — the clinician's workspace: dashboard, calendar & map, patients, timesheet, and the OASIS / visit-note forms they open.

- **Org:** SymmetryCare · **Repo:** `symmetry-emr` · **GitHub:** https://github.com/SymmetryCare/symmetry-emr
- **Type:** Flutter application (module app)
- **Stack:** Flutter/Dart
- **Status:** analyzes and builds standalone and shell-hosted — see CHANGELOG.md

## What this repo is
The screen the monolith's home menu opens at `/emrDesktop` ("Home Health EMR")
for the Clinical, Assistant, Office Admin and CEO roles:

- **Dashboard** — today's visits (start / miss / reschedule / pause), the day's
  map, new visit requests, alerts, reminders, supply orders, forms needing
  correction
- **Calendar** — monthly visit calendar and route map, visit details
- **Patients** — assigned patients; chart (OASIS / plan of care, orders, notes,
  documents), schedule, profile (demographics, insurance, physician, orders,
  initial contact), forms, protocols, alerts, patient and care-team chat
- **Timesheet** — earnings calendar, pay periods, events, daily summary
- **Profile / Settings** (from the app bar) — documents, time off, pending visit
  notes, earnings, availability
- The **OASIS form builder** the chart and Start Visit open

The separate role screens the monolith routes QA, QA Manager, Coder, Clinical
Manager and DME to (`/qaCoordinatorDesktop`, `/qamDesktop`, `/coderDesktop`,
`/clinicalDesktop`, `/dmeDesktop`) are **not** routes of this app. Some of
their widgets are carried because the EMR and OASIS code reaches for them (see
Notes).

## Where the code came from
`Symmetry-Application-FE` `lib/presentation/screens/emr_module` — the working
copy on `dev_final` as of 2026-09-29, uncommitted changes included — plus
everything that subtree transitively needs, and the shared layer (app
scaffolding, API client, token manager, login flow, legacy shared widgets)
taken from **symmetry-RIS**, which had taken it from symmetry-establishment,
which had de-monolithed it from symmetry-hr.

Nothing in `Symmetry-Application-FE`, `symmetry-hr`, `symmetry-establishment`,
`symmetry-RIS` or `symmetry-shell` was modified. This repo is a copy.

The repo's first commit (2026-08-16) held a byte-for-byte copy of
`emr_module` as it stood at monolith commit `fd312020b` (2026-06-30) — screens
only, with monolith import paths and no pubspec dependencies, so it could not
build. It was replaced wholesale; see CHANGELOG.md.

## Structure
Mirrors symmetry-RIS / symmetry-establishment:

- `lib/main.dart` — `EmrApplication`; gates `initialRoute` on the access token,
  exactly as HR and Establishment do
- `lib/app` — config, resources, API client, `TokenManager`, `ShellLink`
- `lib/presentation` — the login flow and shared widgets
- `lib/modules/emr` — this module:
  - `presentation/screens` — the 154 EMR screens, at the same relative paths
    they had under `emr_module` (`responsive_screen/`, `emr_tab/...`)
  - `oasis_form_builder` — the monolith's `lib/oasis_form_builder`, as used by
    EMR (form mapper, builder, the OASIS / evaluation / visit-note forms)
  - `presentation/shared_widgets` — the widgets and constants EMR reaches for
    outside its own subtree, grouped by where they came from in the monolith
    (`legacy/`, `em/`, `scheduler/`, `communication/`, `qa_coordinator/`,
    `coder/`, `clinical_manager/`, `qa_manager/`, `hr/`)
  - `presentation/controllers`, `providers`, `resources`
  - `data/api` (managers + repository), `data/models`
- `web/`, `config/emr.env`, `images/`, `assets/`

## Auth
Same mechanism as HR, Establishment and RIS. `TokenManager` stores the session
in `SharedPreferences`, which on web is `localStorage`, scoped to the
**origin** — that is the whole single-sign-on story, and why every module app
must be served from a path on the shell's origin rather than its own subdomain.

## Two shapes, both supported
Decided at build time, defaulting to standalone so a build that forgets the
flags behaves like a plain standalone app rather than linking somewhere that
may not be deployed:

- **Standalone** — served at the site root, its own login screen:
  ```
  flutter build web --dart-define=API_ENDPOINT=/api --dart-define=APP_VERSION=1.0.0
  ```
- **Shell-hosted** — symmetry-shell at `/`, this app at `/emr/`, one origin.
  Opens already signed in; logout and session expiry go back to the shell's
  login:
  ```
  flutter build web --base-href=/emr/ --dart-define=SHELL_PATH=/ \
    --dart-define=API_ENDPOINT=/api --dart-define=APP_VERSION=1.0.0
  ```
  The shell must also be built with `emr` in `DEPLOYED_MODULES`, or its Home
  Health EMR entry stays disabled. The shell's `module_registry.dart` already
  maps `'emr'` to `/emr/`.

## How to run
```
flutter run -d chrome --dart-define=API_ENDPOINT=https://greenvalley.symmetry.care/api --dart-define=APP_VERSION=standalone-dev
```

## Configuration / keys
`API_ENDPOINT` / `APP_VERSION` via `--dart-define`. With no `API_ENDPOINT`
the default is `https://greenvalley.symmetry.care/api` (the same default as
symmetry-hr and the monolith). Non-secret runtime values in `config/emr.env`.
`web/index.html` loads the Google Maps JS API (dashboard map, Calendar route
map, address pickers) and PDF.js (document previews through `pdfx`).

## Depends on (sibling repos)
- symmetry-RIS (source of the shared layer, duplicated here — see Notes)
- symmetry-ui-kit, symmetry-contracts (not yet wired)

## Used by
- symmetry-shell (composes this module) — not yet wired on the shell side

## Read these first
`lib/main.dart`, then
`lib/modules/emr/presentation/screens/responsive_screen/responsive_screen_emr.dart`,
then `lib/modules/emr/presentation/screens/emr_tab/emr_dashbord/emr_desktop_screen.dart`.

## Notes

### The shared layer is duplicated, not shared
The same duplication that already exists between the shell, HR, Establishment
and RIS. The `TokenManager` key names are what make single sign-on work, so
they must stay identical across the five copies until `symmetry-ui-kit` exists.

What changed in the copy: the package name, the login flow's post-login route
(`/emrDesktop`), the tab title ("EMR | <tenant>"), and the `API_ENDPOINT`
default. `DepartmentIds` is carried but not warmed at start-up — only the
screens RIS and Establishment rewrote read it, and the EMR code here is the
monolith's.

### Where the monolith's import graph was cut
`emr_module`'s transitive import closure in `Symmetry-Application-FE` is
**1367 of the monolith's Dart files** — effectively the whole app. The
monolith analyzes with 0 errors, and the analyzer's `unused_import` warnings
identify exactly which import directives bring in nothing the importing file
uses. Only those were cut: **34 directives in 31 files**, each left in place as
a `// removed in extraction:` comment on the line the import was on. No import
that the analyzer considers used was removed.

After the cuts the closure is **851 files**. That is larger than RIS (130)
because the OASIS form builder alone is ~400 files, and because the form mapper
and several dashboard popups genuinely use widgets from the Scheduler (Intake),
Communication, Company Identity, QA Coordinator and Coder screens. Those are
carried under `presentation/shared_widgets/` but are not routes of this app.

`lib/main.dart` of the monolith is not followed — screens reach back into it,
and this repo has its own. The one symbol read from it, `navigationKeyOasis`
(used by `oasis_form_builder/constants/responsive.dart`), is declared in this
repo's `main.dart`. In the monolith it is never attached to a navigator, so it
is left unattached here too and `Responsive` behaves identically.

### Providers
`main.dart` registers the 21 provider types this code consumes that the
monolith's root `main.dart` registers, found by auditing every
`Consumer`/`Selector`, `context.watch/read/select` and `Provider.of` against
every place a provider is created. Two further types —
`AsyncDataController` (Intake documentation / physician-info widgets) and
`CIPoliciesProcedureProvider` (Company Identity policies tab) — are consumed but
registered nowhere, **in the monolith too**; they are left as they are.

### Assets
Every asset path referenced from `lib` (185 files) was copied from the
monolith and declared in `pubspec.yaml`. One reference,
`images/oasis_rn_soc/wound_body.png` (OASIS RN SOC question 10019004), does not
exist in the monolith either; it is left as is.

### Not exercised against a live backend
No request in this module has been run against a real API from this repo. The
managers and repositories are the monolith's, byte for byte apart from import
paths, so the endpoints are whatever the monolith calls today.

---
_This CONTEXT.md is the machine- and human-readable brief for the repo. Keep it current; log every change in CHANGELOG.md._
