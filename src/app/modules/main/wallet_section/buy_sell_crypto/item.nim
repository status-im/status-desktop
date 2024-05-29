import stew/shims/strformat
  
type Item* = object
  name: string
  description: string
  fees: string
  logoUrl: string
  siteUrl: string  
  hostname: string
  recurrentSiteUrl: string

proc initItem*(name, description, fees, logoUrl, siteUrl,
  hostname, recurrentSiteUrl,: string): Item =
  result.name = name
  result.description = description
  result.fees = fees
  result.logoUrl = logoUrl
  result.siteUrl = siteUrl
  result.hostname = hostname
  result.recurrentSiteUrl = recurrentSiteUrl

proc `$`*(self: Item): string =
  result = "Item("
  result &= fmt"name:{self.name}, "
  result &= fmt"description:{self.description}, "
  result &= fmt"fees:{self.fees}, "
  result &= fmt"logoUrl:{self.logoUrl}, "
  result &= fmt"siteUrl:{self.siteUrl}"
  result &= fmt"hostname:{self.hostname}"
  result &= fmt"recurrentSiteUrl:{self.recurrentSiteUrl}"
  result &= ")"

method getName*(self: Item): string {.base.} =
  return self.name

method getDescription*(self: Item): string {.base.} =
  return self.description

method getFees*(self: Item): string {.base.} =
  return self.fees

method getLogoUrl*(self: Item): string {.base.} =
  return self.logoUrl

method getSiteUrl*(self: Item): string {.base.} =
  return self.siteUrl

method getHostname*(self: Item): string {.base.} =
  return self.hostname

method getRecurrentSiteUrl*(self: Item): string {.base.} =
  return self.recurrentSiteUrl
