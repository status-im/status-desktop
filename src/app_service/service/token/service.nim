import nimqml, tables, json, sequtils, chronicles, strutils, sugar

import web3/eth_api_types
import backend/backend as backend

import app_service/service/network/service as network_service
import app_service/service/settings/service as settings_service

import app/core/eventemitter
import app/core/tasks/[qt, threadpool]
import app/core/signals/types
import app_service/common/cache

import json_serialization
import nimqml, json, chronicles
import backend/tokens as status_go_tokens

import dto/types as dto_types
import items/types as items_types

export dto_types, items_types


logScope:
  topics = "token-service"


include signals_and_payloads
include app_service/common/json_utils
include async_tasks

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    networkService: network_service.Service
    settingsService: settings_service.Service

    # local storage
    allTokenGroups: seq[TokenGroupItem]
    tokenGroupKeyToTokenKeys: Table[string, seq[string]] # [tokenGroupKey, []tokenKey]
    allTokenLists: seq[TokenListItem] # TODO: remove this, fetch when needed, don't store it
    tokenDetailsTable: Table[string, TokenDetailsItem] # [tokenKey, TokenDetailsItem]
    tokenMarketValuesTable: Table[string, TokenMarketValuesItem] # [tokenKey, TokenMarketValuesItem]
    tokenPriceTable: Table[string, float64] # [tokenKey, price]
    tokenPreferencesTable: Table[string, TokenPreferencesItem] # [crossChainId-or-tokenKey, TokenPreferencesItem]

    tokenPreferencesJson: string
    tokensDetailsLoading: bool
    tokensPricesLoading: bool
    tokensMarketDetailsLoading: bool
    hasMarketDetailsCache: bool
    hasPriceValuesCache: bool
    tokenListUpdatedAt: int64

  # Forward declaration
  proc getCurrency*(self: Service): string
  proc rebuildMarketData*(self: Service)
  proc fetchTokenPreferences(self: Service)

  # All slots defined in included files have to be forward declared
  proc tokensMarketValuesRetrieved(self: Service, response: string) {.slot.}
  proc tokensDetailsRetrieved(self: Service, response: string) {.slot.}
  proc tokensPricesRetrieved(self: Service, response: string) {.slot.}
  proc tokenHistoricalDataResolved*(self: Service, response: string) {.slot.}


  proc delete*(self: Service)

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    networkService: network_service.Service,
    settingsService: settings_service.Service
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.networkService = networkService
    result.settingsService = settingsService

    result.tokenGroupKeyToTokenKeys = initTable[string, seq[string]]()
    result.tokenDetailsTable = initTable[string, TokenDetailsItem]()
    result.tokenMarketValuesTable = initTable[string, TokenMarketValuesItem]()
    result.tokenPriceTable = initTable[string, float64]()
    result.tokenPreferencesTable = initTable[string, TokenPreferencesItem]()
    result.tokensDetailsLoading = true
    result.tokensPricesLoading = true
    result.tokensMarketDetailsLoading = true
    result.hasMarketDetailsCache = false
    result.hasPriceValuesCache = false


  include service_tokens
  include service_tokens_details
  include service_tokens_preferences
  include service_main

  proc delete*(self: Service) =
    self.QObject.delete
