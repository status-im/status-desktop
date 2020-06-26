import core, ./types
import json, tables
import json_serialization

proc saveSettings*(key: string, value: string | JsonNode): string =
  callPrivateRPC("settings_saveSetting", %* [
    key, value
  ])

proc getWeb3ClientVersion*(): string =
  parseJson(callPrivateRPC("web3_clientVersion"))["result"].getStr

proc getSettings*(): JsonNode =
  callPrivateRPC("settings_getSettings").parseJSON()["result"]
  # TODO: return an Table/Object instead


proc getSetting*[T](name: string, defaultValue: T): T =
  let settings: JsonNode = getSettings()
  if not settings.contains(name):
    return defaultValue
  result = Json.decode($settings{name}, T)
