import NimQml, json, chronicles

import ../../../backend/provider as status_go_provider
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../ens/service as ens_service

logScope:
  topics = "provider-service"

include ../../common/json_utils
include ./async_tasks

const HTTPS_SCHEME* = "https"
const PROVIDER_SIGNAL_ON_POST_MESSAGE* = "provider-signal-on-post-message"

type
  OnPostMessageArgs* = ref object of Args
    payloadMethod*: string
    result*: string
    chainId*: string

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    ensService: ens_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
    events: EventEmitter,
    threadpool: ThreadPool,
    ensService: ens_service.Service
  ): Service =
    result = Service()
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.ensService = ensService

  proc init*(self: Service) =
    discard

  proc ensResourceURL*(self: Service, username: string, url: string): (string, string, string, string, bool) =
    let (scheme, host, path) = self.ensService.resourceUrl(username)
    if host == "":
      return (url, url, HTTPS_SCHEME, "", false)
    return (url, host, scheme, path, true)

  proc postMessageResolved*(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson

      if responseObj{"error"}.kind != JNull and responseObj{"error"}.getStr != "":
        raise newException(CatchableError, responseObj{"error"}.getStr)

      var data = OnPostMessageArgs()
      discard responseObj.getProp("payloadMethod", data.payloadMethod)
      discard responseObj.getProp("result", data.result)
      discard responseObj.getProp("chainId", data.chainId)

      self.events.emit(PROVIDER_SIGNAL_ON_POST_MESSAGE, data)
    except Exception as e:
      error "error: ", procName="postMessageResolved", errMsg=e.msg

  proc postMessage*(self: Service, payloadMethod: string, requestType: string, message: string) =
    let arg = PostMessageTaskArg(
      tptr: postMessageTask,
      vptr: cast[uint](self.vptr),
      slot: "postMessageResolved",
      payloadMethod: payloadMethod,
      requestType: requestType,
      message: message
    )
    self.threadpool.start(arg)
