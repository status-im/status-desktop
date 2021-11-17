import NimQml, json, strutils, chronicles

import service_model, service_item

import ../../../../core/[main]
import ../../../../core/tasks/[qt, threadpool]
import status/[status, wallet2]
import status/statusgo_backend/wallet as status_wallet

logScope:
  topics = "app-wallet2-crypto-service"

#################################################
# Async request for the list of services to buy/sell crypto
#################################################

const asyncGetCryptoServicesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[QObjectTaskArg](argEncoded)
  var success: bool
  let response = status_wallet.fetchCryptoServices(success)

  var list: JsonNode
  if(success):
    list = response.parseJson()["result"]

  arg.finish($list)

QtObject:
  type CryptoServiceController* = ref object of QObject
    status: Status
    statusFoundation: StatusFoundation
    cryptoServiceModel: CryptoServiceModel 
    servicesFetched: bool

  proc setup(self: CryptoServiceController) = 
    self.QObject.setup

  proc delete*(self: CryptoServiceController) =
    self.cryptoServiceModel.delete
    self.QObject.delete    

  proc newCryptoServiceController*(status: Status, statusFoundation: StatusFoundation): 
    CryptoServiceController =
    new(result, delete)
    result.status = status
    result.statusFoundation = statusFoundation
    result.cryptoServiceModel = newCryptoServiceModel()
    result.servicesFetched = false
    result.setup

  proc getCryptoServiceModel(self: CryptoServiceController): QVariant {.slot.} = 
    newQVariant(self.cryptoServiceModel)

  QtProperty[QVariant] cryptoServiceModel:
    read = getCryptoServiceModel

  #################################################
  # This part is moved here only cause we want to get rid of it from the `app_service`
  # This will be done in appropriate refactored service, the same way as async things are done
  # in other services.
  proc onAsyncFetchCryptoServices*(self: CryptoServiceController, response: string) {.slot.} =
    self.status.wallet2.onAsyncFetchCryptoServices(response)

  proc asyncFetchCryptoServices*(self: CryptoServiceController) =
    ## Asynchronous request for the list of services to buy/sell crypto.
    let arg = QObjectTaskArg(
      tptr: cast[ByteAddress](asyncGetCryptoServicesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncFetchCryptoServices"
    )
    self.statusFoundation.threadpool.start(arg)
  #################################################

  proc fetchCryptoServicesFetched*(self:CryptoServiceController) {.signal.}

  proc fetchCryptoServices*(self: CryptoServiceController) {.slot.} =
    if(not self.servicesFetched):
      self.asyncFetchCryptoServices()
    else:
      self.fetchCryptoServicesFetched()
      
  proc onCryptoServicesFetched*(self: CryptoServiceController, jsonNode: JsonNode) =
    self.servicesFetched = true

    if (jsonNode.kind != JArray):
      info "received crypto services list is empty"
    else:
      var items: seq[CryptoServiceItem] = @[]
      for itemObject in jsonNode:
        items.add(initCryptoServiceItem(itemObject))

      self.cryptoServiceModel.set(items)
    
    self.fetchCryptoServicesFetched()