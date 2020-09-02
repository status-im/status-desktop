import core, ./types, ../signals/types as statusgo_types, ./accounts/constants, ./utils
import json, tables, sugar, sequtils
import json_serialization
import locks

var settingsLock: Lock
initLock(settingsLock)

var settings {.guard: settingsLock.} = %*{}
var dirty {.guard: settingsLock.}  = true

proc saveSetting*(key: Setting, value: string | JsonNode): StatusGoError =
  let response = callPrivateRPC("settings_saveSetting", %* [
    key, value
  ])

  withLock settingsLock:
    try:
      result = Json.decode($response, StatusGoError)
    except:
      dirty = true

proc getWeb3ClientVersion*(): string =
  parseJson(callPrivateRPC("web3_clientVersion"))["result"].getStr

proc getSettings*(useCached: bool = true, keepSensitiveData: bool = false): JsonNode =
  {.gcsafe.}:
    withLock settingsLock:
      if useCached and not dirty and not keepSensitiveData:
        result = settings
      else: 
        result = callPrivateRPC("settings_getSettings").parseJSON()["result"]
        if (keepSensitiveData):
          return
        dirty = false
        delete(result, "mnemonic")
        settings = result

proc getSetting*[T](name: Setting, defaultValue: T, useCached: bool = true): T =
  let settings: JsonNode = getSettings(useCached, $name == "mnemonic")
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