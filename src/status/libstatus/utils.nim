import json
import types
import random
from times import getTime, toUnix, nanosecond
import strutils
import accounts/signing_phrases

proc isWakuEnabled(): bool =
  true # TODO:

proc prefix*(methodName: string): string =
  result = if isWakuEnabled(): "wakuext_" else: "shhext_" 
  result = result & methodName

proc isOneToOneChat*(chatId: string): bool =
  result = chatId.startsWith("0x") # There is probably a better way to do this

proc keys*(obj: JsonNode): seq[string] =
  result = newSeq[string]()
  for k, _ in obj:
    result.add k

proc toGoString*(str: string): GoString =
  result = GoString(str: str, length: cint(str.len))

proc generateSigningPhrase*(count: int): string =
  let now = getTime()
  var rng = initRand(now.toUnix * 1000000000 + now.nanosecond)
  var phrases: seq[string] = @[]
  
  for i in 1..count:
    phrases.add(rng.sample(signing_phrases.phrases))

  result = phrases.join(" ")