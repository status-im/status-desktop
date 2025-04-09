import times, stew/shims/strformat
import backend/backend as backend

include app_service/common/json_utils
#################################################
# Async load transactions
#################################################

const DAYS_IN_WEEK = 7
const HOURS_IN_DAY = 24

proc getSupportedTokenList*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[QObjectTaskArg](argEncoded)
  var output = %*{
    "supportedTokensJson": "",
    "error": ""
  }
  try:
    let response = backend.getTokenList()
    output["supportedTokensJson"] = %*response
  except Exception as e:
    output["error"] = %* fmt"Error fetching supported tokens: {e.msg}"
  arg.finish(output)

type
  FetchTokensMarketValuesTaskArg = ref object of QObjectTaskArg
    groupedTokensKeys: seq[string]
    currency: string

proc fetchTokensMarketValuesTask*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchTokensMarketValuesTaskArg](argEncoded)
  var output = %*{
    "tokenMarketValues": "",
    "error": ""
  }
  try:
    let response = backend.fetchMarketValues(arg.groupedTokensKeys, arg.currency)
    output["tokenMarketValues"] = %*response
  except Exception as e:
    output["error"] = %* fmt"Error fetching market values: {e.msg}"
  arg.finish(output)

type
  FetchTokensDetailsTaskArg = ref object of QObjectTaskArg
    groupedTokensKeys: seq[string]

proc fetchTokensDetailsTask*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchTokensDetailsTaskArg](argEncoded)
  var output = %*{
    "tokensDetails": "",
    "error": ""
  }
  try:
    let response = backend.fetchTokenDetails(arg.groupedTokensKeys)
    output["tokensDetails"] = %*response
  except Exception as e:
    output["error"] = %* fmt"Error fetching token details: {e.msg}"
  arg.finish(output)

type
  FetchTokensPricesTaskArg = ref object of QObjectTaskArg
    groupedTokensKeys: seq[string]
    currencies: seq[string]

proc fetchTokensPricesTask*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchTokensPricesTaskArg](argEncoded)
  var output = %*{
    "tokensPrices": "",
    "error": ""
  }
  try:
    let response = backend.fetchPrices(arg.groupedTokensKeys, arg.currencies)
    output["tokensPrices"] = %*response
  except Exception as e:
    output["error"] = %* fmt"Error fetching prices: {e.msg}"
  arg.finish(output)

type
  GetTokenHistoricalDataTaskArg = ref object of QObjectTaskArg
    groupedTokenKey: string
    currency: string
    range: int

proc getTokenHistoricalDataTask*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetTokenHistoricalDataTaskArg](argEncoded)
  var response = %*{}
  try:
    let td = now()
    case arg.range:
      of WEEKLY_TIME_RANGE:
        response = backend.getHourlyMarketValues(arg.groupedTokenKey, arg.currency, DAYS_IN_WEEK*HOURS_IN_DAY, 1).result
      of MONTHLY_TIME_RANGE:
        response = backend.getHourlyMarketValues(arg.groupedTokenKey, arg.currency, getDaysInMonth(td.month, td.year)*HOURS_IN_DAY, 2).result
      of HALF_YEARLY_TIME_RANGE:
        response = backend.getDailyMarketValues(arg.groupedTokenKey, arg.currency, int(getDaysInYear(td.year)/2), false, 1).result
      of YEARLY_TIME_RANGE:
        response = backend.getDailyMarketValues(arg.groupedTokenKey, arg.currency, getDaysInYear(td.year), false, 1).result
      of ALL_TIME_RANGE:
        response = backend.getDailyMarketValues(arg.groupedTokenKey, arg.currency, 1, true, 12).result
      else:
        let output = %* {
          "groupedTokenKey": arg.groupedTokenKey,
          "range": arg.range,
          "error": "Range not defined",
        }

    let output = %* {
        "groupedTokenKey": arg.groupedTokenKey,
        "range": arg.range,
        "historicalData": response
    }

    arg.finish(output)
    return
  except Exception as e:
    let output = %* {
      "groupedTokenKey": arg.groupedTokenKey,
      "range": arg.range,
      "error": "Historical market value not found",
    }
    arg.finish(output)
