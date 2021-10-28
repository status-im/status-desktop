import status/statusgo_backend/network as status_network
import ./service_interface


export service_interface

type 
  Service* = ref object of ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  discard

method addCustomNetwork*(self: Service, name: string, endpoint: string, networkId: int, networkType: string) =
  status_network.addNetwork(name, endpoint, networkId, networkType)

method changeNetwork*(self: Service, network: string) =
  status_network.changeNetwork(network)
