import NimQml, chronicles
import status/[status, node, network]
import ../core/[main]
import view
import eventemitter

logScope:
  topics = "utils"

type UtilsController* = ref object
  status*: Status
  statusFoundation: StatusFoundation
  view*: UtilsView
  variant*: QVariant

proc newController*(status: Status, statusFoundation: StatusFoundation): UtilsController =
  result = UtilsController()
  result.status = status
  result.statusFoundation = statusFoundation
  result.view = newUtilsView(status, statusFoundation)
  result.variant = newQVariant(result.view)

proc delete*(self: UtilsController) =
  delete self.variant
  delete self.view

proc init*(self: UtilsController) =
  self.view.asyncCheckForUpdates()
