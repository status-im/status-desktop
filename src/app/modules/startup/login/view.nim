import NimQml
import account_item, model
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      selectedAccount: AccountItem
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
    result.selectedAccount = newAccountItem()
    result.selectedAccountVariant = newQVariant(result.selectedAccount)
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc selectedAccountChanged*(self: View) {.signal.}

  proc getSelectedAccount(self: View): QVariant {.slot.} =
    return self.selectedAccountVariant

  proc setSelectedAccount*(self: View, name, identicon, keyUid, thumbnailImage, 
    largeImage: string) =
    self.selectedAccount.setAccountItemData(name, identicon, keyUid, thumbnailImage, 
    largeImage)
    self.selectedAccountChanged()

  QtProperty[QVariant] selectedAccount:
    read = getSelectedAccount
    notify = selectedAccountChanged

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  proc setAccountsList*(self: View, accounts: seq[AccountItem]) =
    self.model.setItems(accounts)
    self.modelChanged()

  QtProperty[QVariant] accountsModel:
    read = getModel
    notify = modelChanged