import Tables, json, sequtils, chronicles
import sets
import options
import strutils
include ../../common/json_utils
import ../dapp_permissions/service as dapp_permissions_service
import ../settings/service as settings_service
import ../ens/service as ens_service
import service_interface
import status/statusgo_backend_new/permissions as status_go_permissions
import status/statusgo_backend_new/accounts as status_go_accounts
import status/statusgo_backend_new/core as status_go_core
import status/statusgo_backend_new/provider as status_go_provider
import stew/byteutils
export service_interface

logScope:
  topics = "provider-service"

const HTTPS_SCHEME* = "https"

type 
  Service* = ref object of service_interface.ServiceInterface
    dappPermissionsService: dapp_permissions_service.ServiceInterface
    settingsService: settings_service.ServiceInterface
    ensService: ens_service.ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(dappPermissionsService: dapp_permissions_service.ServiceInterface, 
    settingsService: settings_service.ServiceInterface,
    ensService: ens_service.ServiceInterface): Service =
  result = Service()
  result.dappPermissionsService = dappPermissionsService
  result.settingsService = settingsService
  result.ensService = ensService

method init*(self: Service) =
  discard


method ensResourceURL*(self: Service, username: string, url: string): (string, string, string, string, bool) =
  let (scheme, host, path) = self.ensService.resourceUrl(username)
  if host == "":
    return (url, url, HTTPS_SCHEME, "", false)


method postMessage*(self: Service, requestType: string, message: string): string =
  try:
    return $providerRequest(requestType, message).result
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
  