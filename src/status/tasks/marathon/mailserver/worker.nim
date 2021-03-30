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
  GetMailserverTopicsTaskArg* = ref object of MarathonTaskArg
  IsActiveMailserverAvailableTaskArg* = ref object of MarathonTaskArg
    topics*: seq[MailserverTopic]
  GetActiveMailserverTaskArg* = ref object of MarathonTaskArg
  RequestMessagesTaskArg* = ref object of MarathonTaskArg
    topics*: seq[string]
    fromValue*: int64
    toValue*: int64
    force*: bool
  AddMailserverTopicTaskArg* = ref object of MarathonTaskArg
    topic*: MailserverTopic
  PeerSummaryChangeTaskArg* = ref object of MarathonTaskArg
    peers*: seq[string]
  GetMailserverTopicsByChatIdTaskArg* = ref object of MarathonTaskArg
    chatId*: string
    fetchRange*: int
  GetMailserverTopicsByChatIdsTaskArg* = ref object of MarathonTaskArg
    chatIds*: seq[string]
    fetchRange*: int
  DeleteMailserverTopicTaskArg* = ref object of MarathonTaskArg
    chatId*: string

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
  of "getMailserverTopics":
    let
      taskArg = decode[GetMailserverTopicsTaskArg](received)
      output = mailserverModel.getMailserverTopics()
    taskArg.finish(output)

  of "isActiveMailserverAvailable":
    let
      taskArg = decode[IsActiveMailserverAvailableTaskArg](received)
      output = mailserverModel.isActiveMailserverAvailable()
      payload: tuple[isActiveMailserverAvailable: bool, topics: seq[MailserverTopic]] = (output, taskArg.topics)
    taskArg.finish(payload)

  of "requestMessages":
    let taskArg = decode[RequestMessagesTaskArg](received)
    mailserverModel.requestMessages(taskArg.topics, taskArg.fromValue, taskArg.toValue, taskArg.force)

  of "getActiveMailserver":
    let
      taskArg = decode[GetActiveMailserverTaskArg](received)
      output = mailserverModel.getActiveMailserver()
    taskArg.finish(output)

  of "getMailserverTopicsByChatId":
    let
      taskArg = decode[GetMailserverTopicsByChatIdTaskArg](received)
      output = mailserverModel.getMailserverTopicsByChatId(taskArg.chatId)
      payload: tuple[topics: seq[MailserverTopic], fetchRange: int] = (output, taskArg.fetchRange)
    taskArg.finish(payload)

  of "getMailserverTopicsByChatIds":
    let
      taskArg = decode[GetMailserverTopicsByChatIdsTaskArg](received)
      output = mailserverModel.getMailserverTopicsByChatIds(taskArg.chatIds)
      payload: tuple[topics: seq[MailserverTopic], fetchRange: int] = (output, taskArg.fetchRange)
    taskArg.finish(payload)

  of "addMailserverTopic":
    let taskArg = decode[AddMailserverTopicTaskArg](received)
    mailserverModel.addMailserverTopic(taskArg.topic)

  of "peerSummaryChange":
    let taskArg = decode[PeerSummaryChangeTaskArg](received)
    mailserverModel.peerSummaryChange(taskArg.peers)

  of "deleteMailserverTopic":
    let taskArg = decode[DeleteMailserverTopicTaskArg](received)
    mailserverModel.deleteMailserverTopic(taskArg.chatId)

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