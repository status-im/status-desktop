type 
  Item* = ref object
    installationId: string
    name: string
    enabled: bool
    isCurrentDevice: bool

proc initItem*(installationId, name: string, enabled, isCurrentDevice: bool): Item =
  result = Item()
  result.installationId = installationId
  result.name = name
  result.enabled = enabled
  result.isCurrentDevice = isCurrentDevice

proc installationId*(self: Item): string = 
  self.installationId

proc name*(self: Item): string = 
  self.name

proc `name=`*(self: Item, value: string) = 
  self.name = value

proc enabled*(self: Item): bool = 
  self.enabled

proc `enabled=`*(self: Item, value: bool) = 
  self.enabled = value

proc isCurrentDevice*(self: Item): bool = 
  self.isCurrentDevice