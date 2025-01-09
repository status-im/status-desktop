import NimQml, json, chronicles, strutils
# import keycard_go
import app/global/global_singleton
import app/core/eventemitter
import app/core/tasks/[qt, threadpool]
include ../../common/mnemonics
include async_tasks

logScope:
  topics = "keycardV2-service"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool

  proc init*(self: Service) =
    discard

  proc receiveKeycardSignal(self: Service, signal: string) {.slot.} =
    var jsonSignal: JsonNode
    try:
      jsonSignal = signal.parseJson
    except:
      error "Invalid signal received", data = signal
      return

    debug "keycard_signal", response = signal

  proc buildSeedPhrasesFromIndexes*(
      self: Service, seedPhraseIndexes: seq[int]
  ): seq[string] =
    var seedPhrase: seq[string]
    for ind in seedPhraseIndexes:
      seedPhrase.add(englishWords[ind])
    return seedPhrase

  proc getMnemonicIndexes*(self: Service): seq[int] =
    # TODO call lib to get mnemonic indexes
    echo "Get mnemonic indexes"
    return @[]

  proc setPin*(self: Service, pin: string) =
    let arg = AsyncSetPinTaskArg(
      tptr: asyncSetPinTask,
      vptr: cast[uint](self.vptr),
      slot: "onAsyncSetPinResponse",
      pin: pin,
    )
    self.threadpool.start(arg)

  proc onAsyncSetPinResponse*(self: Service, response: string) {.slot.} =
    try:
      let rpcResponseObj = response.parseJson
      echo "Set the pin ", response

      if (
        rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != ""
      ):
        raise newException(CatchableError, rpcResponseObj{"error"}.getStr)
    except Exception as e:
      error "error set pin: ", msg = e.msg
