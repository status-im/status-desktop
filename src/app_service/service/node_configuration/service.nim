import chronicles

import ./dto/node_config
import ../settings/service as settings_service
import ../../../app/core/eventemitter
import ../../../app/core/fleets/fleet_configuration
import ../../../backend/node_config as status_node_config
import ../../../constants as main_constants

export node_config

logScope:
  topics = "node-config-service"

const WAKU_VERSION_1* = 1
const WAKU_VERSION_2* = 2

const
  SIGNAL_NODE_LOG_LEVEL_UPDATE* = "nodeLogLevelUpdated"
  DEBUG_LOG_LEVELS = @["DEBUG", "TRACE"]

type NodeLogLevelUpdatedArgs* = ref object of Args
  logLevel*: LogLevel

type ErrorArgs* = ref object of Args
  msg*: string

type Service* = ref object of RootObj
  configuration: NodeConfigDto
  fleetConfiguration: FleetConfiguration
  settingsService: settings_service.Service
  wakuNodes: seq[string]
  events: EventEmitter

# Forward declarations
proc isCommunityHistoryArchiveSupportEnabled*(self: Service): bool
proc enableCommunityHistoryArchiveSupport*(self: Service): bool

proc delete*(self: Service) =
  discard

proc newService*(
    fleetConfiguration: FleetConfiguration,
    settingsService: settings_service.Service,
    events: EventEmitter,
): Service =
  result = Service()
  result.fleetConfiguration = fleetConfiguration
  result.settingsService = settingsService
  result.events = events
  result.wakuNodes = @[]

proc adaptNodeSettingsForTheAppNeed(self: Service) =
  self.configuration.DataDir = "./ethereum"
  self.configuration.KeyStoreDir = "./keystore"
  self.configuration.LogFile = "./geth.log"
  self.configuration.ShhextConfig.BackupDisabledDataDir = "./"

proc init*(self: Service) =
  try:
    let response = status_node_config.getNodeConfig()
    self.configuration = response.result.toNodeConfigDto()

    let wakuNodes = self.configuration.ClusterConfig.WakuNodes
    for nodeAddress in wakuNodes:
      self.wakuNodes.add(nodeAddress)

    self.adaptNodeSettingsForTheAppNeed()
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc getWakuVersion*(self: Service): int =
  if self.configuration.WakuConfig.Enabled:
    return WAKU_VERSION_1
  elif self.configuration.WakuV2Config.Enabled:
    return WAKU_VERSION_2

  error "unsupported waku version"
  return 0

proc isShardFleet(config: NodeConfigDto): bool =
  return
    case config.ClusterConfig.Fleet
    of $Fleet.StatusProd: true
    of $Fleet.StatusStaging: true
    else: false

proc setWakuConfig(configuration: NodeConfigDto): NodeConfigDto =
  var newConfiguration = configuration
  newConfiguration.RegisterTopics = @["whispermail"]
  newConfiguration.NoDiscovery = true
  newConfiguration.Rendezvous = false
  newConfiguration.WakuConfig.Enabled = false
  newConfiguration.WakuV2Config.Enabled = true
  newConfiguration.WakuV2Config.EnableDiscV5 = true
  newConfiguration.WakuV2Config.DiscoveryLimit = 20
  newConfiguration.WakuV2Config.Rendezvous = true
  newConfiguration.WakuV2Config.UseShardAsDefaultTopic = isShardFleet(newConfiguration)

  return newConfiguration

proc isCommunityHistoryArchiveSupportEnabled*(self: Service): bool =
  return self.configuration.TorrentConfig.Enabled

proc enableCommunityHistoryArchiveSupport*(self: Service): bool =
  let response = status_node_config.enableCommunityHistoryArchiveSupport()
  if (not response.error.isNil):
    error "error enabling community history archive support: ",
      errDescription = response.error.message
    return false

  self.configuration.TorrentConfig.Enabled = true
  return true

proc disableCommunityHistoryArchiveSupport*(self: Service): bool =
  let response = status_node_config.disableCommunityHistoryArchiveSupport()
  if (not response.error.isNil):
    error "error disabling community history archive support: ",
      errDescription = response.error.message
    return false

  self.configuration.TorrentConfig.Enabled = false
  return true

proc getFleet*(self: Service): Fleet =
  result = self.settingsService.getFleet()
  if result == Fleet.Undefined:
    let fleetFromNodeConfig = self.configuration.ClusterConfig.Fleet
    result = fleetFromString(fleetFromNodeConfig)

proc getFleetAsString*(self: Service): string =
  result = $self.getFleet()

proc getAllWakuNodes*(self: Service): seq[string] =
  return self.wakuNodes

proc saveNewWakuNode*(self: Service, nodeAddress: string): bool =
  try:
    let response = status_node_config.saveNewWakuNode(nodeAddress)

    if not response.error.isNil:
      error "failed to add new waku node: ", errDescription = response.error.message
      return false

    self.configuration.ClusterConfig.WakuNodes.add(nodeAddress)
  except Exception as e:
    error "error saving new waku node: ", errDescription = e.msg
    return false
  return true

