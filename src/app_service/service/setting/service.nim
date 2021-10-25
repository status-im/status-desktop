import chronicles, json

import ./service_interface, ./dto
import status/statusgo_backend_new/settings as status_go

export service_interface

logScope:
  topics = "setting-service"

type
  Service* = ref object of service_interface.ServiceInterface
    setting: SettingDto

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  try:
    let response = status_go.getSettings()
    self.setting = response.result.toSettingDto()
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method saveSetting*(self: Service, attribute: string, value: string | JsonNode | bool | int): SettingDto =
  status_go.saveSettings(attribute, value)
  case attribute:
    of "latest-derived-path":
      self.setting.latestDerivedPath = cast[int](value)
    of "currency":
      self.setting.currency = cast[string](value)


  return self.setting

method getSetting*(self: Service): SettingDto =
  return self.setting