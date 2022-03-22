import json, chronicles

import ../../../backend/provider as status_go_provider
import ../ens/service as ens_service

logScope:
  topics = "provider-service"

const HTTPS_SCHEME* = "https"

type
  Service* = ref object of RootObj
    ensService: ens_service.Service

proc delete*(self: Service) =
  discard

proc newService*(ensService: ens_service.Service): Service =
  result = Service()
  result.ensService = ensService

proc init*(self: Service) =
  discard

proc ensResourceURL*(self: Service, username: string, url: string): (string, string, string, string, bool) =
  let (scheme, host, path) = self.ensService.resourceUrl(username)
  if host == "":
    return (url, url, HTTPS_SCHEME, "", false)
  return (url, host, scheme, path, true)

proc postMessage*(self: Service, requestType: string, message: string): string =
  try:
    return $status_go_provider.providerRequest(requestType, message).result
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription