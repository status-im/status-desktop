import times, strformat
import backend/backend as backend

include app_service/common/json_utils
#################################################
# Async load transactions
#################################################

const DAYS_IN_WEEK = 7
const HOURS_IN_DAY = 24

const getSupportedTokenList*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
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
    symbols: seq[string]
    currency: string

const fetchTokensMarketValuesTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchTokensMarketValuesTaskArg](argEncoded)
  var output = %*{
    "tokenMarketValues": "",
    "error": ""
  }
  try:
    let response = backend.fetchMarketValues(arg.symbols, arg.currency)
    output["tokenMarketValues"] = %*response
  except Exception as e:
    output["error"] = %* fmt"Error fetching market values: {e.msg}"
  arg.finish(output)

type
  FetchTokensDetailsTaskArg = ref object of QObjectTaskArg
    symbols: seq[string]

const fetchTokensDetailsTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchTokensDetailsTaskArg](argEncoded)
  var output = %*{
    "tokensDetails": "",
    "error": ""
  }
  try:
    let response = backend.fetchTokenDetails(arg.symbols)
    output["tokensDetails"] = %*response
  except Exception as e:
    output["error"] = %* fmt"Error fetching token details: {e.msg}"
  arg.finish(output)

type
  FetchTokensPricesTaskArg = ref object of QObjectTaskArg
    symbols: seq[string]
    currencies: seq[string]

const fetchTokensPricesTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchTokensPricesTaskArg](argEncoded)
  var output = %*{
    "tokensPrices": "",
    "error": ""
  }
  try:
    let response = backend.fetchPrices(arg.symbols, arg.currencies)
    output["tokensPrices"] = %*response
  except Exception as e:
    output["error"] = %* fmt"Error fetching prices: {e.msg}"
  arg.finish(output)

type
  GetTokenHistoricalDataTaskArg = ref object of QObjectTaskArg
    symbol: string
    currency: string
    range: int

const getTokenHistoricalDataTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetTokenHistoricalDataTaskArg](argEncoded)
  var response = %*{}
  try:
    let td = now()
    case arg.range:
      of WEEKLY_TIME_RANGE:
        response = backend.getHourlyMarketValues(arg.symbol, arg.currency, DAYS_IN_WEEK*HOURS_IN_DAY, 1).result
      of MONTHLY_TIME_RANGE:
        response = backend.getHourlyMarketValues(arg.symbol, arg.currency, getDaysInMonth(td.month, td.year)*HOURS_IN_DAY, 2).result
      of HALF_YEARLY_TIME_RANGE:
        response = backend.getDailyMarketValues(arg.symbol, arg.currency, int(getDaysInYear(td.year)/2), false, 1).result
      of YEARLY_TIME_RANGE:
        response = backend.getDailyMarketValues(arg.symbol, arg.currency, getDaysInYear(td.year), false, 1).result
      of ALL_TIME_RANGE:
        response = backend.getDailyMarketValues(arg.symbol, arg.currency, 1, true, 12).result
      else:
        let output = %* {
          "symbol": arg.symbol,
          "range": arg.range,
          "error": "Range not defined",
        }

    let output = %* {
        "symbol": arg.symbol,
        "range": arg.range,
        "historicalData": response
    }

    arg.finish(output)
    return
  except Exception as e:
    let output = %* {
      "symbol": arg.symbol,
      "range": arg.range,
      "error": "Historical market value not found",
    }
    arg.finish(output)

type
  BalanceHistoryTimeInterval* {.pure.} = enum
    BalanceHistory7Hours = 0,
    BalanceHistory1Month,
    BalanceHistory6Months,
    BalanceHistory1Year,
    BalanceHistoryAllTime

type
  GetTokenBalanceHistoryDataTaskArg = ref object of QObjectTaskArg
    chainIds: seq[int]
    addresses: seq[string]
    allAddresses: bool
    tokenSymbol: string
    currencySymbol: string
    timeInterval: BalanceHistoryTimeInterval

const getTokenBalanceHistoryDataTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetTokenBalanceHistoryDataTaskArg](argEncoded)
  var response = %*{}
  try:
    # status-go time intervals are starting from 1
    response = backend.getBalanceHistory(arg.chainIds, arg.addresses, arg.tokenSymbol, arg.currencySymbol, int(arg.timeInterval) + 1).result

    let output = %* {
        "chainIds": arg.chainIds,
        "addresses": arg.addresses,
        "allAddresses": arg.allAddresses,
        "tokenSymbol": arg.tokenSymbol,
        "currencySymbol": arg.currencySymbol,
        "timeInterval": int(arg.timeInterval),
        "historicalData": response
    }

    arg.finish(output)
    return
  except Exception as e:
    let output = %* {
      "chainIds": arg.chainIds,
      "addresses": arg.addresses,
      "allAddresses": arg.allAddresses,
      "tokenSymbol": arg.tokenSymbol,
      "currencySymbol": arg.currencySymbol,
      "timeInterval": int(arg.timeInterval),
      "error": e.msg,
    }
    arg.finish(output)
