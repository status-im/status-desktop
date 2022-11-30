import json, tables
import base

import ../../../../app_service/service/settings/dto/[settings]

type WakuBackedUpSettingsSignal* = ref object of Signal
  backedUpSettings*: SettingsDto

proc fromEvent*(T: type WakuBackedUpSettingsSignal, event: JsonNode): WakuBackedUpSettingsSignal =
  result = WakuBackedUpSettingsSignal()
  
  if event["event"]{"backedUpSettings"} != nil:
    result.backedUpSettings = event["event"]["backedUpSettings"].toSettingsDto()