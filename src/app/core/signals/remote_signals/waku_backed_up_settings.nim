import json, tables
import base

import ../../../../app_service/service/settings/dto/[settings]

type WakuBackedUpSettingsSignal* = ref object of Signal
  backedUpSettingField*: SettingsFieldDto

proc fromEvent*(T: type WakuBackedUpSettingsSignal, event: JsonNode): WakuBackedUpSettingsSignal =
  result = WakuBackedUpSettingsSignal()
  result.signalType = SignalType.WakuBackedUpSettings

  let e = event["event"]
  if e.contains("backedUpSettings"):
    result.backedUpSettingField = e["backedUpSettings"].toSettingsFieldDto()
