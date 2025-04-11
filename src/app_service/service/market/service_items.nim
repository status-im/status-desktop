#import stew/shims/strformat

##include app_service/common/json_utils

#import json_serialization

type MarketItem* = ref object of RootObj
    key*: string
    name*: string
    symbol*: string
    image*: string
    currentPrice*: float64
    marketCap*: float64
    totalVolume*: float64
    priceChangePercentage24h*: float64
