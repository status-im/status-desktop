{.used.}

import json, strutils

type TextItem* = object
  textType*: string
  children*: seq[TextItem]
  literal*: string
  destination*: string

proc toTextItem*(jsonText: JsonNode): TextItem =
  result = TextItem(
    literal: jsonText{"literal"}.getStr,
    textType: jsonText{"type"}.getStr,
    destination: jsonText{"destination"}.getStr,
    children: @[]
  )
  if (result.literal.startsWith("statusim://")):
    result.textType = "link"
    # TODO isolate the link only
    result.destination = result.literal

  if jsonText.hasKey("children") and jsonText["children"].kind != JNull:
    for child in jsonText["children"]:
      result.children.add(child.toTextItem)