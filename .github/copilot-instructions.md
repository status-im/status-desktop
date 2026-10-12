# Project Guidelines

## Architecture

- This repository is the Status app codebase for desktop and mobile. The frontend is primarily Qt/QML (`ui/`), with Nim middleware (`src/`) coordinating UI-facing modules and services.
- Core product behavior runs locally: the app's backend is `vendor/status-go`, which owns local databases and protocol/backend behavior. When tracing a feature, follow the path from QML through Nim and the status-go bindings into `vendor/status-go`; implement a fix in the layer that owns the behavior rather than adding a workaround above it.
- Android may run status-go in a separate service process with a stub/IPC layer. Read the relevant ADRs in `docs/adr/` before changing Android service, IPC, login-resume, or notification behavior.
- Preserve the QML → Nim middleware → local backend responsibilities described in [`docs/architecture.md`](../docs/architecture.md). `ui/StatusQ` is the reusable QML/C++ component library; application-specific `AppLayouts` should not become dependencies of StatusQ.

## Build, test, and lint

For setup and platform prerequisites, follow [`BUILDING.md`](../BUILDING.md) (desktop) and [`mobile/README.md`](../mobile/README.md) (mobile). The desktop build uses the root Makefile; after setting up the required Qt, Nim, Go, and other dependencies, build dependencies and run the app with:

```bash
make update
make run
```

Available focused checks:

| Area | Run | Run one test |
| --- | --- | --- |
| Nim host tests | `make tests-nim` | `make nim-test-run/test/nim/<test_file>.nim` |
| StatusQ C++ tests | `make run-statusq-tests` | `make run-statusq-tests ARGS="-R <CTestName>"` |
| Storybook QML tests | `make run-storybook-tests` | Open the Storybook project in Qt Creator and select a QML test, or run the built `QmlTests` executable with `<TestCase>::<test_function>` |
| Desktop end-to-end tests | From `test/e2e`, activate its virtual environment and run `pytest -m critical` | `pytest tests/onboarding/test_language_selector_and_password_strength.py -v --maxfail=1` |
| QML lint | `make qml-lint` | The target checks all QML files under `ui/`; it does not provide per-file selection. |

Nim tests live in `test/nim/`; files ending in `_bench.nim` are benchmarks, not part of `make tests-nim`. The Nim test make targets and per-test setup are in [`makefiles/nim-tests.mk`](../makefiles/nim-tests.mk). Storybook's tests are built with Storybook and can also be run via CTest in its build directory; test names and setup are defined in [`storybook/CMakeLists.txt`](../storybook/CMakeLists.txt). For the e2e prerequisites, test configuration, and additional test commands, see [`test/e2e/README.md`](../test/e2e/README.md).

## Key conventions

- Keep presentation and interaction in QML, orchestration and module wiring in Nim, and backend logic/persistence/protocol behavior in `vendor/status-go`.
- Nim modules commonly follow a view/interface/module/controller structure; module interfaces connect the view and controller, while controllers call services. Use the examples and diagrams in [`docs/architecture.md`](../docs/architecture.md) when extending module wiring.
- In QML, keep backend access behind domain stores and place model/data transformations in adaptors rather than views or stores. Route popup requests through the app-level popup handlers instead of coupling low-level components to popup construction or stores. Follow [`guidelines/QML_ARCHITECTURE_GUIDE.md`](../guidelines/QML_ARCHITECTURE_GUIDE.md) for store, adaptor, model, and testing details.
- All user-visible text in QML must be wrapped in `qsTr("...")` for translation (use `qsTr("%n item(s)", "", count)` for plurals). After adding or changing strings, run `make update-translations` and commit the updated `ui/i18n/qml_base.ts` and `ui/i18n/qml_en.ts`; CI enforces this. See [`I18N.md`](../I18N.md).
- New QML unit tests should generally go in `storybook/qmlTests/tests`; Storybook discovers these tests. QML unit tests run without the backend, using stubs, and StatusQ-specific tests may live under `ui/StatusQ/tests`.
- When implementing behavior that crosses QML, Nim, and `vendor/status-go`, trace the full call path and keep the change at its owning layer.
