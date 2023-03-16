import json
import base

import ../../../../app_service/service/wallet_account/[key_pair_dto]

type WakuBackedUpKeycardsSignal* = ref object of Signal
  keycards*: seq[KeyPairDto]

proc fromEvent*(T: type WakuBackedUpKeycardsSignal, event: JsonNode): WakuBackedUpKeycardsSignal =
  result = WakuBackedUpKeycardsSignal()

  if event["event"]{"backedUpKeycards"} != nil:
    for jsonKc in event["event"]["backedUpKeycards"]:
      result.keycards.add(jsonKc.toKeyPairDto())