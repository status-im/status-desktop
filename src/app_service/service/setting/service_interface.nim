import json
import ./dto

export dto

type 
  ServiceInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for this service access.

method delete*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: ServiceInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getSetting*(self: ServiceInterface): SettingDto {.base.} =
  raise newException(ValueError, "No implementation available")

method saveSetting*(
  self: ServiceInterface, attribute: string, value: string | JsonNode | bool | int | seq[string]
): SettingDto {.base.} =
  raise newException(ValueError, "No implementation available")
