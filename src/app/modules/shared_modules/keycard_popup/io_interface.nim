import NimQml
import ../../../../app/core/eventemitter
from ../../../../app_service/service/keycard/service import KeycardEvent, CardMetadata, KeyDetails
import models/key_pair_item

const SIGNAL_SHARED_KEYCARD_MODULE_DISPLAY_POPUP* = "sharedKeycarModuleDisplayPopup"
const SIGNAL_SHARED_KEYCARD_MODULE_FLOW_TERMINATED* = "sharedKeycarModuleFlowTerminated"
const SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER* = "sharedKeycarModuleAuthenticateUser"
const SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED* = "sharedKeycarModuleUserAuthenticated"

type
  SharedKeycarModuleBaseArgs* = ref object of Args
    uniqueIdentifier*: string

type
  SharedKeycarModuleArgs* = ref object of SharedKeycarModuleBaseArgs
    data*: string
    keyUid*: string
    txR*: string
    txS*: string
    txV*: string

type
  SharedKeycarModuleFlowTerminatedArgs* = ref object of SharedKeycarModuleArgs
    lastStepInTheCurrentFlow*: bool

type
  SharedKeycarModuleAuthenticationArgs* = ref object of SharedKeycarModuleBaseArgs
    keyUid*: string
    bip44Path*: string
    txHash*: string

type FlowType* {.pure.} = enum
  General = "General"
  FactoryReset = "FactoryReset"
  SetupNewKeycard = "SetupNewKeycard"
  Authentication = "Authentication"

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeycardData*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setKeycardData*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBackActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
    
method onPrimaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSecondaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onTertiaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardResponse*(self: AccessInterface, keycardFlowType: string, keycardEvent: KeycardEvent) {.base.} =
  raise newException(ValueError, "No implementation available")

method runFlow*(self: AccessInterface, flowToRun: FlowType, keyUid = "", bip44Path = "", txHash = "") {.base.} =
  raise newException(ValueError, "No implementation available")

method setPin*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setPassword*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRepeatedKeycardPinWhileTyping*(self: AccessInterface, pin: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getMnemonic*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setSeedPhrase*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSeedPhrase*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method validSeedPhrase*(self: AccessInterface, value: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedKeyPair*(self: AccessInterface, item: KeyPairItem) {.base.} =
  raise newException(ValueError, "No implementation available")

method setKeyPairStoredOnKeycard*(self: AccessInterface, cardMetadata: CardMetadata) {.base.} =
  raise newException(ValueError, "No implementation available")

method loggedInUserUsesBiometricLogin*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method migratingProfileKeyPair*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method isProfileKeyPairMigrated*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getSigningPhrase*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method keychainObtainedDataFailure*(self: AccessInterface, errorDescription: string, errorType: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method keychainObtainedDataSuccess*(self: AccessInterface, data: string) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  DelegateInterface* = concept c
