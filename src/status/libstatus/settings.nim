import
  json, tables, sugar, sequtils, strutils, atomics, os

import
  json_serialization, chronicles, uuids

import
  ./core, ../types, ../signals/types as statusgo_types, ./accounts/constants,
  ../utils

from status_go import nil

var
  settings {.threadvar.}: JsonNode
  settingsInited {.threadvar.}: bool
  dirty: Atomic[bool]

dirty.store(true)
settings = %* {}

proc saveSetting*(key: Setting, value: string | JsonNode | bool): StatusGoError =
  try:
    let response = callPrivateRPC("settings_saveSetting", %* [key, value])
    let responseResult = $(response.parseJSON(){"result"})
    if responseResult == "null":
      result.error = ""
    else: result = Json.decode(response, StatusGoError)
    dirty.store(true)
  except Exception as e:
    error "Error saving setting", key=key, value=value, msg=e.msg

proc getWeb3ClientVersion*(): string =
  parseJson(callPrivateRPC("web3_clientVersion"))["result"].getStr

proc getSettings*(useCached: bool = true, keepSensitiveData: bool = false): JsonNode =
  let cacheIsDirty = (not settingsInited) or dirty.load
  if useCached and (not cacheIsDirty) and (not keepSensitiveData):
    result = settings
  else:
    var
      allSettings = callPrivateRPC("settings_getSettings").parseJSON()["result"]
    var
      noSensitiveData = allSettings.deepCopy
    noSensitiveData.delete("mnemonic")
    if not keepSensitiveData:
      result = noSensitiveData
    else:
      result = allSettings
    dirty.store(false)
    settings = noSensitiveData # never include sensitive data in cache
    settingsInited = true

proc getSetting*[T](name: Setting, defaultValue: T, useCached: bool = true): T =
  let settings: JsonNode = getSettings(useCached, $name == "mnemonic")
  if not settings.contains($name) or settings{$name}.isEmpty():
    return defaultValue
  let value = $settings{$name}
  try:
    result = Json.decode(value, T)
  except Exception as e:
    error "Error decoding setting", name=name, value=value, msg=e.msg
    return defaultValue

proc getSetting*[T](name: Setting, useCached: bool = true): T =
  result = getSetting(name, default(type(T)), useCached)

proc getCurrentNetwork*(): Network =
  case getSetting[string](Setting.Networks_CurrentNetwork, constants.DEFAULT_NETWORK_NAME):
  of "mainnet_rpc":
    result = Network.Mainnet
  of "testnet_rpc":
    result = Network.Testnet
  of "rinkeby_rpc":
    result = Network.Rinkeby
  of "goerli_rpc":
    result = Network.Goerli
  of "xdai_rpc":
    result = Network.XDai
  of "poa_rpc":
    result = Network.Poa
  else:
    result = Network.Other

proc getCurrentNetworkDetails*(): NetworkDetails =
  let currNetwork = getSetting[string](Setting.Networks_CurrentNetwork, constants.DEFAULT_NETWORK_NAME)
  let networks = getSetting[seq[NetworkDetails]](Setting.Networks_Networks)
  networks.find((network: NetworkDetails) => network.id == currNetwork)

proc getLinkPreviewWhitelist*(): JsonNode =
  result = callPrivateRPC("getLinkPreviewWhitelist".prefix, %* []).parseJSON()["result"]

proc getFleet*(): Fleet =
  let fleet = getSetting[string](Setting.Fleet, $Fleet.PROD)
  result = parseEnum[Fleet](fleet)

proc getPinnedMailserver*(): string =
  let pinnedMailservers = getSetting[JsonNode](Setting.PinnedMailservers, %*{})
  let fleet = getSetting[string](Setting.Fleet, $Fleet.PROD)
  return pinnedMailservers{fleet}.getStr()

proc pinMailserver*(enode: string = "") =
  let pinnedMailservers = getSetting[JsonNode](Setting.PinnedMailservers, %*{})
  let fleet = getSetting[string](Setting.Fleet, $Fleet.PROD)

  pinnedMailservers[fleet] = newJString(enode)
  discard saveSetting(Setting.PinnedMailservers, pinnedMailservers)

proc saveMailserver*(name, enode: string) =
  let fleet = getSetting[string](Setting.Fleet, $Fleet.PROD)
  let result = callPrivateRPC("mailservers_addMailserver", %* [
    %*{
      "id": $genUUID(),
      "name": name,
      "address": enode,
      "fleet": $fleet
    }
  ]).parseJSON()["result"]

proc getMailservers*():JsonNode =
  let fleet = getSetting[string](Setting.Fleet, $Fleet.PROD)
  result = callPrivateRPC("mailservers_getMailservers").parseJSON()["result"]

