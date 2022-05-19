include ../../common/json_utils
include ../../../app/core/tasks/common

type
  EstimateTaskArg = ref object of QObjectTaskArg
    chainId*: int
    packId*: string
    fromAddress*: string
    uuid*: string
  ObtainMarketStickerPacksTaskArg = ref object of QObjectTaskArg
    chainId*: int
    running*: ByteAddress # pointer to threadpool's `.running` Atomic[bool]

proc getMarketStickerPacks*(running: var Atomic[bool], chainId: int): Table[string, StickerPackDto] =
  result = initTable[string, StickerPackDto]()
  try:
    let marketResponse = status_stickers.market(chainId)
    if marketResponse.result.kind != JArray: return
    for currItem in marketResponse.result.items():
      let stickerPack = currItem.toStickerPackDto()
      result[stickerPack.id] = stickerPack
  except RpcException:
    error "Error in getMarketStickerPacks", message = getCurrentExceptionMsg()
    result = initTable[string, StickerPackDto]()


# The pragmas `{.gcsafe, nimcall.}` in this context do not force the compiler
# to accept unsafe code, rather they work in conjunction with the proc
# signature for `type Task` in tasks/common.nim to ensure that the proc really
# is gcsafe and that a helpful error message is displayed
const estimateTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[EstimateTaskArg](argEncoded)
  var estimate = 325000
  try:
    let estimateResponse = status_stickers.buyEstimate(arg.chainId, parseAddress(arg.fromAddress), arg.packId)
    estimate = estimateResponse.result.getInt + 1000
  except ValueError:
    # TODO: notify the UI that the trx is likely to fail
    error "Error in buyPack estimate", message = getCurrentExceptionMsg()
  except RpcException:
    error "Error in buyPack estimate", message = getCurrentExceptionMsg()
  let tpl: tuple[estimate: int, uuid: string] = (estimate, arg.uuid)
  arg.finish(tpl)

const obtainMarketStickerPacksTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[ObtainMarketStickerPacksTaskArg](argEncoded)
  var running = cast[ptr Atomic[bool]](arg.running)
  let marketStickerPacks = getMarketStickerPacks(running[], arg.chainId)
  var packs: seq[StickerPackDto] = @[]
  for packId, stickerPack in marketStickerPacks.pairs:
    packs.add(stickerPack)
  arg.finish(%*(packs))