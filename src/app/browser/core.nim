import NimQml, chronicles
import ../../status/status
import ../../status/libstatus/types as status_types
import view

logScope:
  topics = "browser"

type BrowserController* = ref object
  status*: Status
  view*: BrowserView
  variant*: QVariant

proc newController*(status: Status): BrowserController =
  result = BrowserController()
  result.status = status
  result.view = newBrowserView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: BrowserController) =
  delete self.variant
  delete self.view

proc init*(self: BrowserController) =
  self.view.init()
  discard
