import json
import base

import ../../../../app_service/service/wallet_account/[keycard_dto]

type WakuBackedUpKeycardsSignal* = ref object of Signal
  keycards*: seq[KeycardDto]

proc fromEvent*(T: type WakuBackedUpKeycardsSignal, event: JsonNode): WakuBackedUpKeycardsSignal =
  result = WakuBackedUpKeycardsSignal()

  if event["event"]{"backedUpKeycards"} != nil:
    for jsonKc in event["event"]["backedUpKeycards"]:
      result.keycards.add(jsonKc.toKeycardDto())