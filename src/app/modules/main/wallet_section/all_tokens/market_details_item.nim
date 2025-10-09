import nimqml, strutils, json

import ./io_interface
import app/modules/shared/wallet_utils
import app_service/service/currency/dto
import app/modules/shared_models/currency_amount

QtObject:
  type MarketDetailsItem* = ref object of QObject
    delegate: io_interface.TokenMarketValuesDataSource
    currencyFormat: CurrencyFormatDto
    currencyPriceItem: CurrencyAmount
    marketCapItem: CurrencyAmount
    highDayItem: CurrencyAmount
    lowDayItem: CurrencyAmount
    symbol: string

  proc setup*(self: MarketDetailsItem) =
    self.QObject.setup

  proc delete*(self: MarketDetailsItem) =
    self.QObject.delete

  proc newMarketDetailsItem*(
    delegate: io_interface.TokenMarketValuesDataSource, symbol: string
  ): MarketDetailsItem =
    new(result)
    result.setup()
    result.delegate = delegate
    result.symbol = symbol
    result.currencyFormat = delegate.getCurrentCurrencyFormat()
    result.currencyPriceItem = currencyAmountToItem(delegate.getPriceBySymbol(result.symbol), result.currencyFormat)
    result.marketCapItem = currencyAmountToItem(delegate.getMarketValuesBySymbol(result.symbol).marketCap, result.currencyFormat)
    result.highDayItem = currencyAmountToItem(delegate.getMarketValuesBySymbol(result.symbol).highDay, result.currencyFormat)
    result.lowDayItem = currencyAmountToItem(delegate.getMarketValuesBySymbol(result.symbol).lowDay, result.currencyFormat)

  proc marketCapChanged*(self: MarketDetailsItem) {.signal.}
  proc marketCap*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.symbol.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.marketCapItem)
  QtProperty[QVariant] marketCap:
    read = marketCap
    notify = marketCapChanged

  proc highDayChanged*(self: MarketDetailsItem) {.signal.}
  proc highDay*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.symbol.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.highDayItem)
  QtProperty[QVariant] highDay:
    read = highDay
    notify = highDayChanged

  proc lowDayChanged*(self: MarketDetailsItem) {.signal.}
  proc lowDay*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.symbol.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.lowDayItem)
  QtProperty[QVariant] lowDay:
    read = lowDay
    notify = lowDayChanged

  proc changePctHourChanged*(self: MarketDetailsItem) {.signal.}
  proc changePctHour*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.symbol.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).changePctHour)
  QtProperty[QVariant] changePctHour:
    read = changePctHour
    notify = changePctHourChanged

  proc changePctDayChanged*(self: MarketDetailsItem) {.signal.}
  proc changePctDay*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.symbol.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).changePctDay)
  QtProperty[QVariant] changePctDay:
    read = changePctDay
    notify = changePctDayChanged

  proc changePct24hourChanged*(self: MarketDetailsItem) {.signal.}
  proc changePct24hour*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.symbol.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).changePct24hour)
  QtProperty[QVariant] changePct24hour:
    read = changePct24hour
    notify = changePct24hourChanged

  proc change24hourChanged*(self: MarketDetailsItem) {.signal.}
  proc change24hour*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.symbol.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.delegate.getMarketValuesBySymbol(self.symbol).change24hour)
  QtProperty[QVariant] change24hour:
    read = change24hour
    notify = change24hourChanged

  proc currencyPriceChanged*(self: MarketDetailsItem) {.signal.}
  proc currencyPrice*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.symbol.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.currencyPriceItem)
  QtProperty[QVariant] currencyPrice:
    read = currencyPrice
    notify = currencyPriceChanged

  proc updateCurrencyPrice*(self: MarketDetailsItem) =
    let price = currencyAmountToItem(self.delegate.getPriceBySymbol(self.symbol), self.currencyFormat)
    if self.currencyPriceItem == price: return

    self.currencyPriceItem.set(price)
    self.currencyPriceChanged()

  proc updateMarketCap*(self: MarketDetailsItem) =
    let marketCap = currencyAmountToItem(self.delegate.getMarketValuesBySymbol(self.symbol).marketCap, self.currencyFormat)
    if self.marketCapItem == marketCap: return

    self.marketCapItem.set(marketCap)
    self.marketCapChanged()

  proc updateHighDay*(self: MarketDetailsItem) =
    let highDay = currencyAmountToItem(self.delegate.getMarketValuesBySymbol(self.symbol).highDay, self.currencyFormat)
    if self.highDayItem == highDay: return

    self.highDayItem.set(highDay)
    self.highDayChanged()

  proc updateLowDay*(self: MarketDetailsItem) =
    let lowDay = currencyAmountToItem(self.delegate.getMarketValuesBySymbol(self.symbol).lowDay, self.currencyFormat)
    if self.lowDayItem == lowDay: return

    self.lowDayItem.set(lowDay)
    self.lowDayChanged()

  proc updateCurrencyFormat*(self: MarketDetailsItem) =
    self.currencyFormat = self.delegate.getCurrentCurrencyFormat()
    self.updateCurrencyPrice()
    self.updateMarketCap()
    self.updateHighDay()
    self.updateLowDay()

  proc update*(self: MarketDetailsItem) =
    self.updateCurrencyPrice()
    self.updateMarketCap()
    self.updateHighDay()
    self.updateLowDay()
    self.changePctHourChanged()
    self.changePctDayChanged()
    self.changePct24hourChanged()
    self.change24hourChanged()