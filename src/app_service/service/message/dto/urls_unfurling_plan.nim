import json, strformat, chronicles, Tables
include ../../../common/json_utils

type 
  UrlUnfurlingPermit* {.pure.} = enum
    UrlUnfurlingAllowed = 0
    UrlUnfurlingAskUser
    UrlUnfurlingForbiddenBySettings
    UrlUnfurlingNotSupported

  UrlUnfurlingMetadata* = ref object
    permit*: UrlUnfurlingPermit
    isStatusSharedUrl*: bool

  UrlsUnfurlingPlan* = ref object
    urls*: Table[string, UrlUnfurlingMetadata]

proc initUrlsUnfurlingPlan*(): UrlsUnfurlingPlan =
  result = UrlsUnfurlingPlan()
  result.urls = initTable[string, UrlUnfurlingMetadata]()

proc toUrlUnfurlingPermit*(value: int): UrlUnfurlingPermit =
  try:
    return UrlUnfurlingPermit(value)
  except RangeDefect:
    return UrlUnfurlingPermit.UrlUnfurlingForbiddenBySettings

proc toUrlUnfurlingMetadata*(jsonObj: JsonNode): UrlUnfurlingMetadata =
  result = UrlUnfurlingMetadata()

  if jsonObj.kind != JObject:
    warn "node is not an object", source = "toUrlUnfurlingMetadata"
    return

  result.permit = toUrlUnfurlingPermit(jsonObj["permission"].getInt)
  result.isStatusSharedUrl = jsonObj["isStatusSharedURL"].getBool()

proc toUrlUnfurlingPlan*(jsonObj: JsonNode): UrlsUnfurlingPlan =
  result = UrlsUnfurlingPlan()
  
  if jsonObj.kind != JObject:
    warn "node is not an object", source = "toUrlUnfurlingPlan"
    return

  let urlsMap = jsonObj["urls"]

  if urlsMap.kind != JObject:
    warn "urls is not an object", source = "toUrlUnfurlingPlan"
    return

  for url, metadata in urlsMap.pairs:
    result.urls[url] = toUrlUnfurlingMetadata(metadata)

proc `$`*(self: UrlUnfurlingMetadata): string =
  if self == nil:
    return "nil"
  return fmt"""UrlUnfurlingMetadata( permit: {self.permit}, isStatusSharedUrl: {self.isStatusSharedUrl} )"""

proc `$`*(self: UrlsUnfurlingPlan): string =
  var rows = ""

  for url, metadata in self.urls:
    rows = fmt"""{rows}
    url: {url}, metadata: {metadata}"""

  result = fmt"""UrlsUnfurlingPlan({rows}
  )""" 
