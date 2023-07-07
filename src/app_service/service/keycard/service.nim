import NimQml, json, os, chronicles, random, strutils
import keycard_go
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../constants as status_const

import constants

type KCSFlowType* {.pure.} = enum
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
  StoreMetadata
  GetMetadata

const EmptyTxHash = "0000000000000000000000000000000000000000000000000000000000000000"
const DefaultBIP44Path = "m/0"
const DefaultEIP1581Path = "m/43'/60'/1581'"

const PINLengthForStatusApp* = 6
const PUKLengthForStatusApp* = 12
const CardNameLength* = 20

const SupportedMnemonicLength12* = 12
const SupportedMnemonicLength18* = 18
const SupportedMnemonicLength24* = 24

const MnemonicLengthForStatusApp = SupportedMnemonicLength12
const TimerIntervalInMilliseconds = 3 * 1000 # 3 seconds

const SIGNAL_KEYCARD_RESPONSE* = "keycardResponse"

logScope:
  topics = "keycard-service"

include ../../common/json_utils
include ../../common/mnemonics
include internal
include ../../common/async_tasks

type
  KeycardLibArgs* = ref object of Args
    flowType*: string
    flowEvent*: KeycardEvent

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    closingApp: bool
    currentFlow: KCSFlowType
    lastReceivedKeycardData: tuple[flowType: string, flowEvent: KeycardEvent]
    setPayloadForCurrentFlow: JsonNode
    doLogging: bool

  proc delete*(self: Service) =
    self.closingApp = true
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.closingApp = false
    result.currentFlow = KCSFlowType.NoFlow
    result.doLogging = false
    if not defined(production):
      result.doLogging = true

  proc init*(self: Service) =
    if self.doLogging:
      debug "init keycard using ", pairingsJson=status_const.KEYCARDPAIRINGDATAFILE
    let initResp = keycard_go.keycardInitFlow(status_const.KEYCARDPAIRINGDATAFILE)
    if self.doLogging:
      debug "initialization response: ", initResp

  proc processSignal(self: Service, signal: string) =
    var jsonSignal: JsonNode
    try:
      jsonSignal = signal.parseJson
    except:
      error "Invalid signal received", data = signal
      return

    if self.doLogging:
      debug "keycard_signal", response=signal

    var typeObj, eventObj: JsonNode
    if(not jsonSignal.getProp(ResponseKeyType, typeObj) or
      not jsonSignal.getProp(ResponseKeyEvent, eventObj)):
      return

    let flowType = typeObj.getStr
    let flowEvent = toKeycardEvent(eventObj)
    self.lastReceivedKeycardData = (flowType: flowType, flowEvent: flowEvent)
    self.events.emit(SIGNAL_KEYCARD_RESPONSE, KeycardLibArgs(flowType: flowType, flowEvent: flowEvent))

  proc receiveKeycardSignal(self: Service, signal: string) {.slot.} =
    self.processSignal(signal)

  proc getLastReceivedKeycardData*(self: Service): tuple[flowType: string, flowEvent: KeycardEvent] =
    return self.lastReceivedKeycardData

  proc cleanReceivedKeycardData*(self: Service) =
    self.lastReceivedKeycardData = ("", KeycardEvent())

  proc buildSeedPhrasesFromIndexes*(self: Service, seedPhraseIndexes: seq[int]): seq[string] =
    var seedPhrase: seq[string]
    for ind in seedPhraseIndexes:
      seedPhrase.add(englishWords[ind])
    return seedPhrase

  proc updateLocalPayloadForCurrentFlow(self: Service, obj: JsonNode, cleanBefore = false) =
    if cleanBefore:
      self.setPayloadForCurrentFlow = %* {}
    for k, v in obj:
      self.setPayloadForCurrentFlow[k] = v

  proc getCurrentFlow*(self: Service): KCSFlowType =
    return self.currentFlow

  proc startFlow(self: Service, payload: JsonNode) =
    self.updateLocalPayloadForCurrentFlow(payload, cleanBefore = true)
    let response = keycard_go.keycardStartFlow(self.currentFlow.int, $payload)
    if self.doLogging:
      debug "keycardStartFlow", kcServiceCurrFlow=($self.currentFlow), payload=payload, response=response

  proc resumeFlow(self: Service, payload: JsonNode) =
    self.updateLocalPayloadForCurrentFlow(payload)
    let response = keycard_go.keycardResumeFlow($payload)
    if self.doLogging:
      debug "keycardResumeFlow", kcServiceCurrFlow=($self.currentFlow), payload=payload, response=response

  proc cancelCurrentFlow*(self: Service) =
    let response = keycard_go.keycardCancelFlow()
    self.currentFlow = KCSFlowType.NoFlow
    if self.doLogging:
      debug "keycardCancelFlow", kcServiceCurrFlow=($self.currentFlow), response=response

  proc generateRandomPUK*(self: Service): string =
    randomize()
    for i in 0 ..< PUKLengthForStatusApp:
      result = result & $rand(0 .. 9)

  proc onTimeout(self: Service, response: string) {.slot.} =
    if(self.closingApp or self.currentFlow == KCSFlowType.NoFlow):
      return
    if self.doLogging:
      debug "onTimeout, about to start flow: ", kcServiceCurrFlow=($self.currentFlow)
    self.startFlow(self.setPayloadForCurrentFlow)

  proc runTimer(self: Service) =
    if(self.closingApp or self.currentFlow == KCSFlowType.NoFlow):
      return

    let arg = TimerTaskArg(
      tptr: cast[ByteAddress](timerTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onTimeout",
      timeoutInMilliseconds: TimerIntervalInMilliseconds
    )
    self.threadpool.start(arg)

  proc startLoadAccountFlow*(self: Service, seedPhraseLength: int, seedPhrase: string, pin: string, puk: string,
    factoryReset: bool) =
    var payload = %* { }
    if seedPhrase.len > 0 and seedPhraseLength > 0:
      payload[RequestParamMnemonic] = %* seedPhrase
      payload[RequestParamMnemonicLen] = %* seedPhraseLength
      payload[RequestParamNewPUK] = %* self.generateRandomPUK()
    if pin.len > 0:
      payload[RequestParamPIN] = %* pin
      payload[RequestParamNewPIN] = %* pin
      payload[RequestParamNewPUK] = %* self.generateRandomPUK()
    if puk.len > 0:
      payload[RequestParamNewPUK] = %* puk
    if factoryReset:
      payload[RequestParamFactoryReset] = %* factoryReset
    self.currentFlow = KCSFlowType.LoadAccount
    self.startFlow(payload)

  proc startLoginFlow*(self: Service) =
    let payload = %* { }
    self.currentFlow = KCSFlowType.Login
    self.startFlow(payload)

  proc startLoginFlowAutomatically*(self: Service, pin: string) =
    let payload = %* {
      RequestParamPIN: pin
    }
    self.currentFlow = KCSFlowType.Login
    self.startFlow(payload)

  proc startRecoverAccountFlow*(self: Service, seedPhraseLength: int, seedPhrase: string, puk: string, factoryReset: bool) =
    var payload = %* { }
    if seedPhrase.len > 0 and seedPhraseLength > 0:
      payload[RequestParamMnemonic] = %* seedPhrase
      payload[RequestParamMnemonicLen] = %* seedPhraseLength
      payload[RequestParamNewPUK] = %* self.generateRandomPUK()
    if puk.len > 0:
      payload[RequestParamNewPUK] = %* puk
    if factoryReset:
      payload[RequestParamFactoryReset] = %* factoryReset
    self.currentFlow = KCSFlowType.RecoverAccount
    self.startFlow(payload)

  proc startGetAppInfoFlow*(self: Service, factoryReset: bool) =
    var payload = %* { }
    if factoryReset:
      payload[RequestParamFactoryReset] = %* factoryReset
    self.currentFlow = KCSFlowType.GetAppInfo
    self.startFlow(payload)

  proc startGetMetadataFlow*(self: Service, resolveAddress: bool, exportMasterAddr = false, pin = "") =
    var payload = %* { }
    if resolveAddress:
      payload[RequestParamResolveAddr] = %* resolveAddress
    if exportMasterAddr:
      payload[RequestParamExportMasterAddress] = %* exportMasterAddr
    if pin.len > 0:
      payload[RequestParamPIN] = %* pin
    self.currentFlow = KCSFlowType.GetMetadata
    self.startFlow(payload)

  proc startChangePinFlow*(self: Service) =
    var payload = %* { }
    self.currentFlow = KCSFlowType.ChangePIN
    self.startFlow(payload)

  proc startChangePukFlow*(self: Service) =
    var payload = %* { }
    self.currentFlow = KCSFlowType.ChangePUK
    self.startFlow(payload)

  proc startChangePairingFlow*(self: Service) =
    var payload = %* { }
    self.currentFlow = KCSFlowType.ChangePairing
    self.startFlow(payload)

  proc startExportPublicFlow*(self: Service, path: string, exportMasterAddr = false, exportPrivateAddr = false, pin = "") =
    ## Exports addresses for passed `path`. Result of this flow sets instance of `GeneratedWalletAccount` under
    ## `generatedWalletAccount` property in `KeycardEvent`.
    if exportPrivateAddr and not path.startsWith(DefaultEIP1581Path):
      error "in order to export private address path must not be outside of eip1581 tree"
      return

    var payload = %* {
      RequestParamBIP44Path: DefaultBIP44Path,
      RequestParamExportMasterAddress: exportMasterAddr,
      RequestParamExportPrivate: exportPrivateAddr
    }
    if path.len > 0:
      payload[RequestParamBIP44Path] = %* path
    if pin.len > 0:
      payload[RequestParamPIN] = %* pin
    self.currentFlow = KCSFlowType.ExportPublic
    self.startFlow(payload)

  proc startExportPublicFlow*(self: Service, paths: seq[string], exportMasterAddr = false, exportPrivateAddr = false, pin = "") =
    ## Exports addresses for passed `path`. Result of this flow sets array of `GeneratedWalletAccount` under
    ## `generatedWalletAccounts` property in `KeycardEvent`. The order of keys set in `generatedWalletAccounts` array
    ## mathch the order of `paths` sent to this flow.
    if exportPrivateAddr:
      for p in paths:
        if not p.startsWith(DefaultEIP1581Path):
          error "one of paths in the list refers to a private address path which is not in eip1581 tree"
          return

    var payload = %* {
      RequestParamBIP44Path: DefaultBIP44Path,
      RequestParamExportMasterAddress: exportMasterAddr,
      RequestParamExportPrivate: exportPrivateAddr
    }
    if paths.len > 0:
      payload[RequestParamBIP44Path] = %* paths
    if pin.len > 0:
      payload[RequestParamPIN] = %* pin
    self.currentFlow = KCSFlowType.ExportPublic
    self.startFlow(payload)

  proc startStoreMetadataFlow*(self: Service, cardName: string, pin: string, walletPaths: seq[string]) =
    var name = cardName
    if cardName.len > CardNameLength:
      name = cardName[0 .. CardNameLength - 1]
    let payload = %* {
      RequestParamPIN: pin,
      RequestParamCardName: name,
      RequestParamWalletPaths: walletPaths
    }
    self.currentFlow = KCSFlowType.StoreMetadata
    self.startFlow(payload)

  proc startSignFlow*(self: Service, bip44Path: string, txHash: string) =
    var payload = %* {
      RequestParamTXHash: EmptyTxHash,
      RequestParamBIP44Path: DefaultBIP44Path
    }
    if txHash.len > 0:
      payload[RequestParamTXHash] = %* txHash
    if bip44Path.len > 0:
      payload[RequestParamBIP44Path] = %* bip44Path
    self.currentFlow = KCSFlowType.Sign
    self.startFlow(payload)

  proc storePin*(self: Service, pin: string, puk: string) =
    if pin.len == 0:
      error "empty pin provided"
      return
    var payload = %* {
      RequestParamOverwrite: true,
      RequestParamMnemonicLen: MnemonicLengthForStatusApp,
      RequestParamPIN: pin,
      RequestParamNewPIN: pin
    }
    if puk.len > 0:
      payload[RequestParamNewPUK] = %* puk
    self.resumeFlow(payload)

  proc enterPin*(self: Service, pin: string) =
    if pin.len == 0:
      error "empty pin provided"
      return
    var payload = %* {
      RequestParamPIN: pin
    }
    self.resumeFlow(payload)

  proc storePuk*(self: Service, puk: string) =
    if puk.len == 0:
      error "empty puk provided"
      return
    var payload = %* {
      RequestParamOverwrite: true,
      RequestParamPUK: puk,
      RequestParamNewPUK: puk
    }
    self.resumeFlow(payload)

  proc enterPuk*(self: Service, puk: string) =
    if puk.len == 0:
      error "empty puk provided"
      return
    var payload = %* {
      RequestParamPUK: puk
    }
    self.resumeFlow(payload)

  proc storePairingCode*(self: Service, pairingCode: string) =
    if pairingCode.len == 0:
      error "empty pairing code provided"
      return
    var payload = %* {
      RequestParamOverwrite: true,
      RequestParamPairingPass: pairingCode,
      RequestParamNewPairingPass: pairingCode
    }
    self.resumeFlow(payload)

  proc storeSeedPhrase*(self: Service, seedPhraseLength: int, seedPhrase: string) =
    if seedPhrase.len == 0:
      error "empty seed phrase provided"
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

  proc reRunCurrentFlow*(self: Service) =
    let tmpFlow = self.currentFlow
    self.cancelCurrentFlow()
    self.currentFlow = tmpFlow
    self.startFlow(self.setPayloadForCurrentFlow)

  proc reRunCurrentFlowLater*(self: Service) =
    let tmpFlow = self.currentFlow
    self.cancelCurrentFlow()
    self.currentFlow = tmpFlow
    self.runTimer()