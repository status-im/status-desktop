# Onboarding refactoring

TODO

- [ ] Consider moving path requirements, into `StatusGoQt` or unify them as module requirement through abstraction
- [ ] Refactor to use typed IDs across Account and Login services instead of plain strings.
    - A quick workaround would be to add a generic NamedType and convert strings at status-go APIs boundaries
- [ ] Bring uniformity to namespace: `Status::<domain>`. Don't go too deep, not deeper than two domain-related namespaces
- [ ] Consider RAII for controllers, remove `init`
