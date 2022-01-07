import NimQml, json_serialization, chronicles

import ../../../eventemitter
import ../../../fleets/fleet_configuration
import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/node_configuration/service_interface as node_config_service

import status/statusgo_backend_new/settings as status_settings
import status/statusgo_backend_new/mailservers as status_mailservers

import ../../common as task_runner_common

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


  proc getFleet*(self: MailserverController): string =
    let settings = self.getCurrentSettings()
    var fleet = settings_service.DEFAULT_FLEET
    if(settings.fleet.len > 0):
      fleet = settings.fleet
    return fleet

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

  proc requestAllHistoricMessages*(self: MailserverController) =
    try:
      discard status_mailservers.requestAllHistoricMessages()
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-requestAllHistoricMessages", errDesription

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

  proc disconnectActiveMailserver*(self: MailserverController) =
    try:
      discard status_mailservers.disconnectActiveMailserver()
    except Exception as e:
      let errDesription = e.msg
      error "error: ", methodName="mailserver-disconnectActiveMailserver", errDesription
