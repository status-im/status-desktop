import # std libs
  std/json

import # vendor libs
  chronicles, nimqml,
  status/status, status/types/conversions, status/wallet2/saved_addresses,
  stew/results

import # status-desktop modules
  ../../../core/main, ../../../core/tasks/[qt, threadpool],
  ./saved_addresses_list

logScope:
  topics = "saved-addresses-view"

type
  AddSavedAddressTaskArg = ref object of QObjectTaskArg
    savedAddress: SavedAddress

  DeleteSavedAddressTaskArg = ref object of QObjectTaskArg
    address: Address

  EditSavedAddressTaskArg = ref object of QObjectTaskArg
    savedAddress: SavedAddress

  LoadSavedAddressesTaskArg = ref object of QObjectTaskArg

const loadSavedAddressesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[LoadSavedAddressesTaskArg](argEncoded)
    output = saved_addresses.getSavedAddresses()
  arg.finish(output)

proc loadSavedAddresses[T](self: T, slot: string) =
  let arg = LoadSavedAddressesTaskArg(
    tptr: cast[ByteAddress](loadSavedAddressesTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot
  )
  self.appService.threadpool.start(arg)

const addSavedAddressTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[AddSavedAddressTaskArg](argEncoded)
    output = saved_addresses.addSavedAddress(arg.savedAddress)
  arg.finish(output)

proc addSavedAddress[T](self: T, slot, name, address: string) =
  let arg = AddSavedAddressTaskArg(
    tptr: cast[ByteAddress](addSavedAddressTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot
  )
  var addressParsed: Address
  try:
    addressParsed = Address.fromHex(address)
  except:
    raise newException(ValueError, "Error parsing address")
  arg.savedAddress = SavedAddress(name: name, address: addressParsed)
  self.appService.threadpool.start(arg)

const deleteSavedAddressTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[DeleteSavedAddressTaskArg](argEncoded)
    output = saved_addresses.deleteSavedAddress(arg.address)
  arg.finish(output)

proc deleteSavedAddress[T](self: T, slot, address: string) =
  let arg = DeleteSavedAddressTaskArg(
    tptr: cast[ByteAddress](deleteSavedAddressTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot
  )
  var addressParsed: Address
  try:
    addressParsed = Address.fromHex(address)
  except:
    raise newException(ValueError, "Error parsing address")
  arg.address = addressParsed
  self.appService.threadpool.start(arg)

const editSavedAddressTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[EditSavedAddressTaskArg](argEncoded)
    output = saved_addresses.editSavedAddress(arg.savedAddress)
  arg.finish(output)

proc editSavedAddress[T](self: T, slot, name, address: string) =
  let arg = EditSavedAddressTaskArg(
    tptr: cast[ByteAddress](editSavedAddressTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot
  )
  var addressParsed: Address
  try:
    addressParsed = Address.fromHex(address)
  except:
    raise newException(ValueError, "Error parsing address")
  arg.savedAddress = SavedAddress(name: name, address: addressParsed)
  self.appService.threadpool.start(arg)

QtObject:
  type
    SavedAddressesView* = ref object of QObject
      # no need to store the seq[SavedAddress] value in `loadResult`, as it is
      # set in self.savedAddresses
      appService: AppService
      addEditResult: SavedAddressResult[void]
      deleteResult: SavedAddressResult[void]
      loadResult: SavedAddressResult[void]
      savedAddresses: SavedAddressesList
      status: Status

  proc setup(self: SavedAddressesView) = self.QObject.setup

  proc delete(self: SavedAddressesView) =
    self.savedAddresses.delete
    self.QObject.delete

  proc newSavedAddressesView*(status: Status, appService: AppService): SavedAddressesView =
    new(result, delete)
    result.addEditResult = SavedAddressResult[void].ok()
    result.appService = appService
    result.deleteResult = SavedAddressResult[void].ok()
    result.savedAddresses = newSavedAddressesList()
    result.setup
    result.status = status

  # START QtProperty notify backing signals
  proc addEditResultChanged*(self: SavedAddressesView) {.signal.}
  proc deleteResultChanged*(self: SavedAddressesView) {.signal.}
  proc loadResultChanged*(self: SavedAddressesView) {.signal.}
  proc savedAddressesChanged*(self: SavedAddressesView) {.signal.}
  # END QtProperty notify backing signals

  # START QtProperty get backing procs
  proc getAddEditResult(self: SavedAddressesView): string {.slot.} =
    return Json.encode(self.addEditResult)

  proc getDeleteResult(self: SavedAddressesView): string {.slot.} =
    return Json.encode(self.deleteResult)

  proc getLoadResult(self: SavedAddressesView): string {.slot.} =
    return Json.encode(self.loadResult)

  proc getSavedAddressesList(self: SavedAddressesView): QVariant {.slot.} =
    return newQVariant(self.savedAddresses)
  # END QtProperty get backing procs

  # START QtProperties
  QtProperty[string] addEditResult:
    read = getAddEditResult
    notify = addEditResultChanged

  QtProperty[string] deleteResult:
    read = getDeleteResult
    notify = deleteResultChanged

  QtProperty[string] loadResult:
    read = getLoadResult
    notify = loadResultChanged

  QtProperty[QVariant] savedAddresses:
    read = getSavedAddressesList
    notify = savedAddressesChanged
  # END QtProperties

  # START Task runner callbacks
  proc setSavedAddressesList(self: SavedAddressesView, raw: string) {.slot.} =
    let savedAddressesResult = Json.decode(raw, SavedAddressResult[seq[SavedAddress]])

    if savedAddressesResult.isOk:
      self.savedAddresses.setData(savedAddressesResult.get)
      self.savedAddressesChanged()
      self.loadResult = SavedAddressResult[void].ok()
    else:
      self.loadResult = SavedAddressResult[void].err(savedAddressesResult.error)
    self.loadResultChanged()

  proc afterAddEdit(self: SavedAddressesView, raw: string) {.slot.} =
    let addEditResult = Json.decode(raw, SavedAddressResult[void])
    self.addEditResult = addEditResult
    self.addEditResultChanged()

  proc afterDelete(self: SavedAddressesView, raw: string) {.slot.} =
    let deleteResult = Json.decode(raw, SavedAddressResult[void])
    self.deleteResult = deleteResult
    self.deleteResultChanged()
  # END Task runner callbacks

  # START slots
  proc loadSavedAddresses*(self: SavedAddressesView) {.slot.} =
    self.loadSavedAddresses("setSavedAddressesList")

  proc addSavedAddress*(self: SavedAddressesView, name: string, address: string) {.slot.} =
    try:
      self.addSavedAddress("afterAddEdit", name, address)
    except ValueError as e:
      self.addEditResult = SavedAddressResult[void].err(ParseAddressError)
      self.addEditResultChanged()

  proc deleteSavedAddress*(self: SavedAddressesView, address: string) {.slot.} =
    try:
      self.deleteSavedAddress("afterDelete", address)
    except ValueError as e:
      self.deleteResult = SavedAddressResult[void].err(ParseAddressError)
      self.deleteResultChanged()

  proc editSavedAddress*(self: SavedAddressesView, name: string, address: string) {.slot.} =
    try:
      self.editSavedAddress("afterAddEdit", name, address)
    except ValueError as e:
      self.addEditResult = SavedAddressResult[void].err(ParseAddressError)
      self.addEditResultChanged()
  # END slots
