import NimQml
import io_interface
from app_service/service/keycardV2/dto import KeycardEventDto

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      keycardEvent: KeycardEventDto
      syncState: int
      addKeyPairState: int
      pinSettingState: int
      authorizationState: int
      restoreKeysExportState: int

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate


  ### QtSignals ###

  proc appLoaded*(self: View) {.signal.}
  proc accountLoginError*(self: View) {.signal.}

  ### QtProperties ###

  proc syncStateChanged*(self: View) {.signal.}
  proc getSyncState(self: View): int {.slot.} =
    return self.syncState
  QtProperty[int] syncState:
    read = getSyncState
    notify = syncStateChanged
  proc setSyncState*(self: View, syncState: int) =
    self.syncState = syncState
    self.syncStateChanged()

  proc pinSettingStateChanged*(self: View) {.signal.}
  proc getPinSettingState*(self: View): int {.slot.} =
    return self.pinSettingState
  QtProperty[int] pinSettingState:
    read = getPinSettingState
    notify = pinSettingStateChanged
  proc setPinSettingState*(self: View, pinSettingState: int) =
    self.pinSettingState = pinSettingState
    self.pinSettingStateChanged()

  proc authorizationStateChanged*(self: View) {.signal.}
  proc getAuthorizationState*(self: View): int {.slot.} =
    return self.authorizationState
  QtProperty[int] authorizationState:
    read = getAuthorizationState
    notify = authorizationStateChanged
  proc setAuthorizationState*(self: View, authorizationState: int) =
    self.authorizationState = authorizationState
    self.authorizationStateChanged()

  proc restoreKeysExportStateChanged*(self: View) {.signal.}
  proc getRestoreKeysExportState*(self: View): int {.slot.} =
    return self.restoreKeysExportState
  QtProperty[int] restoreKeysExportState:
    read = getRestoreKeysExportState
    notify = restoreKeysExportStateChanged
  proc setRestoreKeysExportState*(self: View, restoreKeysExportState: int) =
    self.restoreKeysExportState = restoreKeysExportState
    self.restoreKeysExportStateChanged()

  proc keycardStateChanged*(self: View) {.signal.}
  proc getKeycardState(self: View): int {.slot.} =
    return self.keycardEvent.state.int
  QtProperty[int] keycardState:
    read = getKeycardState
    notify = keycardStateChanged

  proc keycardRemainingPinAttemptsChanged*(self: View) {.signal.}
  proc getKeycardRemainingPinAttempts(self: View): int {.slot.} =
    return self.keycardEvent.keycardStatus.remainingAttemptsPIN
  QtProperty[int] keycardRemainingPinAttempts:
    read = getKeycardRemainingPinAttempts
    notify = keycardRemainingPinAttemptsChanged

  proc keycardRemainingPukAttemptsChanged*(self: View) {.signal.}
  proc getKeycardRemainingPukAttempts(self: View): int {.slot.} =
    return self.keycardEvent.keycardStatus.remainingAttemptsPUK
  QtProperty[int] keycardRemainingPukAttempts:
    read = getKeycardRemainingPukAttempts
    notify = keycardRemainingPukAttemptsChanged

  proc addKeyPairStateChanged*(self: View) {.signal.}
  proc getAddKeyPairState(self: View): int {.slot.} =
    return self.addKeyPairState
  QtProperty[int] addKeyPairState:
    read = getAddKeyPairState
    notify = addKeyPairStateChanged
  proc setAddKeyPairState*(self: View, addKeyPairState: int) =
    self.addKeyPairState = addKeyPairState
    self.addKeyPairStateChanged()

  proc setKeycardEvent*(self: View, keycardEvent: KeycardEventDto) =
    self.keycardEvent = keycardEvent
    self.keycardStateChanged()
    self.keycardRemainingPinAttemptsChanged()
    self.keycardRemainingPukAttemptsChanged()

  proc getKeycardEvent*(self: View): KeycardEventDto =
    return self.keycardEvent

  ### slots ###

  proc setPin(self: View, pin: string) {.slot.} =
    self.delegate.initialize(pin)

  proc authorize(self: View, pin: string) {.slot.} =
    self.delegate.authorize(pin)

  proc loadMnemonic(self: View, mnemonic: string) {.slot.} =
    self.delegate.loadMnemonic(mnemonic)

  proc getPasswordStrengthScore(self: View, password: string, userName: string): int {.slot.} =
    return self.delegate.getPasswordStrengthScore(password, userName)

  proc validMnemonic(self: View, mnemonic: string): bool {.slot.} =
    return self.delegate.validMnemonic(mnemonic)

  proc getMnemonic(self: View): string {.slot.} =
    return self.delegate.getMnemonic()

  proc validateLocalPairingConnectionString(self: View, connectionString: string): bool {.slot.} =
    return self.delegate.validateLocalPairingConnectionString(connectionString)

  proc inputConnectionStringForBootstrapping(self: View, connectionString: string) {.slot.} =
    self.delegate.inputConnectionStringForBootstrapping(connectionString)

  proc exportRecoverKeys(self: View) {.slot.} =
    self.delegate.exportRecoverKeys()

  proc finishOnboardingFlow(self: View, flowInt: int, dataJson: string): string {.slot.} =
    self.delegate.finishOnboardingFlow(flowInt, dataJson)
