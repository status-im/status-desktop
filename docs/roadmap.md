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

    2.35 release :milestone, m235, 2025-07-21, 1d

    section 2.35
    Qt6 migration           :2025-06-01, 26d
    Tablet build            :t1, 2025-06-08, 31d
    Jump to screen (shell)  :2025-06-01, 24d
    User data local backups :lb1, 2025-06-16, 25d
    Memory improvements     :mi1, 2025-07-01, 30d

    2.36 release            :milestone, m236, 2025-09-08, 1d

    section 2.36
    Mobile build            :2025-06-09, 60d
    Privacy Mode            :after m235, 25d
    Dapp Browser            :after t1, 35d
    Messages local backups  :after lb1, 18d

    2.37 release             :milestone, m237, 2025-10-27, 1d

    section 2.37
    UI Modularization           :2025-08-04, 60d
    Improve user support        :after m236, 20d
    RLN                         :2025-08-04, 55d
    News Feed on Waku           :after mi1, 25d
    File sending over Codex     :2025-09-01, 30d
    Keycard Shell integration   :2025-09-01, 25d

```

### 2.35

Release Epic: https://github.com/status-im/status-desktop/issues/17966

#### Features:

- [Backend refactor](https://github.com/status-im/status-go/issues/6435) 
  - Runs parallel to other features and doesn't need to be shipped to any particular milestones
  - No API changes are expected until the Chat SDK is integrated
  - [Roadmap, Documentation and FURPS](https://zealous-polka-dc7.notion.site/Backend-Refactoring-2078f96fb65c80d8954ae8fc651b3a33)
  - In Progress ⏳ 20% 🟩⬜⬜⬜⬜ (estimated progress as not all subtasks are created)
- [QT6 migration](https://github.com/status-im/status-desktop/issues/17622)
  - No provided FURPS at the moment
    - This is about maintaing the same level of quality as with QT5 but with QT6 instead.
  - In Progress ⏳ 🟩🟩🟩🟩🟨 91%
- [Tablet Build](https://github.com/status-im/status-desktop/issues/17941)
  - [FURPS](/docs/FURPS/tablet-build.md)
  - In Progress ⏳ 🟩🟩🟩🟩⬜ 80%
- [Jump to screen (Shell)](https://github.com/status-im/status-desktop/issues/17971)
  - [FURPS](/docs/FURPS/jump-to-screen-shell.md)
  - Done ✅ 🟩🟩🟩🟩🟩 100%
- [Backup user data locally](https://github.com/status-im/status-desktop/issues/18106)
  - [FURPS](/docs/FURPS/local-user-backups.md)
  - In Progress ⏳ 🟩🟩🟩🟩⬜ 88% (+33%)
- [Memory and Performance improvements](https://github.com/status-im/status-desktop/issues/18296)
  - No provided FURPS at the moment as this is mostly about profiling and fixing issues found.
  - In Progress ⏳ 🟩🟩🟨⬜⬜ 50% (+11%)
- [External Activity fetching](https://github.com/status-im/status-desktop/issues/17188)
  - In Progress ⏳

### 2.36

Release Epic: https://github.com/status-im/status-desktop/issues/18029


### Features:

- [Mobile build](https://github.com/status-im/status-desktop/issues/18082)
  - [FURPS](/docs/FURPS/mobile-build.md)
  - Progress is also inherited from the Tablet Epic above
  - In Progress ⏳ 🟨⬜⬜⬜⬜ 17% (+8%)
- [Privacy mode](https://github.com/status-im/status-desktop/issues/17619)
  - [FURPS](/docs/FURPS/privacy-mode.md)
- [Dapp Browser](https://github.com/status-im/status-desktop/issues/17970)
  - [FURPS](/docs/FURPS/dapp-browser.md)
- Ethereum Follow Protocol

### 2.37

Not all Epics are created yet as it's too early to know exactly what will be worked on. The taks listed below are estimates of what could bring value.

- [UI modularization](https://github.com/status-im/status-desktop/issues/17872)
  - [FURPS](/docs/FURPS/ui-modularization.md)
  - In Progress ⏳ 🟩⬜⬜⬜⬜ 25%
- Improve User support
- RLN
  - Dependant on the Chat SDK being (partialy) implemented and integrated as part of the Backend refactor.
- News Feed on Waku
- File sending over Codex
  - Dependant on Codex being available in Light mode for mobile and having a C library.
- Keycard Shell Integration

