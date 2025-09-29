import json, tables
import base

import ../../../../app_service/service/settings/dto/[settings]

type BackedUpSettingsSignal* = ref object of Signal
  backedUpSettingField*: SettingsFieldDto

proc fromEvent*(T: type BackedUpSettingsSignal, event: JsonNode): BackedUpSettingsSignal =
  result = BackedUpSettingsSignal()
  result.signalType = SignalType.BackedUpSettings

  let e = event["event"]
  if e.contains("backedUpSettings"):
    result.backedUpSettingField = e["backedUpSettings"].toSettingsFieldDto()
