import NimQml
import model, item, selected_account
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      selectedAccount: SelectedAccount
      selectedAccountVariant: QVariant
      model: Model
      modelVariant: QVariant

  proc delete*(self: View) =
    self.selectedAccount.delete
    self.selectedAccountVariant.delete
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.selectedAccount = newSelectedAccount()
    result.selectedAccountVariant = newQVariant(result.selectedAccount)
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc selectedAccountChanged*(self: View) {.signal.}

  proc getSelectedAccount(self: View): QVariant {.slot.} =
    return self.selectedAccountVariant

  proc setSelectedAccount*(self: View, item: Item) =
    self.selectedAccount.setSelectedAccountData(item)
    self.selectedAccountChanged()

  proc setSelectedAccountByIndex*(self: View, index: int) {.slot.} =
    let item = self.model.getItemAtIndex(index)
    self.delegate.setSelectedAccount(item)

  QtProperty[QVariant] selectedAccount:
    read = getSelectedAccount
    notify = selectedAccountChanged

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  proc setModelItems*(self: View, accounts: seq[Item]) =
    self.model.setItems(accounts)
    self.modelChanged()

  QtProperty[QVariant] accountsModel:
    read = getModel
    notify = modelChanged

  proc login*(self: View, password: string) {.slot.} =
    self.delegate.login(password)

  proc accountLoginError*(self: View, error: string) {.signal.}

  proc emitAccountLoginError*(self: View, error: string) =
    self.accountLoginError(error)

  proc obtainingPasswordError*(self:View, errorDescription: string) {.signal.}

  proc emitObtainingPasswordError*(self: View, errorDescription: string) =
    self.obtainingPasswordError(errorDescription)

  proc obtainingPasswordSuccess*(self:View, password: string) {.signal.}

  proc emitObtainingPasswordSuccess*(self: View, password: string) =
    self.obtainingPasswordSuccess(password)

  proc getKeycardModule(self: View): QVariant {.slot.} =
    return self.delegate.getKeycardModule()
  QtProperty[QVariant] keycardModule:
    read = getKeycardModule