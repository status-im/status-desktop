import json, options

include  ../../common/json_utils

const DEFAULT_NETWORK_SLUG = "mainnet_rpc"
const DEFAULT_CURRENCY = "usd"

type NetworkDto* = ref object of RootObj
  id*: int
  slug*: string
  etherscanLink*: string
  name*: string

type
  SettingDto* = ref object of RootObj
    currentNetwork*: NetworkDto
    activeTokenSymbols*: seq[string]
    signingPhrase*: string
    currency*: string
    mnemonic*: string

proc toSettingDto*(jsonObj: JsonNode): SettingDto =
  result = SettingDto()

  discard jsonObj.getProp("signing-phrase", result.signingPhrase)
  discard jsonObj.getProp("mnemonic", result.mnemonic)

  if not jsonObj.getProp("currency", result.currency):
    result.currency = DEFAULT_CURRENCY

  var currentNetworkSlug: string
  if not jsonObj.getProp("networks/current-network", currentNetworkSlug):
    currentNetworkSlug = DEFAULT_NETWORK_SLUG

  var networks: JsonNode
  discard jsonObj.getProp("networks/networks", networks)
  for networkJson in networks.getElems():
    if networkJson{"id"}.getStr != currentNetworkSlug:
      continue

    var networkDto = NetworkDto()
    discard networkJson{"config"}.getProp("NetworkId", networkDto.id)
    discard networkJson.getProp("id", networkDto.slug)
    discard networkJson.getProp("name", networkDto.name)
    discard networkJson.getProp("etherscan-link", networkDto.etherscanLink)
    result.currentNetwork = networkDto
    break

  result.activeTokenSymbols = @[]
  if jsonObj.hasKey("wallet/visible-tokens"):
    let symbols =  parseJson(jsonObj{"wallet/visible-tokens"}.getStr)
    for symbol in symbols{$result.currentNetwork.id}.getElems():
      result.activeTokenSymbols.add(symbol.getStr)

proc isMnemonicBackedUp*(self: SettingDto): bool =
  return self.mnemonic == ""