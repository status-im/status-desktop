import # std libs
  json, tables

import # vendor libs
  chronicles, chronos, json_serialization, task_runner

import # status-desktop libs
  ../worker, ./model, ../../qt, ../../common as task_runner_common,
  ../common as methuselash_common,
  ../../../libstatus/mailservers # TODO: needed for MailserverTopic type, remove?

export
  chronos, task_runner_common, json_serialization

logScope:
  topics = "mailserver worker"

type
  MailserverWorker* = ref object of MarathonWorker

  # below are all custom marathon task arg definitions
  IsActiveMailserverAvailableTaskArg* = ref object of MarathonTaskArg
  GetActiveMailserverTaskArg* = ref object of MarathonTaskArg
  RequestMessagesTaskArg* = ref object of MarathonTaskArg
    chatId*: string
  AddMailserverTopicTaskArg* = ref object of MarathonTaskArg
  PeerSummaryChangeTaskArg* = ref object of MarathonTaskArg
    peers*: seq[string]
  GetMailserverTopicsByChatIdTaskArg* = ref object of MarathonTaskArg
    chatId*: string
    fetchRange*: int
  GetMailserverTopicsByChatIdsTaskArg* = ref object of MarathonTaskArg
    chatIds*: seq[string]
    fetchRange*: int


const
  WORKER_NAME = "mailserver"

# forward declarations
proc workerThread(arg: WorkerThreadArg) {.thread.}

proc newMailserverWorker*(vptr: ByteAddress): MailserverWorker =
  new(result)
  result.chanRecvFromWorker = newAsyncChannel[ThreadSafeString](-1)
  result.chanSendToWorker = newAsyncChannel[ThreadSafeString](-1)
  result.vptr = vptr

method name*(self: MailserverWorker): string = WORKER_NAME

method init*(self: MailserverWorker) =
  self.chanRecvFromWorker.open()
  self.chanSendToWorker.open()
  let arg = WorkerThreadArg(
    chanSendToMain: self.chanRecvFromWorker,
    chanRecvFromMain: self.chanSendToWorker,
    vptr: self.vptr
  )
  createThread(self.thread, workerThread, arg)
  # block until we receive "ready"
  discard $(self.chanRecvFromWorker.recvSync())

method teardown*(self: MailserverWorker) =
  self.chanSendToWorker.sendSync("shutdown".safe)
  self.chanRecvFromWorker.close()
  self.chanSendToWorker.close()
  trace "waiting for the control thread to stop"
  joinThread(self.thread)

method onLoggedIn*(self: MailserverWorker) =
  self.chanSendToWorker.sendSync("loggedIn".safe)

proc processMessage(mailserverModel: MailserverModel, received: string) =
  let
    parsed = parseJson(received)
    messageType = parsed{"$type"}.getStr
    methodName = parsed{"method"}.getStr()
  trace "initiating mailserver task", methodName=methodName, messageType=messageType

  case methodName
  of "requestAllHistoricMessages":
    let taskArg = decode[RequestMessagesTaskArg](received)
    mailserverModel.requestMessages()
    taskArg.finish("") # TODO:

  of "isActiveMailserverAvailable":
    let
      taskArg = decode[IsActiveMailserverAvailableTaskArg](received)
      output = mailserverModel.isActiveMailserverAvailable()
    taskArg.finish(output)

  of "requestMessages":
    let taskArg = decode[RequestMessagesTaskArg](received)
    mailserverModel.requestMessages()

  of "requestMoreMessages":
    let taskArg = decode[RequestMessagesTaskArg](received)
    mailserverModel.requestMoreMessages(taskArg.chatId)

  of "getActiveMailserver":
    let
      taskArg = decode[GetActiveMailserverTaskArg](received)
      output = mailserverModel.getActiveMailserver()
    taskArg.finish(output)

  of "peerSummaryChange":
    let taskArg = decode[PeerSummaryChangeTaskArg](received)
    mailserverModel.peerSummaryChange(taskArg.peers)

  else:
    error "unknown message", message=received

proc worker(arg: WorkerThreadArg) {.async, gcsafe, nimcall.} =
  let
    chanSendToMain = arg.chanSendToMain
    chanRecvFromMain = arg.chanRecvFromMain
  chanSendToMain.open()
  chanRecvFromMain.open()

  trace "sending 'ready' to main thread"
  await chanSendToMain.send("ready".safe)
  let mailserverModel = newMailserverModel(arg.vptr)

  var unprocessedMsgs: seq[string] = @[]
  while true:
    let received = $(await chanRecvFromMain.recv())
    if received == "loggedIn":
      mailserverModel.init()
      break
    else:
      unprocessedMsgs.add received

  discard mailserverModel.checkConnection()
 
  for msg in unprocessedMsgs.items:
    mailserverModel.processMessage(msg)

  while true:
    trace "waiting for message"
    let received = $(await chanRecvFromMain.recv())
    case received
      of "shutdown":
        trace "received 'shutdown'"
        trace "stopping worker"
        break
      else:
        mailserverModel.processMessage(received)

proc workerThread(arg: WorkerThreadArg) =
  waitFor worker(arg)