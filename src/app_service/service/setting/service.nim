import chronicles

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

method getSetting*(self: Service): SettingDto =
  return self.setting