import core, ./types, ../../signals/types as statusgo_types
import json, tables
import json_serialization

var settings: JsonNode = %*{}
var dirty: bool = true

proc saveSettings*(key: string, value: string | JsonNode): StatusGoError =
  let response = callPrivateRPC("settings_saveSetting", %* [
    key, value
  ])
  try:
    result = Json.decode($response, StatusGoError)
  except:
    dirty = true

proc getWeb3ClientVersion*(): string =
  parseJson(callPrivateRPC("web3_clientVersion"))["result"].getStr

proc getSettings*(useCached: bool = true): JsonNode =
  if useCached and not dirty:
    return settings
  settings = callPrivateRPC("settings_getSettings").parseJSON()["result"]
  dirty = false
  result = settings

proc getSetting*[T](name: string, defaultValue: T, useCached: bool = true): T =
  let settings: JsonNode = getSettings(useCached)
  if not settings.contains(name):
    return defaultValue
  result = Json.decode($settings{name}, T)

proc getSetting*[T](name: string, useCached: bool = true): T =
  let settings: JsonNode = getSettings(useCached)
  if not settings.contains(name):
    return default(type(T))
  result = Json.decode($settings{name}, T)
