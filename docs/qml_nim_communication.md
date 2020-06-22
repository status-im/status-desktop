## Communicating with NIM

**Using NimQml - General Overview**

Nim objects meant to be exposed to QT import `NimQml` and use the `QtObject` macro, there is some basic methods that need to be setup for every `QtObject` such as `setup`, `delete`, and when initializing the object the `new` and `setup` method need to be called.
A basic QtObject will look like something like:

```nimrod=
import NimQml

QtObject:
    type MyView* = ref object of QObject
        someField*: string

    proc setup(self: MyView) =
        self.QObject.setup

    proc delete*(self: MyView) =
        self.QObject.delete

    proc newMyView*(): MyView =
        new(result, delete)
        result = MyView()
        result.setup
```

The object then is exposed to QML by creating and registering a `QVariant`

```nimrod=
import NimQml

...

# create variant
var view = newMyView()
var variant: QVariant = newQVariant(view)

# expose it to QML
let engine = newQQmlApplicationEngine()
engine.setRootContextProperty("MyNimObject", variant)
```

The variable `MyNimObject` is then accessible in QML and represent `MyView` and its methods or variables that have been defined to be exposed to QML, for example, adding:

```qml
proc foo*(self: MyView): string {.slot.} =
    "hello world"
```

and in QML doing

```qml
Text {
    text: "NIM says" + MyNimObject.foo()
}
```

will create a text "NIM says hello world"

**NimQml in nim-status-client**

The QtObjects are defined in `src/app/<module>/view.nim` and `src/app/<module>/views/`, they typically include the nim-status object as a parameter, for example `src/app/profile/view.nim`:

```nimrod=
...
QtObject:
  type ProfileView* = ref object of QObject
    ...
    status*: Status

  proc newProfileView*(status: Status): ProfileView =
    new(result, delete)
    result = ProfileView()
    ...
    result.status = status
    result.setup
  ...
```

The variant is created and wrapped in the "controller" `src/app/<module>/core.nim`, for example `src/app/profile/core.nim`:

```nimrod=
...
type ProfileController* = ref object of SignalSubscriber
  view*: ProfileView
  variant*: QVariant
  status*: Status

proc newController*(status: Status): ProfileController =
  result = ProfileController()
  result.status = status
  result.view = newProfileView(status)
  result.variant = newQVariant(result.view)
```

This controller is initialized in `src/nim_status_client.nim` and the variant is registered there, for example:

```nimrod=
var profile = profile.newController(status)
engine.setRootContextProperty("profileModel", profile.variant)
```

this variant is then accessible in QML as `profileModel`, for example in `ui/app/AppLayouts/Profile/Sections/AboutContainer.qml` the node version is displayed with:

```qml
...
    StyledText {
        text: qsTr("Node Version: %1").arg(profileModel.nodeVersion())
        ...
    }
...
```

**exposing methods to QML**

Methods can be exposed to QML need to be public and use the `{.slot.}` pragma

```nimrod=
QtObject:
    ...
    proc nodeVersion*(self: ProfileView): string {.slot.} =
        self.status.getNodeVersion()
```

**QtProperty Macro for simple types**

There is a handy `QtProperty[type]` macro, this macro defines what methods to call to get the latest value (`read`), which method updates that value (`write`) and a signal that notifies that value has changed (`notify`), here is a real example from `src/app/wallet/view.nim` that defines the `defaultCurrency` property

```nimrod=
  proc defaultCurrency*(self: WalletView): string {.slot.} =
    self.status.wallet.getDefaultCurrency()

  proc defaultCurrencyChanged*(self: WalletView) {.signal.}

  proc setDefaultCurrency*(self: WalletView, currency: string) {.slot.} =
    self.status.wallet.setDefaultCurrency(currency)
    self.defaultCurrencyChanged() # notify value has changed

  QtProperty[string] defaultCurrency:
    read = defaultCurrency
    write = setDefaultCurrency
    notify = defaultCurrencyChange
```

note: it's not necessary to define all these fields except for `read`

**QtProperty Macro for other QObjects**

This macro can also be used to expose other QtObjects as QVariants, this is typically done to simplify code and sometimes even required for things that need to be their own individual QTObjects such as Lists.

For example, in `src/app/profile/view.nim` the profileView QtObject (`src/app/profile/profileView.nim`) is exposed to QML with:

```nimrod=
QtObject:
    type ProfileView* = ref object of QObject
        profile*: ProfileInfoView
        ...
    ...
    proc getProfile(self: ProfileView): QVariant {.slot.} =
        return newQVariant(self.profile)

    proc setNewProfile*(self: ProfileView, profile: Profile) =
        self.profile.setProfile(profile)

    QtProperty[QVariant] profile:
        read = getProfile
```

**QAbstractListModel**

Lists are exposed to QML using a `QAbstractListModel` object, this method expects certain methods to be defined so QML can access the data: `rowCount`, `data` and `roleNames`
Other methods can be found in the QT documentation [here](https://doc.qt.io/qt-5/qabstractitemmodel.html)

Let's take as an example `src/app/wallet/views/asset_list.nim`

First the imports

```nim
import NimQml
import tables
```

then we define the `QtObject` macro as usual but this time the object uses `QAbstractListModel`

```nim
QtObject:
  type AssetList* = ref object of QAbstractListModel
    assets*: seq[Asset]
```

`assets` is the sequence that will hold the assets, `Asset` is imported and defined in `src/status/wallet/accounts.nim` and is a simple nim object

```nimrod=
type Asset* = ref object
    name*, symbol*, value*, fiatValue*, accountAddress*, address*: string
```

then there is the typical required initialization

```nimrod=
  proc setup(self: AssetList) = self.QAbstractListModel.setup

  proc delete(self: AssetList) =
    self.QAbstractListModel.delete
    self.assets = @[]

  proc newAssetList*(): AssetList =
    new(result, delete)
    result.assets = @[]
    result.setup
```

a role enum type needs to be defined, specifying the name of each field

```nimrod=
type
  AssetRoles {.pure.} = enum
    Name = UserRole + 1,
    Symbol = UserRole + 2,
    Value = UserRole + 3,
    FiatValue = UserRole + 
```

for the data to be exposed there are methods that need to be defined such as `rowCount` and `data`:

```nimrod=
  # returns total assets
  method rowCount(self: AssetList, index: QModelIndex = nil): int =
    return self.assets.len

  # returns Asset object at given index
  method data(self: AssetList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.assets.len:
      return
    let asset = self.assets[index.row]
    let assetRole = role.AssetRoles
    case assetRole:
    of AssetRoles.Name: result = newQVariant(asset.name)
    of AssetRoles.Symbol: result = newQVariant(asset.symbol)
    of AssetRoles.Value: result = newQVariant(asset.value)
    of AssetRoles.FiatValue: result = newQVariant(asset.fiatValue)
    
  # returns table with columns names and values
  method roleNames(self: AssetList): Table[int, string] =
    { AssetRoles.Name.int:"name",
    AssetRoles.Symbol.int:"symbol",
    AssetRoles.Value.int:"value",
    AssetRoles.FiatValue.int:"fiatValue" }.toTable
```

The asset list has been exposed in `src/app/wallet/view.nim` as QVariant called `assets` and the table can be display in QML, for example using a `ListView`:

```qml
    ListView {
        model: walletModel.assets // the table
        delegate: Text {
            text: "name:" + name + " | symbol: " + symbol
        }
    }
```

**TODO**: qml components with default properties
**TODO**: reusable qml components
**TODO**: qml components alias properties
