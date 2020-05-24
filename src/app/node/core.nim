import NimQml
import chronicles
import eventemitter
import "../../status/core" as status
import ../../signals/types
import ../../models/node
import view

logScope:
  topics = "node"

type NodeController* = ref object of SignalSubscriber
  model*: NodeModel
  view*: NodeView
  variant*: QVariant

proc newController*(events: EventEmitter): NodeController =
  result = NodeController()
  result.model = newNodeModel(events)
  result.view = newNodeView(result.model)
  result.variant = newQVariant(result.view)

proc delete*(self: NodeController) =
  delete self.view
  delete self.variant

proc init*(self: NodeController) =
  discard

method onSignal(self: NodeController, data: Signal) =
  debug "New signal received"
  var msg = cast[WalletSignal](data)
  self.view.setLastMessage(msg.content)
