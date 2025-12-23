# UI Modular Architecture ([#17872](https://github.com/status-im/status-app/issues/17872))

## Functionality
- Establish a clean separation between UI and backend through a layered architecture (Services → Modules → Stores → Adaptors → UI Components).
- Enable domain-specific modularization to support unique functional requirements while maintaining a unified interface.
- Implement a standardized communication layer to pass data and trigger backend methods.

## Usability
- Improve developer usability by exposing clean, testable, and reusable components.
- Enable consistent data flow and structure for all UI domains, improving readability and onboarding.
- Document architectural patterns and usage conventions to reduce ambiguity during development.

## Reliability
- Reduce tight coupling between business logic and UI to minimize bugs from implementation side effects.
- Ensure predictable data flow with read-only modules and strictly typed store usage.
- Safeguard against improper store usage with guidelines on instantiation and component scope.

## Performance
- Avoid unnecessary data duplication and propagation through read-only modules and centralized ground truth state.
- Minimize transformation overhead by using adaptors only when necessary for UI display logic.
- Ensure UI responsiveness by decoupling business logic processing from rendering logic.

## Supportability
- Use strictly typed interfaces (`no var`) to catch issues at compile time and improve tooling support.
- Design components and stores for unit testing and Storybook stubbing.
- Enable cross-domain collaboration with shared structure, architecture diagram, and clear development guidelines.
- Facilitate future scaling by allowing domains to evolve independently within the modular structure.
