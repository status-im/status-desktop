import Tables, json, sequtils, sugar, chronicles
from web3/conversions import `$`

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
    currencyBalance: float64

method delete*(self: Service) =
  discard

proc newService*(settingService: setting_service.Service, tokenService: token_service.Service): Service =
  result = Service()
  result.settingService = settingService
  result.tokenService = tokenService
  result.accounts = initTable[string, WalletAccountDto]()

method buildTokens(self: Service, account: WalletAccountDto, tokens: seq[TokenDto]): seq[WalletTokenDto] =
  result = @[WalletTokenDto(
    name:"Ethereum",
    address: "0x0",
    symbol: "ETH",
    decimals: 18,
    hasIcon: true,
    color: "blue",
    isCustom: false,
    balance: "0.0",
    currencyBalance: "0.0"
  )]

  for token in tokens:
    result.add(
      WalletTokenDto(
        name: token.name,
        address: $token.address,
        symbol: token.symbol,
        decimals: token.decimals,
        hasIcon: token.hasIcon,
        color: token.color,
        isCustom: token.isCustom,
        balance: "0.0",
        currencyBalance: "0.0"
      )
    )

method init*(self: Service) =
  try:
    let response = status_go.getAccounts()
    let accounts = map(
      response.result.getElems(),
      proc(x: JsonNode): WalletAccountDto = x.toWalletAccountDto()
    )
    let currency = self.settingService.getSetting().currency
    let tokens = self.tokenService.getTokens().filter(t => t.visible)

    for account in accounts:
      account.tokens = self.buildTokens(account, tokens)
      self.accounts[account.address] = account

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getAccounts*(self: Service): seq[WalletAccountDto] =
  return toSeq(self.accounts.values).filter(a => a.isChat)

method getCurrencyBalance*(self: Service): float64 =
  return self.currencyBalance