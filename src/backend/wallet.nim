import json, chronicles
import core, utils
import response_type

export response_type

logScope:
  topics = "rpc-wallet"

proc getPendingTransactions*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = core.callPrivateRPC("wallet_getPendingTransactions", payload)