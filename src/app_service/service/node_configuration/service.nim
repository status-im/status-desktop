import chronicles, json, strutils

import service_interface
import ./dto/node_config
import ../settings/service_interface as settings_service
import ../../../app/core/fleets/fleet_configuration
import status/statusgo_backend_new/node_config as status_node_config

export service_interface

logScope:
  topics = "node-config-service"

type
  Service* = ref object of service_interface.ServiceInterface
    configuration: NodeConfigDto
    fleetConfiguration: FleetConfiguration
    settingsService: settings_service.ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(fleetConfiguration: FleetConfiguration, settingsService: settings_service.ServiceInterface): Service =
  result = Service()
  result.fleetConfiguration = fleetConfiguration
  result.settingsService = settingsService

proc adaptNodeSettingsForTheAppNeed(self: Service) = 
  let currentNetworkDetails = self.settingsService.getCurrentNetworkDetails()
  var dataDir = currentNetworkDetails.config.dataDir
  dataDir.removeSuffix("_rpc")
  
  self.configuration.DataDir = dataDir
  self.configuration.KeyStoreDir = "./keystore"
  self.configuration.LogFile = "./geth.log"
  self.configuration.ShhextConfig.BackupDisabledDataDir = "./"

method init*(self: Service) =
  try:
    let response = status_node_config.getNodeConfig()
    self.configuration = response.result.toNodeConfigDto()

    self.adaptNodeSettingsForTheAppNeed()
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc saveConfiguration(self: Service, configuration: NodeConfigDto) =
  if(not self.settingsService.saveNodeConfiguration(configuration.toJsonNode())):
    error "error saving node configuration "
    return
  self.configuration = configuration
  
method getWakuVersion*(self: Service): int =
  if self.configuration.WakuConfig.Enabled:
    return WAKU_VERSION_1
  elif self.configuration.WakuV2Config.Enabled:
    return WAKU_VERSION_2
  return 0

method setWakuVersion*(self: Service, wakuVersion: int) =
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
  self.saveConfiguration(newConfiguration)

method setNetwork*(self: Service, network: string) =
  if(not self.settingsService.saveCurrentNetwork(network)):
    error "error saving network ", network, methodName="setNetwork"
    return

  let currentNetworkDetails = self.settingsService.getCurrentNetworkDetails()
  var dataDir = currentNetworkDetails.config.dataDir
  dataDir.removeSuffix("_rpc")

  var newConfiguration = self.configuration
  newConfiguration.NetworkId = currentNetworkDetails.config.networkId
  newConfiguration.DataDir = dataDir
  newConfiguration.UpstreamConfig.Enabled = currentNetworkDetails.config.upstreamConfig.enabled
  newConfiguration.UpstreamConfig.URL = currentNetworkDetails.config.upstreamConfig.url
  self.saveConfiguration(newConfiguration)
  
method setBloomFilterMode*(self: Service, bloomFilterMode: bool) =
  if(not self.settingsService.saveWakuBloomFilterMode(bloomFilterMode)):
    error "error saving waku bloom filter mode ", methodName="setBloomFilterMode"
    return

  var newConfiguration = self.configuration
  newConfiguration.WakuConfig.BloomFilterMode = bloomFilterMode
  self.saveConfiguration(newConfiguration)

method setBloomLevel*(self: Service, bloomFilterMode: bool, fullNode: bool) =
  if(not self.settingsService.saveWakuBloomFilterMode(bloomFilterMode)):
    error "error saving waku bloom filter mode ", methodName="setBloomLevel"
    return

  var newConfiguration = self.configuration
  newConfiguration.WakuConfig.BloomFilterMode = bloomFilterMode
  newConfiguration.WakuConfig.FullNode = fullNode
  newConfiguration.WakuConfig.LightClient = not fullNode
  self.saveConfiguration(newConfiguration)

method setFleet*(self: Service, fleet: string) =
  if(not self.settingsService.saveFleet(fleet)):
    error "error saving fleet ", methodName="setFleet"
    return

  let fleetType = parseEnum[Fleet](fleet)
  var newConfiguration = self.configuration
  newConfiguration.ClusterConfig.Fleet = fleet
  newConfiguration.ClusterConfig.BootNodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.Bootnodes)
  newConfiguration.ClusterConfig.TrustedMailServers = self.fleetConfiguration.getNodes(fleetType, FleetNodes.Mailservers)
  newConfiguration.ClusterConfig.StaticNodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.Whisper)
  newConfiguration.ClusterConfig.RendezvousNodes = self.fleetConfiguration.getNodes(fleetType, FleetNodes.Rendezvous)
  newConfiguration.ClusterConfig.RelayNodes = @["enrtree://AOFTICU2XWDULNLZGRMQS4RIZPAZEHYMV4FYHAPW563HNRAOERP7C@test.nodes.vac.dev"]
  newConfiguration.ClusterConfig.StoreNodes = @["enrtree://AOFTICU2XWDULNLZGRMQS4RIZPAZEHYMV4FYHAPW563HNRAOERP7C@test.nodes.vac.dev"]
  newConfiguration.ClusterConfig.FilterNodes = @["enrtree://AOFTICU2XWDULNLZGRMQS4RIZPAZEHYMV4FYHAPW563HNRAOERP7C@test.nodes.vac.dev"]
  newConfiguration.ClusterConfig.LightpushNodes = @["enrtree://AOFTICU2XWDULNLZGRMQS4RIZPAZEHYMV4FYHAPW563HNRAOERP7C@test.nodes.vac.dev"]
  #TODO: in the meantime we're using the go-waku test fleet for rendezvous.
  #      once we have a prod fleet this code needs to be updated
  newConfiguration.ClusterConfig.WakuRendezvousNodes = self.fleetConfiguration.getNodes(Fleet.GoWakuTest, FleetNodes.LibP2P)
  self.saveConfiguration(newConfiguration)

method setV2LightMode*(self: Service, enabled: bool) =
  var newConfiguration = self.configuration
  newConfiguration.WakuV2Config.LightClient = enabled
  self.saveConfiguration(newConfiguration)
