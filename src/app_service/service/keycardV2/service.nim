import NimQml, json, chronicles, strutils, random, json_serialization
import keycard_go
import app/global/global_singleton
import app/core/eventemitter
import app/core/tasks/[qt, threadpool]
import app_service/service/keycard/service as old_keycard_service
import ../../../backend/response_type
import ../../../constants as status_const
import ./dto

proc callRPC*(rpcCounter: int, methodName: string, params: JsonNode = %*{}): string  =
    var request = %*{
      "id": rpcCounter,
      "method": "keycard." & methodName,
      "params": %*[ params ],
    }
    var response = keycard_go.keycardCallRPC($request)
    return response

include ../../common/mnemonics
include async_tasks

logScope:
  topics = "keycardV2-service"

const SupportedMnemonicLength12* = 12
const PUKLengthForStatusApp* = 12

const SIGNAL_KEYCARD_STATE_UPDATED* = "keycardStateUpdated"
const SIGNAL_KEYCARD_SET_PIN_FAILURE* = "keycardSetPinFailure"
const SIGNAL_KEYCARD_AUTHORIZE_FAILURE* = "keycardAuthorizeFailure"
const SIGNAL_KEYCARD_LOAD_MNEMONIC_FAILURE* = "keycardLoadMnemonicFailure"
const SIGNAL_KEYCARD_LOAD_MNEMONIC_SUCCESS* = "keycardLoadMnemonicSuccess"
const SIGNAL_KEYCARD_EXPORT_KEYS_FAILURE* = "keycardExportKeysFailure"
const SIGNAL_KEYCARD_EXPORT_KEYS_SUCCESS* = "keycardExportKeysSuccess"

