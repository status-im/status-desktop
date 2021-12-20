import Tables, json, chronicles
import chronicles
include ../../common/json_utils
import service_interface
import status/statusgo_backend_new/ens as status_go
export service_interface

logScope:
  topics = "ens-service"

type 
  Service* = ref object of ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  discard

method resourceUrl*(self: Service, username: string): (string, string, string) =
  try:
    let response = status_go.resourceURL(username)
    return (response.result{"Scheme"}.getStr, response.result{"Host"}.getStr, response.result{"Path"}.getStr)
  except Exception as e:
    error "Error getting ENS resourceUrl", username=username, exception=e.msg
    raise