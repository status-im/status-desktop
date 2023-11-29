import NimQml, Tables, json, sequtils, strutils, system, uuids, chronicles, os

import ./dto/mailserver as mailserver_dto
import ../../../app/core/signals/types
import ../../../app/core/fleets/fleet_configuration
import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]
import ../settings/service as settings_service
import ../node_configuration/service as node_configuration_service
import ../../../backend/mailservers as status_mailservers

# allow runtime override via environment variable; core contributors can set a
# mailserver id in this way for local development or test
let MAILSERVER_ID = $getEnv("MAILSERVER")

# allow runtime override via environment variable. core contributors can set a
# specific peer to set for testing messaging and mailserver functionality with squish.
let TEST_PEER_ENR = getEnv("TEST_PEER_ENR").string

logScope:
  topics = "mailservers-service"

type
  ActiveMailserverChangedArgs* = ref object of Args
    nodeAddress*: string

  MailserverAvailableArgs* = ref object of Args

  MailserverSyncedArgs* = ref object of Args
    chatId*: string
    syncedFrom*: int64

  RequestMoreMessagesTaskArg = ref object of QObjectTaskArg
    chatId*: string

  FillGapsTaskArg* = ref object of QObjectTaskArg
    chatId*: string
    messageIds*: seq[string]

# Signals which may be emitted by this service:
const SIGNAL_ACTIVE_MAILSERVER_CHANGED* = "activeMailserverChanged"
const SIGNAL_MAILSERVER_AVAILABLE* = "mailserverAvailable"
const SIGNAL_MAILSERVER_NOT_WORKING* = "mailserverNotWorking"
const SIGNAL_MAILSERVER_SYNCED* = "mailserverSynced"
const SIGNAL_MAILSERVER_HISTORY_REQUEST_STARTED* = "historyRequestStarted"
const SIGNAL_MAILSERVER_HISTORY_REQUEST_COMPLETED* = "historyRequestCompleted"

const requestMoreMessagesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[RequestMoreMessagesTaskArg](argEncoded)
  try:
    info "Requesting additional message history for chat", chatId=arg.chatId
    let response = status_mailservers.requestMoreMessages(arg.chatId)

    if(not response.error.isNil):
      error "Could not request additional messages due to error", errDescription = response.error.message
      arg.finish(%*{"error": response.error.message})
    else:
      info "synced mailserver successfully", chatID=arg.chatId
      arg.finish(%*{"error": ""})

  except Exception as e:
    warn "Could not request additional messages due to error", errDescription=e.msg
    arg.finish(%* {
      "error": e.msg
    })

const fillGapsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FillGapsTaskArg](argEncoded)
  try:
    info "Requesting fill gaps", chatId=arg.chatId, messageIds=arg.messageIds
    discard status_mailservers.fillGaps(arg.chatId, arg.messageIds)
  except Exception as e:
    warn "Could not fill gaps due to error", errDescription=e.msg

