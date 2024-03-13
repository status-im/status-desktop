import json, stew/shims/strformat

include  ../../common/json_utils

type
  CryptoRampDto* = ref object of RootObj
    name*: string
    description*: string
    fees*: string
    logoUrl*: string
    siteUrl*: string
    hostname*: string

proc newDto*(
  name: string,
  description: string,
  fees: string,
  logoUrl: string,
  siteUrl: string,
  hostname: string
): CryptoRampDto =
  return CryptoRampDto(
    name: name,
    description: description,
    fees: fees,
    logoUrl: logoUrl,
    siteUrl: siteUrl,
    hostname: hostname
  )

proc `$`*(self: CryptoRampDto): string =
  result = "CryptoRampDto("
  result &= fmt"name:{self.name}, "
  result &= fmt"description:{self.description}, "
  result &= fmt"fees:{self.fees}, "
  result &= fmt"logoUrl:{self.logoUrl}, "
  result &= fmt"siteUrl:{self.siteUrl}, "
  result &= fmt"hostname:{self.hostname}"
  result &= ")"

proc toCryptoRampDto*(jsonObj: JsonNode): CryptoRampDto =
  result = CryptoRampDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("description", result.description)
  discard jsonObj.getProp("fees", result.fees)
  discard jsonObj.getProp("logoUrl", result.logoUrl)
  discard jsonObj.getProp("siteUrl", result.siteUrl)
  discard jsonObj.getProp("hostname", result.hostname)
