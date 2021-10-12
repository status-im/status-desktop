import NimQml
import model, item
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
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
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc setAccountList*(self: View, accounts: seq[Item]) =
    self.model.setItems(accounts)

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] accountsModel:
    read = getModel
    notify = modelChanged

  proc setSelectedAccountId*(self: View, id: string) {.slot.} =
    self.delegate.setSelectedAccountId(id)

  proc storeSelectedAccountAndLogin*(self: View, password: string) {.slot.} =
    self.delegate.storeSelectedAccountAndLogin(password)