QtObject:
  type Service* = ref object of QObject
    mailservers: seq[tuple[name: string, nodeAddress: string]]
    events: EventEmitter
    threadpool: ThreadPool
    settingsService: settings_service.Service
    nodeConfigurationService: node_configuration_service.Service
    fleetConfiguration: FleetConfiguration

  # Forward declaration:
  proc doConnect(self: Service)
  proc initMailservers(self: Service)
  proc fetchMailservers(self: Service)
  proc saveMailserver*(self: Service, name: string, nodeAddress: string): string

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool,
    settingsService: settings_service.Service,
    nodeConfigurationService: node_configuration_service.Service,
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

    let fleet = self.nodeConfigurationService.getFleet()
    if TEST_PEER_ENR != "":
      var found = false
      for mailserver in self.mailservers:
        if mailserver.nodeAddress == TEST_PEER_ENR:
          found = true
          break
      if not found:
        let mailserverName = "Test Mailserver"
        self.mailservers.add((name: mailserverName, nodeAddress: TEST_PEER_ENR))
        let mailserverID = self.saveMailserver(mailserverName, TEST_PEER_ENR)
        discard self.settingsService.pinMailserver(mailserverId, fleet)

    if MAILSERVER_ID != "":
      discard self.settingsService.pinMailserver(MAILSERVER_ID, fleet)

  proc requestMoreMessages*(self: Service, chatId: string) =
    let arg = RequestMoreMessagesTaskArg(
      tptr: cast[ByteAddress](requestMoreMessagesTask),
      vptr: cast[ByteAddress](self.vptr),
      chatId: chatId,
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

      if address == "":
        info "removing active mailserver"
      else:
        info "active mailserver changed", node=address
      let data = ActiveMailserverChangedArgs(nodeAddress: address)
      self.events.emit(SIGNAL_ACTIVE_MAILSERVER_CHANGED, data)

    self.events.on(SignalType.MailserverAvailable.event) do(e: Args):
      info "mailserver available"
      let data = MailserverAvailableArgs()
      self.events.emit(SIGNAL_MAILSERVER_AVAILABLE, data)

    self.events.on(SignalType.MailserverNotWorking.event) do(e: Args):
      info "mailserver not working"
      self.events.emit(SIGNAL_MAILSERVER_NOT_WORKING, Args())

    self.events.on(SignalType.HistoryRequestStarted.event) do(e: Args):
      let h = HistoryRequestStartedSignal(e)
      info "history request started", numBatches=h.numBatches
      self.events.emit(SIGNAL_MAILSERVER_HISTORY_REQUEST_STARTED, Args())

    self.events.on(SignalType.HistoryRequestCompleted.event) do(e: Args):
      let h = HistoryRequestCompletedSignal(e)
      info "history request completed"
      self.events.emit(SIGNAL_MAILSERVER_HISTORY_REQUEST_COMPLETED, Args())

    self.events.on(SignalType.HistoryRequestFailed.event) do(e: Args):
      let h = HistoryRequestFailedSignal(e)
      info "history request failed", requestId=h.requestId, peerId=h.peerId, errorMessage=h.errorMessage

    self.events.on(SignalType.HistoryRequestSuccess.event) do(e: Args):
      let h = HistoryRequestSuccessSignal(e)
      info "history request success", requestId=h.requestId, peerId=h.peerId


  proc initMailservers(self: Service) =
    let wakuVersion = self.nodeConfigurationService.getWakuVersion()
    let isWakuV2 = wakuVersion == WAKU_VERSION_2
    let fleet = self.nodeConfigurationService.getFleet()
    let mailservers = self.fleetConfiguration.getMailservers(fleet, isWakuV2)

    for (name, nodeAddress) in mailservers.pairs():
      info "initMailservers", topics="mailserver-interaction", name, nodeAddress
      self.mailservers.add((name: name, nodeAddress: nodeAddress))

  proc fetchMailservers(self: Service) =
    try:
      let response = status_mailservers.getMailservers()
      info "fetch mailservers", topics="mailserver-interaction", rpc_proc="mailservers_getMailservers", response

      for el in response.result.getElems():
        let dto = el.toMailserverDto()
        self.mailservers.add((name: dto.name, nodeAddress: dto.address))

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc getAllMailservers*(self: Service): seq[tuple[name: string, nodeAddress: string]] =
    return self.mailservers

  proc saveMailserver*(self: Service, name: string, nodeAddress: string): string =
    try:
      let fleet = self.nodeConfigurationService.getFleetAsString()
      let id = $genUUID()

      let response = status_mailservers.saveMailserver(id, name, nodeAddress, fleet)
      info "save mailserver", topics="mailserver-interaction", rpc_proc="mailservers_addMailserver", response
      # once we have more info from `status-go` we may emit a signal from here and
      # update view or display an error accordingly

      return id

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return ""

  proc enableAutomaticSelection*(self: Service, value: bool) =
    if value:
      let fleet = self.nodeConfigurationService.getFleet()
      discard self.settingsService.unpinMailserver(fleet)
    else:
      discard # TODO: handle pin mailservers in status-go (in progress)
      #let mailserverWorker = self.marathon[MailserverWorker().name]
      #let task = GetActiveMailserverTaskArg(
      #    `proc`: "getActiveMailserver",
      #    vptr: cast[ByteAddress](self.vptr),
      #    slot: "onActiveMailserverResult"
      #  )
      #mailserverWorker.start(task)

  proc onActiveMailserverResult*(self: Service, response: string) {.slot.} =
    let fleet = self.nodeConfigurationService.getFleet()
    discard self.settingsService.pinMailserver(response, fleet)
