import NimQml
import app_service/service/wallet_account/keypair_dto

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeycardSharedModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method onDisplayKeycardSharedModuleFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSharedKeycarModuleFlowTerminated*(self: AccessInterface, lastStepInTheCurrentFlow: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method runSetupKeycardPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runCreateNewKeycardWithNewSeedPhrasePopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runImportOrRestoreViaSeedPhrasePopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runImportFromKeycardToAppPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runUnlockKeycardPopupForKeycardWithUid*(self: AccessInterface, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method runDisplayKeycardContentPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runFactoryResetPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runRenameKeycardPopup*(self: AccessInterface, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method runChangePinPopup*(self: AccessInterface, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method runCreateBackupCopyOfAKeycardPopup*(self: AccessInterface, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method runCreatePukPopup*(self: AccessInterface, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method runCreateNewPairingCodePopup*(self: AccessInterface, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onLoggedInUserImageChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method resolveRelatedKeycardsForKeypair*(self: AccessInterface, keypair: KeypairDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNewKeycardSet*(self: AccessInterface, keyPair: KeycardDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardLocked*(self: AccessInterface, keyUid: string, keycardUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardUnlocked*(self: AccessInterface, keyUid: string, keycardUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardNameChanged*(self: AccessInterface, keycardUid: string, keycardNewName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardUidUpdated*(self: AccessInterface, keycardUid: string, keycardNewUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardAccountsRemoved*(self: AccessInterface, keyUid: string, keycardUid: string, accountsToRemove: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onWalletAccountUpdated*(self: AccessInterface, account: WalletAccountDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method prepareKeycardDetailsModel*(self: AccessInterface, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")


# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
