import NimQml, Tables, json, sequtils, strutils, system, uuids, chronicles

import ./dto/mailserver as mailserver_dto
import ../../../app/core/signals/types
import ../../../app/core/fleets/fleet_configuration
import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]
import ../settings/service_interface as settings_service
import ../node_configuration/service_interface as node_configuration_service
import status/mailservers as status_mailservers

logScope:
  topics = "mailservers-service"

type
  ActiveMailserverChangedArgs* = ref object of Args
    nodeAddress*: string

  MailserverAvailableArgs* = ref object of Args

  RequestMessagesTaskArg = ref object of QObjectTaskArg

  RequestMoreMessagesTaskArg = ref object of QObjectTaskArg
    chatId*: string

  FillGapsTaskArg* = ref object of QObjectTaskArg
    chatId*: string
    messageIds*: seq[string]

# Signals which may be emitted by this service:
const SIGNAL_ACTIVE_MAILSERVER_CHANGED* = "activeMailserverChanged"
const SIGNAL_MAILSERVER_AVAILABLE* = "mailserverAvailable"

const requestMessagesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[RequestMessagesTaskArg](argEncoded)
  try:
    info "Requesting message history"
    discard status_mailservers.requestAllHistoricMessages()
  except Exception as e:
    warn "Disconnecting active mailserver due to error", errDescription=e.msg
    discard status_mailservers.disconnectActiveMailserver()

const requestMoreMessagesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[RequestMoreMessagesTaskArg](argEncoded)
  try:
    info "Requesting additional message history for chat", chatId=arg.chatId
    discard status_mailservers.syncChatFromSyncedFrom(arg.chatId)
  except Exception as e:
    warn "Disconnecting active mailserver due to error", errDescription=e.msg
    discard status_mailservers.disconnectActiveMailserver()

const fillGapsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FillGapsTaskArg](argEncoded)
  try:
    info "Requesting fill gaps", chatId=arg.chatId, messageIds=arg.messageIds
    discard status_mailservers.fillGaps(arg.chatId, arg.messageIds)
  except Exception as e:
    warn "Disconnecting active mailserver due to error", errDescription=e.msg
    discard status_mailservers.disconnectActiveMailserver()

