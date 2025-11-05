import nimqml, chronicles, strutils, tables, json, stint

import ../../../backend/backend as backend
import ../../../backend/activity as backend_activity

import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/core/signals/types

import ../settings/service as settings_service
import ../token/service as token_service
import ./dto

include  ../../common/json_utils
include async_tasks

export dto

# Signals which may be emitted by this service:
const SIGNAL_CURRENCY_FORMATS_UPDATED* = "currencyFormatsUpdated"

type
  CurrencyFormatsUpdatedArgs* = ref object of Args
    discard

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    tokenService: token_service.Service
    settingsService: settings_service.Service
    currencyFormatCache: Table[string, CurrencyFormatDto]

  # Forward declarations
  proc fetchAllCurrencyFormats(self: Service)
  proc getCachedCurrencyFormats(self: Service): Table[string, CurrencyFormatDto]

  proc delete*(self: Service)
  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    tokenService: token_service.Service,
    settingsService: settings_service.Service,
  ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.tokenService = tokenService
    result.settingsService = settingsService

  proc init*(self: Service) =
    self.events.on(SignalType.Wallet.event) do(e:Args):
      var data = WalletSignal(e)
      case data.eventType:
        of "wallet-currency-tick-update-format":
          self.fetchAllCurrencyFormats()
          discard
    # Load cache from DB
    self.currencyFormatCache = self.getCachedCurrencyFormats()
    # Trigger async fetch
    self.fetchAllCurrencyFormats()

  proc jsonToFormatsTable(node: JsonNode) : Table[string, CurrencyFormatDto] =
    result = initTable[string, CurrencyFormatDto]()

    for (symbol, formatObj) in node.pairs:
      result[symbol] = formatObj.toCurrencyFormatDto()

  proc getCachedCurrencyFormats(self: Service): Table[string, CurrencyFormatDto] =
    try:
      let response = backend.getCachedCurrencyFormats()
      result = jsonToFormatsTable(response.result)
    except Exception as e:
      let errDesription = e.msg
      error "error getCachedCurrencyFormats: ", errDesription

  proc onAllCurrencyFormatsFetched(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson
      if (responseObj.kind == JObject):

        var formatsJson: JsonNode
        discard responseObj.getProp("formats", formatsJson)
        if formatsJson.isNil or formatsJson.kind == JNull:
          return

        let formatsPerSymbol = jsonToFormatsTable(formatsJson)
        for symbol, format in formatsPerSymbol:
          self.currencyFormatCache[symbol] = format
        self.events.emit(SIGNAL_CURRENCY_FORMATS_UPDATED, CurrencyFormatsUpdatedArgs())
    except Exception as e:
      let errDescription = e.msg
      error "error onAllCurrencyFormatsFetched: ", errDescription

  proc fetchAllCurrencyFormats(self: Service) =
    let arg = FetchAllCurrencyFormatsTaskArg(
      tptr: fetchAllCurrencyFormatsTaskArg,
      vptr: cast[uint](self.vptr),
      slot: "onAllCurrencyFormatsFetched",
    )
    self.threadpool.start(arg)

  proc getCurrencyFormat*(self: Service, symbol: string): CurrencyFormatDto =
    if not self.currencyFormatCache.hasKey(symbol):
      return newCurrencyFormatDto(symbol)
    return self.currencyFormatCache[symbol]

  proc toFloat(amountInt: UInt256): float64 =
    return float64(amountInt.truncate(uint64))

  proc u256ToFloat(decimals: int, amountInt: UInt256): float64 =
    if decimals == 0:
      return amountInt.toFloat()

    # Convert to float at the end to avoid losing precision
    let base = 10.to(UInt256)
    let p = base.pow(decimals)
    let i = amountInt.div(p)
    let r = amountInt.mod(p)

    return i.toFloat() + r.toFloat() / p.toFloat()

  # TODO: left this for activity controller as it uses token symbol
  proc parseCurrencyValueByTokensKey*(self: Service, tokensKey: string, amountInt: UInt256): float64 =
    let token = self.tokenService.getTokenBySymbolByTokensKey(tokensKey)
    var decimals: int = 0
    if token != nil:
      decimals = token.decimals
    return u256ToFloat(decimals, amountInt)

  proc parseCurrencyValueAndSymbolByToken*(self: Service, activityToken: Option[backend_activity.Token], amountInt: UInt256): (float64, string) =
    if activityToken.isNone():
      return (u256ToFloat(0, amountInt), "")

    let t = activityToken.get()
    if t.address.isNone():
      return (u256ToFloat(0, amountInt), "")

    let fullTokenData = self.tokenService.findTokenByAddress(int(t.chainId), $t.address.get())
    var decimals: int = 0
    var symbol: string = ""
    if fullTokenData != nil:
      decimals = fullTokenData.decimals
      symbol = fullTokenData.symbol
    return (u256ToFloat(decimals, amountInt), symbol)

  proc delete*(self: Service) =
    self.QObject.delete

