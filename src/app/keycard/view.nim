import NimQml, chronicles, strutils
import status/[status, keycard]
import types/keycard as keycardtypes
import pairing
import status/statusgo_backend/accounts/constants
import status/types/[account, multi_accounts, derived_account, rpc_response]

logScope:
  topics = "keycard-model"

type
  CardState* {.pure.} = enum
    Disconnected = 0
    NotKeycard = 1
    PreInit = 2
    Unpaired = 3
    NoFreeSlots = 4
    Paired = 5
    Frozen = 6
    Blocked = 7
    Authenticated = 8

type
  OnboardingFlow* {.pure.} = enum
    Recover = 0,
    Generate = 1
    ImportMnemonic = 2

QtObject:
  type KeycardView* = ref object of QObject
    status*: Status
    pairings*: KeycardPairingController
    cardState*: CardState
    appInfo*: KeycardApplicationInfo
    appStatus*: KeycardStatus
    onboardingFlow*: OnboardingFlow

  proc setup(self: KeycardView) =
    self.QObject.setup

  proc delete*(self: KeycardView) =
    self.QObject.delete

  proc newKeycardView*(status: Status): KeycardView =
    new(result, delete)
    result.status = status
    result.pairings = newPairingController()
    result.onboardingFlow = Recover
    result.setup

  proc cardConnected*(self: KeycardView) {.signal.}
  proc cardDisconnected*(self: KeycardView) {.signal.}
  proc cardNotKeycard*(self: KeycardView) {.signal.}
  proc cardPreInit*(self: KeycardView) {.signal.}
  proc cardUnpaired*(self: KeycardView) {.signal.}
  proc cardNoFreeSlots*(self: KeycardView) {.signal.}
  proc cardPaired*(self: KeycardView) {.signal.}
  proc cardFrozen*(self: KeycardView) {.signal.}
  proc cardBlocked*(self: KeycardView) {.signal.}
  proc cardAuthenticated*(self: KeycardView) {.signal.}
  proc cardUnhandledError*(self: KeycardView, error: string) {.signal.}
  proc cardPairingError*(self: KeycardView) {.signal.}
  proc cardPinError*(self: KeycardView, retries: int) {.signal.}

  proc startConnection*(self: KeycardView) {.slot.} =
    try:
      self.status.keycard.start()
    except KeycardStartException as ex:
      self.cardUnhandledError(ex.error)

  proc stopConnection*(self: KeycardView) {.slot.} =
    self.cardState = Disconnected
    try:
      self.status.keycard.stop()
    except KeycardStopException as ex:
      self.cardUnhandledError(ex.error)

  proc attemptOpenSecureChannel(self: KeycardView): bool =
    let pairing = self.pairings.getPairing(self.appInfo.instanceUID)

    if pairing == nil:
      return false

    try:
      self.status.keycard.openSecureChannel(int(pairing.index), pairing.key)
    except KeycardOpenSecureChannelException:
      self.pairings.removePairing(self.appInfo.instanceUID)
      return false

    return true

  proc onSecureChannelOpened(self: KeycardView) =
    self.appStatus = self.status.keycard.getStatusApplication()
    if self.appStatus.pukRetryCount == 0:
      self.cardState = Blocked
      self.cardBlocked()
    elif self.appStatus.pinRetryCount == 0:
      self.cardState = Frozen
      self.cardFrozen()
    else:
      self.cardState = Paired
      self.cardPaired()

  proc pair*(self: KeycardView, password: string) {.slot.} =
    try:
      let pairing = self.status.keycard.pair(password)
      self.pairings.addPairing(self.appInfo.instanceUID, pairing)
      if self.attemptOpenSecureChannel():
        self.onSecureChannelOpened()
    except KeycardPairException:
      self.cardPairingError()

  proc authenticate*(self: KeycardView, pin: string) {.slot.} =
    try:
      self.status.keycard.verifyPin(pin)
      self.cardAuthenticated()
    except KeycardVerifyPINException as ex:
      self.appStatus.pinRetryCount = ex.remainingAttempts
      self.cardPinError(int(ex.remainingAttempts))

  proc init*(self: KeycardView, pin: string) {.slot.} =
    discard """
    """

  proc recoverAccount(self: KeycardView) =
    try:
      let master = self.status.keycard.exportKey(path="m", derive=true, makeCurrent=false, onlyPublic=true)
      let walletKey = self.status.keycard.exportKey(path=PATH_DEFAULT_WALLET, derive=true, makeCurrent=false, onlyPublic=true)
      let whisperKey = self.status.keycard.exportKey(path=PATH_WHISPER, derive=true, makeCurrent=false, onlyPublic=false)
      let encryptionKey = self.status.keycard.exportKey(path=PATH_EIP_1581 & "/1'/0", derive=true, makeCurrent=false, onlyPublic=false)

      var account = GeneratedAccount()
      account.publicKey = master.pubKey
      account.address = ""
      account.derived.whisper.publicKey = whisperKey.pubKey
      account.derived.defaultWallet.publicKey = walletKey.pubKey
      account.name = self.status.accounts.generateAlias(whisperKey.pubKey)
      account.keyUid = self.appInfo.keyUID
      account.identicon = self.status.accounts.generateIdenticon(whisperKey.pubKey)
      account.isKeycard = true

      discard self.status.accounts.storeDerivedAndLogin(self.status.fleet.config, account, encryptionKey.privKey, whisperKey.privKey).toJson

    except KeycardExportKeyException as ex:
      self.cardUnhandledError(ex.error)
    except StatusGoException as e:
      info "error = ", error=e.msg

  proc onboarding*(self: KeycardView) {.slot.} =
    case self.onboardingFlow:
      of Recover:
        self.recoverAccount()
      of Generate:
        discard
      of ImportMnemonic:
        discard

  proc getCardState*(self: KeycardView) =
    var appInfo: KeycardApplicationInfo

    try:
      appInfo = self.status.keycard.select()
    except KeycardSelectException as ex:
      self.cardUnhandledError(ex.error)
      return

    self.appInfo = appInfo

    if not appInfo.installed:
      self.cardState = NotKeycard
      self.cardNotKeycard()
    elif not appInfo.initialized:
      self.cardState = PreInit
      self.cardPreInit()
    elif self.attemptOpenSecureChannel():
      self.onSecureChannelOpened()
    elif appInfo.availableSlots > 0:
      self.cardState = Unpaired
      self.cardUnpaired()
    else:
      self.cardState = NoFreeSlots
      self.cardNoFreeSlots()