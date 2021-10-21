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

method saveSetting*(
  self: Service, attribute: string, value: string | JsonNode | bool | int | seq[string]
): SettingDto =
  case attribute:
    of "latest-derived-path":
      self.setting.latestDerivedPath = cast[int](value)
      status_go.saveSettings(attribute, self.setting.latestDerivedPath)
    of "currency":
      self.setting.currency = cast[string](value)
      status_go.saveSettings(attribute, self.setting.currency)
    of "wallet/visible-tokens":
      let newValue = cast[seq[string]](value)
      self.setting.activeTokenSymbols = newValue
      self.setting.rawActiveTokenSymbols[$self.setting.currentNetwork.id] = newJArray()
      self.setting.rawActiveTokenSymbols[$self.setting.currentNetwork.id] = %* newValue

      status_go.saveSettings(attribute, $self.setting.rawActiveTokenSymbols)

  return self.setting

method getSetting*(self: Service): SettingDto =
  return self.setting