import stew/shims/strformat

#include app_service/common/json_utils

import json_serialization

# Only contains DTO used for deserialisation of data from go lib
type CryptocurrencyDto* = ref object of RootObj
    id*                       {.serializedFieldName("id").}: string
    symbol*                   {.serializedFieldName("symbol").}: string
    name*                     {.serializedFieldName("name").}: string
    image*                    {.serializedFieldName("image").}: string
    currentPrice*             {.serializedFieldName("current_price").}: float64
    marketCap*                {.serializedFieldName("market_cap").}: float64
    totalVolume*              {.serializedFieldName("total_volume").}: float64
    priceChangePercentage24h* {.serializedFieldName("price_change_percentage_24h").}: float64

proc `$`*(self: CryptocurrencyDto): string =
  result = fmt"""CryptocurrencyDto[
    id: {self.id},
    name: {self.name},
    symbol: {self.symbol},
    image: {self.image},
    currentPrice: {self.currentPrice},
    marketCap: {self.marketCap},
    totalVolume: {self.totalVolume},
    priceChangePercentage24h: {self.priceChangePercentage24h},
    ]"""

type LeaderboardPageDto* = ref object of RootObj
    totalCount* {.serializedFieldName("all_cryptocurrency_count").}: int
    page*       {.serializedFieldName("page").}: int
    pageSize*   {.serializedFieldName("page_size").}: int
    sortOrder*  {.serializedFieldName("sorting").}: int
    currency*   {.serializedFieldName("currency").}: string
    data*       {.serializedFieldName("cryptocurrencies").}: seq[CryptocurrencyDto]

proc `$`*(self: LeaderboardPageDto): string =
  result = fmt"""LeaderboardPageDto[
    totalCount: {self.totalCount},
    page: {self.page},
    pageSize: {self.pageSize},
    sortOrder: {self.sortOrder},
    currency: {self.currency},
    data: {self.data}
    ]"""
