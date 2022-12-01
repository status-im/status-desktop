import NimQml
import ../../../app_service/service/accounts/service as accounts_service
import models/login_account_item as login_acc_item
from ../../../app_service/service/keycard/service import KeycardEvent, KeyDetails


type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeycardSharedModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method onDisplayKeycardSharedModuleFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSharedKeycarModuleFlowTerminated*(self: AccessInterface, lastStepInTheCurrentFlow: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method moveToLoadingAppState*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method moveToAppState*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method moveToStartupState*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBackActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
    
method onPrimaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSecondaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onTertiaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onQuaternaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onQuinaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method startUpUIRaised*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitLogOut*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getImportedAccount*(self: AccessInterface): GeneratedAccountDto {.base.} =
  raise newException(ValueError, "No implementation available")

method generateImage*(self: AccessInterface, imageUrl: string, aX: int, aY: int, bX: int, bY: int): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getCroppedProfileImage*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setDisplayName*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getDisplayName*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setPassword*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setDefaultWalletEmoji*(self: AccessInterface, emoji: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getPassword*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setPin*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setPuk*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getPin*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getPasswordStrengthScore*(self: AccessInterface, password: string, userName: string): int {.base.} =
  raise newException(ValueError, "No implementation available")

method setupAccountError*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method validMnemonic*(self: AccessInterface, mnemonic: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method importAccountError*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method importAccountSuccess*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedLoginAccount*(self: AccessInterface, item: login_acc_item.Item) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNodeLogin*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitAccountLoginError*(self: AccessInterface, error: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitObtainingPasswordError*(self: AccessInterface, errorDescription: string, errorType: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitObtainingPasswordSuccess*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardResponse*(self: AccessInterface, keycardFlowType: string, keycardEvent: KeycardEvent) {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRepeatedKeycardPinWhileTyping*(self: AccessInterface, pin: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getSeedPhrase*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeycardData*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setKeycardData*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method runFactoryResetPopup*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method storeKeyPairForNewKeycardUser*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

# This way (using concepts) is used only for the modules managed by AppController
type
  DelegateInterface* = concept c
    c.startupDidLoad()
    c.userLoggedIn()
    c.storeKeyPairForNewKeycardUser()
