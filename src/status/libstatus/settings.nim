import core, ./types, ../../signals/types as statusgo_types, ./accounts/constants, ./utils
import json, tables, sugar, sequtils
import json_serialization

var settings: JsonNode = %*{}
var dirty: bool = true

proc saveSetting*(key: Setting, value: string | JsonNode): StatusGoError =
  let response = callPrivateRPC("settings_saveSetting", %* [
    key, value
  ])
  try:
    result = Json.decode($response, StatusGoError)
  except:
    dirty = true

proc getWeb3ClientVersion*(): string =
  parseJson(callPrivateRPC("web3_clientVersion"))["result"].getStr

proc getSettings*(useCached: bool = true): JsonNode =
  if useCached and not dirty:
    return settings
  settings = callPrivateRPC("settings_getSettings").parseJSON()["result"]
  dirty = false
  result = settings

proc getSetting*[T](name: Setting, defaultValue: T, useCached: bool = true): T =
  let settings: JsonNode = getSettings(useCached)
  if not settings.contains($name) or settings{$name}.isEmpty():
    return defaultValue
  result = Json.decode($settings{$name}, T)

proc getSetting*[T](name: Setting, useCached: bool = true): T =
  result = getSetting(name, default(type(T)), useCached)

proc getCurrentNetwork*(): Network =
  result = Network.Mainnet
  if getSetting[string](Setting.Networks_CurrentNetwork, constants.DEFAULT_NETWORK_NAME) == "testnet_rpc":
    result = Network.Testnet

proc getCurrentNetworkDetails*(): NetworkDetails =
  let currNetwork = getSetting[string](Setting.Networks_CurrentNetwork, constants.DEFAULT_NETWORK_NAME)
  let networks = getSetting[seq[NetworkDetails]](Setting.Networks_Networks)
  networks.find((network: NetworkDetails) => network.id == currNetwork)