import Tables, chronicles

import io_interface

import ../../../core/eventemitter
import ../../../../app_service/service/keycard/service as keycard_service
import ../../../../app_service/service/accounts/service as accounts_service

logScope:
  topics = "keycard-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    keycardService: keycard_service.Service
    accountsService: accounts_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  keycardService: keycard_service.Service,
  accountsService: accounts_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.keycardService = keycardService
  result.accountsService = accountsService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SignalKeycardReaderUnplugged) do(e: Args):
    self.delegate.switchToState(FlowStateType.PluginKeycard)
  
  self.events.on(SignalKeycardNotInserted) do(e: Args):
    self.delegate.switchToState(FlowStateType.InsertKeycard)
  
  self.events.on(SignalKeycardInserted) do(e: Args):
    self.delegate.switchToState(FlowStateType.ReadingKeycard)

  self.events.on(SignalCreateKeycardPIN) do(e: Args):
    self.delegate.switchToState(FlowStateType.CreateKeycardPin)

  self.events.on(SignalEnterKeycardPIN) do(e: Args):
    self.delegate.switchToState(FlowStateType.EnterKeycardPin)

  self.events.on(SignalKeycardNotEmpty) do(e: Args):
    self.delegate.switchToState(FlowStateType.KeycardNotEmpty)

  self.events.on(SignalKeycardIsEmpty) do(e: Args):
    self.delegate.switchToState(FlowStateType.KeycardIsEmpty)

  self.events.on(SignalEnterKeycardPUK) do(e: Args):
    self.delegate.onEnterKeycardPukRequest()

  self.events.on(SignalMaxPINRetriesReached) do(e: Args):
    self.delegate.switchToState(FlowStateType.MaxPinRetriesReached)

  self.events.on(SignalMaxPairingSlotsReached) do(e: Args):
    self.delegate.switchToState(FlowStateType.MaxPairingSlotsReached)

  self.events.on(SignalKeycardFlowResult) do(e: Args):
    let arg = KeycardArgs(e)
    self.delegate.onFlowResult(arg.flowResult)

  self.events.on(SignalCreateSeedPhrase) do(e: Args):
    let arg = KeycardArgs(e)
    self.delegate.setSeedPhraseAndSwitchToState(arg.seedPhrase, FlowStateType.KeycardPinSet)

  self.events.on(SignalWrongKeycardPIN) do(e: Args):
    let arg = KeycardArgs(e)
    self.delegate.onWrongKeycardPin(arg.data)

proc runLoadAccountFlow*(self: Controller) =
  self.keycardService.startLoadAccountFlow()

proc runLoginFlow*(self: Controller) =
  self.keycardService.startLoginFlow()

proc runRecoverAccountFlow*(self: Controller) =
  self.keycardService.startRecoverAccountFlow()

proc storePin*(self: Controller, pin: string) =
  self.keycardService.storePin(pin)

proc enterPin*(self: Controller, pin: string) =
  self.keycardService.enterPin(pin)

proc storeSeedPhrase*(self: Controller, seedPhraseLength: int, seedPhrase: string) =
  self.keycardService.storeSeedPhrase(seedPhraseLength, seedPhrase)

proc resumeCurrentFlow*(self: Controller) =
  self.keycardService.resumeCurrentFlow()

proc factoryReset*(self: Controller) =
  self.keycardService.factoryReset()

proc cancelCurrentFlow*(self: Controller) =
  self.keycardService.cancelCurrentFlow()

proc validSeedPhrase*(self: Controller, seedPhrase: string): bool =
  return self.accountsService.validateMnemonic(seedPhrase).len == 0

proc setupAccount*(self: Controller, keycardData: KeycardEvent) =
  self.accountsService.setupAccountKeycard(keycardData)

# Once we improve our states and merge `startupModule`, `onboardingModule` and `loginModule` into one,
# we should use `accountServices` from here to deal with accounts in an appropriate way.
#
# proc importMnemonic*(self: Controller, mnemonic: string): tuple[generatedAcc: GeneratedAccountDto, error: string] =
#   result.error = self.accountsService.importMnemonic(mnemonic)
#   result.generatedAcc = self.accountsService.getImportedAccount()