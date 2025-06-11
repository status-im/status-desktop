# Status Roadmap

## Table of Contents
- [2025 H2](#2025-h2)
  - [Gantt Chart](#gantt-chart)
  - [2.35](#235)
  - [2.36](#236)
  - [2.37](#237)

## 2025 H2

### Gantt Chart

```mermaid
gantt
    title Status Roadmap 2025 H2
    excludes    weekends
    dateFormat  YYYY-MM-DD

    Backend refactor        :2025-06-01, 90d

    2.35 release :milestone, m237, 2025-07-14, 1d

    section 2.35
    Qt6 migration           :2025-06-01, 20d
    Tablet build            :t1, 2025-06-01, 31d
    Jump to screen (shell)  :2025-06-01, 24d
    UI Modularization       :2025-06-01, 60d
    User data local backups :lb1, 2025-06-16, 20d

    2.36 release            :milestone, m236, 2025-09-01, 1d

    section 2.36
    Mobile build            :2025-06-09, 60d
    Memory improvements     :mi1, after lb1, 30d
    Dapp Browser            :after t1, 35d
    Messages local backups  :after lb1, 18d

    2.37 release             :milestone, m237, 2025-10-20, 1d

    section 2.37
    Privacy Mode            :after m236, 25d
    Improve user support    :after m236, 20d
    RLN                     :2025-08-04, 55d
    News Feed on Waku       :after mi1, 25d
    File sending over Codex :2025-09-01, 30d
```

### 2.35

Release Epic: https://github.com/status-im/status-desktop/issues/17966

Estimated release: Mid-End July

#### Features:

- [Backend refactor](https://github.com/status-im/status-go/issues/6435) 
  - Runs parallel to other features and doesn't need to be shipped to any particular milestones
  - No API changes are expected until the Chat SDK is integrated
  - [Roadmap, Documentation and FURPS](https://zealous-polka-dc7.notion.site/Backend-Refactoring-2078f96fb65c80d8954ae8fc651b3a33)
- [QT6 migration](https://github.com/status-im/status-desktop/issues/17622)
  - No provided FURPS at the moment and this is about maintaing the same level of quality as with QT5 but with WT6 instead.
- [Tablet Build](https://github.com/status-im/status-desktop/issues/17941)
  - [FURPS](/docs/FURPS/tablet-build.md)
- [Jump to screen (Shell)](https://github.com/status-im/status-desktop/issues/17971)
  - [FURPS](/docs/FURPS/jump-to-screen-shell.md)
- [UI modularization](https://github.com/status-im/status-desktop/issues/17872)
  - [FURPS](/docs/FURPS/ui-modularization.md)
- [Backup user data locally](https://github.com/status-im/status-desktop/issues/18106)
  - [FURPS](/docs/FURPS/local-user-backups.md)

### 2.36

Release Epic: https://github.com/status-im/status-desktop/issues/18029

Estimated release: Mid September

### Features:

- [Mobile build](https://github.com/status-im/status-desktop/issues/18082)
  - [FURPS](/docs/FURPS/mobile-build.md)
- [Memory improvements](https://github.com/status-im/status-go/issues/6544)
  - No provided FURPS at the moment as this is mostly about profiling and fixing issues found.
- [Dapp Browser](https://github.com/status-im/status-desktop/issues/17970)
  - [FURPS](/docs/FURPS/dapp-browser.md)

### 2.37

Not all Epics are created yet as it's too early to know exactly what will be worked on. The taks listed below are estimates of what could bring value.

- [Privacy mode](https://github.com/status-im/status-desktop/issues/17619)
  - [FURPS](/docs/FURPS/privacy-mode.md)
- Improve User support
- RLN
  - Dependant on the Chat SDK being (partialy) implemented and integrated as part of the Backend refactor.
- News Feed on Waku
- File sending over Codex
  - Dependant on Codex being available in Light mode for mobile and having a C library.

Estimated release: End of October
