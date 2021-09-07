import json

import base

import ../../status/types/community

type CommunitySignal* = ref object of Signal
  community*: Community

proc fromEvent*(event: JsonNode): Signal =
  var signal: CommunitySignal = CommunitySignal()
  signal.community = event["event"].toCommunity()
  result = signal