import core
import json

proc saveSettings*(key: string, value: string): string =
  callPrivateRPC("settings_saveSetting", %* [
    key, $value
  ])

proc getWeb3ClientVersion*(): string =
  parseJson(callPrivateRPC("web3_clientVersion"))["result"].getStr

proc getSettings*(): JsonNode =
  callPrivateRPC("settings_getSettings").parseJSON()["result"]
  # TODO: return an Table/Object instead

proc getSetting*(name: string): string =
  let settings: JsonNode = getSettings()
  result = settings{name}.getStr
