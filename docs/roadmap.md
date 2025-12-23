# Status Roadmap

## Table of Contents
- [Status Roadmap](#status-roadmap)
  - [Table of Contents](#table-of-contents)
  - [2025 H2](#2025-h2)
    - [2.35](#235)
      - [Features](#features)
    - [2.36](#236)
      - [Features](#features-1)
    - [2.37](#237)
      - [Features](#features-2)
    - [2.38](#238)
      - [Features](#features-3)

## 2025 H2

### 2.35

Release Epic: https://github.com/status-im/status-app/issues/17966

#### Features

- [QT6 migration](https://github.com/status-im/status-app/issues/17622)
  - No provided FURPS at the moment
    - This is about maintaing the same level of quality as with QT5 but with QT6 instead.
  - Done ✅ 🟩🟩🟩🟩🟩 100%
- [Tablet Build](https://github.com/status-im/status-desktop/issues/17941)
  - [FURPS](/docs/FURPS/tablet-build.md)
  - Done ✅ 🟩🟩🟩🟩🟩 100%
- [Jump to screen (Shell)](https://github.com/status-im/status-app/issues/17971)
  - [FURPS](/docs/FURPS/jump-to-screen-shell.md)
  - Done ✅ 🟩🟩🟩🟩🟩 100%
- [Backup user data locally](https://github.com/status-im/status-app/issues/18106)
  - [FURPS](/docs/FURPS/local-user-backups.md)
  - Done ✅ 🟩🟩🟩🟩🟩 100%

### 2.36

Release Epic: https://github.com/status-im/status-app/issues/18029

Estimated release: End of November

#### Features

- [Mobile build](https://github.com/status-im/status-desktop/issues/18082)
  - [FURPS](/docs/FURPS/mobile-build.md)
  - Progress is also inherited from the Tablet Epic above
  - In Progress ⏳ 🟩🟩🟩🟩⬜ 83%
- [Memory and Performance improvements](https://github.com/status-im/status-desktop/issues/18296)
  - No provided FURPS at the moment as this is mostly about profiling and fixing issues found.
  - In Progress ⏳ 🟩🟩🟩⬜⬜ 64%
- [Dapp Browser](https://github.com/status-im/status-desktop/issues/19246)
  - [FURPS](/docs/FURPS/dapp-browser.md)
  - In Progress ⏳ 🟩🟩🟨⬜⬜ 55%
- [Local Backup finishing touches](https://github.com/status-im/status-desktop/issues/18583)
  - Done ✅ 🟩🟩🟩🟩🟩 100%
- [Opt-in Messages local backup](https://github.com/status-im/status-app/issues/18527)
  - Done ✅ 🟩🟩🟩🟩🟩 100%
- [Opt-in Messages Sync during local pairing](https://github.com/status-im/status-app/issues/18892)
  - Done ✅ 🟩🟩🟩🟩🟩 100%
- [External Activity fetching](https://github.com/status-im/status-app/issues/17188)
  - Done ✅ 🟩🟩🟩🟩🟩 100%
- [Translation initiative](https://github.com/status-im/status-app/issues/18293)
  - In Progress ⏳ 🟩🟩🟩🟩⬜ 82%
- [Full Emoji list in Reactions](https://github.com/status-im/status-desktop/issues/18766)
  - Done ✅ 🟩🟩🟩🟩🟩 100%


### 2.37

Release Epic: https://github.com/status-im/status-app/issues/18528

Estimated release: Mid-December

#### Features

- [Backend refactor](https://github.com/status-im/status-go/issues/6435) 
  - Runs parallel to other features and doesn't need to be shipped to any particular milestones
  - No API changes are expected until the Chat SDK is integrated
  - [Roadmap, Documentation and FURPS](https://zealous-polka-dc7.notion.site/Backend-Refactoring-2078f96fb65c80d8954ae8fc651b3a33)
  - In Progress ⏳ 🟩🟩🟨⬜⬜ 55% (estimated progress as not all subtasks are created)
- [Privacy mode](https://github.com/status-im/status-desktop/issues/17619)
  - [FURPS](/docs/FURPS/privacy-mode.md)
  - In Progress ⏳ 🟩🟩🟩🟩⬜ 88%
- Improve Token List and Support custom tokens
  - In Progress ⏳
- Private Transactions
- [Ethereum Follow Protocol](https://github.com/status-im/status-desktop/issues/18685)
  - In Progress ⏳ 🟨⬜⬜⬜⬜ 10%
- Keycard Shell Integration
- [UI modularization](https://github.com/status-im/status-desktop/issues/17872)
  - [FURPS](/docs/FURPS/ui-modularization.md)
  - In Progress ⏳ 🟩⬜⬜⬜⬜ 27%

### 2.38

Estimated release: February

#### Features

- Improve User support
- RLN
  - Dependant on the Chat SDK being (partialy) implemented and integrated as part of the Backend refactor
- News Feed on Waku
- File sending over Codex
  - Dependant on Codex being available in Light mode for mobile and having a C library
