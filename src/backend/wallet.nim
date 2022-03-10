import json, chronicles
import core, utils
import response_type

export response_type

logScope:
  topics = "rpc-wallet"

proc getPendingTransactions*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []
  result = core.callPrivateRPC("wallet_getPendingTransactions", payload)

proc generateAccount*(password, name, color, emoji: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [hashPassword(password), name, color, emoji]
  return core.callPrivateRPC("accounts_generateAccount", payload)

proc addAccountWithMnemonic*(mnemonic, password, name, color, emoji: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [mnemonic, hashPassword(password), name, color, emoji]
  return core.callPrivateRPC("accounts_addAccountWithMnemonic", payload)

proc addAccountWithPrivateKey*(privateKey, password, name, color, emoji: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [privateKey, hashPassword(password), name, color, emoji]
  return core.callPrivateRPC("accounts_addAccountWithPrivateKey", payload)

proc addAccountWatch*(address, name, color, emoji: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [address, name, color, emoji]
  return core.callPrivateRPC("accounts_addAccountWatch", payload)
