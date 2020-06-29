import json, types, random, strutils, strformat
import stint
from times import getTime, toUnix, nanosecond
import accounts/signing_phrases

proc isWakuEnabled(): bool =
  true # TODO:

proc prefix*(methodName: string, isExt:bool = true): string =
  result = if isWakuEnabled(): "waku" else: "shh" 
  result = result & (if isExt: "ext_" else: "_")
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

proc handleRPCErrors*(response: string) =
  let parsedReponse = parseJson(response)
  if (parsedReponse.hasKey("error")):
    raise newException(ValueError, parsedReponse["error"]["message"].str)

proc wei2Eth*(input: Stuint[256]): string =
  var one_eth = fromHex(Stuint[256], "DE0B6B3A7640000")

  var (eth, remainder) = divmod(input, one_eth)
  let leading_zeros = "0".repeat(($one_eth).len - ($remainder).len - 1)

  fmt"{eth}.{leading_zeros}{remainder}"


