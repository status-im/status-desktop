import json, json_serialization, chronicles

import status/types/[rpc_response]

import status/statusgo_backend/settings as status_go_settings
import status/statusgo_backend/accounts as status_accounts
from status/types/setting import Setting
import status/[fleet]

import ./service_interface, ./dto

import dto/network_details
import dto/node_config
import dto/upstream_config

export service_interface

logScope:
  topics = "settings-service"

const DEFAULT_NETWORK_NAME = "mainnet_rpc"

type 
  Service* = ref object of ServiceInterface
    fleet: FleetModel

method delete*(self: Service) =
  discard

proc newService*(fleet: FleetModel): Service =
  result = Service()
  result.fleet = fleet

method init*(self: Service) =
  try:
    echo "init"

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getPubKey*(self: Service): string=
  return status_go_settings.getSetting(Setting.PublicKey, "0x0")

method getNetwork*(self: Service): string =
  return status_go_settings.getSetting(Setting.Networks_CurrentNetwork, DEFAULT_NETWORK_NAME)

method getAppearance*(self: Service): int =
  let appearance: int = status_go_settings.getSetting[int](Setting.Appearance, 0)
  return appearance

method getMessagesFromContactsOnly*(self: Service): bool =
  return status_go_settings.getSetting[bool](Setting.MessagesFromContactsOnly)

method setMessagesFromContactsOnly*(self: Service, contactsOnly: bool): bool =
  let r = status_go_settings.saveSetting(Setting.MessagesFromContactsOnly, contactsOnly)
  return r.error == ""

method getSendUserStatus*(self: Service): bool =
  return status_go_settings.getSetting[bool](Setting.SendUserStatus)

method getCurrentUserStatus*(self: Service): int =
   let userStatus = status_go_settings.getSetting[JsonNode](Setting.CurrentUserStatus)
   return userStatus{"statusType"}.getInt()

method getIdentityImage*(self: Service, address: string): IdentityImage =
  var obj = status_accounts.getIdentityImage(address)
  var identityImage = IdentityImage(thumbnail: obj.thumbnail, large: obj.large)
  return identityImage

method getDappsAddress*(self: Service): string =
  return status_go_settings.getSetting[string](Setting.DappsAddress)

method setDappsAddress*(self: Service, address: string): bool =
  let r = status_go_settings.saveSetting(Setting.DappsAddress, address)
  return r.error == ""

method getCurrentNetworkDetails*(self: Service): NetworkDetails =
  let currNetwork = getSetting[string](Setting.Networks_CurrentNetwork, DEFAULT_NETWORK_NAME)
  let networks = getSetting[seq[NetworkDetails]](Setting.Networks_Networks)
  for n in networks:
    if n.id == currNetwork:
      return n

method getNetworks*(self: Service): seq[NetworkDetails] =
  getSetting[seq[NetworkDetails]](Setting.Networks_Networks)

method getFleet*(self: Service): string =
  $status_go_settings.getFleet()

method setFleet*(self: Service, fleet: Fleet): StatusGoError =
  status_go_settings.setFleet(self.fleet.config, fleet)

method setWakuVersion*(self: Service, version: int) =
  status_go_settings.setWakuVersion(version)