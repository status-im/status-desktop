import json, sequtils, sugar

type
  EmojiHashDto* = seq[string]

proc toEmojiHashDto*(jsonObj: JsonNode): EmojiHashDto =
  result = map(jsonObj.getElems(), node => node.getStr())
  return

proc toColorId*(jsonObj: JsonNode): int =
  return jsonObj.getInt()
