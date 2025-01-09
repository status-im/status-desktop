import json, sequtils, sugar

type
  EmojiHashDto* = seq[string]
  ColorHashSegmentDto* = tuple[len, colorIdx: int]
  ColorHashDto* = seq[ColorHashSegmentDto]

proc toEmojiHashDto*(jsonObj: JsonNode): EmojiHashDto =
  result = map(jsonObj.getElems(), node => node.getStr())
  return

proc toColorHashDto*(jsonObj: JsonNode): ColorHashDto =
  result = map(
    jsonObj.getElems(),
    node => (len: node.getElems()[0].getInt(), colorIdx: node.getElems()[1].getInt()),
  )
  return

proc toJson*(self: ColorHashDto): string =
  let json = newJArray()
  for segment in self:
    json.add(%*{"segmentLength": segment.len, "colorId": segment.colorIdx})
  return $json

proc toColorId*(jsonObj: JsonNode): int =
  return jsonObj.getInt()
