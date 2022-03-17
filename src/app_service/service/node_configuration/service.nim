import chronicles, json, strutils

import ./dto/node_config
import ../settings/service as settings_service
import ../../../app/core/fleets/fleet_configuration
import ../../../backend/node_config as status_node_config

export node_config

logScope:
  topics = "node-config-service"

const WAKU_VERSION_1* = 1
const WAKU_VERSION_2* = 2
const BLOOM_LEVEL_NORMAL* = "normal"
const BLOOM_LEVEL_FULL* = "full"
const BLOOM_LEVEL_LIGHT* = "light"

type
  Service* = ref object of RootObj
    configuration: NodeConfigDto
    fleetConfiguration: FleetConfiguration
    settingsService: settings_service.Service

proc delete*(self: Service) =
  discard

proc newService*(fleetConfiguration: FleetConfiguration, settingsService: settings_service.Service): Service =
  result = Service()
  result.fleetConfiguration = fleetConfiguration
  result.settingsService = settingsService

proc adaptNodeSettingsForTheAppNeed(self: Service) =
  let currentNetworkDetails = self.settingsService.getCurrentNetworkDetails()
  var dataDir = currentNetworkDetails.config.DataDir
  dataDir.removeSuffix("_rpc")

  self.configuration.DataDir = dataDir
  self.configuration.KeyStoreDir = "./keystore"
  self.configuration.LogFile = "./geth.log"
  self.configuration.ShhextConfig.BackupDisabledDataDir = "./"

proc init*(self: Service) =
  try:
    let response = status_node_config.getNodeConfig()
    self.configuration = response.result.toNodeConfigDto()

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

proc getBloomLevel*(self: Service): string =
  let wakuVersion = self.getWakuVersion()
  if wakuVersion == WAKU_VERSION_2:
    error "get - bloom level is supported only for a waku version 1"
    return BLOOM_LEVEL_NORMAL

  if wakuVersion == WAKU_VERSION_1:
    let bloomFilterMode = self.configuration.WakuConfig.BloomFilterMode
    let fullNode = self.configuration.WakuConfig.FullNode

    if (bloomFilterMode):
      if(fullNode):
        return BLOOM_LEVEL_FULL
      else:
        return BLOOM_LEVEL_NORMAL
    else:
      return BLOOM_LEVEL_LIGHT

proc setWakuVersion*(self: Service, wakuVersion: int): bool =
  var newConfiguration = self.configuration
  newConfiguration.RegisterTopics = @["whispermail"]
  newConfiguration.WakuConfig.Enabled = wakuVersion == WAKU_VERSION_1
  newConfiguration.WakuV2Config.Enabled = wakuVersion == WAKU_VERSION_2

  if wakuVersion == WAKU_VERSION_1:
    newConfiguration.NoDiscovery = false
    newConfiguration.Rendezvous = true
  elif wakuVersion == WAKU_VERSION_2:
    newConfiguration.NoDiscovery = true
    newConfiguration.Rendezvous = false
    newConfiguration.WakuV2Config.DiscoveryLimit = 20
    newConfiguration.WakuV2Config.Rendezvous = true
  return self.saveConfiguration(newConfiguration)

proc setNetwork*(self: Service, network: string): bool =
  if(not self.settingsService.saveCurrentNetwork(network)):
    error "error saving network ", network, procName="setNetwork"
    return false

  let currentNetworkDetails = self.settingsService.getCurrentNetworkDetails()
  var dataDir = currentNetworkDetails.config.DataDir
  dataDir.removeSuffix("_rpc")

  var newConfiguration = self.configuration
  newConfiguration.NetworkId = currentNetworkDetails.config.NetworkId
  newConfiguration.DataDir = dataDir
  newConfiguration.UpstreamConfig.Enabled = currentNetworkDetails.config.UpstreamConfig.Enabled
  newConfiguration.UpstreamConfig.URL = currentNetworkDetails.config.UpstreamConfig.URL
  return self.saveConfiguration(newConfiguration)

proc setBloomFilterMode*(self: Service, bloomFilterMode: bool): bool =
  if(not self.settingsService.saveWakuBloomFilterMode(bloomFilterMode)):
    error "error saving waku bloom filter mode ", procName="setBloomFilterMode"
    return false

  var newConfiguration = self.configuration
  newConfiguration.WakuConfig.BloomFilterMode = bloomFilterMode
  return self.saveConfiguration(newConfiguration)

