import NimQml, strformat

QtObject:
  type DerivedAddressItem* = ref object of QObject
    order: int
    address: string
    publicKey: string
    path: string
    hasActivity: bool
    alreadyCreated: bool
    loaded: bool

  proc delete*(self: DerivedAddressItem) =
    self.QObject.delete

  proc newDerivedAddressItem*(
    order: int = 0,
    address: string = "",
    publicKey: string = "",
    path: string = "",
    alreadyCreated: bool = false,
    hasActivity: bool = false,
    loaded: bool = false
  ): DerivedAddressItem =
    new(result, delete)
    result.QObject.setup
    result.order = order
    result.address = address
    result.publicKey = publicKey
    result.path = path
    result.alreadyCreated = alreadyCreated
    result.hasActivity = hasActivity
    result.loaded = loaded

  proc `$`*(self: DerivedAddressItem): string =
    result = fmt"""DerivedAddressItem(
      order: {self.order},
      address: {self.address},
      publicKey: {self.publicKey},
      path: {self.path},
      alreadyCreated: {self.alreadyCreated},
      hasActivity: {self.hasActivity},
      loaded: {self.loaded}
      ]"""

  proc orderChanged*(self: DerivedAddressItem) {.signal.}
  proc getOrder*(self: DerivedAddressItem): int {.slot.} =
    return self.order
  proc setOrder*(self: DerivedAddressItem, value: int) {.slot.} =
    self.order = value
    self.orderChanged()
  QtProperty[int] order:
    read = getOrder
    write = setOrder
    notify = orderChanged

  proc addressChanged*(self: DerivedAddressItem) {.signal.}
  proc getAddress*(self: DerivedAddressItem): string {.slot.} =
    return self.address
  proc setAddress*(self: DerivedAddressItem, value: string) {.slot.} =
    self.address = value
    self.addressChanged()
  QtProperty[string] address:
    read = getAddress
    write = setAddress
    notify = addressChanged

  proc publicKeyChanged*(self: DerivedAddressItem) {.signal.}
  proc getPublicKey*(self: DerivedAddressItem): string {.slot.} =
    return self.publicKey
  proc setPublicKey*(self: DerivedAddressItem, value: string) {.slot.} =
    self.publicKey = value
    self.publicKeyChanged()
  QtProperty[string] publicKey:
    read = getPublicKey
    write = setPublicKey
    notify = publicKeyChanged

  proc pathChanged*(self: DerivedAddressItem) {.signal.}
  proc getPath*(self: DerivedAddressItem): string {.slot.} =
    return self.path
  proc setPath*(self: DerivedAddressItem, value: string) {.slot.} =
    self.path = value
    self.pathChanged()
  QtProperty[string] path:
    read = getPath
    write = setPath
    notify = pathChanged

  proc alreadyCreatedChanged*(self: DerivedAddressItem) {.signal.}
  proc getAlreadyCreated*(self: DerivedAddressItem): bool {.slot.} =
    return self.alreadyCreated
  proc setAlreadyCreated*(self: DerivedAddressItem, value: bool) {.slot.} =
    self.alreadyCreated = value
    self.alreadyCreatedChanged()
  QtProperty[bool] alreadyCreated:
    read = getAlreadyCreated
    write = setAlreadyCreated
    notify = alreadyCreatedChanged

  proc hasActivityChanged*(self: DerivedAddressItem) {.signal.}
  proc getHasActivity*(self: DerivedAddressItem): bool {.slot.} =
    return self.hasActivity
  proc setHasActivity*(self: DerivedAddressItem, value: bool) {.slot.} =
    self.hasActivity = value
    self.hasActivityChanged()
  QtProperty[bool] hasActivity:
    read = getHasActivity
    write = setHasActivity
    notify = hasActivityChanged

  proc loadedChanged*(self: DerivedAddressItem) {.signal.}
  proc getLoaded*(self: DerivedAddressItem): bool {.slot.} =
    return self.loaded
  proc setLoaded*(self: DerivedAddressItem, value: bool) {.slot.} =
    self.loaded = value
    self.loadedChanged()
  QtProperty[bool] loaded:
    read = getLoaded
    write = setLoaded
    notify = loadedChanged

  proc setItem*(self: DerivedAddressItem, item: DerivedAddressItem) =
    self.setOrder(item.getOrder())
    self.setAddress(item.getAddress())
    self.setPublicKey(item.getPublicKey())
    self.setPath(item.getPath())
    self.setAlreadyCreated(item.getAlreadyCreated())
    self.setHasActivity(item.getHasActivity())
    self.setLoaded(item.getLoaded())