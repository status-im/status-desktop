import NimQml

import ./io_interface
import app/modules/shared_models/currency_amount
import app/modules/shared/wallet_utils
import app_service/service/currency/dto

QtObject:
  type MarketDetailsItem* = ref object of QObject
    delegate: io_interface.TokenMarketValuesDataSource
    currencyFormat: CurrencyFormatDto
    symbol: string

  proc setup*(self: MarketDetailsItem) =
    self.QObject.setup

  proc delete*(self: MarketDetailsItem) =
    self.QObject.delete

  proc newMarketDetailsItem*(
    delegate: io_interface.TokenMarketValuesDataSource, symbol: string): MarketDetailsItem =
    new(result)
    result.setup()
    result.delegate = delegate
    result.symbol = symbol
    result.currencyFormat = delegate.getCurrentCurrencyFormat()

  proc updateCurrencyFormat*(self: MarketDetailsItem) =
    self.currencyFormat = self.delegate.getCurrentCurrencyFormat()

  proc marketCapChanged*(self: MarketDetailsItem) {.signal.}
  proc marketCap*(self: MarketDetailsItem): QVariant {.slot.} =
    return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).marketCap)
  QtProperty[QVariant] marketCap:
    read = marketCap
    notify = marketCapChanged

  proc highDayChanged*(self: MarketDetailsItem) {.signal.}
  proc highDay*(self: MarketDetailsItem): QVariant {.slot.} =
    return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).highDay)
  QtProperty[QVariant] highDay:
    read = highDay
    notify = highDayChanged

  proc lowDayChanged*(self: MarketDetailsItem) {.signal.}
  proc lowDay*(self: MarketDetailsItem): QVariant {.slot.} =
    return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).lowDay)
  QtProperty[QVariant] lowDay:
    read = lowDay
    notify = lowDayChanged

  proc changePctHourChanged*(self: MarketDetailsItem) {.signal.}
  proc changePctHour*(self: MarketDetailsItem): QVariant {.slot.} =
    return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).changePctHour)
  QtProperty[QVariant] changePctHour:
    read = changePctHour
    notify = changePctHourChanged

  proc changePctDayChanged*(self: MarketDetailsItem) {.signal.}
  proc changePctDay*(self: MarketDetailsItem): QVariant {.slot.} =
    return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).changePctDay)
  QtProperty[QVariant] changePctDay:
    read = changePctDay
    notify = changePctDayChanged

  proc changePct24hourChanged*(self: MarketDetailsItem) {.signal.}
  proc changePct24hour*(self: MarketDetailsItem): QVariant {.slot.} =
    return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).changePct24hour)
  QtProperty[QVariant] changePct24hour:
    read = changePct24hour
    notify = changePct24hourChanged

  proc change24hourChanged*(self: MarketDetailsItem) {.signal.}
  proc change24hour*(self: MarketDetailsItem): QVariant {.slot.} =
    return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).change24hour)
  QtProperty[QVariant] change24hour:
    read = change24hour
    notify = change24hourChanged

  proc currencyPriceChanged*(self: MarketDetailsItem) {.signal.}
  proc currencyPrice*(self: MarketDetailsItem): QVariant {.slot.} =
    let price = self.delegate.getPriceBySymbol(self.symbol)
    return newQVariant(currencyAmountToItem(price, self.currencyFormat))
  QtProperty[QVariant] currencyPrice:
    read = currencyPrice
    notify = currencyPriceChanged
