import ./core as status, ./types, ./contracts, ./settings, ./edn_helpers
import
  json, json_serialization, tables, chronicles, strutils, sequtils, httpclient,
  stint, libp2p/[multihash, multicodec, cid], eth/common/eth_types
from strutils import parseHexInt
from nimcrypto import fromHex

proc decodeContentHash*(value: string): string =
  if value == "":
    return ""

  # eg encoded sticker multihash cid:
  #  e30101701220eab9a8ef4eac6c3e5836a3768d8e04935c10c67d9a700436a0e53199e9b64d29
  #
  # The first 4 bytes (in hex) represent:
  # e3 = codec identifier "ipfs-ns" for content-hash
  # 01 = unused
  # 01 = CID version (effectively unused, as we will decode with CIDv0 regardless)
  # 70 = codec identifier "dag-pb"

  # ipfs-ns
  if value[0] & value[1] != "e3":
    warn "Could not decode sticker. It may still be valid, but requires a different codec to be used", hash=value
    return ""

  try:
    # dag-pb
    let codecStr = value[6] & value[7]
    let codec = parseHexInt(codecStr)

    # strip the info we no longer need
    var multiHashStr = value[8..<value.len]

    # The rest of the hash identifies the multihash algo, length, and digest
    # More info: https://multiformats.io/multihash/
    # 12 = identifies sha2-256 hash
    # 20 = multihash length = 32
    # ...rest = multihash digest
    let multiHash = MultiHash.init(nimcrypto.fromHex(multiHashStr)).get()
    result = $Cid.init(CIDv0, MultiCodec.codec(codec), multiHash)
    trace "Decoded sticker hash", cid=result
  except Exception as e:
    error "Error decoding sticker", hash=value, exception=e.msg
    result = ""


# Retrieves number of sticker packs owned by user
# See https://notes.status.im/Q-sQmQbpTOOWCQcYiXtf5g#Read-Sticker-Packs-owned-by-a-user
# for more details
proc getBalance*(address: EthAddress): int =
  let contract = contracts.getContract(Network.Mainnet, "sticker-pack")
  let payload = %* [{
      "to": $contract.address,
      "data": contract.methods["balanceOf"].encodeAbi(address)
    }, "latest"]
  
  let responseStr = status.callPrivateRPC("eth_call", payload)
  let response = Json.decode(responseStr, RpcResponse)
  if response.error != "":
    raise newException(RpcException, "Error getting stickers balance: " & response.error)
  result = fromHex[int](response.result)

# Gets number of sticker packs
proc getPackCount*(): int =
  let contract = contracts.getContract(Network.Mainnet, "stickers")
  let payload = %* [{
      "to": $contract.address,
      "data": contract.methods["packCount"].encodeAbi()
    }, "latest"]
  
  let responseStr = status.callPrivateRPC("eth_call", payload)
  let response = Json.decode(responseStr, RpcResponse)
  if response.error != "":
    raise newException(RpcException, "Error getting stickers balance: " & response.error)
  result = fromHex[int](response.result)

# Gets sticker pack data
proc getPackData*(id: int): StickerPack =
  let contract = contracts.getContract(Network.Mainnet, "stickers")
  let contractMethod = contract.methods["getPackData"]
  let payload = %* [{
      "to": $contract.address,
      "data": contractMethod.encodeAbi(id)
    }, "latest"]
  let responseStr = status.callPrivateRPC("eth_call", payload)
  let response = Json.decode(responseStr, RpcResponse)
  if response.error != "":
    raise newException(RpcException, "Error getting sticker pack data: " & response.error)

  let packData = contracts.decodeContractResponse[PackData](response.result)

  # contract response includes a contenthash, which needs to be decoded to reveal
  # an IPFS identifier. Once decoded, download the content from IPFS. This content
  # is in EDN format, ie https://ipfs.infura.io/ipfs/QmWVVLwVKCwkVNjYJrRzQWREVvEk917PhbHYAUhA1gECTM
  # and it also needs to be decoded in to a nim type
  var client = newHttpClient()
  let contentHash = contracts.toHex(packData.contentHash)
  let url = "https://ipfs.infura.io/ipfs/" & decodeContentHash(contentHash)
  var ednMeta = client.getContent(url)

  # decode the EDN content in to a StickerPack
  result = edn_helpers.decode[StickerPack](ednMeta)
  # EDN doesn't include a packId for each sticker, so add it here
  result.stickers.apply(proc(sticker: var Sticker) =
    sticker.packId = id)
  result.id = id
  result.price = packData.price

# Buys a sticker pack for user
# See https://notes.status.im/Q-sQmQbpTOOWCQcYiXtf5g#Buy-a-Sticker-Pack for more
# details
proc buyPack*(packId: int, address: EthAddress, price: int, password: string): string =
  let stickerMktContract = contracts.getContract(Network.Mainnet, "sticker-market")
  let sntContract = contracts.getContract(Network.Mainnet, "sticker-market")
  let buyTxAbiEncoded = stickerMktContract.methods["buyToken"].encodeAbi(packId, address, price)
  let approveAndCallAbiEncoded = sntContract.methods["approveAndCall"].encodeAbi($stickerMktContract.address, price, buyTxAbiEncoded)
  let payload = %* [{
      "from": $address,
      "to": $sntContract.address,
      "gas": 200000,
      "data": approveAndCallAbiEncoded
    }, "latest"]
  
  let responseStr = status.sendTransaction($payload, password)
  let response = Json.decode(responseStr, RpcResponse)
  if response.error != "":
    raise newException(RpcException, "Error getting stickers balance: " & response.error)
  result = response.result # should be a tx receipt

proc saveInstalledStickerPacks*(installedStickerPacks: Table[int, StickerPack]) =
  let json = %* {}
  for packId, pack in installedStickerPacks.pairs:
    json[$packId] = %(pack)
  discard settings.saveSettings("stickers/packs-installed", $json)

proc saveRecentStickers*(stickers: seq[Sticker]) =
  discard settings.saveSettings("stickers/recent-stickers", %(stickers.mapIt($it.hash)))

proc getInstalledStickerPacks*(): Table[int, StickerPack] =
  let setting = settings.getSetting[string]("stickers/packs-installed", "{}").parseJson
  result = initTable[int, StickerPack]()
  for i in setting.keys:
    let packId = parseInt(i)
    result[packId] = Json.decode($(setting[i]), StickerPack)
    result[packId].stickers.apply(proc(sticker: var Sticker) =
      sticker.packId = packId)

proc getPackIdForSticker*(packs: Table[int, StickerPack], hash: string): int =
  for packId, pack in packs.pairs:
    if pack.stickers.any(proc(sticker: Sticker): bool = return sticker.hash == hash):
      return packId
  return 0

proc getRecentStickers*(): seq[Sticker] =
  # TODO: this should be a custom `readValue` implementation of nim-json-serialization
  let settings = settings.getSetting[seq[string]]("stickers/recent-stickers", @[])
  let installedStickers = getInstalledStickerPacks()
  result = newSeq[Sticker]()
  for hash in settings:
    # pack id is not returned from status-go settings, populate here
    let packId = getPackIdForSticker(installedStickers, $hash)
    # .insert instead of .add to effectively reverse the order stickers because
    # stickers are re-reversed when added to the view due to the nature of
    # inserting recent stickers at the front of the list
    result.insert(Sticker(hash: $hash, packId: packId), 0)
