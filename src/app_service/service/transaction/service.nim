import chronicles
import status/statusgo_backend_new/transactions as transactions

import ./service_interface, ./dto

export service_interface

logScope:
  topics = "transaction-service"

type 
  Service* = ref object of ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  discard

method checkRecentHistory*(self: Service, addresses: seq[string]) =
  try:
    transactions.checkRecentHistory(addresses)
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

