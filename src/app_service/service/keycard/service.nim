import NimQml, json, os, chronicles, random # strutils, , json_serialization
import keycard_go
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../constants as status_const

type FlowType {.pure.} = enum
  NoFlow = -1 # this type is added only for the desktop app purpose
  GetAppInfo = 0 # enumeration of these flows should follow enumeration in the `status-keycard-go`
  RecoverAccount
  LoadAccount
  Login
  ExportPublic
  Sign
  ChangePIN
  ChangePUK
  ChangePairing
  UnpairThis
  UnpairOthers
  DeleteAccountAndUnpair

const PINLengthForStatusApp* = 6
const PUKLengthForStatusApp = 12

const SupportedMnemonicLength12* = 12
const SupportedMnemonicLength18* = 18
const SupportedMnemonicLength24* = 24

const MnemonicLengthForStatusApp = SupportedMnemonicLength12
const TimerIntervalInMilliseconds = 5 * 1000 # 5 seconds

const SignalKeycardFlowResult* = "keycardFlowResult"
const SignalKeycardReaderUnplugged* = "keycardReaderUnplugged"
const SignalKeycardNotInserted* = "keycardNotInserted"
const SignalKeycardInserted* = "keycardInserted"
const SignalCreateKeycardPIN* = "createKeycardPIN"
const SignalEnterKeycardPIN* = "enterKeycardPIN"
const SignalCreateKeycardPUK* = "createKeycardPUK"
const SignalEnterKeycardPUK* = "enterKeycardPUK"
const SignalCreateSeedPhrase* = "createSeedPhrase"
const SignalSwapKeycard* = "swapKeycard"
const SignalKeycardError* = "keycardError"
const SignalMaxPINRetriesReached* = "maxPINRetriesReached"
const SignalWrongKeycardPIN* = "wrongKeycardPIN"
const SignalMaxPUKRetriesReached* = "maxPUKRetriesReached"
const SignalWrongKeycardPUK* = "wrongKeycardPUK"
const SignalMaxPairingSlotsReached* = "maxPairingSlotsReached"
const SignalKeycardNotEmpty* = "keycardNotEmpty"
const SignalKeycardIsEmpty* = "keycardIsEmpty"

logScope:
  topics = "keycard-service"

include constants
include ../../common/json_utils
include ../../common/mnemonics
include internal
include async_tasks

