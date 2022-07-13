import NimQml
import ../../../../app_service/service/keycard/service as keycard_service

type KeycardMode* {.pure.} = enum
  GenerateNewKeys = "GenerateNewKeys"
  ImportSeedPhrase = "ImportSeedPhrase"
  OldUserLogin = "OldUserLogin"
  CurrentUserLogin = "CurrentUserLogin"

type FlowStateType* {.pure.} = enum
  PluginKeycard = "PluginKeycardState"
  InsertKeycard = "InsertKeycardState"
  ReadingKeycard = "ReadingKeycardState"
  CreateKeycardPin = "CreateKeycardPinState"
  RepeatKeycardPin = "RepeatKeycardPinState"
  KeycardPinSet = "KeycardPinSetState"
  EnterKeycardPin = "EnterKeycardPinState"
  DisplaySeedPhrase = "DisplaySeedPhraseState"
  EnterSeedPhrase = "EnterSeedPhraseState"
  EnterSeedPhraseWords = "EnterSeedPhraseWordsState"
  YourProfileState = "YourProfileState"
  KeycardNotEmpty = "KeycardNotEmptyState"
  KeycardIsEmpty = "KeycardIsEmptyState"
  KeycardLockedFactoryReset = "KeycardLockedFactoryResetState"
  KeycardLockedRecover = "KeycardLockedRecoverState"
  MaxPairingSlotsReached = "MaxPairingSlotsReachedState"
  WrongKeycardPin = "WrongKeycardPinState"
  MaxPinRetriesReached = "MaxPinRetriesReachedState"
  RecoverKeycard = "RecoverKeycardState"

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method switchToState*(self: AccessInterface, state: FlowStateType) {.base.} =
  raise newException(ValueError, "No implementation available")

method runLoadAccountFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runLoginFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method runRecoverAccountFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method cancelFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method checkKeycardPin*(self: AccessInterface, pin: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRepeatedKeycardPinCurrent*(self: AccessInterface, pin: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRepeatedKeycardPin*(self: AccessInterface, pin: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method checkSeedPhrase*(self: AccessInterface, seedPhraseLength: int, seedPhrase: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method shouldExitKeycardFlow*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method backClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method nextState*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSeedPhrase*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setSeedPhraseAndSwitchToState*(self: AccessInterface, seedPhrase: seq[string], state: FlowStateType) {.base.} =
  raise newException(ValueError, "No implementation available")

method onFlowResult*(self: AccessInterface, flowResult: KeycardEvent) {.base.} =
  raise newException(ValueError, "No implementation available")

method factoryReset*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchCard*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onWrongKeycardPin*(self: AccessInterface, pinRetries: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getTmpData*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method onEnterKeycardPukRequest*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")