import core
import json

proc saveSettings*(key: string, value: string): string =
  callPrivateRPC("settings_saveSetting", %* [
    key, $value
  ])

proc getSettings*(): string =
  callPrivateRPC("settings_getSettings")
# TODO: return an Table/Object instead of string
