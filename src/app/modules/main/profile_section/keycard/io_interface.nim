import NimQml
from ../../../../../app_service/service/wallet_account/service import KeyPairDto

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

method runGenerateSeedPhrasePopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runImportOrRestoreViaSeedPhrasePopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runImportFromKeycardToAppPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runUnlockKeycardPopupForKeycardWithUid*(self: AccessInterface, keycardUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method runDisplayKeycardContentPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runFactoryResetPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runRenameKeycardPopup*(self: AccessInterface, keycardUid: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method runChangePinPopup*(self: AccessInterface, keycardUid: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method runCreateBackupCopyOfAKeycardPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runCreatePukPopup*(self: AccessInterface, keycardUid: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method runCreateNewPairingCodePopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onLoggedInUserImageChanged*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNewKeycardSet*(self: AccessInterface, keyPair: KeyPairDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardLocked*(self: AccessInterface, keycardUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardUnlocked*(self: AccessInterface, keycardUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardNameChanged*(self: AccessInterface, keycardUid: string, keycardNewName: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardUidUpdated*(self: AccessInterface, keycardUid: string, keycardNewUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeycardDetailsAsJson*(self: AccessInterface, keycardUid: string): string {.base.} =
  raise newException(ValueError, "No implementation available")


# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
