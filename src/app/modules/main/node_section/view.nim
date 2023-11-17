import NimQml, json, strutils
import io_interface
import ../../../core/signals/types


QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      callResult: string
      lastMessage*: string
      stats*: Stats
      peerSize: int

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.callResult = "Use this tool to call JSONRPC methods"
    result.lastMessage = ""

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc callResult*(self: View): string {.slot.} =
    result = self.callResult

  proc callResultChanged*(self: View, callResult: string) {.signal.}

  proc setCallResult(self: View, callResult: string) =
    echo $callResult # Added so we can copy paste response from terminal
    if self.callResult == callResult: return
    self.callResult = callResult
    self.callResultChanged(callResult)

  QtProperty[string] callResult:
    read = callResult
    notify = callResultChanged

  proc onSend*(self: View, inputJSON: string) {.slot.} =
    self.setCallResult(self.delegate.sendRPCMessageRaw(inputJSON))

  proc onMessage*(self: View, message: string) {.slot.} =
    self.setCallResult(message)

  proc receivedMessage*(self: View, lastMessage: string) {.signal.}

  proc getLastMessage*(self: View): string {.slot.} =
    return self.lastMessage

  proc setLastMessage*(self: View, lastMessage: string) =
    self.lastMessage = lastMessage
    self.receivedMessage(lastMessage)

  QtProperty[string] lastMessage:
    read = getLastMessage
    notify = receivedMessage

  proc getWakuBloomFilterMode*(self: View): bool {.slot.} =
    return self.delegate.getWakuBloomFilterMode()

  proc getBloomLevel*(self: View): string {.slot.} =
    return self.delegate.getBloomLevel()

  QtProperty[bool] wakuBloomFilterMode:
    read = getWakuBloomFilterMode
    notify = initialized

  QtProperty[string] bloomLevel:
    read = getBloomLevel
    notify = initialized

  proc setWakuBloomFilterMode*(self: View, bloomFilterMode: bool) {.slot.} =
    self.delegate.setBloomFilterMode(bloomFilterMode)

  proc wakuVersion*(self: View): int {.slot.} =
    return self.delegate.getWakuVersion()

  proc setBloomLevel*(self: View, level: string) {.slot.} =
    self.delegate.setBloomLevel(level)

  proc statsChanged*(self: View) {.signal.}

  proc setStats*(self: View, stats: Stats) =
    self.stats = stats
    self.statsChanged()

  proc uploadRate*(self: View): string {.slot.} = $self.stats.uploadRate

  QtProperty[string] uploadRate:
    read = uploadRate
    notify = statsChanged

  proc downloadRate*(self: View): string {.slot.} = $self.stats.downloadRate

  QtProperty[string] downloadRate:
    read = downloadRate
    notify = statsChanged

  proc getPeerSize*(self: View): int {.slot.} = self.peerSize

  proc peerSizeChanged*(self: View, value: int) {.signal.}

  proc setPeerSize*(self: View, value: int) {.slot.} =
    self.peerSize = value
    self.peerSizeChanged(value)

  proc resetPeers*(self: View) {.slot.} =
    self.setPeerSize(0)

  QtProperty[int] peerSize:
    read = getPeerSize
    notify = peerSizeChanged

  proc log*(self: View, logContent: string) {.signal.}

  proc getWakuV2LightClient(self: View): bool {.slot.} = self.delegate.isV2LightMode()

  QtProperty[bool] WakuV2LightClient:
    read = getWakuV2LightClient
    notify = initialized

  proc setWakuV2LightClient*(self: View, enabled: bool) {.slot.} =
    self.delegate.setV2LightMode(enabled)
