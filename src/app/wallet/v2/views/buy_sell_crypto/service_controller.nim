import NimQml, json, strutils, chronicles

import service_model, service_item

import ../../../../../status/[status, wallet2]

logScope:
  topics = "app-wallet2-crypto-service"

QtObject:
  type CryptoServiceController* = ref object of QObject
    status: Status
    cryptoServiceModel: CryptoServiceModel 
    servicesFetched: bool

  proc setup(self: CryptoServiceController) = 
    self.QObject.setup

  proc delete*(self: CryptoServiceController) =
    self.cryptoServiceModel.delete
    self.QObject.delete    

  proc newCryptoServiceController*(status: Status): CryptoServiceController =
    new(result, delete)
    result.status = status
    result.cryptoServiceModel = newCryptoServiceModel()
    result.servicesFetched = false
    result.setup

  proc getCryptoServiceModel(self: CryptoServiceController): QVariant {.slot.} = 
    newQVariant(self.cryptoServiceModel)

  QtProperty[QVariant] cryptoServiceModel:
    read = getCryptoServiceModel

  proc fetchCryptoServicesFetched*(self:CryptoServiceController) {.signal.}

  proc fetchCryptoServices*(self: CryptoServiceController) {.slot.} =
    if(not self.servicesFetched):
      self.status.wallet2.asyncFetchCryptoServices()
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