{.used.}

import json

include ../../../common/[json_utils]

type MailserverDto* = object
  id*: string 
  name*: string
  address*: string
  fleet*: string

proc toMailserverDto*(jsonObj: JsonNode): MailserverDto =
  result = MailserverDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("fleet", result.fleet)