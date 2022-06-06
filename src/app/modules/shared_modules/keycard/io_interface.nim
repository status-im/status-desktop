import NimQml

type FlowStateType* {.pure.} = enum
  PluginKeycard = "pluginKeycardState"
  InsertKeycard = "insertKeycardState"
  ReadingKeycard = "readingKeycardState"
  CreateKeycardPin = "createKeycardPinState"
  RepeatKeycardPin = "repeatKeycardPinState"
  KeycardPinSet = "keycardPinSetState"
  DisplaySeedPhrase = "displaySeedPhraseState"
  EnterSeedPhraseWords = "enterSeedPhraseWordsState"
  YourProfileState = "yourProfileState"
  KeycardNotEmpty = "keycardNotEmpty"
  KeycardLocked = "keycardLocked"

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

method startOnboardingKeycardFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method cancelFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method checkKeycardPin*(self: AccessInterface, pin: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRepeatedKeycardPinCurrent*(self: AccessInterface, pin: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRepeatedKeycardPin*(self: AccessInterface, pin: string): bool {.base.} =
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

method setKeyUidAndSwitchToState*(self: AccessInterface, keyUid: string, state: FlowStateType) {.base.} =
  raise newException(ValueError, "No implementation available")

method factoryReset*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchCard*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")