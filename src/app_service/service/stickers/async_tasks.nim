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
  InstallStickerPackTaskArg = ref object of QObjectTaskArg
    packId*: string
    chainId*: int
  
  AsyncGetRecentStickersTaskArg* = ref object of QObjectTaskArg
  AsyncGetInstalledStickerPacksTaskArg* = ref object of QObjectTaskArg

const asyncGetRecentStickersTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetRecentStickersTaskArg](argEncoded)
  let response = status_stickers.recent()
  arg.finish(response)

const asyncGetInstalledStickerPacksTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetInstalledStickerPacksTaskArg](argEncoded)
  let response = status_stickers.installed()
  arg.finish(response)

proc getMarketStickerPacks*(chainId: int): 
    tuple[stickers: Table[string, StickerPackDto], error: string] =
  result = (initTable[string, StickerPackDto](), "")
  try:
    let marketResponse = status_stickers.market(chainId)
    if marketResponse.result.kind != JArray: return
    for currItem in marketResponse.result.items():
      let stickerPack = currItem.toStickerPackDto()
      result.stickers[stickerPack.id] = stickerPack
  except RpcException:
    error "Error in getMarketStickerPacks", message = getCurrentExceptionMsg()
    result.error = getCurrentExceptionMsg()

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
  let (marketStickerPacks, error) = getMarketStickerPacks(arg.chainId)
  var packs: seq[StickerPackDto] = @[]
  for packId, stickerPack in marketStickerPacks.pairs:
    packs.add(stickerPack)
  let tpl: tuple[packs: seq[StickerPackDto], error: string] = (packs, error)
  arg.finish(tpl)

const installStickerPackTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[InstallStickerPackTaskArg](argEncoded)

  var installed = false
  try:
    let installResponse = status_stickers.install(arg.chainId, arg.packId)
    if installResponse.error == nil:
      installed = true
    else:
      let err = Json.decode($installResponse.error, RpcError)
      error "Error installing stickers", message = err.message
  except RpcException:
    error "Error installing stickers", message = getCurrentExceptionMsg()
  let tpl: tuple[packId: string, installed: bool] = (arg.packId, installed)
  arg.finish(tpl)
