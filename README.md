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
