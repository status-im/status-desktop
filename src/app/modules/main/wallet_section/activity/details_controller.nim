import NimQml, logging, stint

import entry
import entry_details

import app_service/service/currency/service as currency_service

import app/modules/shared/wallet_utils
import app/modules/shared_models/currency_amount

QtObject:
  type
    Controller* = ref object of QObject
      activityEntry: ActivityEntry
      activityDetails: ActivityDetails
      currencyService: currency_service.Service

  proc setup(self: Controller) =
    self.QObject.setup

  proc delete*(self: Controller) =
    self.QObject.delete

  proc newController*(currencyService: currency_service.Service): Controller =
    new(result, delete)

    result.currencyService = currencyService

    result.setup()

  proc activityEntryChanged*(self: Controller) {.signal.}
  proc getActivityEntry(self: Controller): QVariant {.slot.} =
    if self.activityEntry == nil:
      return newQVariant()
    return newQVariant(self.activityEntry)

  QtProperty[QVariant] activityEntry:
    read = getActivityEntry
    notify = activityEntryChanged

  proc activityDetailsChanged*(self: Controller) {.signal.}
  proc getActivityDetails(self: Controller): QVariant {.slot.} =
    if self.activityDetails == nil:
      return newQVariant()
    return newQVariant(self.activityDetails)

  QtProperty[QVariant] activityDetails:
    read = getActivityDetails
    notify = activityDetailsChanged

  proc setActivityEntry*(self: Controller, entry: ActivityEntry) =
    if self.activityDetails != nil:
      self.activityDetails = nil
      self.activityDetailsChanged()
    self.activityEntry = entry
    self.activityEntryChanged()    

  proc resetActivityEntry*(self: Controller) {.slot.} =
    self.setActivityEntry(nil)

  proc fetchExtraTxDetails*(self: Controller) {.slot.} =
    let amountToCurrencyConvertor = proc(amount: UInt256, symbol: string): CurrencyAmount =
      return currencyAmountToItem(self.currencyService.parseCurrencyValue(symbol, amount),
                                    self.currencyService.getCurrencyFormat(symbol))
    if self.activityEntry == nil:
      error "activity entry is not set"
      return

    try:
      self.activityDetails = newActivityDetails(self.activityEntry.getMetadata(), amountToCurrencyConvertor)
      self.activityDetailsChanged()
    except Exception as e:
      error "error: ", e.msg
      return
