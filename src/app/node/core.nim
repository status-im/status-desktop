import NimQml, chronicles
import status/[status, node, network, settings]
import ../core/[main]
import eventemitter
import view

logScope:
  topics = "node"

type NodeController* = ref object
  statusFoundation: StatusFoundation
  view*: NodeView
  variant*: QVariant
  isWakuV2: bool

proc newController*(statusFoundation: StatusFoundation): NodeController =
  result = NodeController()
  result.statusFoundation = statusFoundation
  result.view = newNodeView(statusFoundation)
  result.variant = newQVariant(result.view)

proc delete*(self: NodeController) =
  delete self.variant
  delete self.view

proc setPeers(self: NodeController, peers: seq[string]) =
  self.statusFoundation.status.network.peerSummaryChange(peers)
  self.view.setPeerSize(peers.len)

proc init*(self: NodeController) =
  self.isWakuV2 = self.statusFoundation.status.settings.getWakuVersion() == 2
  
  self.statusFoundation.status.events.on(SignalType.Wallet.event) do(e:Args):
    self.view.setLastMessage($WalletSignal(e).blockNumber)

  self.statusFoundation.status.events.on(SignalType.DiscoverySummary.event) do(e:Args):
    var data = DiscoverySummarySignal(e)
    self.setPeers(data.enodes)

  self.statusFoundation.status.events.on(SignalType.PeerStats.event) do(e:Args):
    var data = PeerStatsSignal(e)
    self.setPeers(data.peers)

  self.statusFoundation.status.events.on(SignalType.Stats.event) do (e:Args):
    self.view.setStats(StatsSignal(e).stats)
    if not self.isWakuV2: self.view.fetchBitsSet()

  self.statusFoundation.status.events.on(SignalType.ChroniclesLogs.event) do(e:Args):
    self.view.log(ChroniclesLogsSignal(e).content)

  self.view.init()

  self.setPeers(self.statusFoundation.status.network.fetchPeers())
