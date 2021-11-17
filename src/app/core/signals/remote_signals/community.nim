import json

import base

import status/types/community
import signal_type

type CommunitySignal* = ref object of Signal
  community*: Community

proc fromEvent*(T: type CommunitySignal, event: JsonNode): CommunitySignal = 
  result = CommunitySignal()
  result.signalType = SignalType.CommunityFound
  result.community = event["event"].toCommunity()
