import NimQml
import io_interface, model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
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
    notify = pinnedMailserverIdChanged

  proc activeMailserverIdChanged*(self: View) {.signal.}

  proc getActiveMailserverId(self: View): string {.slot.} =
    let res =  self.delegate.getActiveMailserverId()
    return res

  QtProperty[string] activeMailserverId:
    read = getActiveMailserverId
    notify = activeMailserverIdChanged

  proc onActiveMailserverSet*(self: View) =
    self.activeMailserverIdChanged()

  proc pinnedMailserverIdChanged*(self: View) {.signal.}

  proc getPinnedMailserverId(self: View): string {.slot.} =
    let res = self.delegate.getPinnedMailserverId()
    return res

  QtProperty[string] pinnedMailserverId:
    read = getPinnedMailserverId
    write = setPinnedMailserverId
    notify = pinnedMailserverIdChanged

  proc setPinnedMailserverId(self: View, mailserverID: string) {.slot.} =
    if mailserverID == self.getPinnedMailserverId():
      return
    self.delegate.setPinnedMailserverId(mailserverID)

  proc onPinnedMailserverSet*(self: View) =
    self.pinnedMailserverIdChanged()

  proc saveNewMailserver(self: View, name: string, address: string) {.slot.} =
    self.delegate.saveNewMailserver(name, address)

  proc enableAutomaticSelection(self: View, value: bool) {.slot.} =
    self.delegate.enableAutomaticSelection(value)

  proc useMailserversChanged*(self: View) {.signal.}

  proc getUseMailservers*(self: View): bool {.slot.} =
    return self.delegate.getUseMailservers()

  proc setUseMailservers*(self: View, value: bool) {.slot.} =
    if value == self.delegate.getUseMailservers():
      return
    self.delegate.setUseMailservers(value)

  QtProperty[bool] useMailservers:
    read = getUseMailservers
    notify = useMailserversChanged
    write = setUseMailservers