include ../../common/json_utils
include ../../../app/core/tasks/common

# type
#   EstimateTaskArg = ref object of QObjectTaskArg
#     packId: int
#     address: string
#     price: string
#     uuid: string
#   ObtainAvailableStickerPacksTaskArg = ref object of QObjectTaskArg
#     running*: ByteAddress # pointer to threadpool's `.running` Atomic[bool]
#     contract*: ContractDto

type
  # EstimateTaskArg = ref object of QObjectTaskArg
  #   packId: int
  #   address: string
  #   price: string
  #   uuid: string
  EstimateTaskArg = ref object of QObjectTaskArg
    data:  JsonNode
    uuid: string
    # tx: TransactionDataDto
    # approveAndCall: ApproveAndCall[100]
    # sntContract: Erc20ContractDto
  ObtainAvailableStickerPacksTaskArg = ref object of QObjectTaskArg
    running*: ByteAddress # pointer to threadpool's `.running` Atomic[bool]
    contract*: ContractDto
    packCountMethod*: MethodDto
    getPackDataMethod*: MethodDto


proc getPackCount*(contract: ContractDto, packCountMethod: MethodDto): RpcResponse[JsonNode] =
  status_stickers.getPackCount($contract.address, packCountMethod.encodeAbi())

proc getPackData*(contract: ContractDto, getPackDataMethod: MethodDto, id: Stuint[256], running: var Atomic[bool]): StickerPackDto =
  let secureSSLContext = newContext()
  let client = newHttpClient(sslContext = secureSSLContext)
  try:
    let
      contractMethod = getPackDataMethod
      getPackData = GetPackData(packId: id)
      payload = %* [{
        "to": $contract.address,
        "data": contractMethod.encodeAbi(getPackData)
        }, "latest"]
    let response = eth.doEthCall(payload)
    if not response.error.isNil:
      raise newException(RpcException, "Error getting sticker pack data: " & response.error.message)

    let packData = decodeContractResponse[PackData](response.result.getStr)

    if not running.load():
      trace "Sticker pack task interrupted, exiting sticker pack loading"
      return

    # contract response includes a contenthash, which needs to be decoded to reveal
    # an IPFS identifier. Once decoded, download the content from IPFS. This content
    # is in EDN format, ie https://ipfs.infura.io/ipfs/QmWVVLwVKCwkVNjYJrRzQWREVvEk917PhbHYAUhA1gECTM
    # and it also needs to be decoded in to a nim type
    let contentHash = toHex(packData.contentHash)
    let url = "https://ipfs.infura.io/ipfs/" & decodeContentHash(contentHash)
    var ednMeta = client.getContent(url)

    # decode the EDN content in to a StickerPackDto
    result = edn_helper.ednDecode[StickerPackDto](ednMeta)
    # EDN doesn't include a packId for each sticker, so add it here
    result.stickers.apply(proc(sticker: var StickerDto) =
      sticker.packId = truncate(id, int))
    result.id = truncate(id, int)
    result.price = packData.price
  except Exception as e:
    raise newException(RpcException, "Error getting sticker pack data: " & e.msg)
  finally:
    client.close()

proc getAvailableStickerPacks*(
    contract: ContractDto,
    getPackCount: MethodDto,
    getPackDataMethod: MethodDto,
    running: var Atomic[bool]
    ): Table[int, StickerPackDto] =
  
  var availableStickerPacks = initTable[int, StickerPackDto]()
  try:
    let numPacksReponse = getPackCount(contract, getPackCount)

    var numPacks = 0
    if numPacksReponse.result.getStr != "0x":
      numPacks = parseHexInt(numPacksReponse.result.getStr)

    for i in 0..<numPacks:
      if not running.load():
        trace "Sticker pack task interrupted, exiting sticker pack loading"
        break
      try:
        let stickerPack = getPackData(contract, getPackDataMethod, i.u256, running)
        availableStickerPacks[stickerPack.id] = stickerPack
      except:
        continue
    result = availableStickerPacks
  except RpcException:
    error "Error in getAvailableStickerPacks", message = getCurrentExceptionMsg()
    result = initTable[int, StickerPackDto]()


# The pragmas `{.gcsafe, nimcall.}` in this context do not force the compiler
# to accept unsafe code, rather they work in conjunction with the proc
# signature for `type Task` in tasks/common.nim to ensure that the proc really
# is gcsafe and that a helpful error message is displayed
const estimateTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[EstimateTaskArg](argEncoded)
  var success: bool

  let response = eth.estimateGas(arg.data)
  var estimate = 325000
  if $response.result != "0x":
    estimate = parseHexInt(response.result.getStr)
  let tpl: tuple[estimate: int, uuid: string] = (estimate, arg.uuid)
  arg.finish(tpl)

const obtainAvailableStickerPacksTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[ObtainAvailableStickerPacksTaskArg](argEncoded)
  var running = cast[ptr Atomic[bool]](arg.running)
  let availableStickerPacks = getAvailableStickerPacks(
    arg.contract,
    arg.packCountMethod,
    arg.getPackDataMethod,
    running[])
  var packs: seq[StickerPackDto] = @[]
  for packId, stickerPack in availableStickerPacks.pairs:
    packs.add(stickerPack)
  arg.finish(%*(packs))
