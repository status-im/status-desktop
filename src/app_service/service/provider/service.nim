import json, chronicles

import service_interface
import ../../../backend/provider as status_go_provider
import ../ens/service as ens_service

export service_interface

logScope:
  topics = "provider-service"

const HTTPS_SCHEME* = "https"

type
  Service* = ref object of service_interface.ServiceInterface
    ensService: ens_service.Service

method delete*(self: Service) =
  discard

proc newService*(ensService: ens_service.Service): Service =
  result = Service()
  result.ensService = ensService

method init*(self: Service) =
  discard

method ensResourceURL*(self: Service, username: string, url: string): (string, string, string, string, bool) =
  let (scheme, host, path) = self.ensService.resourceUrl(username)
  if host == "":
    return (url, url, HTTPS_SCHEME, "", false)
  return (url, host, scheme, path, true)

method postMessage*(self: Service, requestType: string, message: string): string =
  try:
    return $status_go_provider.providerRequest(requestType, message).result
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription