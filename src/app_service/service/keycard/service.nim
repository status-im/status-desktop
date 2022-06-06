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

const PUKLengthForStatusApp = 12
const MnemonicLengthForStatusApp = 12
const TimerIntervalInMilliseconds = 5 * 1000 # 5 seconds

const SignalKeycardReaderUnplugged* = "keycardReaderUnplugged"
const SignalKeycardNotInserted* = "keycardNotInserted"
const SignalKeycardInserted* = "keycardInserted"
const SignalCreateKeycardPin* = "createKeycardPin"
const SignalCreateSeedPhrase* = "createSeedPhrase"
const SignalKeyUidReceived* = "keyUidReceived"
const SignalSwapKeycard* = "swapKeycard"
const SignalKeycardError* = "keycardError"
const SignalMaxPINRetriesFetched* = "maxPINRetriesFetched"
const SignalMaxPUKRetriesFetched* = "maxPUKRetriesFetched"
const SignalMaxPairingSlotsFetched* = "maxPairingSlotsFetched"
const SignalKeycardNotEmpty* = "keycardNotEmpty"

type
  KeycardArgs* = ref object of Args
    data*: string
    seedPhrase*: seq[string]
    errMessage*: string

logScope:
  topics = "keycard-service"

include constants
include ../../common/json_utils
include ../../common/mnemonics
include async_tasks

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    closingApp: bool
    cancelFlow: bool
    currentFlow: FlowType

  #################################################
  # Forward declaration section
  proc runTimer(self: Service)
  proc handleMnemonic(self: Service, jsonObj: JsonNode)
  proc handleKeyUid(self: Service, jsonObj: JsonNode)
  proc handleError(self: Service, jsonObj: JsonNode): bool

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
    result.cancelFlow = false
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

    echo "\n\nKEYCARD SIGNAL: ", $jsonSignal

    var typeObj, eventObj: JsonNode
    if(not jsonSignal.getProp(ResponseKeyType, typeObj) or 
      not jsonSignal.getProp(ResponseKeyEvent, eventObj)):
      return
    
    let flowType = typeObj.getStr

    if flowType == ResponseTypeValueKeycardFlowResult:  
      if self.handleError(eventObj):
        return
      if eventObj.contains(RequestParamKeyUID):
        self.handleKeyUid(eventObj)
        return
      return

    if flowType == ResponseTypeValueInsertCard:
      self.events.emit(SignalKeycardNotInserted, Args())
      return

    if flowType == ResponseTypeValueCardInserted:
      self.events.emit(SignalKeycardInserted, Args())
      return
  
    if flowType == ResponseTypeValueEnterPIN or
      flowType == ResponseTypeValueEnterNewPIN:
      if self.handleError(eventObj):
        return
      self.events.emit(SignalCreateKeycardPin, Args())
      return

    if flowType == ResponseTypeValueEnterMnemonic:
      self.handleMnemonic(eventObj)
      return

    if flowType == ResponseTypeValueSwapCard:
      if self.handleError(eventObj):
        return
      self.events.emit(SignalSwapKeycard, Args())
      return

  proc receiveKeycardSignal(self: Service, signal: string) {.slot.} =
    self.processSignal(signal)

  proc handleMnemonic(self: Service, jsonObj: JsonNode) =
    var indexesObj: JsonNode
    if not jsonObj.getProp(RequestParamMnemonicIdxs, indexesObj) or indexesObj.kind != JArray:
      let err = "cannot generate mnemonic"
      error "keycard error: ", err
      self.events.emit(SignalKeycardError, KeycardArgs(errMessage: err))
      return
    var seedPhrase: seq[string]
    for ind in indexesObj:
      seedPhrase.add(englishWords[ind.getInt])
    self.events.emit(SignalCreateSeedPhrase, KeycardArgs(seedPhrase: seedPhrase))

  proc handleKeyUid(self: Service, jsonObj: JsonNode) =
    var keyUidObj: JsonNode
    if not jsonObj.getProp(RequestParamKeyUID, keyUidObj):
      let err = "cannot generate key-uid"
      error "keycard error: ", err
      self.events.emit(SignalKeycardError, KeycardArgs(errMessage: err))
      return
    self.events.emit(SignalKeyUidReceived, KeycardArgs(data: keyUidObj.getStr))

  proc handleError(self: Service, jsonObj: JsonNode): bool =
    var errValueObj: JsonNode
    if jsonObj.getProp(ErrorKey, errValueObj):
      if errValueObj.getStr == ErrorConnection:
        self.runTimer()
        self.events.emit(SignalKeycardReaderUnplugged, Args())
        return true
      if errValueObj.getStr == RequestParamPIN:
        self.events.emit(SignalMaxPINRetriesFetched, KeycardArgs())
        return true
      if errValueObj.getStr == RequestParamPUK:
        # A keycard is locked in real when PUK is missed 5 times.
        self.events.emit(SignalMaxPUKRetriesFetched, KeycardArgs())
        return true
      if errValueObj.getStr == RequestParamFreeSlots:
        self.events.emit(SignalMaxPairingSlotsFetched, KeycardArgs())
        return true
      if errValueObj.getStr == ErrorHasKeys:
        self.events.emit(SignalKeycardNotEmpty, KeycardArgs())
        return true
      return false
    return false

  proc startLoadAccountFlow(self: Service) {.slot.} =
    let payload = %* { }
    self.currentFlow = FlowType.LoadAccount
    let response = keycard_go.keycardStartFlow(FlowType.LoadAccount.int, $payload)
    debug "LoadAccount flow response: ", response

  proc onTimeout(self: Service, response: string) {.slot.} =
    if(self.closingApp or self.cancelFlow or self.currentFlow == FlowType.NoFlow):
      return
    debug "onTimeout, about to start flow: ", flowType=self.currentFlow
    if self.currentFlow == FlowType.LoadAccount:
      self.startLoadAccountFlow()

  proc runTimer(self: Service) =
    if(self.closingApp or self.cancelFlow):
      return

    let arg = TimerTaskArg(
      tptr: cast[ByteAddress](timerTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onTimeout",
      timeoutInMilliseconds: TimerIntervalInMilliseconds
    )
    self.threadpool.start(arg)

  proc startOnboardingKeycardFlow*(self: Service) =
    self.cancelFlow = false
    self.startLoadAccountFlow()

  proc generateRandomPUK(self: Service): string =
    for i in 0 ..< PUKLengthForStatusApp:
      result = result & $rand(0 .. 9)

  proc resumeFlow(self: Service, payload: JsonNode) =
    let response = keycard_go.keycardResumeFlow($payload)
    debug "resumeCurrentFlow flow response: ", response

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

  proc storeSeedPhrase*(self: Service, seedPhrase: string) =
    if seedPhrase.len == 0:
      info "empty seed phrase provided"
      return
    var payload = %* {
      RequestParamOverwrite: true,
      RequestParamMnemonicLen: MnemonicLengthForStatusApp,
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

  proc cancelCurrentFlow*(self: Service) =
    self.cancelFlow = true
    self.currentFlow = FlowType.LoadAccount
    let response = keycard_go.keycardCancelFlow()
    debug "cancel keycard flow response: ", response