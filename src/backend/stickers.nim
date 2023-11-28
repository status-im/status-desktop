import json
import ./eth
import ./core, ./response_type
import web3/[ethtypes, conversions]

proc market*(chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId]
  return core.callPrivateRPC("stickers_market", payload)

proc pending*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("stickers_pending", payload)

proc addPending*(chainId: int, packId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, packId]
  result = core.callPrivateRPC("stickers_addPending", payload)

proc installed*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("stickers_installed", payload)

proc install*(chainId: int, packId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, packId]
  return core.callPrivateRPC("stickers_install", payload)

proc uninstall*(packId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [packId]
  return core.callPrivateRPC("stickers_uninstall", payload)

proc recent*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("stickers_recent", payload)

proc addRecent*(packId: string, hash: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [packId, hash]
  return core.callPrivateRPC("stickers_addRecent", payload)

proc stickerMarketAddress*(chainId: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId]
  return core.callPrivateRPC("stickers_stickerMarketAddress", payload)

proc buyEstimate*(chainId: int, fromAccount: Address, packId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, $fromAccount, packId]
  return core.callPrivateRPC("stickers_buyEstimate", payload)

proc buy*(chainId: int, txData: JsonNode, packId: string, hashedPassword: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, txData, packID, hashedPassword]
  return core.callPrivateRPC("stickers_buy", payload)

proc clearRecentStickers*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  return core.callPrivateRPC("stickers_clearRecent", payload)

proc removePending*(packId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [packId]
  return core.callPrivateRPC("stickers_removePending", payload)

proc prepareTxForBuyingStickers*(chainId: int, address: string, packId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [chainId, address, packId]
  result = core.callPrivateRPC("stickers_buyPrepareTx", payload)
