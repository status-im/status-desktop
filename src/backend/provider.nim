import json, json_serialization, chronicles
import ./utils
import ./core

logScope:
  topics = "provider"

proc providerRequest*(requestType: string, message: string): RpcResponse[JsonNode] =
  let jsonMessage = message.parseJson
  if requestType == "web3-send-async-read-only" and jsonMessage.hasKey("payload") and jsonMessage["payload"].hasKey("password"):
      jsonMessage["payload"]["password"] = newJString(hashPassword(jsonMessage["payload"]["password"].getStr()))
  callPrivateRPC("provider_processRequest", %*[requestType, jsonMessage])
