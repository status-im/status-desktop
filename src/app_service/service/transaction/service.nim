import chronicles, sequtils, sugar
import status/statusgo_backend_new/transactions as transactions

import ../wallet_account/service as wallet_account_service
import ./service_interface, ./dto

export service_interface

logScope:
  topics = "transaction-service"

type 
  Service* = ref object of service_interface.ServiceInterface
    walletAccountService: wallet_account_service.ServiceInterface

method delete*(self: Service) =
  discard

proc newService*(walletAccountService: wallet_account_service.ServiceInterface): Service =
  result = Service()
  result.walletAccountService = walletAccountService

method init*(self: Service) =
  discard

method checkRecentHistory*(self: Service) =
  try:
    let addresses = self.walletAccountService.getWalletAccounts().map(a => a.address)
    transactions.checkRecentHistory(addresses)
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return