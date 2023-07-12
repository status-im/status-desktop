import NimQml, tables
import app/core/eventemitter
from app_service/service/keycard/service import KeycardEvent, CardMetadata, KeyDetails
from app_service/service/wallet_account/service as wallet_account_service import WalletTokenDto
import app/modules/shared_models/keypair_item

const SIGNAL_SHARED_KEYCARD_MODULE_DISPLAY_POPUP* = "sharedKeycarModuleDisplayPopup"
const SIGNAL_SHARED_KEYCARD_MODULE_FLOW_TERMINATED* = "sharedKeycarModuleFlowTerminated"
const SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER* = "sharedKeycarModuleAuthenticateUser"
const SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED* = "sharedKeycarModuleUserAuthenticated"
const SIGNAL_SHARED_KEYCARD_MODULE_TRY_KEYCARD_SYNC* = "sharedKeycarModuleTryKeycardSync"
const SIGNAL_SHARED_KEYCARD_MODULE_KEYCARD_SYNC_TERMINATED* = "sharedKeycarModuleKeycardSyncTerminated"

## Authentication in the app is a global thing and may be used from any part of the app. How to achieve that... it's enough just to send
## `SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER` signal with properly set `SharedKeycarModuleAuthenticationArgs` and props there:
## -- `uniqueIdentifier` - some unique string, for the readability usually name of the module which needs authentication,
## -- in case of non keycard user (regular) user that's enough,
## -- in case of keycard user we want to authenticate it with a card that his profile is migrated to, that means apart of `uniqueIdentifier`
## we need to set `keyUid` as well,
##
## `SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER` will be handled in the `mainModule` (shared keycard popup module will be run) and as a
## result, when authentication gets done `SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED` signal with properly set `SharedKeycarModuleArgs`
## and props there will be emitted:
## -- `uniqueIdentifier` - will be the same as one used for running authentication process
## -- in case of success of a regular user authentication `keyUid`, `password` will be sent, otherwise it will be empty
## -- in case of success of a keycard user authentication `keycardUid`, `keyUid`, `pin` and `password` will be sent, otherwise they will be empty
##
## TLDR: when you need to authenticate user, from the module where it's needed you have to send `SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER`
## signal to run authentication process and connect to `SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED` signal to get the results of it.

type
  SharedKeycarModuleBaseArgs* = ref object of Args
    uniqueIdentifier*: string

type
  SharedKeycarModuleArgs* = ref object of SharedKeycarModuleBaseArgs
    password*: string
    pin*: string # this is used in case we need to run another keycard flow which requires pin, after we successfully authenticated logged in user
    keyUid*: string
    keycardUid*: string
    additinalPathsDetails*: Table[string, KeyDetails] # [path, KeyDetails]

type
  SharedKeycarModuleFlowTerminatedArgs* = ref object of SharedKeycarModuleArgs
    lastStepInTheCurrentFlow*: bool

type
  SharedKeycarModuleAuthenticationArgs* = ref object of SharedKeycarModuleBaseArgs
    keyUid*: string
    additionalBip44Paths*: seq[string] # can be used in authentication flow to export additinal paths if needed except encryption path

type FlowType* {.pure.} = enum
  General = "General"
  FactoryReset = "FactoryReset"
  SetupNewKeycard = "SetupNewKeycard"
  SetupNewKeycardNewSeedPhrase = "SetupNewKeycardNewSeedPhrase"
  SetupNewKeycardOldSeedPhrase = "SetupNewKeycardOldSeedPhrase"
  ImportFromKeycard = "ImportFromKeycard"
  Authentication = "Authentication"
  UnlockKeycard = "UnlockKeycard"
  DisplayKeycardContent = "DisplayKeycardContent"
  RenameKeycard = "RenameKeycard"
  ChangeKeycardPin = "ChangeKeycardPin"
  ChangeKeycardPuk = "ChangeKeycardPuk"
  ChangePairingCode = "ChangePairingCode"
  CreateCopyOfAKeycard = "CreateCopyOfAKeycard"

# For the following flows we don't run card syncing.
const FlowsWeShouldNotTryAKeycardSyncFor* = @[
  FlowType.General,
  FlowType.FactoryReset,
  FlowType.UnlockKeycard,
  FlowType.SetupNewKeycard,
  FlowType.SetupNewKeycardNewSeedPhrase,
  FlowType.SetupNewKeycardOldSeedPhrase,
  FlowType.ImportFromKeycard,
  FlowType.Authentication,
  FlowType.CreateCopyOfAKeycard
]

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getCurrentFlowType*(self: AccessInterface): FlowType {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeycardData*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setKeycardData*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setRemainingAttempts*(self: AccessInterface, value: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method onBackActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onPrimaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSecondaryActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCancelActionClicked*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onKeycardResponse*(self: AccessInterface, keycardFlowType: string, keycardEvent: KeycardEvent) {.base.} =
  raise newException(ValueError, "No implementation available")

method runFlow*(self: AccessInterface, flowToRun: FlowType, keyUid = "", bip44Paths: seq[string] = @[], txHash = "") {.base.} =
  raise newException(ValueError, "No implementation available")

method setPin*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setPuk*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setPassword*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setKeycardName*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNameFromKeycard*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method setPairingCode*(self: AccessInterface, value: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRepeatedKeycardPinWhileTyping*(self: AccessInterface, pin: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRepeatedKeycardPukWhileTyping*(self: AccessInterface, puk: string): bool {.base.} =
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

method getKeyPairForProcessing*(self: AccessInterface): KeyPairItem {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeyPairHelper*(self: AccessInterface): KeyPairItem {.base.} =
  raise newException(ValueError, "No implementation available")

method updateKeyPairForProcessing*(self: AccessInterface, cardMetadata: CardMetadata) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateKeyPairHelper*(self: AccessInterface, cardMetadata: CardMetadata) {.base.} =
  raise newException(ValueError, "No implementation available")

method setKeyPairForProcessing*(self: AccessInterface, item: KeyPairItem) {.base.} =
  raise newException(ValueError, "No implementation available")

method prepareKeyPairForProcessing*(self: AccessInterface, keyUid: string, keycardUid = "") {.base.} =
  raise newException(ValueError, "No implementation available")

method migratingProfileKeyPair*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getSigningPhrase*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, password: string, pin: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method keychainObtainedDataFailure*(self: AccessInterface, errorDescription: string, errorType: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method keychainObtainedDataSuccess*(self: AccessInterface, data: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method syncKeycardBasedOnAppState*(self: AccessInterface, keyUid: string, pin: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getPin*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method onTokensRebuilt*(self: AccessInterface, accountsTokens: OrderedTable[string, seq[WalletTokenDto]]) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  DelegateInterface* = concept c
