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

  proc getDefaultCurrency(self: View): QVariant {.slot.} =
    return newQVariant(self.defaultCurrency)

  QtProperty[QVariant] defaultCurrency:
    read = getDefaultCurrency

  proc getTotalCurrencyBalance(self: View): QVariant {.slot.} =
    return newQVariant(self.totalCurrencyBalance)

  QtProperty[QVariant] totalCurrencyBalance:
    read = getTotalCurrencyBalance

  proc getSigningPhrase(self: View): QVariant {.slot.} =
    return newQVariant(self.signingPhrase)

  QtProperty[QVariant] signingPhrase:
    read = getSigningPhrase

  proc getIsMnemonicBackedUp(self: View): QVariant {.slot.} =
    return newQVariant(self.isMnemonicBackedUp)

  QtProperty[QVariant] isMnemonicBackedUp:
    read = getIsMnemonicBackedUp
