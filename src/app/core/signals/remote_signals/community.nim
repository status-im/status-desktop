import json

import base

import ../../../../app_service/service/community/dto/[community]
import signal_type

type CommunitySignal* = ref object of Signal
  community*: CommunityDto

proc fromEvent*(T: type CommunitySignal, event: JsonNode): CommunitySignal = 
  result = CommunitySignal()
  result.signalType = SignalType.CommunityFound
  result.community = event["event"].toCommunityDto()
