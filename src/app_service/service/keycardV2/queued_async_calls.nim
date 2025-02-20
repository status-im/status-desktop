proc onAsyncResponse(self: Service, response: string) {.slot.} =
  try:
    let responseObj = response.parseJson
    if responseObj{"error"}.kind != JNull and responseObj{"error"}.getStr != "":
      raise newException(CatchableError, responseObj{"error"}.getStr)
    let rpcResponseObj = responseObj["response"].getStr().parseJson()
    self.currentRequest.callback(rpcResponseObj, "")
  except Exception as e:
    error "onAsyncResponse", err=e.msg
    self.currentRequest.callback(newJNull(), e.msg)
  self.requestsQueue.del(0)
  self.currentRequest = nil

proc onTimeout(self: Service, reason: string) {.slot.} =
  if not self.currentRequest.isNil:
    self.runTimer()
    return
  if self.requestsQueue.len == 0:
    return
  self.currentRequest = self.requestsQueue[0]
  let arg = AsyncRequestArg(
    tptr: asyncRequestTask,
    vptr: cast[uint](self.vptr),
    slot: "onAsyncResponse",
    action: $self.currentRequest.action,
    params: self.currentRequest.params,
  )
  self.threadpool.start(arg)

proc runTimer(self: Service) =
  let arg = TimerTaskArg(
    tptr: timerTask,
    vptr: cast[uint](self.vptr),
    slot: "onTimeout",
    timeoutInMilliseconds: KeycardLibCallsInterval,
  )
  self.threadpool.start(arg)

proc asyncCallRPC(self: Service, action: KeycardAction, params: JsonNode, callback: proc (responseObj: JsonNode, err: string)) =
  let request = KeycardRequest(
    action: action,
    params: params,
    callback: callback
  )
  self.requestsQueue.add(request)
  if self.currentRequest.isNil:
    self.onTimeout("")
    return
  self.runTimer()