import NimQml, sequtils, sugar, chronicles, json

import app/core/[main]
import app/core/signals/types
import app/core/tasks/[qt, threadpool]

import ./dto
export dto

const SIGNAL_CRYPTO_RAMP_PROVIDERS_READY* = "cryptoRampProvidersReady"
const SIGNAL_CRYPTO_RAMP_URL_READY* = "cryptoRampUrlReady"

type CryptoRampProvidersArgs* = ref object of Args
  data*: seq[CryptoRampDto]

type CryptoRampUrlArgs* = ref object of Args
  uuid*: string
  url*: string

logScope:
  topics = "ramp-service"

include async_tasks
include app_service/common/json_utils

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool

  proc init*(self: Service) =
    discard

  proc onFetchCryptoRampProviders*(self: Service, response: string) {.slot.} =
    let cryptoServices =
      parseJson(response){"result"}.getElems().map(x => x.toCryptoRampDto())
    self.events.emit(
      SIGNAL_CRYPTO_RAMP_PROVIDERS_READY, CryptoRampProvidersArgs(data: cryptoServices)
    )

  proc fetchCryptoRampProviders*(self: Service) =
    let arg = QObjectTaskArg(
      tptr: getCryptoServicesTask,
      vptr: cast[uint](self.vptr),
      slot: "onFetchCryptoRampProviders",
    )
    self.threadpool.start(arg)

  proc onFetchCryptoRampURL*(self: Service, response: string) {.slot.} =
    let responseJson = parseJson(response)
    let uuid = responseJson{"uuid"}.getStr()
    let url = responseJson{"url"}.getStr()
    self.events.emit(
      SIGNAL_CRYPTO_RAMP_URL_READY, CryptoRampUrlArgs(uuid: uuid, url: url)
    )

  proc fetchCryptoRampUrl*(
      self: Service,
      uuid: string,
      providerID: string,
      parameters: CryptoRampParametersDto,
  ) =
    let arg = GetCryptoRampUrlTaskArg(
      tptr: getCryptoRampURLTask,
      vptr: cast[uint](self.vptr),
      slot: "onFetchCryptoRampURL",
      uuid: uuid,
      providerID: providerID,
      parameters: %parameters,
    )
    self.threadpool.start(arg)
