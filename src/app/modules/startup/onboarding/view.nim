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

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  proc setAccountList*(self: View, accounts: seq[Item]) =
    self.model.setItems(accounts)
    self.modelChanged()

  QtProperty[QVariant] accountsModel:
    read = getModel
    notify = modelChanged

  proc importedAccountChanged*(self: View) {.signal.}

  proc getImportedAccountAlias*(self: View): string {.slot.} =
    return self.delegate.getImportedAccount().alias

  QtProperty[string] importedAccountAlias:
    read = getImportedAccountAlias
    notify = importedAccountChanged

  proc getImportedAccountAddress*(self: View): string {.slot.} =
    return self.delegate.getImportedAccount().address

  QtProperty[string] importedAccountAddress:
    read = getImportedAccountAddress
    notify = importedAccountChanged

  proc getImportedAccountPubKey*(self: View): string {.slot.} =
    return self.delegate.getImportedAccount().derivedAccounts.whisper.publicKey

  QtProperty[string] importedAccountPubKey:
    read = getImportedAccountPubKey
    notify = importedAccountChanged

  proc setDisplayName*(self: View, displayName: string) {.slot.} =
    self.delegate.setDisplayName(displayName)

  proc setSelectedAccountByIndex*(self: View, index: int) {.slot.} =
    self.delegate.setSelectedAccountByIndex(index)

  proc storeSelectedAccountAndLogin*(self: View, password: string) {.slot.} =
    self.delegate.storeSelectedAccountAndLogin(password)

  proc accountSetupError*(self: View, error: string) {.signal.}

  proc setupAccountError*(self: View, error: string) =
    self.accountSetupError(error)

  proc validateMnemonic*(self: View, mnemonic: string): string {.slot.} =
    return self.delegate.validateMnemonic(mnemonic)

  proc importMnemonic*(self: View, mnemonic: string) {.slot.} =
    self.delegate.importMnemonic(mnemonic)

  proc accountImportError*(self: View, error: string) {.signal.}

  proc importAccountError*(self: View, error: string) =
    # In QML we can connect to this signal and notify a user
    # before refactoring we didn't have this signal
    self.accountImportError(error)

  proc accountImportSuccess*(self: View) {.signal.}

  proc importAccountSuccess*(self: View) =
    self.importedAccountChanged()
    self.accountImportSuccess()

  proc getPasswordStrengthScore*(self: View, password: string, userName: string): int {.slot.} =
    return self.delegate.getPasswordStrengthScore(password, userName)

  proc generateImage*(self: View, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string {.slot.} =
    self.delegate.generateImage(imageUrl, aX, aY, bX, bY)

  proc getKeycardModule(self: View): QVariant {.slot.} =
    return self.delegate.getKeycardModule()
  QtProperty[QVariant] keycardModule:
    read = getKeycardModule