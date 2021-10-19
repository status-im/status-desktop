import Tables, json, sequtils, sugar, chronicles

import ../setting/service as setting_service
import ../token/service as token_service

import ./service_interface, ./dto
import status/statusgo_backend_new/accounts as status_go

export service_interface

logScope:
  topics = "wallet-account-service"

type 
  Service* = ref object of service_interface.ServiceInterface
    settingService: setting_service.Service
    tokenService: token_service.Service
    accounts: Table[string, WalletAccountDto]

method delete*(self: Service) =
  discard

proc newService*(settingService: setting_service.Service, tokenService: token_service.Service): Service =
  result = Service()
  result.accounts = initTable[string, WalletAccountDto]()

method init*(self: Service) =
  try:
    let response = status_go.getAccounts()
    let accounts = map(response.result.getElems(), proc(x: JsonNode): WalletAccountDto = x.toWalletAccountDto())

    for account in accounts:
      self.accounts[account.address] = account
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getAccounts*(self: Service): seq[WalletAccountDto] =
  return toSeq(self.accounts.values).filter(a => a.isChat)