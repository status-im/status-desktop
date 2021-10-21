import NimQml

import ../../../../app_service/service/setting/service as setting_service

QtObject:
  type
    View* = ref object of QObject
      defaultCurrency: string
      totalCurrencyBalance: float64
      signingPhrase: string
      isMnemonicBackedUp: bool
      
  proc setup(self: View) = 
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(): View =
    new(result, delete)
    result.setup()

  proc updateFromSetting*(self: View, setting: setting_service.SettingDto) =
    self.defaultCurrency = setting.currency
    self.signingPhrase = setting.signingPhrase
    self.isMnemonicBackedUp = setting.isMnemonicBackedUp

  proc setTotalCurrencyBalance*(self: View, totalCurrencyBalance: float64) = 
    self.totalCurrencyBalance = totalCurrencyBalance
