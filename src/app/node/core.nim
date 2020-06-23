import NimQml, chronicles
import ../../signals/types
import ../../status/[status, node]
import view

logScope:
  topics = "node"

type NodeController* = ref object of SignalSubscriber
  status*: Status
  view*: NodeView
  variant*: QVariant

proc newController*(status: Status): NodeController =
  result = NodeController()
  result.status = status
  result.view = newNodeView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: NodeController) =
  delete self.variant
  delete self.view

proc init*(self: NodeController) =
  discard

method onSignal(self: NodeController, data: Signal) =
  debug "New signal received"
  var msg = cast[WalletSignal](data)
  self.view.setLastMessage(msg.content)
