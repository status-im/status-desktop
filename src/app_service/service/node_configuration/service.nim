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
  self.configuration.DataDir = "./ethereum"
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

proc fetchNodeConfig(self: Service) =
  try:
    let response = status_node_config.getNodeConfig()
    self.configuration = response.result.toNodeConfigDto()
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

method enableCommunityHistoryArchiveSupport*(self: Service): bool =
  let response = status_node_config.enableCommunityHistoryArchiveSupport()
  if(not response.error.isNil):
    error "error enabling community history archive support: ", errDescription = response.error.message
    return false

  self.fetchNodeConfig()
  return true

method disableCommunityHistoryArchiveSupport*(self: Service): bool =
  let response = status_node_config.disableCommunityHistoryArchiveSupport()
  if(not response.error.isNil):
    error "error disabling community history archive support: ", errDescription = response.error.message
    return false

  self.fetchNodeConfig()
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


proc setWakuConfig(configuration: NodeConfigDto, wakuVersion: int): NodeConfigDto =
  var newConfiguration = configuration
  newConfiguration.RegisterTopics = @["whispermail"]
  newConfiguration.WakuConfig.Enabled = wakuVersion == WAKU_VERSION_1
  newConfiguration.WakuV2Config.Enabled = wakuVersion == WAKU_VERSION_2

  if wakuVersion == WAKU_VERSION_1:
    newConfiguration.NoDiscovery = false
    newConfiguration.Rendezvous = true
  elif wakuVersion == WAKU_VERSION_2:
    newConfiguration.NoDiscovery = true
    newConfiguration.Rendezvous = false
    newConfiguration.WakuV2Config.EnableDiscV5 = true
    newConfiguration.WakuV2Config.DiscoveryLimit = 20
    newConfiguration.WakuV2Config.Rendezvous = true

  return newConfiguration

proc setWakuVersion*(self: Service, wakuVersion: int): bool =
  let newConfiguration = setWakuConfig(self.configuration, wakuVersion)
  return self.saveConfiguration(newConfiguration)

method isCommunityHistoryArchiveSupportEnabled*(self: Service): bool =
  return self.configuration.TorrentConfig.Enabled

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
  if bloomLevel == BLOOM_LEVEL_LIGHT:
    bloomFilterMode = false
    fullNode = false
  elif bloomLevel == BLOOM_LEVEL_FULL:
    bloomFilterMode = true
    fullNode = true
  elif bloomLevel == BLOOM_LEVEL_NORMAL:
    bloomFilterMode = true
    fullNode = false

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

  var wakuVersion = 2
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
      wakuVersion = 1

  if fleetType == Fleet.StatusTest:
    newConfiguration.ClusterConfig.DiscV5BootstrapNodes = @[
      "enr:-JK4QM2ylZVUhVPqXrqhWWi38V46bF2XZXPSHh_D7f2PmUHbIw-4DidCBnBnm-IbxtjXOFbdMMgpHUv4dYVH6TgnkucBgmlkgnY0gmlwhCJ6_HaJc2VjcDI1NmsxoQM06FsT6EJ57mzR_wiLu2Bz1dER2nUFSCpaXzCccQtnhYN0Y3CCdl-DdWRwgiMohXdha3UyDw",
      "enr:-JK4QAi2yenhIbflVpUtkLDAM7yR5qeinZSQ_TNxfAWxdffkQWlstXyspEUlapiLl-S_MTPyp5V1uiV14ATjcVU_iLoBgmlkgnY0gmlwhC_y6SSJc2VjcDI1NmsxoQJkb7I6j5X1-zjieMeBdxgDqQWuMuDUEqDR419lyKNZb4N0Y3CCdl-DdWRwgiMohXdha3UyDw",
      "enr:-JK4QIGyJyjSlponBZqe9XZ75b5ePSU9fWw5UtxEF1vsYXTLYkTa4psnUxJPmOcJGVt9XCYpC2h2kNoowl1t5KzuW6wBgmlkgnY0gmlwhEDhUe2Jc2VjcDI1NmsxoQIE3HkSvDkl2zD64j2kGMH9XZHpuu-5VYT4wnBgJApW_oN0Y3CCdl-DdWRwgiMohXdha3UyDw"
    ]

  if fleetType == Fleet.StatusProd:
    newConfiguration.ClusterConfig.DiscV5BootstrapNodes = @[     
      "enr:-JK4QM_67uA3pGij4m6J0Bka7-Hzb7HdHXVfopgOD8HAMvD_YlPz9nJ9WLsXJMsG8naD8cRwpzx56bojkwKnX24-UwMBgmlkgnY0gmlwhCPKN5mJc2VjcDI1NmsxoQIaKnT5AGTbzUbsxHnAxsJ7eVGxffKsDNej2RtyZlupFIN0Y3CCdl-DdWRwgiMohXdha3UyDw",
      "enr:-JK4QHlrYkod8u0NYpBV_1iVCeiU6jVn80UJtbbyOMuO5gkIUGmfSxfMjNrcxkApxHGGiVDizs_6_SzoOAxS6zMxg7YBgmlkgnY0gmlwhCKE1emJc2VjcDI1NmsxoQMLQEj6Ys-Rqt87hblheDE74kFYqYtx2kBsrRfuMH23b4N0Y3CCdl-DdWRwgiMohXdha3UyDw",
      "enr:-JK4QF8RVwcRLTV0hfSwvpZECy1j8YKu7uy8z7X82qoQC_5LbdTkfRdPiuCgdjydbR3Bti6rvG4hqGtwSlIWDVZDadcBgmlkgnY0gmlwhC_zgIaJc2VjcDI1NmsxoQMxOGCAazyuaE__TL2BHoIJmg3dtOYlODZ9TAIVOcamOYN0Y3CCdl-DdWRwgiMohXdha3UyDw"
    ]

  # Disabling go-waku rendezvous
  # newConfiguration.ClusterConfig.WakuRendezvousNodes = self.fleetConfiguration.getNodes(Fleet.GoWakuTest, FleetNodes.LibP2P)

  newConfiguration = setWakuConfig(newConfiguration, wakuVersion)


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
