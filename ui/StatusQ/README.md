# StatusQ

> An emerging reusable QML UI component library for Status applications.

## Usage

StatusQ introduces a module namespace that semantically groups components so they can be easily imported.
These modules are:

- [StatusQ.Core](https://github.com/status-im/StatusQ/blob/master/src/StatusQ/Core/qmldir)
- [StatusQ.Core.Theme](https://github.com/status-im/StatusQ/blob/master/src/StatusQ/Core/Theme/qmldir)
- [StatusQ.Components](https://github.com/status-im/StatusQ/blob/master/src/StatusQ/Controls/qmldir)
- [StatusQ.Controls](https://github.com/status-im/StatusQ/blob/master/src/StatusQ/Components/qmldir)
- [StatusQ.Layout](https://github.com/status-im/StatusQ/blob/master/src/StatusQ/Layout/qmldir)
- [StatusQ.Platform](https://github.com/status-im/StatusQ/blob/master/src/StatusQ/Platform/qmldir)
- [StatusQ.Popups](https://github.com/status-im/StatusQ/blob/master/src/StatusQ/Popups/qmldir)

Provided components can be viewed and tested in the [sandbox application](#viewing-and-testing-components) that comes with this repository.
Other than that, modules and components can be used as expected.

Example:

```
import Status.Core 0.1
import Status.Controls 0.1

StatusInput {
  ...
}
```

More Documentation available on the [wiki](https://hackmd.io/@status-desktop/B1naRjxh_/%2FwFtiXvOiQqCdw2lk6gbOLA)