QtObject:
  type Service* = ref object of QObject
    mailservers: seq[tuple[name: string, nodeAddress: string]]
    events: EventEmitter
    threadpool: ThreadPool
    settingsService: settings_service.ServiceInterface
    nodeConfigurationService: node_configuration_service.ServiceInterface
    fleetConfiguration: FleetConfiguration

  # Forward declaration:
  proc doConnect(self: Service)
  proc initMailservers(self: Service)
  proc fetchMailservers(self: Service)

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool, 
    settingsService: settings_service.ServiceInterface, 
    nodeConfigurationService: node_configuration_service.ServiceInterface, 
    fleetConfiguration: FleetConfiguration): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.settingsService = settingsService
    result.nodeConfigurationService = nodeConfigurationService
    result.fleetConfiguration = fleetConfiguration

  proc init*(self: Service) =
    self.doConnect()
    self.initMailservers()
    self.fetchMailservers()  

  proc requestMessages(self: Service) =
    let arg = RequestMessagesTaskArg(
      tptr: cast[ByteAddress](requestMessagesTask),
      vptr: cast[ByteAddress](self.vptr)
    )
    self.threadpool.start(arg)

  proc requestMoreMessages*(self: Service, chatId: string) =
    let arg = RequestMoreMessagesTaskArg(
      tptr: cast[ByteAddress](requestMoreMessagesTask),
      vptr: cast[ByteAddress](self.vptr),
      chatId: chatId
    )
    self.threadpool.start(arg)

  proc fillGaps*(self: Service, chatId: string, messageId: string) =
    let arg = FillGapsTaskArg(
      tptr: cast[ByteAddress](fillGapsTask),
      vptr: cast[ByteAddress](self.vptr),
      chatId: chatId,
      messageIds: @[messageId]
    )
    self.threadpool.start(arg)

  proc doConnect(self: Service) =
    self.events.on(SignalType.MailserverChanged.event) do(e: Args):
      let receivedData = MailserverChangedSignal(e)
      let address = receivedData.address
      info "active mailserver changed", node=address
      let data = ActiveMailserverChangedArgs(nodeAddress: address)
      self.events.emit(SIGNAL_ACTIVE_MAILSERVER_CHANGED, data)
    
    self.events.on(SignalType.MailserverAvailable.event) do(e: Args):
      info "mailserver available"
      self.requestMessages()
      let data = MailserverAvailableArgs()
      self.events.emit(SIGNAL_MAILSERVER_AVAILABLE, data)

    self.events.on(SignalType.HistoryRequestStarted.event) do(e: Args):
      let h = HistoryRequestStartedSignal(e)
      info "history request started", requestId=h.requestId, numBatches=h.numBatches

    self.events.on(SignalType.HistoryRequestBatchProcessed.event) do(e: Args):
      let h = HistoryRequestBatchProcessedSignal(e)
      info "history batch processed", requestId=h.requestId, batchIndex=h.batchIndex

    self.events.on(SignalType.HistoryRequestCompleted.event) do(e: Args):
      let h = HistoryRequestCompletedSignal(e)
      info "history request completed", requestId=h.requestId

    self.events.on(SignalType.HistoryRequestFailed.event) do(e: Args):
      let h = HistoryRequestFailedSignal(e)
      info "history request failed", requestId=h.requestId, errorMessage=h.errorMessage

  proc initMailservers(self: Service) =
    let wakuVersion = self.nodeConfigurationService.getWakuVersion()
    let isWakuV2 = wakuVersion == WAKU_VERSION_2
    let fleet = self.settingsService.getFleet()
    let mailservers = self.fleetConfiguration.getMailservers(fleet, isWakuV2)

    for (name, nodeAddress) in mailservers.pairs():
      info "initMailservers", topics="mailserver-interaction", name, nodeAddress
      self.mailservers.add((name: name, nodeAddress: nodeAddress))
      
  proc fetchMailservers(self: Service) =
    try:
      let response = status_mailservers.getMailservers()
      info "fetch mailservers", topics="mailserver-interaction", rpc_method="mailservers_getMailservers", response

      for el in response.result.getElems():
        let dto = el.toMailserverDto()
        self.mailservers.add((name: dto.name, nodeAddress: dto.address))

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc getAllMailservers*(self: Service): seq[tuple[name: string, nodeAddress: string]] =
    return self.mailservers

  proc saveMailserver*(self: Service, name: string, nodeAddress: string) =
    try:
      let fleet = self.settingsService.getFleetAsString()
      let id = $genUUID()

      let response = status_mailservers.saveMailserver(id, name, nodeAddress, fleet)
      info "save mailserver", topics="mailserver-interaction", rpc_method="mailservers_addMailserver", response
      # once we have more info from `status-go` we may emit a signal from here and 
      # update view or display an error accordingly

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc enableAutomaticSelection*(self: Service, value: bool) =
    if value:
      let fleet = self.settingsService.getFleet()
      discard self.settingsService.unpinMailserver(fleet)
    else:
      discard # TODO: handle pin mailservers in status-go (in progress)
      #let mailserverWorker = self.marathon[MailserverWorker().name]
      #let task = GetActiveMailserverTaskArg(
      #    `method`: "getActiveMailserver",
      #    vptr: cast[ByteAddress](self.vptr),
      #    slot: "onActiveMailserverResult"
      #  )
      #mailserverWorker.start(task)

  proc onActiveMailserverResult*(self: Service, response: string) {.slot.} =
    let fleet = self.settingsService.getFleet()
    discard self.settingsService.pinMailserver(response, fleet)
