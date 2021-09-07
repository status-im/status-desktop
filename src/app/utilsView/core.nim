import NimQml, chronicles
import ../../status/[status, node, network]
import ../../app_service/[main]
import view
import ../../eventemitter

logScope:
  topics = "utils"

type UtilsController* = ref object
  status*: Status
  appService: AppService
  view*: UtilsView
  variant*: QVariant

proc newController*(status: Status, appService: AppService): UtilsController =
  result = UtilsController()
  result.status = status
  result.appService = appService
  result.view = newUtilsView(status, appService)
  result.variant = newQVariant(result.view)

proc delete*(self: UtilsController) =
  delete self.variant
  delete self.view

proc init*(self: UtilsController) =
  self.view.asyncCheckForUpdates()
