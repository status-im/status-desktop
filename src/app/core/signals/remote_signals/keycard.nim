import json

import base
import signal_type

type KeycardConnectedSignal* = ref object of Signal
  started*: string

proc fromEvent*(T: type KeycardConnectedSignal, event: JsonNode): KeycardConnectedSignal =
  result = KeycardConnectedSignal()
  result.started = event["event"].getStr()
