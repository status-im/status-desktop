import NimQml, strformat, strutils, tables
import ../settings/service as settings_service
import ../token/service as token_service
import ./dto, ./utils
import ../../common/cache

export dto

const DECIMALS_CALCULATION_CURRENCY = "USD"

QtObject:
  type Service* = ref object of QObject
    tokenService: token_service.Service
    settingsService: settings_service.Service
    isCurrencyFiatCache: Table[string, bool]                    # Fiat info does not change, we can fetch/calculate once and
    fiatCurrencyFormatCache: Table[string, CurrencyFormatDto]   # keep the results forever.
    tokenCurrencyFormatCache: TimedCache[CurrencyFormatDto]     # Token format changes with price, so we use a timed cache.

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    tokenService: token_service.Service,
    settingsService: settings_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.tokenService = tokenService
    result.settingsService = settingsService
    result.tokenCurrencyFormatCache = newTimedCache[CurrencyFormatDto]()
  
  proc init*(self: Service) =
    discard

  proc isCurrencyFiat(self: Service, symbol: string): bool =
    if not self.isCurrencyFiatCache.hasKey(symbol):
      self.isCurrencyFiatCache[symbol] = isCurrencyFiat(symbol)
    return self.isCurrencyFiatCache[symbol]

  proc getFiatCurrencyFormat(self: Service, symbol: string): CurrencyFormatDto =
    if not self.fiatCurrencyFormatCache.hasKey(symbol):
      self.fiatCurrencyFormatCache[symbol] = CurrencyFormatDto(
        symbol: toUpperAscii(symbol),
        displayDecimals: getFiatDisplayDecimals(symbol),
        stripTrailingZeroes: false
      )
    return self.fiatCurrencyFormatCache[symbol]

  proc getTokenCurrencyFormat(self: Service, symbol: string): CurrencyFormatDto =
    if self.tokenCurrencyFormatCache.isCached(symbol):
      return self.tokenCurrencyFormatCache.get(symbol)

    var updateCache = true
    let pegSymbol = self.tokenService.getTokenPegSymbol(symbol)
    if pegSymbol != "":
      let currencyFormat = self.getFiatCurrencyFormat(pegSymbol)
      result = CurrencyFormatDto(
        symbol: symbol,
        displayDecimals: currencyFormat.displayDecimals,
        stripTrailingZeroes: currencyFormat.stripTrailingZeroes
      )
      updateCache = true
    else:
      let price = self.tokenService.getCachedTokenPrice(symbol, DECIMALS_CALCULATION_CURRENCY, true)
      result = CurrencyFormatDto(
        symbol: symbol,
        displayDecimals: getTokenDisplayDecimals(price),
        stripTrailingZeroes: true
      )
      updateCache = self.tokenService.isCachedTokenPriceRecent(symbol, DECIMALS_CALCULATION_CURRENCY)

    if updateCache:
      self.tokenCurrencyFormatCache.set(symbol, result)

  proc getCurrencyFormat*(self: Service, symbol: string): CurrencyFormatDto =
    if self.isCurrencyFiat(symbol):
      return self.getFiatCurrencyFormat(symbol)
    else:
      return self.getTokenCurrencyFormat(symbol)
