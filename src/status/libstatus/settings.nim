import json
import core

proc saveSettings*(key: string, value: string): string =
  callPrivateRPC("settings_saveSetting", %* [
    key, $value
  ])

proc getSettings*(): string =
  callPrivateRPC("settings_getSettings")
# TODO: return an Table/Object instead of string

proc getWeb3ClientVersion*(): string =
  parseJson(callPrivateRPC("web3_clientVersion"))["result"].getStr
