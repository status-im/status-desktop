import json
import base

import ../../../../app_service/service/wallet_account/[keycard_dto]

type WakuBackedUpKeycardsSignal* = ref object of Signal
  keycards*: seq[KeycardDto]

proc fromEvent*(T: type WakuBackedUpKeycardsSignal, event: JsonNode): WakuBackedUpKeycardsSignal =
  result = WakuBackedUpKeycardsSignal()

  let e = event["event"]
  if e.contains("backedUpKeycards"):
    for jsonKc in e["backedUpKeycards"]:
      result.keycards.add(jsonKc.toKeycardDto())