type
  KeycardArgs* = ref object of Args
    data*: string
    seedPhrase*: seq[string]
    errMessage*: string
    flowResult*: KeycardEvent

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    closingApp: bool
    currentFlow: FlowType

  #################################################
  # Forward declaration section
  proc runTimer(self: Service)
  proc handleMnemonic(self: Service, keycardEvent: KeycardEvent)
  proc handleError(self: Service, keycardEvent: KeycardEvent): bool
  proc factoryReset*(self: Service)

  #################################################

  proc setup(self: Service) =
    self.QObject.setup

  proc delete*(self: Service) =
    self.closingApp = true
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool): Service =
    new(result)
    result.setup()
    result.events = events
    result.threadpool = threadpool
    result.closingApp = false
    result.currentFlow = FlowType.NoFlow

  proc init*(self: Service) =
    debug "init keycard using ", pairingsJson=status_const.ROOTKEYCARDDIR
    let initResp = keycard_go.keycardInitFlow(status_const.ROOTKEYCARDDIR)
    debug "initialization response: ", initResp

  proc processSignal(self: Service, signal: string) =
    var jsonSignal: JsonNode
    try:
      jsonSignal = signal.parseJson
    except:
      error "Invalid signal received", data = signal
      return

    # REMOVE THE FOLLOWING LINE, it's added for easier development only!!!
    echo "\n\nKEYCARD SIGNAL: ", $jsonSignal

    var typeObj, eventObj: JsonNode
    if(not jsonSignal.getProp(ResponseKeyType, typeObj) or 
      not jsonSignal.getProp(ResponseKeyEvent, eventObj)):
      return
    
    let flowType = typeObj.getStr
    let keycardEvent = toKeycardEvent(eventObj)

    if flowType == ResponseTypeValueKeycardFlowResult:  
      if self.handleError(keycardEvent):
        return
      self.events.emit(SignalKeycardFlowResult, KeycardArgs(flowResult: keycardEvent))
      return

    if flowType == ResponseTypeValueInsertCard:
      self.events.emit(SignalKeycardNotInserted, Args())
      return

    if flowType == ResponseTypeValueCardInserted:
      self.events.emit(SignalKeycardInserted, Args())
      return
  
    if flowType == ResponseTypeValueEnterNewPIN:
      if self.handleError(keycardEvent):
        return
      self.events.emit(SignalCreateKeycardPIN, Args())
      return

    if flowType == ResponseTypeValueEnterPIN:
      if self.handleError(keycardEvent):
        return
      self.events.emit(SignalEnterKeycardPIN, Args())
      return

    if flowType == ResponseTypeValueEnterNewPUK:
      if self.handleError(keycardEvent):
        return
      self.events.emit(SignalCreateKeycardPUK, Args())
      return

    if flowType == ResponseTypeValueEnterPUK:
      if self.handleError(keycardEvent):
        return
      self.events.emit(SignalEnterKeycardPUK, Args())
      return

    if flowType == ResponseTypeValueEnterMnemonic:
      self.handleMnemonic(keycardEvent)
      return

    if flowType == ResponseTypeValueSwapCard:
      if self.handleError(keycardEvent):
        return
      self.events.emit(SignalSwapKeycard, Args())
      return

  proc receiveKeycardSignal(self: Service, signal: string) {.slot.} =
    self.processSignal(signal)

  proc handleMnemonic(self: Service, keycardEvent: KeycardEvent) =
    if keycardEvent.seedPhraseIndexes.len == 0:
      let err = "cannot generate mnemonic"
      error "keycard error: ", err
      self.events.emit(SignalKeycardError, KeycardArgs(errMessage: err))
      return
    var seedPhrase: seq[string]
    for ind in keycardEvent.seedPhraseIndexes:
      seedPhrase.add(englishWords[ind])
    self.events.emit(SignalCreateSeedPhrase, KeycardArgs(seedPhrase: seedPhrase))

  proc handleError(self: Service, keycardEvent: KeycardEvent): bool =
    if keycardEvent.error.len > 0:
      if keycardEvent.error == ErrorConnection:
        self.runTimer()
        self.events.emit(SignalKeycardReaderUnplugged, Args())
        return true
      if keycardEvent.error == RequestParamPIN:
        if keycardEvent.pinRetries == 0:
          self.events.emit(SignalMaxPINRetriesReached, KeycardArgs())
        else:
          self.events.emit(SignalWrongKeycardPIN, KeycardArgs(data: $keycardEvent.pinRetries))
        return true
      if keycardEvent.error == RequestParamPUK:
        if keycardEvent.pukRetries == 0:
          self.events.emit(SignalMaxPUKRetriesReached, KeycardArgs())
        else:
          self.events.emit(SignalWrongKeycardPUK, KeycardArgs())
        return true
      if keycardEvent.error == ErrorHasKeys:
        self.events.emit(SignalKeycardNotEmpty, KeycardArgs())
        return true
      if keycardEvent.error == ErrorNoKeys:
        self.events.emit(SignalKeycardIsEmpty, KeycardArgs())
        return true
      if keycardEvent.error == RequestParamFreeSlots:
        if keycardEvent.freePairingSlots == 0:
          self.events.emit(SignalMaxPairingSlotsReached, KeycardArgs())
        return true
      return false
    return false

  proc startFlow(self: Service, payload: JsonNode) =
    let response = keycard_go.keycardStartFlow(self.currentFlow.int, $payload)
    debug "keycardStartFlow", flowType=self.currentFlow.int, payload=payload, response=response

  proc resumeFlow(self: Service, payload: JsonNode) =
    let response = keycard_go.keycardResumeFlow($payload)
    debug "keycardResumeFlow", flowType=self.currentFlow.int, payload=payload, response=response

  proc cancelCurrentFlow*(self: Service) =
    self.currentFlow = FlowType.NoFlow
    let response = keycard_go.keycardCancelFlow()
    debug "keycardCancelFlow", flowType=self.currentFlow.int, response=response

  proc generateRandomPUK(self: Service): string =
    for i in 0 ..< PUKLengthForStatusApp:
      result = result & $rand(0 .. 9)

  proc onTimeout(self: Service, response: string) {.slot.} =
    if(self.closingApp or self.currentFlow == FlowType.NoFlow):
      return
    debug "onTimeout, about to start flow: ", flowType=self.currentFlow
    if self.currentFlow == FlowType.LoadAccount:
      self.startFlow(%* { })

  proc runTimer(self: Service) =
    if(self.closingApp or self.currentFlow == FlowType.NoFlow):
      return

    let arg = TimerTaskArg(
      tptr: cast[ByteAddress](timerTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onTimeout",
      timeoutInMilliseconds: TimerIntervalInMilliseconds
    )
    self.threadpool.start(arg)

  proc startLoadAccountFlow*(self: Service) =
    let payload = %* { }
    self.currentFlow = FlowType.LoadAccount
    self.startFlow(payload)

  proc startLoginFlow*(self: Service) =
    let payload = %* { }
    self.currentFlow = FlowType.Login
    self.startFlow(payload)

  proc startRecoverAccountFlow*(self: Service) =
    let payload = %* { }
    self.currentFlow = FlowType.RecoverAccount
    self.startFlow(payload)    

  proc storePin*(self: Service, pin: string) =
    if pin.len == 0:
      info "empty pin provided"
      return
    var payload = %* {
      RequestParamOverwrite: true,
      RequestParamMnemonicLen: MnemonicLengthForStatusApp,
      RequestParamNewPUK: self.generateRandomPUK(),
      RequestParamPIN: pin,
      RequestParamNewPIN: pin
    }
    self.resumeFlow(payload)

  proc enterPin*(self: Service, pin: string) =
    if pin.len == 0:
      info "empty pin provided"
      return
    var payload = %* {
      RequestParamPIN: pin
    }
    self.resumeFlow(payload)

  proc storeSeedPhrase*(self: Service, seedPhraseLength: int, seedPhrase: string) =
    if seedPhrase.len == 0:
      info "empty seed phrase provided"
      return
    var payload = %* {
      RequestParamOverwrite: true,
      RequestParamMnemonicLen: seedPhraseLength,
      RequestParamNewPUK: self.generateRandomPUK(),
      RequestParamMnemonic: seedPhrase
    }
    self.resumeFlow(payload)

  proc resumeCurrentFlow*(self: Service) =
    var payload = %* { }
    self.resumeFlow(payload)

  proc factoryReset*(self: Service) =
    var payload = %* { 
      RequestParamFactoryReset: true
    }
    self.resumeFlow(payload)