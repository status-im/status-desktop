import ../../../../../app_service/service/devices/service as devices_service
import ../../../../../app_service/service/devices/dto/[installation]

type Item* = ref object
  installation: InstallationDto
  isCurrentDevice: bool

proc initItem*(installation: InstallationDto, isCurrentDevice: bool): Item =
  result = Item()
  result.installation = installation
  result.isCurrentDevice = isCurrentDevice

proc installation*(self: Item): InstallationDto =
  return self.installation

proc `installation=`*(self: Item, installation: InstallationDto) =
  self.installation = installation

proc name*(self: Item): string =
  self.installation.metadata.name

proc `name=`*(self: Item, value: string) =
  self.installation.metadata.name = value

proc enabled*(self: Item): bool =
  self.installation.enabled

proc `enabled=`*(self: Item, value: bool) =
  self.installation.enabled = value

proc isCurrentDevice*(self: Item): bool =
  self.isCurrentDevice
