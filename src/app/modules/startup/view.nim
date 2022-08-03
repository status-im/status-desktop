import NimQml
import io_interface
import selected_login_account
import internal/[state, state_wrapper]
import models/generated_account_model as gen_acc_model
import models/generated_account_item as gen_acc_item
import models/login_account_model as login_acc_model
import models/login_account_item as login_acc_item

type
  AppState* {.pure.} = enum
    StartupState = 0
    MainAppState

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      showBeforeGetStartedPopup: bool
      currentStartupState: StateWrapper
      currentStartupStateVariant: QVariant
      generatedAccountsModel: gen_acc_model.Model
      generatedAccountsModelVariant: QVariant
      selectedLoginAccount: SelectedLoginAccount
      selectedLoginAccountVariant: QVariant
      loginAccountsModel: login_acc_model.Model
      loginAccountsModelVariant: QVariant
      appState: AppState
      keycardData: string # used to temporary store the data coming from keycard, depends on current state different data may be stored

  proc delete*(self: View) =
    self.currentStartupStateVariant.delete
    self.currentStartupState.delete
    self.generatedAccountsModel.delete
    self.generatedAccountsModelVariant.delete
    self.selectedLoginAccount.delete
    self.selectedLoginAccountVariant.delete
    self.loginAccountsModel.delete
    self.loginAccountsModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.showBeforeGetStartedPopup = true
    result.appState = AppState.StartupState
    result.currentStartupState = newStateWrapper()
    result.currentStartupStateVariant = newQVariant(result.currentStartupState)
    result.generatedAccountsModel = gen_acc_model.newModel()
    result.generatedAccountsModelVariant = newQVariant(result.generatedAccountsModel)
    result.selectedLoginAccount = newSelectedLoginAccount()
    result.selectedLoginAccountVariant = newQVariant(result.selectedLoginAccount)
    result.loginAccountsModel = login_acc_model.newModel()
    result.loginAccountsModelVariant = newQVariant(result.loginAccountsModel)

    signalConnect(result.currentStartupState, "backActionClicked()", result, "onBackActionClicked()", 2)
    signalConnect(result.currentStartupState, "primaryActionClicked()", result, "onPrimaryActionClicked()", 2)
    signalConnect(result.currentStartupState, "secondaryActionClicked()", result, "onSecondaryActionClicked()", 2)
    signalConnect(result.currentStartupState, "tertiaryActionClicked()", result, "onTertiaryActionClicked()", 2)

  proc currentStartupStateObj*(self: View): State =
    return self.currentStartupState.getStateObj()

  proc setCurrentStartupState*(self: View, state: State) =
    self.currentStartupState.setStateObj(state)
  proc getCurrentStartupState(self: View): QVariant {.slot.} =
    return self.currentStartupStateVariant
  QtProperty[QVariant] currentStartupState:
    read = getCurrentStartupState

  proc onBackActionClicked*(self: View) {.slot.} =
    self.delegate.onBackActionClicked()

  proc onPrimaryActionClicked*(self: View) {.slot.} =
    self.delegate.onPrimaryActionClicked()

  proc onSecondaryActionClicked*(self: View) {.slot.} =
    self.delegate.onSecondaryActionClicked()
  
  proc onTertiaryActionClicked*(self: View) {.slot.} =
    self.delegate.onTertiaryActionClicked()

  proc startUpUIRaised*(self: View) {.signal.}

  proc showBeforeGetStartedPopup*(self: View): bool {.slot.} =
    return self.showBeforeGetStartedPopup
  proc beforeGetStartedPopupAccepted*(self: View) {.slot.} =
    self.showBeforeGetStartedPopup = false

  proc appStateChanged*(self: View, state: int) {.signal.}
  proc getAppState(self: View): int {.slot.} =
    return self.appState.int
  proc setAppState*(self: View, state: AppState) =
    if(self.appState == state):
      return
    self.appState = state
    self.appStateChanged(self.appState.int)
  QtProperty[int] appState:
    read = getAppState
    notify = appStateChanged

  proc logOut*(self: View) {.signal.}
  proc emitLogOut*(self: View) =
    self.logOut()

  proc generatedAccountsModelChanged*(self: View) {.signal.}
  proc getGeneratedAccountsModel(self: View): QVariant {.slot.} =
    return self.generatedAccountsModelVariant
  proc setGeneratedAccountList*(self: View, accounts: seq[gen_acc_item.Item]) =
    self.generatedAccountsModel.setItems(accounts)
    self.generatedAccountsModelChanged()
  QtProperty[QVariant] generatedAccountsModel:
    read = getGeneratedAccountsModel
    notify = generatedAccountsModelChanged

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

  proc generateImage*(self: View, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string {.slot.} =
    return self.delegate.generateImage(imageUrl, aX, aY, bX, bY)

  proc getCroppedProfileImage*(self: View): string {.slot.} =
    return self.delegate.getCroppedProfileImage()

  proc setDisplayName*(self: View, value: string) {.slot.} =
    self.delegate.setDisplayName(value)

  proc getDisplayName*(self: View): string {.slot.} =
    return self.delegate.getDisplayName()

  proc setPassword*(self: View, value: string) {.slot.} =
    self.delegate.setPassword(value)

  proc getPassword*(self: View): string {.slot.} =
    return self.delegate.getPassword()

  proc setPin*(self: View, value: string) {.slot.} =
    self.delegate.setPin(value)

  proc getPin*(self: View): string {.slot.} =
    return self.delegate.getPin()

  proc setPuk*(self: View, value: string) {.slot.} =
    self.delegate.setPuk(value)

  proc getPasswordStrengthScore*(self: View, password: string, userName: string): int {.slot.} =
    return self.delegate.getPasswordStrengthScore(password, userName)

  proc accountSetupError*(self: View, error: string) {.signal.}
  proc setupAccountError*(self: View, error: string) =
    self.accountSetupError(error)

  proc validMnemonic*(self: View, mnemonic: string): bool {.slot.} =
    return self.delegate.validMnemonic(mnemonic)

  proc accountImportError*(self: View, error: string) {.signal.}
  proc importAccountError*(self: View, error: string) =
    # In QML we can connect to this signal and notify user, before refactoring we didn't have this signal
    self.accountImportError(error)

  proc accountImportSuccess*(self: View) {.signal.}
  proc importAccountSuccess*(self: View) =
    self.importedAccountChanged()
    self.accountImportSuccess()

  proc selectedLoginAccountChanged*(self: View) {.signal.}
  proc getSelectedLoginAccount(self: View): QVariant {.slot.} =
    return self.selectedLoginAccountVariant
  proc setSelectedLoginAccount*(self: View, item: login_acc_item.Item) =
    self.selectedLoginAccount.setData(item)
    self.selectedLoginAccountChanged()
  proc setSelectedLoginAccountByIndex*(self: View, index: int) {.slot.} =
    let item = self.loginAccountsModel.getItemAtIndex(index)
    self.delegate.setSelectedLoginAccount(item)
  QtProperty[QVariant] selectedLoginAccount:
    read = getSelectedLoginAccount
    notify = selectedLoginAccountChanged

  proc loginAccountsModelChanged*(self: View) {.signal.}
  proc getLoginAccountsModel(self: View): QVariant {.slot.} =
    return self.loginAccountsModelVariant
  proc setLoginAccountsModelItems*(self: View, accounts: seq[login_acc_item.Item]) =
    self.loginAccountsModel.setItems(accounts)
    self.loginAccountsModelChanged()
  QtProperty[QVariant] loginAccountsModel:
    read = getLoginAccountsModel
    notify = loginAccountsModelChanged

  proc accountLoginError*(self: View, error: string) {.signal.}
  proc emitAccountLoginError*(self: View, error: string) =
    self.accountLoginError(error)

  proc obtainingPasswordError*(self:View, errorDescription: string, errorType: string) {.signal.}
  proc emitObtainingPasswordError*(self: View, errorDescription: string, errorType: string) =
    self.obtainingPasswordError(errorDescription, errorType)

  proc obtainingPasswordSuccess*(self:View, password: string) {.signal.}
  proc emitObtainingPasswordSuccess*(self: View, password: string) =
    self.obtainingPasswordSuccess(password)

  proc checkRepeatedKeycardPinWhileTyping*(self: View, pin: string): bool {.slot.} =
    return self.delegate.checkRepeatedKeycardPinWhileTyping(pin)

  proc getSeedPhrase*(self: View): string {.slot.} =
    return self.delegate.getSeedPhrase()

  proc keycardDataChanged*(self: View) {.signal.}
  proc setKeycardData*(self: View, value: string) =
    if self.keycardData == value:
      return
    self.keycardData = value
    self.keycardDataChanged()
  proc getKeycardData*(self: View): string {.slot.} =
    return self.keycardData
  QtProperty[string] keycardData:
    read = getKeycardData
    notify = keycardDataChanged