type
  KeycardEventArg* = ref object of Args
    keycardEvent*: KeycardEventDto

  KeycardErrorArg* = ref object of Args
    error*: string

  KeycardKeyUIDArg* = ref object of Args
    keyUID*: string

  KeycardExportedKeysArg* = ref object of Args
    exportedKeys*: KeycardExportedKeysDto

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    rpcCounter: int
    oldKeyCardService: old_keycard_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool, oldKeyCardService: old_keycard_service.Service): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.rpcCounter = 0
    result.oldKeyCardService = oldKeyCardService

  proc initializeRPC(self: Service)
  proc start*(self: Service, storageDir: string)

  proc init*(self: Service) =
    debug "KeycardServiceV2 init"
    self.initializeRPC()
    self.start(status_const.KEYCARDPAIRINGDATAFILE)
    discard

  proc initializeRPC(self: Service) {.slot.} =
    var response = keycard_go.keycardInitializeRPC()

  proc callRPC(self: Service, methodName: string, params: JsonNode = %*{}): string  =
    self.rpcCounter += 1
    return callRPC(self.rpcCounter, methodName, params)

  proc start*(self: Service, storageDir: string) =
    discard self.callRPC("Start", %*{"storageFilePath": storageDir})

  proc stop*(self: Service) =
    discard self.callRPC("Stop")
  
  proc buildSeedPhrasesFromIndexes*(seedPhraseIndexes: JsonNode): seq[string] =
    var seedPhrase: seq[string]
    for ind in seedPhraseIndexes.items:
      seedPhrase.add(englishWords[ind.getInt])
    return seedPhrase

  proc generateMnemonic*(self: Service, length: int): string =
    try:
      let response = self.callRPC("GenerateMnemonic", %*{"length": length})
      let rpcResponseObj = response.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
          let error = Json.decode(rpcResponseObj["error"].getStr, RpcError)
          raise newException(RpcException, "Error loading mnemonic: " & error.message)

      let words = buildSeedPhrasesFromIndexes(rpcResponseObj["result"]["indexes"])
      var jArray = newJArray()
      for item in words:
        jArray.add(%item)
      return $jArray
    except Exception as e:
      error "error generating mnemonic", err=e.msg

  proc loadMnemonic*(self: Service, mnemonic: string) =
    self.rpcCounter += 1
    let arg = AsyncLoadMnemonicArg(
      tptr: asyncLoadMnemonicTask,
      vptr: cast[uint](self.vptr),
      slot: "onAsyncLoadMnemonicResponse",
      mnemonic: mnemonic,
      rpcCounter: self.rpcCounter,
    )
    self.threadpool.start(arg)
    
  proc onAsyncLoadMnemonicResponse(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson
      if responseObj{"error"}.kind != JNull and responseObj{"error"}.getStr != "":
        raise newException(CatchableError, responseObj{"error"}.getStr)

      let rpcResponseObj = responseObj["response"].getStr().parseJson()

      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        let error = Json.decode(rpcResponseObj["error"].getStr, RpcError)
        raise newException(RpcException, "Error loading mnemonic: " & error.message)

      self.events.emit(SIGNAL_KEYCARD_LOAD_MNEMONIC_SUCCESS, KeycardKeyUIDArg(keyUID: rpcResponseObj["result"]["keyUID"].getStr))
    except Exception as e:
      error "error loading mnemonic", err=e.msg
      self.events.emit(SIGNAL_KEYCARD_LOAD_MNEMONIC_FAILURE, KeycardErrorArg(error: e.msg))

  proc asyncAuthorize*(self: Service, pin: string) =
    self.rpcCounter += 1
    let arg = AsyncAuthorizeArg(
      tptr: asyncAuthorizeTask,
      vptr: cast[uint](self.vptr),
      slot: "onAsyncAuthorizeResponse",
      pin: pin,
      rpcCounter: self.rpcCounter,
    )
    self.threadpool.start(arg)

  proc onAsyncAuthorizeResponse*(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson

      if responseObj{"error"}.kind != JNull and responseObj{"error"}.getStr != "":
        raise newException(CatchableError, responseObj{"error"}.getStr)

      let rpcResponseObj = responseObj["response"].getStr().parseJson()
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        let error = Json.decode(rpcResponseObj["error"].getStr, RpcError)
        raise newException(RpcException, "Error authorizing: " & error.message)
    except Exception as e:
      error "error set pin: ", msg = e.msg
      self.events.emit(SIGNAL_KEYCARD_AUTHORIZE_FAILURE, KeycardErrorArg(error: e.msg))

  proc receiveKeycardSignalV2(self: Service, signal: string) {.slot.} =
    try:
      # Since only one service can register to signals, we pass the signal to the old service too
      self.oldKeyCardService.receiveKeycardSignal(signal)
      var jsonSignal = signal.parseJson

      if jsonSignal["type"].getStr == "status-changed":
        let keycardEvent = jsonSignal["event"].toKeycardEventDto()
        
        self.events.emit(SIGNAL_KEYCARD_STATE_UPDATED, KeycardEventArg(keycardEvent: keycardEvent))
    except Exception as e:
      error "error receiving a keycard signal", err=e.msg, data = signal

  proc initialize*(self: Service, pin: string, puk: string) =
    self.rpcCounter += 1
    let arg = AsyncInitializeTaskArg(
      tptr: asyncInitializeTask,
      vptr: cast[uint](self.vptr),
      slot: "onAsyncInitializeResponse",
      pin: pin,
      puk: puk,
      rpcCounter: self.rpcCounter,
    )
    self.threadpool.start(arg)

  proc onAsyncInitializeResponse*(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson

      if responseObj{"error"}.kind != JNull and responseObj{"error"}.getStr != "":
        raise newException(CatchableError, responseObj{"error"}.getStr)

      let rpcResponseObj = responseObj["response"].getStr().parseJson()
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        let error = Json.decode(rpcResponseObj["error"].getStr, RpcError)
        raise newException(RpcException, "Error authorizing: " & error.message)
    except Exception as e:
      error "error set pin: ", msg = e.msg
      self.events.emit(SIGNAL_KEYCARD_SET_PIN_FAILURE, KeycardErrorArg(error: e.msg))

  proc generateRandomPUK*(self: Service): string =
    randomize()
    for i in 0 ..< PUKLengthForStatusApp:
      result = result & $rand(0 .. 9)

  proc asyncExportRecoverKeys*(self: Service) =
    self.rpcCounter += 1
    let arg = AsyncExportRecoverKeysArg(
      tptr: asyncExportRecoverKeysTask,
      vptr: cast[uint](self.vptr),
      slot: "onAsyncExportRecoverKeys",
      rpcCounter: self.rpcCounter,
    )
    self.threadpool.start(arg)

  proc onAsyncExportRecoverKeys*(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson

      if responseObj{"error"}.kind != JNull and responseObj{"error"}.getStr != "":
        raise newException(CatchableError, responseObj{"error"}.getStr)

      let rpcResponseObj = responseObj["response"].getStr().parseJson()
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        let error = Json.decode(rpcResponseObj["error"].getStr, RpcError)
        raise newException(RpcException, "Error authorizing: " & error.message)

      let keys = rpcResponseObj["result"]["keys"].toKeycardExportedKeysDto()
      self.events.emit(SIGNAL_KEYCARD_EXPORT_KEYS_SUCCESS, KeycardExportedKeysArg(exportedKeys: keys))
    except Exception as e:
      error "error exporting recover keys", msg = e.msg
      self.events.emit(SIGNAL_KEYCARD_EXPORT_KEYS_FAILURE, KeycardErrorArg(error: e.msg))

    