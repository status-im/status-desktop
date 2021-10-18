import Tables, json, sequtils, sugar, chronicles

import ./service_interface, ./dto
import status/statusgo_backend_new/accounts as status_go

export service_interface

logScope:
  topics = "wallet-account-service"

type 
  Service* = ref object of service_interface.ServiceInterface
    accounts: Table[string, WalletAccountDto]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.accounts = initTable[string, WalletAccountDto]()

method init*(self: Service) =
  try:
    let response = status_go.getAccounts()
    let accounts = map(response.result.getElems(), proc(x: JsonNode): WalletAccountDto = x.toDto())

    for account in accounts:
      self.accounts[account.address] = account
      echo account.address
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getAccounts*(self: Service): seq[WalletAccountDto] =
  return toSeq(self.accounts.values).filter(a => a.isChat)