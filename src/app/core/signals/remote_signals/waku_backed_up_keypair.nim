import json
import base

import ../../../../app_service/service/wallet_account/[keypair_dto]

type WakuBackedUpKeypairSignal* = ref object of Signal
  keypair*: KeypairDto

proc fromEvent*(T: type WakuBackedUpKeypairSignal, event: JsonNode): WakuBackedUpKeypairSignal =
  result = WakuBackedUpKeypairSignal()

  let e = event["event"]
  if e.contains("backedUpKeypair"):
    result.keypair = e["backedUpKeypair"].toKeypairDto()  
