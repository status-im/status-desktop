type
  KeycardEvent = object
    error*: string
    seedPhraseIndexes*: seq[int]
    freePairingSlots*: int
    keyUid*: string
    pinRetries*: int
    pukRetries*: int

proc toKeycardEvent(jsonObj: JsonNode): KeycardEvent =
  discard jsonObj.getProp(ErrorKey, result.error)
  discard jsonObj.getProp(RequestParamFreeSlots, result.freePairingSlots)
  discard jsonObj.getProp(RequestParamKeyUID, result.keyUid)
  discard jsonObj.getProp(RequestParamPINRetries, result.pinRetries)
  discard jsonObj.getProp(RequestParamPUKRetries, result.pukRetries)

  var indexesArr: JsonNode
  if jsonObj.getProp(RequestParamMnemonicIdxs, indexesArr) and indexesArr.kind == JArray:
    for ind in indexesArr:
      result.seedPhraseIndexes.add(ind.getInt)