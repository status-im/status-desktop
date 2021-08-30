import NimQml, chronicles
import status/[signals, status, node, network]
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

proc init*(self: NodeController) =
  self.status.events.on(SignalType.Wallet.event) do(e:Args):
    self.view.setLastMessage($WalletSignal(e).blockNumber)

  self.status.events.on(SignalType.DiscoverySummary.event) do(e:Args):
    var data = DiscoverySummarySignal(e)
    self.status.network.peerSummaryChange(data.enodes)
    self.view.setPeerSize(data.enodes.len)

  self.status.events.on(SignalType.PeerStats.event) do(e:Args):
    var data = PeerStatsSignal(e)
    self.status.network.peerSummaryChange(data.peers)
    self.view.setPeerSize(data.peers.len)

  self.status.events.on(SignalType.Stats.event) do (e:Args):
    self.view.setStats(StatsSignal(e).stats)
    self.view.fetchBitsSet()

  self.status.events.on(SignalType.ChroniclesLogs.event) do(e:Args):
    self.view.log(ChroniclesLogsSignal(e).content)

  self.view.init()
