
# Status Desktop Architecture Guide

## Introduction

This document contains a series of architectural decisions, principles, and
best practices. They are largely derived from
[SOLID](https://en.wikipedia.org/wiki/SOLID), adapted to the needs of
the project. Many of them are not applied in the current code, but there is
a great need to change this and establish a clear application architecture and
improve the quality of the code. The goal is to follow these guideline in new
code and gradually fix existing codebase.

The diagram depicting top-level architecture can be found
[here](https://miro.com/app/board/uXjVKS3chcc=/).

## General architecture good practices

- Singletons should be stateless.

  Any state in a singleton is a flaw from the application architecture point
  of view. This creates a number of problems. First, it causes unit tests to be
  interdependent, introducing hard to detect bugs. Another, even more important
  problem is the order of initialization. In code like this:

  ```qml
  Component.onCompleted: {
    Global.applicationWindow = this // BAD
  }
  ```

  there is no guarantee that other components will not call `Global.applicationWindow`
  before this variable is initialized. The order of initialization of QML
  components and therefore calls to `Component.onCompleted` is undefined.

- Singletons should not refer to the backend.
  The only layer that has access to the backend is the layer of stores.
  Components relying on singletons accessing the backend are hard to test.
  Backend references used in the singleton must be mocked, which is problematic
  and requires additional exposure of context properties from the singleton only
  for testing and storybook purposes, as in the example below.

  ```qml
  // Utils.qml (singleton)
  
  QtObject {
    property var mainModuleInst: typeof mainModule !== "undefined" ? mainModule : null
    property var sharedUrlsModuleInst: typeof  sharedUrlsModule !== "undefined" ? sharedUrlsModule : null
    property var globalUtilsInst: typeof globalUtils !== "undefined" ? globalUtils : null
  }
  ```

  The testing/storybook code also becomes complicated because it is important to
  ensure that a singleton is mocked before the tested component is instantiated.

  Stateless singleton also means not using components like `Settings` inside singletons.

- The API of components should be well thought out. Expose dependencies,
  hide internal details.

  Ideally, it should be enough for a developer to read the public API of a given
  component to understand what is needed to use it correctly.

  - Examples of hidden dependencies:
    - using stateful singletons - components communicate to each other
      implicitly, dependency is not visible in their public API
    - communicating by calling signals on global objects
    - accessing backend via singletons
    - taking via public API much more than needed (e.g. component needs two
      properties from store, but the whole store is provided with tens of
      properties and methods). It is violation of `ISP` from `SOLID`
  - Examples of not hidden details:
    - component contains searchable list and exposes search string assuming that
      filtering will be done externally

- Favor composition over parameterization and inheritance.

  Overly parameterized components are fragile and not easy to maintain. Big set
  of switches, altering the appearance and behavior of the component, introduces
  a lot of conditional statements in the internal implementation. Finally,
  it is difficult to assure that all combinations are valid or specify which ones
  are valid and desired.

- Do not make assumptions about the context in which the component will be used.

  ```qml
  Item {
    anchors.fill: parent // Bad, will lead to warnings when used in a Layout
    // ...
  }
  ```

  In most cases, it is a good idea to use `Control` (or more specialized component)
  as the base component.

  ```qml
  Control {
    contentItem: ColumnLayout {
      // ...
    }
  }
  ```

- Action signals (e.g. click on delegate) should not provide metadata from the
  model. Only `index` or unique `key` should be an argument. The necessary
  metadata should be fetched on the signal receiver side.

  ```qml
  signal collectibleClicked(int chainId, string contractAddress, 
                            string tokenId, string uid, int tokenType) // BAD
  signal collectibleClicked(var collectible)                           // BAD

  signal collectibleClicked(string key)                                // OK
  ```
  
  Otherwise, the component unnecessarily bypasses some values from the model.
  Callers may also want to access roles which are not used for displaying.
  It leads to creating unnecessary requirements for the input model.

- use consistently `key` as a unique identifier of the model, even if there are
  other roles with unique values.
  
  On the UI side, `key` should be used only for identification, with no other
  assumptions and usage. Thanks to that, content of that role can be freely
  changed on the backend with no implications to the UI side. Even if `address`
  is unique, a separate `key` role should be used (providing the same content as
  `address` role).
  
  Other good name for that role - `id` - does not fit well in qml environment as
  it is reserved keyword. Defining such role with `ListElement` in tests or
  Storybook would be not possible.
  
- `model.rowCount()` should not be used in bindings.
  
  This call provides count only once when it is called, and the expression will not
  be re-evaluated when count is changed. Solution is to use the attached property
  `ModelCount` (`model.ModelCount.count`) context property instead. However,
  in signal handling, using `rowCount()` is fully correct and preferred over `ModelCount`
  attached property (because it does not create any additional attached object unnecesarily).

- `model.count` should not be used on models taken from outside as a dependency.
  
  `count` property is not a part of the `QAbstractItemModel` interface. Proxy
  models and backend models may not have that property defined.

- Objects holding the whole model's row should not be used in bindings.

  ```qml
  readonly property var selectedAccount: ModelUtils.get(store.accounts, 0) // BAD
  ```

  Such objects may be deleted at any time, e.g. because of model reset. The
  expression will not be automatically re-evaluated to take the current first item.

- Avoid `QML`'s dynamic scoping. Refer for details
  [here](https://doc.qt.io/qt-5/qtqml-documents-scope.html#component-instance-hierarchy).

- Follow [C++ Core Guidelines](https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines)
  in C++ code.

## Stores

Store are an intermediate layer between the backend and the UI components.
They expose backend's functionality grouped by domain (e.g. `TransactionStore`, `AssetsStore`,
`CommunitiesStore`), without following the UI layouts, where one view can interact with multiple
domains (e.g. communities and wallet's tokens). In other words, changes in the UI should
not result in changes in the store layer.

> [!NOTE]
> The store layer will undergo significant structural changes, including removing singletons,
> moving some code elsewhere, deduplication to expose a given backend functionality in only one
> store, and leaving at most one `RootStore`. For this reason, the following points are more
> about the target state than the current state.

- Stores are a thin wrapper over context properties exposed from the backend, no
  additional logic should be there like e.g. data transformations done by proxy models.

  Stores are cut-off line in tests and `Storybook pages`. When additional logic
  is put there, it is not available in unit tests and `Storybook`. It leads to
  more complicated mocking and code duplication (same logic repeated in real
  stores and mocked ones).

  ```qml
  // WalletAssetsStore.qml
  
  QtObject {
      property LeftJoinModel groupedAccountAssetsModel: LeftJoinModel {
          leftModel: root.baseGroupedAccountAssetModel
          rightModel: _jointTokensBySymbolModel
          joinRole: "tokensKey"
      } // Bad - transformation should be kept in adaptor object,
        // only basic models should be exposed from store
  }
  ```

- Stores completely hide the backend's context properties and not expose them
  directly.

  It makes the contract between backend and frontend clear already from the
  perspective of the store. It should be enough for a UI developer to rely on
  the store's API without inspection of the nim code in order to discover what
  methods and properties are exposed from objects directly exposed to the UI
  from the backend via store.

  ```qml
  // WalletStore.qml
  
  QtObject {
      property var networksModuleInst: networksModule // BAD
  }
  ```
  
  ```qml
  // WalletStore.qml
  
  QtObject {
      id: root
  
      readonly property bool isGoerliEnabled: networksModule.isGoerliEnabled
  
      signal chainIdFetchedForUrl(string url, int chainId)
  
      function foo() {
          return networksModule.foo()
      }
  
      Component.onCompleted: {
         networksModule.chainIdFetchedForUrl.connect(root.chainIdFetchedForUrl)
      }
  }
  ```

  This additional layer causes that backend changes affect only this part of
  the UI code, which can be adjusted here even without changing the API of the
  store itself. It is also clear what exactly is exposed.

- A single context property injected from the backend should be exposed only
  once in a single store.

  Bad:

  ```qml
  // SwapStore.qml
  QtObject {
    readonly property var flatNetworks: networksModule.flatNetworks
  }

  // CommunityTokensStore.qml
  QtObject {
    readonly property var flatNetworks: networksModule.flatNetworks
  }
  ```

  Stores represent the state of the application but they are not aware how that
  state is rendered and interacted by UI components. There is no rule that a
  single component must take a single store with everything exposed what is
  needed for that component. On the contrary, the UI component should take all
  the stores (assuming that stores do not duplicate exposition) it needs as a
  dependency. Moving on, in most cases a UI component should only take
  the models/properties it needs and not the entire store.

- Stores are not singletons (if an existing singleton store needs to be used,
  still can be taken by a component as an explicit dependency).

  When stores are singleton, UI components can access backend from arbitrary
  places, in an implicit way. Dependencies are harder to track, APIs are not
  clear as they could be and it causes other problems covered in the `general` section.

  ```qml
  isGoerliEnabled: root.rootStore.isGoerliEnabled         // OK
  isGoerliEnabled: WalletStores.RootStore.isGoerliEnabled // Bad
  ```

- Exposed properties are read-only, state modification is done by methods.

  This approach makes the data flow unidirectional. UI always transforms and
  renders read-only data. UI requests any changes via methods (also called actions).
  Those actions may result in updates of one or more read-only properties/models.

- Stores should be always typed, no need to use `var`.

  Thanks to overriding proper import paths, typed stores are not a problem for
  tests and Storybook pages. They can be freely mocked, with the type preserved.

  ```qml
  required property TransactionStore store // OK
  required property var store              // Bad
  ```
  
- **Low-level UI components** should remain decoupled from application stores. Instead of directly accessing stores or dispatching actions, these components should emit intent-based events for actions they cannot or should not handle internally—such as opening dialogs, triggering navigation, or requesting data that is outside their scope of concern.

  This pattern **avoids coupling UI components** to specific data sources and keeps their APIs clean and focused on rendering and user interaction. Introducing store dependencies would require exposing unrelated data through the component’s public API, violating the principle of separation of concerns.

  Event emissions from low-level components should be handled by intermediate or upper layers in the component hierarchy, which are responsible for interpreting these events and coordinating with stores or services as needed. While this may lead to centralized handling of certain actions (e.g., modal management), the primary goal is modularity, reusability, and maintainability—not centralization for its own sake.

### Popup Instantiation and Store Access

To ensure loose coupling, it is recommended to request the popup to be opened externally rather than instantiating it directly within the UI component that triggers it. This approach is particularly important when the popup requires additional data not available in the triggering component. Instantiating the popup internally would necessitate passing all required data through the component, potentially leading to an unnecessarily expanded API.

The popup instantiation can be managed by dedicated handler component. It can handle requests from different parts of the application. For this reason, they should be high in the component hierarchy, like `appMain.popupRequestsHandler`.

#### Benefits
- No deep store injection into QML.
- UI logic stays at the application level.
- Easier testing and debugging of popup workflows.

---
#### 🚫 What to Avoid

Avoid instantiating popups like this within QML components:

```qml
// Bad practice: store passed deeply into the UI tree
PopupComponent {
    store: myStore
}
```

This approach leads to tightly coupled code and requires propagating stores deep into the UI hierarchy, which makes maintenance and testing harder.

---

#### ✅ Recommended Approach

Use the **popups handlers mechanism**. This is a centralized way designed to handle UI actions such as displaying popups in a clean, controller-like layer of the app.

Popups should be instantiated in response to signals or actions routed through handlers, not embedded directly in the component tree.

---

#### How It Works

- `HandlersManager` acts as a plain aggregator that holds and organizes various domain-specific popup handlers.
- All popup logic (creation, configuration, and display) is handled inside these dedicated popup handlers.
- The main application (`appMain`) exposes the `popupRequestsHandler`, which is the entry point for triggering popup actions.

#### Example Usage: Triggering a popup from the AppMain.qml logic

```qml 
onTransferOwnershipRequested: popupRequestsHandler.sendModalHandler.transferOwnership(tokenId, senderAddress)
```

Or

```qml
onRequestLaunchSwap: popupRequestsHandler.swapModalHandler.launchSwap()
```

## Adaptors

Adaptors are special type of `QML` components responsible for transforming backend's data.
Thanks to isolating data (especially models) transformations in adaptors, views
take possibly simple, ready to display data (models and other read-only properties).

Adaptors are usually a composition of proxy models (from external library
`SortFilterProxyModel` and from own library of proxy models: `ObjectProxyModel`,
`LeftJoinModel`, `GroupingModel`, `ConcatModel`, `RenamingProxyModel`,
`MovableModel`, `WritableModel`).

Diagram depicting custom proxy models can be found [here](https://miro.com/app/board/uXjVKTuFYOU=/)

- Adaptors are data-oriented and not tightly coupled to a specific view. Adaptors' names
should reflect the transformation they do instead of following the naming of the UI component
consuming them.

- API of adaptors, similarly as for UI components, should be possibly explicit
  and simple. Passing the whole store is usually not a good idea because it is
  not clear which part of the store's API is really used by the adaptor. Taking
  plain models with well-specified expected roles is usually a better idea.

- Output of one adaptor (usually model) can be an input of another adaptor. This
  structure should intuitively reflect the branches in the data flow in the application.

## Storybook

### Features

`Storybook` is an internal tool that supports rapid development of components in
isolation, outside the application. It is also a kind of catalog of components from
which the application is built.

It offers a number of functionalities that improve development:

- hot reloading
- import paths overloading and `stubs` to isolate from the backend
- integrated test runner
- figma integration
- built-in visual components inspector
- pages organized in groups
- bunch of dedicated components like `GenericListView` to create pages quickly

> [!NOTE]
> The `StatusQ` library also contains this type of utility application, called `Sandbox`,
> which is currently deprecated as it offers less functionality.

### Running

`Storybook` is a `cmake` project and can be easily opened, compiled and run in
`QtCreator` from the `storybook/CMakeLists.txt` file.

### Good practices

- Single `page` instantiates a single component and only necessary mocks/test
  data and auxiliary controls interacting with component's API.
  
  It makes the pages simple, easy to maintain and directly presenting the API of
  a given component.

- Storybook pages are valuable for all types of components - both basic ones
  (delegates, buttons) and more complex ones, doing complex flows like e.g.
  funds transfer.

- Storybook (and unit tests) has a mechanism of so-called `stubs` to replace
  real stores with empty objects, but in a way preserving types. It is needed
  because in Storybook and unit tests backend's context properties used in real
  stores are not available. Store's stubs are intended to be empty QtObjects,
  actual mocking should be done within a page.
  
  This approach allows making the dependencies of the component truly visible
  and explicit in a Storybook page. An alternative approach would be to
  implement single, shared mocks for every store and share the among pages. But
  it leads to situation that given mock provides much more than is needed by a
  single UI component. As a consequence, it is not clear on which part of the
  store given component depends on. A separate thing is that UI components
  should not depend on the store at all unless it is really necessary (only top
  level components covering complex flows).

- A component in Storybook should be functional.
  
  The state of a component's Storybook page quite accurately reflects the state
  of the component. Components with a well-designed API and no unnecessary
  dependencies are easy to instantiate in isolation in Storybook. Conversely,
  overly complex components are a nightmare in Storybook.

- Use identified modules to import stores (using unquoted identifiers). It is
  required for the stubs mechanism to work properly.

  In practice imports like `import AppLayouts.Wallet.stores 1.0 as WalletStores`
  should be used instead of `import "./stores" as WalletStores`. Second version is
  relative import from the file system. As a consequence, the mechanism for
  overriding import paths for tests and Storybook's pages will not work.

### Page classification

To keep the components and Storybook pages in the good shape, a simple classification
has been introduced. It allows to assign pages one of the following statuses:

- Good
  - It is fully possible to interact with the whole component's public API.
  - No workarounds are needed to use a component in isolation (like e.g. altering singletons).
  - Additional controls are not overly complicated (e.g. the model editor is often not an
    ideal solution - it is better to use a separate page for the delegate).
  - No errors and warnings printed.
- Decent
  - Most of the component's functionality is reachable.
  - The component does not print errors, some minor warnings are acceptable only.
- Bad
  - The component is not working properly (e.g. some elements are missing).
  - Most of the component's functionality is unreachable (lack of additional controls
    to interact with the component).
  - The page prints many errors/warnings.

## Unit tests

The project has unit tests for both C++ and QML code.

### C++ unit tests

C++ unit tests are located under `ui/StatusQ/tests`. They can be executed
easily from QtCreator. Just open the `StatusQ` project in `QtCreator`
(`status-desktop/ui/StatusQ/CMakeLists.txt`) and select the appropriate target (each test is a separate target).

C++ unit tests are located under `ui/StatusQ/tests`. They can be executed
easily from QtCreator or make target:

- Open the `StatusQ` project in `QtCreator` (`status-desktop/ui/StatusQ/CMakeLists.txt`) and
  select the appropriate target (each test is a separate target).
- Run the `run-statusq-tests` target, e.g. `make -j10 run-statusq-tests ARGS="-R ModelEntryTest"`

### QML unit tests

QML tests are located under `storybook/qmlTests/tests` and `ui/StatusQ/tests`. The
first location is recommended for all new tests because it provides integration with
the `Storybook`.

Unit tests operate without backend. Backend layer is cut-off using stubs mechanism in the same
way as for pages in `Storybook`.

QML tests can be executed by running `QmlTests` target of `Storybook` project
(setup described in section regarding `Storybook` above) or from `QtCreator` where only
single test or subset of tests can be selected easily. Another convenient option is to
use the test runner in `Storybook`, which gives ability to automatically execute tests
for currently opened page when changes are detected in the code, or on demand using the
button in the bottom bar. `Storybook` discovers tests by naming convention
(e.g. `SwapModalPage.qml` will run `tst_SwapModal.qml` tests).

### Unit tests recommendations

- Unit tests should be independent and isolated.

  They should not depend on anything except the unit of code under test. It means that
  dependencies should be mocked and input data provided in the simplest possible form.
  If the component under test needs a model, ideally it should be provided as a simple `ListModel`
  instead of being created using additional components such as adapters or stores. Using an
  additional component introduces a dependency on it in the test, even if the component under test
  itself is independent of it.

> [!NOTE]
> Separately testing components that are used together in an application may lead to the
> conclusion that it is uncertain whether they are compatible. However, the point is not to
> not test it, but to do it in an appropriate test (usually in test of component using those
> two components together).

- Unit tests should test units.

  This statement is also true regarding subcomponents used in a component tested in a given
  unit test. Subcomponents should not be subject of testing in unit test (as they form
  a different unit), they should be subject of testing in their own unit test. The unit tests
  should verify if subcomponents are used in the intended way and simply assume that
  internally they work as expected.

  Respecting this rule will help keep unit tests smaller, better structured and easier
  to maintain.

- Unit tests should execute very quickly.

  Relying on `wait(...)` calls slows down tests and is unreliable, may lead to flakey tests,
  therefore should be avoided.

- Unit tests should not generate any warnings and debug logs. Expected warning from the
  component can be supressed by using `TestCase::ignoreWarning`.

## Code Style

- QML code should be in-line with
  [QML Coding Conventions](https://doc.qt.io/qt-5/qml-codingconventions.html).
- Top level component `id` should be always `root`.
- Private properties should be hidden in a `d` object (`QtObject { id: d }`, or
  `QObject { id: d }`).
- `objectName` property should not be specified for the top level component in
  a given file.
  
  Component may be used in various context and usually should have different
  name in every context to disambiguate when doing lookup in unit tests, squish
  tests or monitoring tool.
- `qmldir`: entries should be sorted (`Alt+Shift+S` on selection in `QtCreator`).
- Comments and documentation should cover parts which are not obvious, can be
  skipped where intention is clear.
- A declarative implementation should be favoured over imperative code in QML
  in most cases.
- Use curly brackets to make complex expressions easier to read:

  ```qml
  readonly property bool errorMode: popup.isLoading || !recipientInputLoader.ready ?
                                      false : errorType !== Constants.NoError
                                      || networkSelector.errorMode
                                      || !(amountToSendInput.inputNumberValid
                                            || d.isCollectiblesTransfer) // Hard to read
  ```

  ```qml
  readonly property bool errorMode: { // Easier to read
      if (popup.isLoading || !recipientInputLoader.ready)
          return false

      return errorType !== Constants.NoError
          || networkSelector.errorMode
          || !(amountToSend.ready || d.isCollectiblesTransfer)
  }
  ```

## Other

- Cryptocurrency balances should be always handled as a big integer strings and
  converted to localized human-friendly form only for displaying. Some basic rationale is
  provided in [this ticket](https://github.com/status-im/status-app/issues/11376).

## Useful links

- [Qt Quick Layouts Overview](https://doc.qt.io/qt-6/qtquicklayouts-overview.html)
- [Customizing Qt Quick Controls](https://doc.qt.io/qt-6/qtquickcontrols-customize.html)
- [Keyboard Focus in Qt Quick](https://doc.qt.io/qt-6/qtquick-input-focus.html)
- [Important Concepts In Qt Quick - Positioning
](https://doc.qt.io/qt-6/qtquick-positioning-topic.html)
