import json

include  ../../common/json_utils

const DEFAULT_NETWORK_ID = "mainnet_rpc"

type NetworkDto* = ref object of RootObj
  id*: string
  etherscanLink*: string
  name*: string
         
type
  SettingDto* = ref object of RootObj
    currentNetwork*: NetworkDto
    signingPhrase*: string
    currency*: string
    
proc toDto*(jsonObj: JsonNode): SettingDto =
  result = SettingDto()
  discard jsonObj.getProp("signing-phrase", result.signingPhrase)  
  discard jsonObj.getProp("currency", result.currency)

  var currentNetworkId: string
  if not jsonObj.getProp("networks/current-network", currentNetworkId):
    currentNetworkId = DEFAULT_NETWORK_ID

  var networks: JsonNode
  discard jsonObj.getProp("networks/networks", networks) 
  for networkJson in networks.getElems():
    if networkJson{"id"}.getStr != currentNetworkId:
      continue
    
    var networkDto = NetworkDto()
    discard networkJson.getProp("id", networkDto.id)
    discard networkJson.getProp("name", networkDto.name)
    discard networkJson.getProp("etherscan-link", networkDto.etherscanLink)
    result.currentNetwork = networkDto
    break