import NimQml
import chronicles
import "../../status/core" as status
import ../signals/types
import nodeView

logScope:
  topics = "node"

type NodeController* = ref object of SignalSubscriber
  view*: NodeView
  variant*: QVariant

var sendRPCMessage = proc (msg: string): string =
  echo "sending RPC message"
  status.callPrivateRPC(msg)

proc newController*(): NodeController =
  result = NodeController()
  result.view = newNodeView(sendRPCMessage)
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
