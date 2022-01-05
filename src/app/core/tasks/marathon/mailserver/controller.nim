import NimQml, times, strutils, json, json_serialization, chronicles

import ../../../fleets/fleet_configuration
import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/node_configuration/service_interface as node_config_service

import status/statusgo_backend_new/settings as status_settings
import status/statusgo_backend_new/node_config as status_node_config
import status/statusgo_backend_new/mailservers as status_mailservers
import status/statusgo_backend_new/general as status_general

import events
import ../../common as task_runner_common

import eventemitter

logScope:
  topics = "mailserver controller"

const STATUS_MAILSERVER_PASS = "status-offline-inbox"
const STATUS_STORE_MESSAGES_TIMEOUT = 30

################################################################################
##                                                                            ##
## NOTE: MailserverController runs on the main thread                         ##
##                                                                            ##
################################################################################
QtObject:
  type MailserverController* = ref object of QObject
    events: EventEmitter

  proc newMailserverController*(events: EventEmitter): MailserverController =
    new(result)
    result.events = events
    result.setup()

  proc setup(self: MailserverController) =
    self.QObject.setup

  proc delete*(self: MailserverController) =
    self.QObject.delete

  proc receiveEvent(self: MailserverController, eventTuple: string) {.slot.} =
    let event = Json.decode(eventTuple, tuple[name: string, arg: MailserverArgs])
    trace "forwarding event from long-running mailserver task to the main thread", event=eventTuple
    self.events.emit(event.name, event.arg)

  # In case of mailserver task, we need to fetch data directly from the `status-go`, and that's why direct calls to 
  # `status-lib` are made here. If we use services here, the state remains the same as it was in the moment when certain
  # service is passed to the mailserver thread.
  proc getCurrentSettings(self: MailserverController): SettingsDto =
    try:
      let response = status_settings.getSettings()
      let settings = response.result.toSettingsDto()
      return settings
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-getCurrentSettings", errDesription

  proc getCurrentNodeConfiguration(self: MailserverController): NodeConfigDto =
    try:
      let response = status_node_config.getNodeConfig()
      let configuration = response.result.toNodeConfigDto()
      return configuration
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-getCurrentNodeConfiguration", errDesription

  proc getCurrentMailservers*(self: MailserverController): seq[JsonNode] =
    try:
      let response = status_mailservers.getMailservers()
      return response.result.getElems()
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-getCurrentMailservers", errDesription

  proc getFleet*(self: MailserverController): string =
    let settings = self.getCurrentSettings()
    var fleet = settings_service.DEFAULT_FLEET
    if(settings.fleet.len > 0):
      fleet = settings.fleet
    return fleet

  proc getWakuVersion*(self: MailserverController): int =
    let nodeConfiguration = self.getCurrentNodeConfiguration()
    if nodeConfiguration.WakuConfig.Enabled:
      return WAKU_VERSION_1
    elif nodeConfiguration.WakuV2Config.Enabled:
      return WAKU_VERSION_2
    
    error "error: unsupported waku version", methodName="mailserver-getWakuVersion"
    return 0

  proc getPinnedMailserver*(self: MailserverController): string =
    let settings = self.getCurrentSettings()
    let fleet = self.getFleet()

    if (fleet == $Fleet.Prod):
      return settings.pinnedMailserver.ethProd
    elif (fleet == $Fleet.Staging):
      return settings.pinnedMailserver.ethStaging
    elif (fleet == $Fleet.Test):
      return settings.pinnedMailserver.ethTest
    elif (fleet == $Fleet.WakuV2Prod):
      return settings.pinnedMailserver.wakuv2Prod
    elif (fleet == $Fleet.WakuV2Test):
      return settings.pinnedMailserver.wakuv2Test
    elif (fleet == $Fleet.GoWakuTest):
      return settings.pinnedMailserver.goWakuTest
    return ""

  proc dialPeer*(self: MailserverController, address: string): bool =
    try:
      let response = status_general.dialPeer(address)
      if response.result.hasKey("error"):
        let errMsg = $response.result
        error "waku peer could not be dialed", methodName="mailserver-dialPeer", errMsg
        return false
      return true
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-dialPeer", errDesription
      return false

  proc generateSymKeyFromPassword*(self: MailserverController): string =
    try:
      let response = status_general.generateSymKeyFromPassword(STATUS_MAILSERVER_PASS)
      let resultAsString = $response.result
      return resultAsString.strip(chars = {'"'})
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-dialPeer", errDesription

  proc setMailserver*(self: MailserverController, peer: string) =
    try:
      discard status_mailservers.setMailserver(peer)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-setMailserver", errDesription

  proc update*(self: MailserverController, peer: string) =
    try:
      discard status_mailservers.update(peer)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-update", errDesription

  proc requestAllHistoricMessages*(self: MailserverController) =
    try:
      discard status_mailservers.requestAllHistoricMessages()
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-requestAllHistoricMessages", errDesription

  proc requestStoreMessages*(self: MailserverController, topics: seq[string], symKeyID: string, peer: string, 
    numberOfMessages: int, fromTimestamp: int64, toTimestamp: int64, force: bool) =
    try:
      var toValue = toTimestamp
      if toValue <= 0:
        toValue = times.toUnix(times.getTime())

      var fromValue = fromTimestamp
      if fromValue <= 0:
        fromValue = toValue - 86400
      
      discard status_mailservers.requestStoreMessages(topics, STATUS_STORE_MESSAGES_TIMEOUT, symKeyID, peer, 
      numberOfMessages, fromValue, toValue, force)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-requestStoreMessages", errDesription

  proc syncChatFromSyncedFrom*(self: MailserverController, chatId: string) =
    try:
      discard status_mailservers.syncChatFromSyncedFrom(chatId)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-syncChatFromSyncedFrom", errDesription

  proc fillGaps*(self: MailserverController, chatId: string, messageIds: seq[string]) =
    try:
      discard status_mailservers.fillGaps(chatId, messageIds)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-fillGaps", errDesription

  proc ping*(self: MailserverController, addresses: seq[string], timeoutMs: int, isWakuV2: bool): JsonNode =
    try:
      let response = status_mailservers.ping(addresses, timeoutMs, isWakuV2)
      return response.result
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-ping", errDesription

  proc dropPeerByID*(self: MailserverController, peer: string) =
    try:
      discard status_general.dropPeerByID(peer)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-dropPeerByID", errDesription

  proc removePeer*(self: MailserverController, peer: string) =
    try:
      discard status_general.removePeer(peer)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-removePeer", errDesription