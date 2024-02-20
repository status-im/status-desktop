import chronicles, strutils

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

type
  NodeLogLevelUpdatedArgs* = ref object of Args
    logLevel*: LogLevel

type
  ErrorArgs* = ref object of Args
    msg*: string

type
  Service* = ref object of RootObj
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

proc newService*(fleetConfiguration: FleetConfiguration, settingsService: settings_service.Service, events: EventEmitter): Service =
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

  if (not self.isCommunityHistoryArchiveSupportEnabled()):
    # Force community archive support true on Desktop
    # TODO those lines can be removed in the future once we are sure no one has used a legacy client where it is off
    if (self.enableCommunityHistoryArchiveSupport()):
      self.configuration.TorrentConfig.Enabled = true
    else:
      error "Setting Community History Archive On failed"

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

proc saveConfiguration(self: Service, configuration: NodeConfigDto): bool =
  if(not self.settingsService.saveNodeConfiguration(configuration.toJsonNode())):
    error "error saving node configuration "
    return false
  self.configuration = configuration
  return true

proc getWakuVersion*(self: Service): int =
  if self.configuration.WakuConfig.Enabled:
    return WAKU_VERSION_1
  elif self.configuration.WakuV2Config.Enabled:
    return WAKU_VERSION_2

  error "unsupported waku version"
  return 0

proc isShardFleet(config: NodeConfigDto): bool =
  return case config.ClusterConfig.Fleet:
    of $Fleet.ShardsTest: true
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
  if(not response.error.isNil):
    error "error enabling community history archive support: ", errDescription = response.error.message
    return false

  return true

proc getFleet*(self: Service): Fleet =
  result = self.settingsService.getFleet()
  if result == Fleet.Undefined:
    let fleetFromNodeConfig = self.configuration.ClusterConfig.Fleet
    result = parseEnum[Fleet](fleetFromNodeConfig)

proc getFleetAsString*(self: Service): string =
  result = $self.getFleet()

proc getAllWakuNodes*(self: Service): seq[string] =
  return self.wakuNodes

proc saveNewWakuNode*(self: Service, nodeAddress: string) =
  var newConfiguration = self.configuration
  newConfiguration.ClusterConfig.WakuNodes.add(nodeAddress)
  self.configuration = newConfiguration
  discard self.saveConfiguration(newConfiguration)

proc setFleet*(self: Service, fleet: string): bool =
  if(not self.settingsService.saveFleet(fleet)):
    error "error saving fleet ", procName="setFleet"
    return false
  
  let fleetType = parseEnum[Fleet](fleet)
  var newConfiguration = self.configuration
  newConfiguration.ClusterConfig.Fleet = fleet
  newConfiguration.ClusterConfig.BootNodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.Bootnodes)
  newConfiguration.ClusterConfig.TrustedMailServers = self.fleetConfiguration.getNodes(fleetType, FleetNodes.Mailservers)
  newConfiguration.ClusterConfig.StaticNodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.Whisper)
  newConfiguration.ClusterConfig.RendezvousNodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.Rendezvous)

  var dnsDiscoveryURL: seq[string] = @[]
  case fleetType:
    of Fleet.WakuV2Prod:
      dnsDiscoveryURL.add("enrtree://ANEDLO25QVUGJOUTQFRYKWX6P4Z4GKVESBMHML7DZ6YK4LGS5FC5O@prod.wakuv2.nodes.status.im")
    of Fleet.WakuV2Test:
      dnsDiscoveryURL.add("enrtree://AO47IDOLBKH72HIZZOXQP6NMRESAN7CHYWIBNXDXWRJRZWLODKII6@test.wakuv2.nodes.status.im")
    of Fleet.ShardsTest:
      dnsDiscoveryURL.add("enrtree://AMOJVZX4V6EXP7NTJPMAYJYST2QP6AJXYW76IU6VGJS7UVSNDYZG4@boot.test.shards.nodes.status.im")
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

proc getV2LightMode*(self: Service): bool =
  return self.configuration.WakuV2Config.LightClient

proc setV2LightMode*(self: Service, enabled: bool): bool =
  var newConfiguration = self.configuration
  newConfiguration.WakuV2Config.LightClient = enabled
  return self.saveConfiguration(newConfiguration)

proc getLogLevel(self: Service): string =
  return self.configuration.LogLevel

proc isDebugEnabled*(self: Service): bool =
  var logLevel = self.getLogLevel()
  if main_constants.runtimeLogLevelSet():
    logLevel = main_constants.LOG_LEVEL
  return logLevel in DEBUG_LOG_LEVELS

proc setLogLevel*(self: Service, logLevel: LogLevel): bool =
  var newConfiguration = self.configuration
  newConfiguration.LogLevel = $logLevel
  if self.saveConfiguration(newConfiguration):
    self.events.emit(SIGNAL_NODE_LOG_LEVEL_UPDATE, NodeLogLevelUpdatedArgs(logLevel: logLevel))
    return true
  else:
    return false

proc getNimbusProxyConfig(self: Service): bool =
  return self.configuration.NimbusProxyConfig.Enabled

proc isNimbusProxyEnabled*(self: Service): bool =
  return self.getNimbusProxyConfig()

proc setNimbusProxyConfig*(self: Service, value: bool): bool =
  var newConfiguration = self.configuration
  newConfiguration.NimbusProxyConfig.Enabled = value
  return self.saveConfiguration(newConfiguration)

proc isV2LightMode*(self: Service): bool =
   return self.configuration.WakuV2Config.LightClient

proc isFullNode*(self: Service): bool =
   return self.configuration.WakuConfig.FullNode

proc getLogMaxBackups*(self: Service): int =
  return self.configuration.LogMaxBackups

proc setMaxLogBackups*(self: Service, value: int): bool =
  var newConfiguration = self.configuration
  newConfiguration.LogMaxBackups = value
  return self.saveConfiguration(newConfiguration)
