import nimqml, stew/shims/strformat

QtObject:
  type DerivedAddressItem* = ref object of QObject
    order: int
    address: string
    publicKey: string
    path: string
    hasActivity: bool
    alreadyCreated: bool
    alreadyCreatedChecked: bool
    detailsLoaded: bool
    errorInScanningActivity: bool

  proc delete*(self: DerivedAddressItem)
  proc newDerivedAddressItem*(
    order: int = 0,
    address: string = "",
    publicKey: string = "",
    path: string = "",
    alreadyCreated: bool = false,
    hasActivity: bool = false,
    alreadyCreatedChecked: bool = false,
    detailsLoaded: bool = false,
    errorInScanningActivity: bool = false
  ): DerivedAddressItem =
    new(result, delete)
    result.QObject.setup
    result.order = order
    result.address = address
    result.publicKey = publicKey
    result.path = path
    result.alreadyCreated = alreadyCreated
    result.hasActivity = hasActivity
    result.alreadyCreatedChecked = alreadyCreatedChecked
    result.detailsLoaded = detailsLoaded
    result.errorInScanningActivity = errorInScanningActivity

  proc `$`*(self: DerivedAddressItem): string =
    result = fmt"""DerivedAddressItem(
      order: {self.order},
      address: {self.address},
      publicKey: {self.publicKey},
      path: {self.path},
      alreadyCreated: {self.alreadyCreated},
      hasActivity: {self.hasActivity},
      alreadyCreatedChecked: {self.alreadyCreatedChecked},
      detailsLoaded: {self.detailsLoaded}
      errorInScanningActivity: {self.errorInScanningActivity}
      )""""

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

  proc alreadyCreatedCheckedChanged*(self: DerivedAddressItem) {.signal.}
  proc getAlreadyCreatedChecked*(self: DerivedAddressItem): bool {.slot.} =
    return self.alreadyCreatedChecked
  proc setAlreadyCreatedChecked*(self: DerivedAddressItem, value: bool) {.slot.} =
    self.alreadyCreatedChecked = value
    self.alreadyCreatedCheckedChanged()
  QtProperty[bool] alreadyCreatedChecked:
    read = getAlreadyCreatedChecked
    write = setAlreadyCreatedChecked
    notify = alreadyCreatedCheckedChanged

  proc detailsLoadedChanged*(self: DerivedAddressItem) {.signal.}
  proc getDetailsLoaded*(self: DerivedAddressItem): bool {.slot.} =
    return self.detailsLoaded
  proc setDetailsLoaded*(self: DerivedAddressItem, value: bool) {.slot.} =
    self.detailsLoaded = value
    self.detailsLoadedChanged()
  QtProperty[bool] detailsLoaded:
    read = getDetailsLoaded
    write = setDetailsLoaded
    notify = detailsLoadedChanged

  proc errorInScanningActivityChanged*(self: DerivedAddressItem) {.signal.}
  proc getErrorInScanningActivity*(self: DerivedAddressItem): bool {.slot.} =
    return self.errorInScanningActivity
  proc setErrorInScanningActivity*(self: DerivedAddressItem, value: bool) {.slot.} =
    self.errorInScanningActivity = value
    self.errorInScanningActivityChanged()
  QtProperty[bool] errorInScanningActivity:
    read = getErrorInScanningActivity
    write = setErrorInScanningActivity
    notify = errorInScanningActivityChanged

  proc setItem*(self: DerivedAddressItem, item: DerivedAddressItem) =
    self.setOrder(item.getOrder())
    self.setAddress(item.getAddress())
    self.setPublicKey(item.getPublicKey())
    self.setPath(item.getPath())
    self.setAlreadyCreated(item.getAlreadyCreated())
    self.setHasActivity(item.getHasActivity())
    self.setAlreadyCreatedChecked(item.getAlreadyCreatedChecked())
    self.setDetailsLoaded(item.getDetailsLoaded())
    self.setErrorInScanningActivity(item.getErrorInScanningActivity())

  proc update*(self: DerivedAddressItem, other: DerivedAddressItem) =
    ## Update this DerivedAddressItem from another, calling setters for changed properties
    ## This ensures proper signal emission for fine-grained QML updates (Pattern 5)
    if self.isNil or other.isNil: return
    
    if self.order != other.order:
      self.setOrder(other.order)
    if self.address != other.address:
      self.setAddress(other.address)
    if self.publicKey != other.publicKey:
      self.setPublicKey(other.publicKey)
    if self.path != other.path:
      self.setPath(other.path)
    if self.alreadyCreated != other.alreadyCreated:
      self.setAlreadyCreated(other.alreadyCreated)
    if self.hasActivity != other.hasActivity:
      self.setHasActivity(other.hasActivity)
    if self.alreadyCreatedChecked != other.alreadyCreatedChecked:
      self.setAlreadyCreatedChecked(other.alreadyCreatedChecked)
    if self.detailsLoaded != other.detailsLoaded:
      self.setDetailsLoaded(other.detailsLoaded)
    if self.errorInScanningActivity != other.errorInScanningActivity:
      self.setErrorInScanningActivity(other.errorInScanningActivity)
  
  proc delete*(self: DerivedAddressItem) =
    self.QObject.delete