proc getNodeConfig*():JsonNode =
  result = status_go.getNodeConfig().parseJSON()

  # setting correct values in json
  let currNetwork = getSetting[string](Setting.Networks_CurrentNetwork, constants.DEFAULT_NETWORK_NAME)
  let networks = getSetting[JsonNode](Setting.Networks_Networks)
  let networkConfig = networks.getElems().find((n:JsonNode) => n["id"].getStr() == currNetwork)
  var newDataDir = networkConfig["config"]["DataDir"].getStr
  newDataDir.removeSuffix("_rpc")
  result["DataDir"] = newDataDir.newJString()
  result["KeyStoreDir"] = newJString("./keystore")
  result["LogFile"] = newJString("./geth.log")
  result["ShhextConfig"]["BackupDisabledDataDir"] = newJString("./")

proc getWakuVersion*():int =
  let nodeConfig = getNodeConfig()
  if nodeConfig["WakuConfig"]["Enabled"].getBool():
    return 1
  if nodeConfig["WakuV2Config"]["Enabled"].getBool():
    return 2
  return 0

proc setWakuVersion*(newVersion: int) =
  let nodeConfig = getNodeConfig()
  nodeConfig["RegisterTopics"] = %* @["whispermail"]
  if newVersion == 1:
    nodeConfig["WakuConfig"]["Enabled"] = newJBool(true)
    nodeConfig["WakuV2Config"]["Enabled"] = newJBool(false)
    nodeConfig["NoDiscovery"] = newJBool(false)
    nodeConfig["Rendezvous"] = newJBool(true)
  else:
    nodeConfig["WakuConfig"]["Enabled"] = newJBool(false)
    nodeConfig["WakuV2Config"]["Enabled"] = newJBool(true)
    nodeConfig["NoDiscovery"] = newJBool(true)
    nodeConfig["Rendezvous"] = newJBool(false)
  discard saveSetting(Setting.NodeConfig, nodeConfig)

proc setNetwork*(network: string): StatusGoError =
  let statusGoResult = saveSetting(Setting.Networks_CurrentNetwork, network)
  if statusGoResult.error != "":
    return statusGoResult

  let networks = getSetting[JsonNode](Setting.Networks_Networks)
  let networkConfig = networks.getElems().find((n:JsonNode) => n["id"].getStr() == network)

  var nodeConfig = getNodeConfig()
  let upstreamUrl = networkConfig["config"]["UpstreamConfig"]["URL"]
  var newDataDir = networkConfig["config"]["DataDir"].getStr
  newDataDir.removeSuffix("_rpc")
  
  nodeConfig["NetworkId"] = networkConfig["config"]["NetworkId"]
  nodeConfig["DataDir"] = newDataDir.newJString()
  nodeConfig["UpstreamConfig"]["Enabled"] = networkConfig["config"]["UpstreamConfig"]["Enabled"]
  nodeConfig["UpstreamConfig"]["URL"] = upstreamUrl

  return saveSetting(Setting.NodeConfig, nodeConfig)

proc setBloomFilterMode*(bloomFilterMode: bool): StatusGoError =
  let statusGoResult = saveSetting(Setting.WakuBloomFilterMode, bloomFilterMode)
  if statusGoResult.error != "":
    return statusGoResult
  var nodeConfig = getNodeConfig()
  nodeConfig["WakuConfig"]["BloomFilterMode"] = newJBool(bloomFilterMode)
  return saveSetting(Setting.NodeConfig, nodeConfig)

proc setBloomLevel*(bloomFilterMode: bool, fullNode: bool): StatusGoError =
  let statusGoResult = saveSetting(Setting.WakuBloomFilterMode, bloomFilterMode)
  if statusGoResult.error != "":
    return statusGoResult
  var nodeConfig = getNodeConfig()
  nodeConfig["WakuConfig"]["BloomFilterMode"] = newJBool(bloomFilterMode)
  nodeConfig["WakuConfig"]["FullNode"] = newJBool(fullNode)
  return saveSetting(Setting.NodeConfig, nodeConfig)

proc setFleet*(fleetConfig: FleetConfig, fleet: Fleet): StatusGoError =
  let statusGoResult = saveSetting(Setting.Fleet, $fleet)
  if statusGoResult.error != "":
    return statusGoResult

  var nodeConfig = getNodeConfig()
  nodeConfig["ClusterConfig"]["Fleet"] = newJString($fleet)
  nodeConfig["ClusterConfig"]["BootNodes"] = %* fleetConfig.getNodes(fleet, FleetNodes.Bootnodes)
  nodeConfig["ClusterConfig"]["TrustedMailServers"] = %* fleetConfig.getNodes(fleet, FleetNodes.Mailservers)
  nodeConfig["ClusterConfig"]["StaticNodes"] = %* fleetConfig.getNodes(fleet, FleetNodes.Whisper)
  nodeConfig["ClusterConfig"]["RendezvousNodes"] = %* fleetConfig.getNodes(fleet, FleetNodes.Rendezvous)
  nodeConfig["ClusterConfig"]["WakuNodes"] =  %* fleetConfig.getNodes(fleet, FleetNodes.Waku)
  nodeConfig["ClusterConfig"]["WakuStoreNodes"] =  %* fleetConfig.getNodes(fleet, FleetNodes.Waku)

  return saveSetting(Setting.NodeConfig, nodeConfig)

