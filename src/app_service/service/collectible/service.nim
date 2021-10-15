import chronicles

import ./service_interface, ./dto

export service_interface

logScope:
  topics = "collectible-service"

type 
  Service* = ref object of ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  discard