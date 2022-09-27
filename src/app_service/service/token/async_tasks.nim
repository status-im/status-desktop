import times
include ../../common/json_utils
import ../eth/utils

import ../../../backend/backend as backend
import ./dto
#################################################
# Async load transactions
#################################################

const DAYS_IN_WEEK = 7
const HOURS_IN_DAY = 24

type
  GetTokenDetailsTaskArg = ref object of QObjectTaskArg
    chainIds: seq[int]
    address: string


const getTokenDetailsTask*: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetTokenDetailsTaskArg](argEncoded)
  for chainId in arg.chainIds:
    try:
      let response = backend.discoverToken(chainId, arg.address).result
      
      let output = %* {
        "address": arg.address,
        "name": response{"name"}.getStr,
        "symbol": response{"symbol"}.getStr,
        "decimals": response{"decimals"}.getInt
      }
      arg.finish(output)
      return
    except Exception as e:
      continue
    
  let output = %* {
    "address": arg.address,
    "error": "Is this an ERC-20 or ERC-721 contract?",
  }
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

