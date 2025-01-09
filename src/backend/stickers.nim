import json
import ./eth
import ./core, ./response_type

proc market*(chainId: int): RpcResponse[JsonNode] =
  let payload = %*[chainId]
  return core.callPrivateRPC("stickers_market", payload)

proc pending*(): RpcResponse[JsonNode] =
  let payload = %*[]
  return core.callPrivateRPC("stickers_pending", payload)

proc installed*(): RpcResponse[JsonNode] =
  let payload = %*[]
  return core.callPrivateRPC("stickers_installed", payload)

proc install*(chainId: int, packId: string): RpcResponse[JsonNode] =
  let payload = %*[chainId, packId]
  return core.callPrivateRPC("stickers_install", payload)

proc uninstall*(packId: string): RpcResponse[JsonNode] =
  let payload = %*[packId]
  return core.callPrivateRPC("stickers_uninstall", payload)

proc recent*(): RpcResponse[JsonNode] =
  let payload = %*[]
  return core.callPrivateRPC("stickers_recent", payload)

proc addRecent*(packId: string, hash: string): RpcResponse[JsonNode] =
  let payload = %*[packId, hash]
  return core.callPrivateRPC("stickers_addRecent", payload)

proc stickerMarketAddress*(chainId: int): RpcResponse[JsonNode] =
  let payload = %*[chainId]
  return core.callPrivateRPC("stickers_stickerMarketAddress", payload)

proc clearRecentStickers*(): RpcResponse[JsonNode] =
  let payload = %*[]
  return core.callPrivateRPC("stickers_clearRecent", payload)

proc removePending*(packId: string): RpcResponse[JsonNode] =
  let payload = %*[packId]
  return core.callPrivateRPC("stickers_removePending", payload)
