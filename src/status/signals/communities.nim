import json, strutils, sequtils, sugar, chronicles
import json_serialization
import ../libstatus/types as status_types
import ../chat/[chat]
import types, messages

proc fromEvent*(event: JsonNode): Signal =
  var signal: CommunitySignal = CommunitySignal()
  signal.community = event["event"].toCommunity()
  result = signal
