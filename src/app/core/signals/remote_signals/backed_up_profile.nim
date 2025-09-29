import json, tables
import base

import ../../../../app_service/service/accounts/dto/[accounts]

type BackedUpProfileSignal* = ref object of Signal
  backedUpProfile*: WakuBackedUpProfileDto

proc fromEvent*(T: type BackedUpProfileSignal, event: JsonNode): BackedUpProfileSignal =
  result = BackedUpProfileSignal()
  result.signalType = SignalType.BackedUpProfile

  let e = event["event"]
  if e.contains("backedUpProfile"):
    result.backedUpProfile = e["backedUpProfile"].toWakuBackedUpProfileDto()
