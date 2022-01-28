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

  