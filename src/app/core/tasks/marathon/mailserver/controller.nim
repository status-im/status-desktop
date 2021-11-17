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
    status*: Status

  proc newMailserverController*(status: Status): MailserverController =
    new(result)
    result.status = status
    result.setup()

  proc setup(self: MailserverController) =
    self.QObject.setup

  proc delete*(self: MailserverController) =
    self.QObject.delete
