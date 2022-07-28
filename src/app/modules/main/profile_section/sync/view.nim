import NimQml
import io_interface, model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      activeMailserver: string
      model: Model
      modelVariant: QVariant

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.activeMailserver = ""
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc model*(self: View): Model =
    return self.model

  proc modelChanged*(self: View) {.signal.}
  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant
  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc isAutomaticSelection(self: View): bool {.slot.} =
    return self.delegate.isAutomaticSelection()
  QtProperty[bool] automaticSelection:
    read = isAutomaticSelection

  proc activeMailserverChanged*(self: View) {.signal.}
  proc getActiveMailserver(self: View): string {.slot.} =
    return self.activeMailserver
  QtProperty[string] activeMailserver:
    read = getActiveMailserver
    notify = activeMailserverChanged

  proc setActiveMailserver(self: View, nodeAddress: string) {.slot.} =
    self.delegate.setActiveMailserver(nodeAddress)

  proc onActiveMailserverSet*(self: View, nodeAddress: string) =
    if(self.activeMailserver == nodeAddress):
      return
    self.activeMailserver = nodeAddress
    self.activeMailserverChanged()

  proc getMailserverNameForNodeAddress*(self: View, nodeAddress: string): string {.slot.} =
    self.delegate.getMailserverNameForNodeAddress(nodeAddress)

  proc saveNewMailserver(self: View, name: string, address: string) {.slot.} =
    self.delegate.saveNewMailserver(name, address)

  proc enableAutomaticSelection(self: View, value: bool) {.slot.} =
    self.delegate.enableAutomaticSelection(value)

  proc useMailserversChanged*(self: View) {.signal.}

  proc getUseMailservers*(self: View): bool {.slot.} =
    return self.delegate.getUseMailservers()

  proc setUseMailservers*(self: View, value: bool) {.slot.} =
    self.delegate.setUseMailservers(value)

  QtProperty[bool] useMailservers:
    read = getUseMailservers
    notify = useMailserversChanged
    write = setUseMailservers