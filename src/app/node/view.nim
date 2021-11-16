import NimQml, chronicles, strutils, json
import status/[node, settings, accounts]
import status/types/[setting]
import ../core/[main]
import status/signals/[stats]
import ../core/tasks/[qt, threadpool]

logScope:
  topics = "node-view"

type
  BloomBitsSetTaskArg = ref object of QObjectTaskArg
    bitsSet: int

const bloomBitsSetTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let
    arg = decode[BloomBitsSetTaskArg](argEncoded)
    output = getBloomFilterBitsSet(nil)
  arg.finish(output)

proc bloomFiltersBitsSet[T](self: T, slot: string) =
  let arg = BloomBitsSetTaskArg(
    tptr: cast[ByteAddress](bloomBitsSetTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot
  )
  self.appService.threadpool.start(arg)


QtObject:
  type NodeView* = ref object of QObject
    appService: AppService
    callResult: string
    lastMessage*: string
    wakuBloomFilterMode*: bool
    fullNode*: bool
    stats*: Stats
    peerSize: int
    bloomBitsSet: int
    wakuV2LightClient: bool

  proc setup(self: NodeView) =
    self.QObject.setup

  proc newNodeView*(appService: AppService): NodeView =
    new(result)
    result.appService = appService
    result.callResult = "Use this tool to call JSONRPC methods"
    result.lastMessage = ""
    result.wakuBloomFilterMode = false
    result.fullNode = false
    result.wakuV2LightClient = false
    result.setup

  proc delete*(self: NodeView) =
    self.QObject.delete

  proc callResult*(self: NodeView): string {.slot.} =
    result = self.callResult

  proc callResultChanged*(self: NodeView, callResult: string) {.signal.}

  proc setCallResult(self: NodeView, callResult: string) {.slot.} =
    if self.callResult == callResult: return
    self.callResult = callResult
    self.callResultChanged(callResult)

  proc `callResult=`*(self: NodeView, callResult: string) = self.setCallResult(callResult)

  QtProperty[string] callResult:
    read = callResult
    write = setCallResult
    notify = callResultChanged

  proc onSend*(self: NodeView, inputJSON: string) {.slot.} =
    self.setCallResult(self.appService.status.node.sendRPCMessageRaw(inputJSON))
    echo "Done!: ", self.callResult

  proc onMessage*(self: NodeView, message: string) {.slot.} =
    self.setCallResult(message)
    echo "Received message: ", message

  proc lastMessage*(self: NodeView): string {.slot.} =
    result = self.lastMessage

  proc receivedMessage*(self: NodeView, lastMessage: string) {.signal.}

  proc setLastMessage*(self: NodeView, lastMessage: string) {.slot.} =
    self.lastMessage = lastMessage
    self.receivedMessage(lastMessage)

  QtProperty[string] lastMessage:
    read = lastMessage
    write = setLastMessage
    notify = receivedMessage

  proc initialized(self: NodeView) {.signal.}

  proc getWakuBloomFilterMode*(self: NodeView): bool {.slot.} =
    result = self.wakuBloomFilterMode

  proc getBloomLevel*(self: NodeView): string {.slot.} =
    if self.wakuBloomFilterMode and not self.fullNode:
      return "normal"
    if self.wakuBloomFilterMode and self.fullNode:
      return "full"
    return "light"

  QtProperty[bool] wakuBloomFilterMode:
    read = getWakuBloomFilterMode
    notify = initialized

  QtProperty[string] bloomLevel:
    read = getBloomLevel
    notify = initialized

  proc setWakuBloomFilterMode*(self: NodeView, bloomFilterMode: bool) {.slot.} =
    let statusGoResult = self.appService.status.settings.setBloomFilterMode(bloomFilterMode)
    if statusGoResult.error != "":
      error "Error saving updated node config", msg=statusGoResult.error
    quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

  proc init*(self: NodeView) {.slot.} =
    let nodeConfig = self.appService.status.settings.getNodeConfig()
    self.wakuBloomFilterMode = self.appService.status.settings.getSetting[:bool](Setting.WakuBloomFilterMode)
    self.fullNode = nodeConfig["WakuConfig"]["FullNode"].getBool()
    self.wakuV2LightClient = nodeConfig["WakuV2Config"]{"LightClient"}.getBool()
    self.initialized()

  proc wakuVersion*(self: NodeView): int {.slot.} =
    var fleetStr = self.appService.status.settings.getSetting[:string](Setting.Fleet)
    let fleet = parseEnum[Fleet](fleetStr)
    let isWakuV2 = if fleet == WakuV2Prod or fleet == WakuV2Test: true else: false
    if isWakuV2: return 2
    return 1

  proc setBloomLevel*(self: NodeView, level: string) {.slot.} =
    var FullNode = false
    var BloomFilterMode = false
    case level:
    of "light":
      BloomFilterMode = false
      FullNode = false
    of "full":
      BloomFilterMode = true
      FullNode = true
    else:
      BloomFilterMode = true
      FullNode = false

    let statusGoResult = self.appService.status.settings.setBloomLevel(BloomFilterMode, FullNode)
    if statusGoResult.error != "":
      error "Error saving updated node config", msg=statusGoResult.error
    quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported

  proc statsChanged*(self: NodeView) {.signal.}

  proc setStats*(self: NodeView, stats: Stats) =
    self.stats = stats
    self.statsChanged()

  proc fetchBitsSet*(self: NodeView) =
    self.bloomFiltersBitsSet("bitsSet")

  proc getBloomBitsSet(self: NodeView): int {.slot.} =
    self.bloomBitsSet

  proc bloomBitsSetChanged(self: NodeView) {.signal.}

  proc bitsSet*(self: NodeView, bitsSet: string) {.slot.} =
    self.bloomBitsSet = parseInt(bitsSet)
    self.bloomBitsSetChanged();

  QtProperty[int] bloomBits:
    read = getBloomBitsSet
    notify = bloomBitsSetChanged

  proc uploadRate*(self: NodeView): string {.slot.} = $self.stats.uploadRate

  QtProperty[string] uploadRate:
    read = uploadRate
    notify = statsChanged

  proc downloadRate*(self: NodeView): string {.slot.} = $self.stats.downloadRate

  QtProperty[string] downloadRate:
    read = downloadRate
    notify = statsChanged

  proc getPeerSize*(self: NodeView): int {.slot.} = self.peerSize

  proc peerSizeChanged*(self: NodeView, value: int) {.signal.}

  proc setPeerSize*(self: NodeView, value: int) {.slot.} =
    self.peerSize = value
    self.peerSizeChanged(value)

  proc resetPeers*(self: NodeView) {.slot.} =
    self.setPeerSize(0)

  QtProperty[int] peerSize:
    read = getPeerSize
    notify = peerSizeChanged

  proc log*(self: NodeView, logContent: string) {.signal.}
  
  proc getWakuV2LightClient(self: NodeView): bool {.slot.} = self.wakuV2LightClient

  QtProperty[bool] WakuV2LightClient:
    read = getWakuV2LightClient
    notify = initialized

  proc setWakuV2LightClient*(self: NodeView, enabled: bool) {.slot.} =
    let statusGoResult = self.appService.status.settings.setV2LightMode(enabled)
    if statusGoResult.error != "":
      error "Error saving updated node config", msg=statusGoResult.error
    else:
      quit(QuitSuccess) # quits the app TODO: change this to logout instead when supported
