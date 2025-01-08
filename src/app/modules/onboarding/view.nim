import NimQml
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      syncState: int
      keycardState: int
      keycardRemainingPinAttempts: int
      addKeyPairState: int

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate


  ### QtSignals ###

  proc appLoaded*(self: View) {.signal.}

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

  proc keycardStateChanged*(self: View) {.signal.}
  proc getKeycardState(self: View): int {.slot.} =
    return self.keycardState
  QtProperty[int] keycardState:
    read = getKeycardState
    notify = keycardStateChanged
  proc setKeycardState*(self: View, keycardState: int) =
    self.keycardState = keycardState
    self.keycardStateChanged()

  proc keycardRemainingPinAttemptsChanged*(self: View) {.signal.}
  proc getKeycardRemainingPinAttempts(self: View): int {.slot.} =
    return self.keycardRemainingPinAttempts
  QtProperty[int] keycardRemainingPinAttempts:
    read = getKeycardRemainingPinAttempts
    notify = keycardRemainingPinAttemptsChanged
  proc setKeycardRemainingPinAttempts*(self: View, keycardRemainingPinAttempts: int) =
    self.keycardRemainingPinAttempts = keycardRemainingPinAttempts
    self.keycardRemainingPinAttemptsChanged()

  proc addKeyPairStateChanged*(self: View) {.signal.}
  proc getAddKeyPairState(self: View): int {.slot.} =
    return self.addKeyPairState
  QtProperty[int] addKeyPairState:
    read = getAddKeyPairState
    notify = addKeyPairStateChanged
  proc setAddKeyPairState*(self: View, addKeyPairState: int) =
    self.addKeyPairState = addKeyPairState
    self.addKeyPairStateChanged()


  ### slots ###

  proc shouldStartWithOnboardingScreen(self: View): bool {.slot.} =
    return self.delegate.shouldStartWithOnboardingScreen()

  proc setPin(self: View, pin: string): bool {.slot.} =
    return self.delegate.setPin(pin)

  # TODO find what does this do
  # proc startKeypairTransfer(self: View) {.slot.} =
  #   self.delegate.startKeypairTransfer()

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

  # TODO find what does this do
  # proc mnemonicWasShown(self: View): string {.slot.} =
  #   return self.delegate.getMnemonic()

  proc finishOnboardingFlow(self: View, flowInt: int, dataJson: string): string {.slot.} =
    self.delegate.finishOnboardingFlow(flowInt, dataJson)