proc setBloomLevel*(self: Service, bloomLevel: string): bool =
  let wakuVersion = self.getWakuVersion()
  if wakuVersion == WAKU_VERSION_2:
    error "set - bloom level is supported only for a waku version 1"
    return false

  # default is BLOOM_LEVEL_NORMAL
  var bloomFilterMode = false
  var fullNode = true
  if (bloomLevel == BLOOM_LEVEL_LIGHT):
    bloomFilterMode = false
    fullNode = false
  elif (bloomLevel == BLOOM_LEVEL_FULL):
    bloomFilterMode = true
    fullNode = true

  if(not self.settingsService.saveWakuBloomFilterMode(bloomFilterMode)):
    error "error saving waku bloom filter mode ", procName="setBloomLevel"
    return false

  if wakuVersion == WAKU_VERSION_1:
    var newConfiguration = self.configuration
    newConfiguration.WakuConfig.BloomFilterMode = bloomFilterMode
    newConfiguration.WakuConfig.FullNode = fullNode
    newConfiguration.WakuConfig.LightClient = not fullNode
    return self.saveConfiguration(newConfiguration)

  return false

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

  case fleetType:
    of Fleet.WakuV2Prod:
      newConfiguration.ClusterConfig.RelayNodes = @["enrtree://ANTL4SLG2COUILKAPE7EF2BYNL2SHSHVCHLRD5J7ZJLN5R3PRJD2Y@prod.waku.nodes.status.im"]
      newConfiguration.ClusterConfig.StoreNodes = @["enrtree://ANTL4SLG2COUILKAPE7EF2BYNL2SHSHVCHLRD5J7ZJLN5R3PRJD2Y@prod.waku.nodes.status.im"]
      newConfiguration.ClusterConfig.FilterNodes = @["enrtree://ANTL4SLG2COUILKAPE7EF2BYNL2SHSHVCHLRD5J7ZJLN5R3PRJD2Y@prod.waku.nodes.status.im"]
      newConfiguration.ClusterConfig.LightpushNodes = @["enrtree://ANTL4SLG2COUILKAPE7EF2BYNL2SHSHVCHLRD5J7ZJLN5R3PRJD2Y@prod.waku.nodes.status.im"]
    of Fleet.WakuV2Test:
      newConfiguration.ClusterConfig.RelayNodes = @["enrtree://AOFTICU2XWDULNLZGRMQS4RIZPAZEHYMV4FYHAPW563HNRAOERP7C@test.waku.nodes.status.im"]
      newConfiguration.ClusterConfig.StoreNodes = @["enrtree://AOFTICU2XWDULNLZGRMQS4RIZPAZEHYMV4FYHAPW563HNRAOERP7C@test.waku.nodes.status.im"]
      newConfiguration.ClusterConfig.FilterNodes = @["enrtree://AOFTICU2XWDULNLZGRMQS4RIZPAZEHYMV4FYHAPW563HNRAOERP7C@test.waku.nodes.status.im"]
      newConfiguration.ClusterConfig.LightpushNodes = @["enrtree://AOFTICU2XWDULNLZGRMQS4RIZPAZEHYMV4FYHAPW563HNRAOERP7C@test.waku.nodes.status.im"]
    of Fleet.StatusTest, Fleet.StatusProd:
      newConfiguration.ClusterConfig.RelayNodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.TCP_P2P_Waku)
      newConfiguration.ClusterConfig.StoreNodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.TCP_P2P_Waku)
      newConfiguration.ClusterConfig.FilterNodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.TCP_P2P_Waku)
      newConfiguration.ClusterConfig.LightpushNodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.TCP_P2P_Waku)
    else:
      discard

  # Disabling go-waku rendezvous
  # newConfiguration.ClusterConfig.WakuRendezvousNodes = self.fleetConfiguration.getNodes(Fleet.GoWakuTest, FleetNodes.LibP2P)

  try:
    discard status_node_config.switchFleet(fleet, newConfiguration.toJsonNode())
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

proc getDebugLevel*(self: Service): string =
  return self.configuration.LogLevel

proc setDebugLevel*(self: Service, logLevel: LogLevel): bool =
  var newConfiguration = self.configuration
  newConfiguration.LogLevel = $logLevel
  return self.saveConfiguration(newConfiguration)

proc isV2LightMode*(self: Service): bool =
   return self.configuration.WakuV2Config.LightClient

proc isFullNode*(self: Service): bool =
   return self.configuration.WakuConfig.FullNode
