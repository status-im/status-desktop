import json, tables
import base

import ../../../../app_service/service/settings/dto/[settings]

type WakuBackedUpSettingsSignal* = ref object of Signal
  backedUpSettings*: SettingsDto

proc fromEvent*(T: type WakuBackedUpSettingsSignal, event: JsonNode): WakuBackedUpSettingsSignal =
  result = WakuBackedUpSettingsSignal()
  
  let e = event["event"]
  if e.contains("backedUpSettings"):
    result.backedUpSettings = e["backedUpSettings"].toSettingsDto()  
