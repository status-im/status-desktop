import json, tables
import base

import ../../../../app_service/service/accounts/dto/[accounts]

type WakuBackedUpProfileSignal* = ref object of Signal
  backedUpProfile*: WakuBackedUpProfileDto

proc fromEvent*(T: type WakuBackedUpProfileSignal, event: JsonNode): WakuBackedUpProfileSignal =
  result = WakuBackedUpProfileSignal()
  
  let e = event["event"]
  if e.contains("backedUpProfile"):
    result.backedUpProfile = e["backedUpProfile"].toWakuBackedUpProfileDto()  
