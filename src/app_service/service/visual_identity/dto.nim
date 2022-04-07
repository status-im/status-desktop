import json, sequtils, sugar

type
  EmojiHashDto* = seq[string]
  ColorHashSegmentDto* = tuple[len, colorIdx: int]
  ColorHashDto* = seq[ColorHashSegmentDto]

proc toEmojiHashDto*(jsonObj: JsonNode): EmojiHashDto =
  result = map(jsonObj.getElems(), node => node.getStr())
  return

proc toColorHashDto*(jsonObj: JsonNode): ColorHashDto =
  result = map(jsonObj.getElems(),
               node => (len: node.getElems()[0].getInt(),
                        colorIdx: node.getElems()[1].getInt())
              )
  return

proc toColorId*(jsonObj: JsonNode): int =
  return jsonObj.getInt()
