# symmetry-emr

Home Health EMR module (clinician dashboard, calendar & map, patients, timesheet, OASIS / visit-note forms).

See **CONTEXT.md** for the full brief (purpose, stack, auth, how to run) and **CHANGELOG.md** for the log.

Part of the SymmetryCare platform. GitHub: https://github.com/SymmetryCare/symmetry-emr

## Run standalone

```sh
flutter run -d chrome \
  --dart-define=API_ENDPOINT=https://greenvalley.symmetry.care/api \
  --dart-define=APP_VERSION=standalone-dev
```

## Build behind symmetry-shell

Served at `/emr/` on the shell's origin, opening already signed in:

```sh
flutter build web --base-href=/emr/ \
  --dart-define=SHELL_PATH=/ \
  --dart-define=API_ENDPOINT=/api \
  --dart-define=APP_VERSION=1.0.0
```

The shell must be built with `emr` in `--dart-define=DEPLOYED_MODULES`
or its Home Health EMR entry stays disabled.

## URLs

Every page has its own real path — no `#` — relative to the base href. The
full list is in `lib/app/router/emr_routes.dart`:

```
/emr/dashboard   /emr/calendar   /emr/patients   /emr/timesheet   /emr/chat
/emr/qa/dashboard      /emr/qa/my-tasks      /emr/qa/chat
/emr/coder/dashboard   /emr/coder/my-tasks   /emr/coder/chat
```

`/emr/` (and the login screen's URL when signed in) opens the signed-in role's
dashboard — QA and Coder their own, everyone else the clinician one. The old
route names go where they always did: `/emrDesktop` and `/home` to the
clinician dashboard, `/qaCoordinatorDesktop` and `/coderDesktop` to theirs.
Old `#` links (`/emr/#/emrDesktop`) are rewritten in `web/index.html`.

The clinician's patient and visit screens add their names to the URL while
open — `/emr/patients/patient/protocol` — never the patient or visit itself,
which stays in memory. Back closes them one at a time, as it always has; a
refresh on one lands on the page under it.

## Deploy: the server must serve index.html for every EMR path

Refreshing a page, pressing Enter in the address bar or opening a copied link
asks the server for that path, and no such file exists. The server must answer
any path under `/emr/` that is not a real file with `/emr/index.html`:

```nginx
location /emr/ {
  try_files $uri $uri/ /emr/index.html;
}
```

Without this rule every page except `/emr/` itself is a 404 on refresh.
Standalone at the site root, the same rule applies to `/` and `/index.html`.
