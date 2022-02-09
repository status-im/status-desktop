import json, chronicles
import core, utils
import response_type

export response_type

logScope:
  topics = "mailserver"

proc saveMailserver*(id: string, name: string, enode: string, fleet: string):
  RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [{
      "id": id,
      "name": name,
      "address": enode,
      "fleet": fleet
    }]
  result = core.callPrivateRPC("mailservers_addMailserver", payload)

proc getMailservers*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  result = core.callPrivateRPC("mailservers_getMailservers")

proc requestAllHistoricMessages*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = core.callPrivateRPC("requestAllHistoricMessages".prefix, payload)
  info "requestAllHistoricMessages", topics="mailserver-interaction", rpc_method="mailservers_requestAllHistoricMessages"

proc syncChatFromSyncedFrom*(chatId: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[chatId]
  result = core.callPrivateRPC("syncChatFromSyncedFrom".prefix, payload)
  info "syncChatFromSyncedFrom", topics="mailserver-interaction", rpc_method="wakuext_syncChatFromSyncedFrom", chatId, result

proc fillGaps*(chatId: string, messageIds: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %*[chatId, messageIds]
  result = core.callPrivateRPC("fillGaps".prefix, payload)
  info "fillGaps", topics="mailserver-interaction", rpc_method="wakuext_fillGaps", chatId, messageIds, result

proc disconnectActiveMailserver*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = core.callPrivateRPC("disconnectActiveMailserver".prefix, payload)
  info "delete", topics="mailserver-interaction", rpc_method="wakuext_disconnectActiveMailserver", result
