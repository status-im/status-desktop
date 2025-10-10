import nimqml, strutils

import ./io_interface
import app/modules/shared/wallet_utils
import app_service/service/currency/dto

QtObject:
  type MarketDetailsItem* = ref object of QObject
    delegate: io_interface.TokenMarketValuesDataSource
    currencyFormat: CurrencyFormatDto
    tokenKey: string

  proc setup*(self: MarketDetailsItem) =
    self.QObject.setup

  proc delete*(self: MarketDetailsItem) =
    self.QObject.delete

  proc newMarketDetailsItem*(delegate: io_interface.TokenMarketValuesDataSource, tokenKey: string): MarketDetailsItem =
    new(result)
    result.setup()
    result.delegate = delegate
    result.tokenKey = tokenKey
    result.currencyFormat = delegate.getCurrentCurrencyFormat()


  proc updateCurrencyFormat*(self: MarketDetailsItem) =
    self.currencyFormat = self.delegate.getCurrentCurrencyFormat()

  proc marketCapChanged*(self: MarketDetailsItem) {.signal.}
  proc marketCap*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.tokenKey.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(currencyAmountToItem(self.delegate.getMarketValuesForToken(self.tokenKey).marketCap, self.currencyFormat))
  QtProperty[QVariant] marketCap:
    read = marketCap
    notify = marketCapChanged

  proc highDayChanged*(self: MarketDetailsItem) {.signal.}
  proc highDay*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.tokenKey.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(currencyAmountToItem(self.delegate.getMarketValuesForToken(self.tokenKey).highDay, self.currencyFormat))
  QtProperty[QVariant] highDay:
    read = highDay
    notify = highDayChanged

  proc lowDayChanged*(self: MarketDetailsItem) {.signal.}
  proc lowDay*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.tokenKey.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(currencyAmountToItem(self.delegate.getMarketValuesForToken(self.tokenKey).lowDay, self.currencyFormat))
  QtProperty[QVariant] lowDay:
    read = lowDay
    notify = lowDayChanged

  proc changePctHourChanged*(self: MarketDetailsItem) {.signal.}
  proc changePctHour*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.tokenKey.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.delegate.getMarketValuesForToken(self.tokenKey).changePctHour)
  QtProperty[QVariant] changePctHour:
    read = changePctHour
    notify = changePctHourChanged

  proc changePctDayChanged*(self: MarketDetailsItem) {.signal.}
  proc changePctDay*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.tokenKey.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.delegate.getMarketValuesForToken(self.tokenKey).changePctDay)
  QtProperty[QVariant] changePctDay:
    read = changePctDay
    notify = changePctDayChanged

  proc changePct24hourChanged*(self: MarketDetailsItem) {.signal.}
  proc changePct24hour*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.tokenKey.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.delegate.getMarketValuesForToken(self.tokenKey).changePct24hour)
  QtProperty[QVariant] changePct24hour:
    read = changePct24hour
    notify = changePct24hourChanged

  proc change24hourChanged*(self: MarketDetailsItem) {.signal.}
  proc change24hour*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.tokenKey.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading(): return newQVariant()
    else: return newQVariant(self.delegate.getMarketValuesForToken(self.tokenKey).change24hour)
  QtProperty[QVariant] change24hour:
    read = change24hour
    notify = change24hourChanged

  proc currencyPriceChanged*(self: MarketDetailsItem) {.signal.}
  proc currencyPrice*(self: MarketDetailsItem): QVariant {.slot.} =
    if self.tokenKey.isEmptyOrWhitespace or self.delegate.getTokensMarketValuesLoading():
      return newQVariant(currencyAmountToItem(0, self.currencyFormat))
    else:
      let price = self.delegate.getPriceForToken(self.tokenKey)
      return newQVariant(currencyAmountToItem(price, self.currencyFormat))
  QtProperty[QVariant] currencyPrice:
    read = currencyPrice
    notify = currencyPriceChanged
