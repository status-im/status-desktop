import NimQml, chronicles
import ../../signals/types
import ../../status/[status, node, network]
import ../../status/libstatus/types as status_types
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

proc handleWalletSignal(self: NodeController, data: WalletSignal) =
  self.view.setLastMessage(data.content)

proc handleDiscoverySummary(self: NodeController, data: DiscoverySummarySignal) =
  self.status.network.peerSummaryChange(data.enodes)

method onSignal(self: NodeController, data: Signal) =
  case data.signalType: 
  of SignalType.Wallet: handleWalletSignal(self, WalletSignal(data))
  of SignalType.DiscoverySummary: handleDiscoverySummary(self, DiscoverySummarySignal(data))
  else:
    warn "Unhandled signal received", signalType = data.signalType
  
