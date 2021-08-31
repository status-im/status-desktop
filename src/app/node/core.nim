import NimQml, chronicles
import status/[signals, status, node, network, settings]
import ../../app_service/[main]
import eventemitter
import view

logScope:
  topics = "node"

type NodeController* = ref object
  status*: Status
  appService: AppService
  view*: NodeView
  variant*: QVariant
  networkAccessMananger*: QNetworkAccessManager
  isWakuV2: bool

proc newController*(status: Status, appService: AppService, nam: QNetworkAccessManager): NodeController =
  result = NodeController()
  result.status = status
  result.appService = appService
  result.view = newNodeView(status, appService)
  result.variant = newQVariant(result.view)
  result.networkAccessMananger = nam

proc delete*(self: NodeController) =
  delete self.variant
  delete self.view

proc setPeers(self: NodeController, peers: seq[string]) =
  self.status.network.peerSummaryChange(peers)
  self.view.setPeerSize(peers.len)

proc init*(self: NodeController) =
  self.isWakuV2 = self.status.settings.getWakuVersion() == 2
  self.status.events.on(SignalType.Wallet.event) do(e:Args):
    self.view.setLastMessage($WalletSignal(e).blockNumber)

  self.status.events.on(SignalType.DiscoverySummary.event) do(e:Args):
    var data = DiscoverySummarySignal(e)
    self.setPeers(data.enodes)

  self.status.events.on(SignalType.PeerStats.event) do(e:Args):
    var data = PeerStatsSignal(e)
    self.setPeers(data.peers)

  self.status.events.on(SignalType.Stats.event) do (e:Args):
    self.view.setStats(StatsSignal(e).stats)
    if not self.isWakuV2: self.view.fetchBitsSet()

  self.status.events.on(SignalType.ChroniclesLogs.event) do(e:Args):
    self.view.log(ChroniclesLogsSignal(e).content)

  self.view.init()

  self.setPeers(self.status.network.fetchPeers())
