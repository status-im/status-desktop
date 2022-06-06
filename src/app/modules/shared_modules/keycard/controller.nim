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

  self.events.on(SignalCreateKeycardPin) do(e: Args):
    self.delegate.switchToState(FlowStateType.CreateKeycardPin)

  self.events.on(SignalKeycardNotEmpty) do(e: Args):
    self.delegate.switchToState(FlowStateType.KeycardNotEmpty)

  self.events.on(SignalCreateSeedPhrase) do(e: Args):
    let arg = KeycardArgs(e)
    self.delegate.setSeedPhraseAndSwitchToState(arg.seedPhrase, FlowStateType.KeycardPinSet)

  self.events.on(SignalKeyUidReceived) do(e: Args):
    let arg = KeycardArgs(e)
    self.delegate.setKeyUidAndSwitchToState(arg.data, FlowStateType.YourProfileState)

proc startOnboardingKeycardFlow*(self: Controller) =
  self.keycardService.startOnboardingKeycardFlow()

proc storePin*(self: Controller, pin: string) =
  self.keycardService.storePin(pin)

proc storeSeedPhrase*(self: Controller, seedPhrase: string) =
  self.keycardService.storeSeedPhrase(seedPhrase)

proc resumeCurrentFlow*(self: Controller) =
  self.keycardService.resumeCurrentFlow()

proc factoryReset*(self: Controller) =
  self.keycardService.factoryReset()

proc cancelCurrentFlow*(self: Controller) =
  self.keycardService.cancelCurrentFlow()

# proc importMnemonic*(self: Controller, mnemonic: string): tuple[generatedAcc: GeneratedAccountDto, error: string] =
#   result.error = self.accountsService.importMnemonic(mnemonic)
#   result.generatedAcc = self.accountsService.getImportedAccount()