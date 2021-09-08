import json, strformat, chronicles

include status/utils/[json_utils]

logScope:
  topics = "app-wallet2-crypto-service"
  
type CryptoServiceItem* = object
  name: string
  description: string
  fees: string
  logoUrl: string
  siteUrl: string  
  hostname: string

proc initCryptoServiceItem*(name, description, fees, logoUrl, siteUrl, 
  hostname: string): CryptoServiceItem =

  result.name = name
  result.description = description
  result.fees = fees
  result.logoUrl = logoUrl
  result.siteUrl = siteUrl
  result.hostname = hostname

proc initCryptoServiceItem*(jsonObject: JsonNode): CryptoServiceItem =

  if (jsonObject.kind != JObject):
      info "CryptoServiceItem initialization failed: JsonNode is not JObject"
      return

  discard jsonObject.getProp("name", result.name)
  discard jsonObject.getProp("description", result.description)
  discard jsonObject.getProp("fees", result.fees)
  discard jsonObject.getProp("logoUrl", result.logoUrl)
  discard jsonObject.getProp("siteUrl", result.siteUrl)
  discard jsonObject.getProp("hostname", result.hostname)

proc `$`*(self: CryptoServiceItem): string =
  result = "CryptoServiceItem("
  result &= fmt"name:{self.name}, "
  result &= fmt"description:{self.description}, "
  result &= fmt"fees:{self.fees}, "
  result &= fmt"logoUrl:{self.logoUrl}, "
  result &= fmt"siteUrl:{self.siteUrl}"
  result &= fmt"hostname:{self.hostname}"
  result &= ")"

method getName*(self: CryptoServiceItem): string {.base.} =
  return self.name

method getDescription*(self: CryptoServiceItem): string {.base.} =
  return self.description

method getFees*(self: CryptoServiceItem): string {.base.} =
  return self.fees

method getLogoUrl*(self: CryptoServiceItem): string {.base.} =
  return self.logoUrl

method getSiteUrl*(self: CryptoServiceItem): string {.base.} =
  return self.siteUrl

method getHostname*(self: CryptoServiceItem): string {.base.} =
  return self.hostname