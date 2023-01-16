import NimQml, strformat, strutils
import ../settings/service as settings_service
import ../token/service as token_service
import ./dto, ./utils

export dto

const DECIMALS_CALCULATION_CURRENCY = "USD"

QtObject:
  type Service* = ref object of QObject
    tokenService: token_service.Service
    settingsService: settings_service.Service

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
  
  proc init*(self: Service) =
    discard

  proc getFiatCurrencyFormat(self: Service, symbol: string): CurrencyFormatDto =
    return CurrencyFormatDto(
      symbol: toUpperAscii(symbol),
      displayDecimals: getFiatDisplayDecimals(symbol),
      stripTrailingZeroes: false
    )

  proc getTokenCurrencyFormat(self: Service, symbol: string): CurrencyFormatDto =
    let pegSymbol = self.tokenService.getTokenPegSymbol(symbol)
    if pegSymbol != "":
      var currencyFormat = self.getFiatCurrencyFormat(pegSymbol)
      currencyFormat.symbol = symbol
      return currencyFormat
    else:
      let price = self.tokenService.getTokenPrice(symbol, DECIMALS_CALCULATION_CURRENCY, false)
      return CurrencyFormatDto(
        symbol: symbol,
        displayDecimals: getTokenDisplayDecimals(price),
        stripTrailingZeroes: true
      )

  proc getCurrencyFormat*(self: Service, symbol: string): CurrencyFormatDto =
    if isCurrencyFiat(symbol):
      return self.getFiatCurrencyFormat(symbol)
    else:
      return self.getTokenCurrencyFormat(symbol)
