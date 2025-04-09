import json_serialization

const WEEKLY_TIME_RANGE* = 0
const MONTHLY_TIME_RANGE* = 1
const HALF_YEARLY_TIME_RANGE* = 2
const YEARLY_TIME_RANGE* = 3
const ALL_TIME_RANGE* = 4

type TokenMarketValuesDto* = object
  marketCap* {.serializedFieldName("MKTCAP").}: float64
  highDay* {.serializedFieldName("HIGHDAY").}: float64
  lowDay* {.serializedFieldName("LOWDAY").}: float64
  changePctHour* {.serializedFieldName("CHANGEPCTHOUR").}: float64
  changePctDay* {.serializedFieldName("CHANGEPCTDAY").}: float64
  changePct24hour* {.serializedFieldName("CHANGEPCT24HOUR").}: float64
  change24hour* {.serializedFieldName("CHANGE24HOUR").}: float64