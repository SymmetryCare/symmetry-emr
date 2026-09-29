# Changelog

All notable changes to this repo. Newest first.

## 2026-09-29 — EMR extracted from the monolith as a runnable module app

`symmetry-emr` is now the Home Health EMR lifted out of `Symmetry-Application-FE`
`lib/presentation/screens/emr_module`, as its own Flutter app in the shape
symmetry-hr, symmetry-establishment and symmetry-RIS already use. Nothing in
`Symmetry-Application-FE`, `symmetry-hr`, `symmetry-establishment`,
`symmetry-RIS` or `symmetry-shell` was touched.

### What was replaced

The previous contents (`lib/emr_module`, 148 files from the 2026-08-16 import)
were a byte-for-byte copy of `emr_module` at monolith commit `fd312020b`
(2026-06-30). Since then the monolith's EMR had 147 more commits (about 17k
lines added and 11k removed, 136 of the 148 files changed) and 6 new files
(treatment pause, availability, pending visit notes, edit document / profile
popups, a shared text field). The copy also could not build: it imported
monolith paths (`../../app/...`, `package:prohealth/...`) that are not in the
repo, and `pubspec.yaml` declared no dependencies. It was removed, not merged.
The old files remain in git history.

### What was carried

- **The shared layer** — `lib/app`, `lib/data`, `lib/services`, the login flow
  and `lib/presentation/shared/widgets` — copied from symmetry-RIS and renamed
  to the `symmetry_emr` package. The login flow now lands on `/emrDesktop`, the
  tab title reads "EMR | <tenant>", and `API_ENDPOINT` defaults to
  `https://greenvalley.symmetry.care/api`. The shared layer's imports into
  RIS's module were pointed at the EMR copies of the same monolith files; the
  one RIS-only helper they need, `form_dialog_fields.dart`, is carried at
  `modules/emr/presentation/shared_widgets/`.
- **851 files from the monolith's working copy** (`dev_final`, uncommitted
  changes included): the 154 EMR screens at their original relative paths
  under `lib/modules/emr/presentation/screens`, the OASIS form builder, the
  managers and repositories they call, their models, providers and resources,
  and the widgets they reach for outside their own subtree.
- **185 asset files**, every one the code references.
- `web/`, `analysis_options.yaml` and `.gitignore` from symmetry-RIS, with the
  web title and manifest renamed to EMR. `.gitignore` replaces a one-line file
  whose newlines were literal `\n`.

### Cutting the import graph

`emr_module`'s transitive import closure in the monolith is 1367 files. The
monolith analyzes with 0 errors, so its `unused_import` warnings are an exact
list of import directives that bring in nothing the file uses. Only those were
cut — **34 directives in 31 files** — each left as a
`// removed in extraction:` comment on the line it occupied. Closure after the
cuts: 851 files. The monolith's own `lib/main.dart` is not followed; the single
symbol read from it (`navigationKeyOasis`, never attached to a navigator in
the monolith) is declared, likewise unattached, in this repo's `main.dart`.

### Entry point and shell connection

`lib/main.dart` is `EmrApplication`, following Establishment and RIS:

- boots to `/emrDesktop` when a session is in `localStorage`, otherwise to the
  login screen (Establishment's gate);
- every route that would show a login form goes through `_loginOrShell()`, so a
  shell-hosted build (`SHELL_PATH=/`) sends logout and session expiry to the
  shell rather than showing a second login form at `/emr/`;
- registers the 21 providers the EMR code consumes that the monolith registers
  app-wide (see CONTEXT.md > Providers).

### Verified

- `flutter analyze` — **0 errors** (1236 warnings and 4871 infos, all in code
  inherited from the monolith).
- `flutter build web` with no shell flags — builds, `<base href="/">`.
- `flutter build web --base-href=/emr/ --dart-define=SHELL_PATH=/ --dart-define=API_ENDPOINT=/api`
  — builds, `<base href="/emr/">`.
- Standalone build in a browser: boots to the login screen, title
  "EMR | localhost", frontend config loaded, clean console.
- A scratch copy (not this repo) built with `initialRoute` forced to
  `/emrDesktop` and an unreachable `API_ENDPOINT`: the dashboard renders (map,
  stat cards, today's visits, to-do list), and the Calendar, Patients and
  Timesheet tabs each render, with no `ProviderNotFoundException` and no error
  widget. The only console errors are the failed calls to the unreachable API.
  With the real default endpoint and no session, the calls return 401, the
  refresh fails, and the app signs out to the login screen, as designed.
- Shell-hosted build served at `/emr/` on one origin: with no session it
  redirects to the shell at `/`; with a session in `localStorage` it opens
  straight to `/emr/#/emrDesktop`, no second login.

### Not verified

- No request has been run against a live backend with a real session.
- Only the four tabs' first screens were opened. The patient chart, the OASIS
  forms, the popups and Profile / Settings were not clicked through — they need
  a signed-in session and data. The provider audit covers the whole repo, not
  just the screens reached.
- The shell side is not wired: `emr` still has to be added to the shell's
  `DEPLOYED_MODULES` and the shell's menu entry pointed at `/emr/`.

## 2026-08-16 — repo initialized
- Created under the SymmetryCare org with the agreed name.
- Added CONTEXT.md (repo brief) and this changelog.
- Initial code import from source (see CONTEXT.md > Where the code came from).
