import math, chronicles, json, strutils
import ../../../backend/backend as backend

logScope:
  topics = "currency-utils"

proc isCurrencyFiat*(symbol: string): bool =
    let response = backend.isCurrencyFiat(symbol)
    return response.result.getBool

proc getFiatDisplayDecimals*(symbol: string): int =
    result = 0
    try: 
        let response = backend.getFiatCurrencyMinorUnit(symbol)
        result = response.result.getInt
    except Exception as e:
        let errDesription = e.msg
        error "error getFiatDisplayDecimals: ", errDesription

proc getTokenDisplayDecimals*(currencyPrice: float): int =
    var decimals = 0.0
    if currencyPrice > 0:
        const lowerCurrencyResolution = 0.1
        const higherCurrencyResolution = 0.01
        let lowerDecimalsBound = max(0.0, log10(currencyPrice) - log10(lowerCurrencyResolution))
        let upperDecimalsBound = max(0.0, log10(currencyPrice) - log10(higherCurrencyResolution))

        # Use as few decimals as needed to ensure lower precision
        decimals = ceil(lowerDecimalsBound)
        if (decimals + 1 < upperDecimalsBound):
            # If allowed by upper bound, ensure resolution changes as soon as currency hits multiple of 10
            decimals += 1
    return decimals.int