proc setFleet*(self: Service, fleet: string): bool =
  if (not self.settingsService.saveFleet(fleet)):
    error "error saving fleet ", procName = "setFleet"
    return false

  let fleetType = fleetFromString(fleet)
  var newConfiguration = self.configuration
  newConfiguration.ClusterConfig.Fleet = fleet
  newConfiguration.ClusterConfig.BootNodes =
    self.fleetConfiguration.getNodes(fleetType, FleetNodes.Bootnodes)
  newConfiguration.ClusterConfig.TrustedMailServers =
    self.fleetConfiguration.getNodes(fleetType, FleetNodes.Mailservers)
  newConfiguration.ClusterConfig.StaticNodes =
    self.fleetConfiguration.getNodes(fleetType, FleetNodes.Whisper)
  newConfiguration.ClusterConfig.RendezvousNodes =
    self.fleetConfiguration.getNodes(fleetType, FleetNodes.Rendezvous)

  var dnsDiscoveryURL: seq[string] = @[]
  case fleetType
  of Fleet.WakuSandbox:
    dnsDiscoveryURL.add(
      "enrtree://AIRVQ5DDA4FFWLRBCHJWUWOO6X6S4ZTZ5B667LQ6AJU6PEYDLRD5O@sandbox.waku.nodes.status.im"
    )
  of Fleet.WakuTest:
    dnsDiscoveryURL.add(
      "enrtree://AOGYWMBYOUIMOENHXCHILPKY3ZRFEULMFI4DOM442QSZ73TT2A7VI@test.waku.nodes.status.im"
    )
  of Fleet.StatusProd:
    dnsDiscoveryURL.add(
      "enrtree://AMOJVZX4V6EXP7NTJPMAYJYST2QP6AJXYW76IU6VGJS7UVSNDYZG4@boot.prod.status.nodes.status.im"
    )
  of Fleet.StatusStaging:
    dnsDiscoveryURL.add(
      "enrtree://AI4W5N5IFEUIHF5LESUAOSMV6TKWF2MB6GU2YK7PU4TYUGUNOCEPW@boot.staging.status.nodes.status.im"
    )
  else:
    discard

  newConfiguration.ClusterConfig.WakuNodes = dnsDiscoveryURL

  var discV5Bootnodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.WakuENR)
  if dnsDiscoveryURL.len != 0:
    discV5Bootnodes.add(dnsDiscoveryURL[0])

  newConfiguration.ClusterConfig.DiscV5BootstrapNodes = discV5Bootnodes

  newConfiguration = setWakuConfig(newConfiguration)

  try:
    discard status_node_config.switchFleet(fleet, newConfiguration.toJsonNode())
    self.configuration = newConfiguration
    return true
  except:
    error "Could not switch fleet"
    return false

proc setLightClient*(self: Service, enabled: bool): bool =
  let response = status_node_config.setLightClient(enabled)

  if not response.error.isNil:
    error "failed to set light client: ", errDescription = response.error.message
    return false

  self.configuration.WakuV2Config.LightClient = enabled
  return true

proc getLogLevel(self: Service): string =
  return self.configuration.LogLevel

proc isDebugEnabled*(self: Service): bool =
  var logLevel = self.getLogLevel()
  if main_constants.runtimeLogLevelSet():
    logLevel = main_constants.LOG_LEVEL
  return logLevel in DEBUG_LOG_LEVELS

proc setLogLevel*(self: Service, logLevel: LogLevel): bool =
  let response = status_node_config.setLogLevel(logLevel)

  if not response.error.isNil:
    error "failed to set log level: ", errDescription = response.error.message
    return false

  self.configuration.LogLevel = $logLevel
  self.events.emit(
    SIGNAL_NODE_LOG_LEVEL_UPDATE, NodeLogLevelUpdatedArgs(logLevel: logLevel)
  )
  return true

proc getNimbusProxyConfig(self: Service): bool =
  return self.configuration.NimbusProxyConfig.Enabled

proc isNimbusProxyEnabled*(self: Service): bool =
  return self.getNimbusProxyConfig()

proc setNimbusProxyConfigEnabled*(self: Service, enabled: bool): bool =
  # FIXME: call status-go API to update NodeConfig
  # when this is merged https://github.com/status-im/status-go/pull/4254
  self.configuration.NimbusProxyConfig.Enabled = enabled
  return true

proc isLightClient*(self: Service): bool =
  return self.configuration.WakuV2Config.LightClient

proc isFullNode*(self: Service): bool =
  return self.configuration.WakuConfig.FullNode

proc getLogMaxBackups*(self: Service): int =
  return self.configuration.LogMaxBackups

proc setMaxLogBackups*(self: Service, value: int): bool =
  let response = status_node_config.setMaxLogBackups(value)

  if not response.error.isNil:
    error "failed to set max log backups: ", errDescription = response.error.message
    return false

  self.configuration.LogMaxBackups = value
  return true
