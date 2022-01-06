import # vendor libs
  chronicles, NimQml, json_serialization

import # status-desktop libs
  status/status, ../../common as task_runner_common

logScope:
  topics = "mailserver controller"

################################################################################
##                                                                            ##
## NOTE: MailserverController runs on the main thread                         ##
##                                                                            ##
################################################################################
QtObject:
  type MailserverController* = ref object of QObject
    variant*: QVariant
    status*: Status

  proc newController*(status: Status): MailserverController =
    new(result)
    result.status = status
    result.setup()
    result.variant = newQVariant(result)

  proc setup(self: MailserverController) =
    self.QObject.setup

  proc delete*(self: MailserverController) =
    self.variant.delete
    self.QObject.delete
