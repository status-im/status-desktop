import Tables, json, sequtils, sugar, chronicles, strformat, stint, httpclient, net, strutils
import web3/[ethtypes, conversions]

import ../setting/service as setting_service
import ../token/service as token_service

import ./service_interface, ./dto
import status/statusgo_backend_new/accounts as status_go_accounts
import status/statusgo_backend_new/eth as status_go_eth

export service_interface

logScope:
  topics = "wallet-account-service"

proc hex2Balance*(input: string, decimals: int): string =
  var value = fromHex(Stuint[256], input)

  if decimals == 0:
    return fmt"{value}"
  
  var p = u256(10).pow(decimals)
  var i = value.div(p)
  var r = value.mod(p)
  var leading_zeros = "0".repeat(decimals - ($r).len)
  var d = fmt"{leading_zeros}{$r}"
  result = $i
  if(r > 0): result = fmt"{result}.{d}"


proc getPrice(crypto: string, fiat: string): string =
  let secureSSLContext = newContext()
  let client = newHttpClient(sslContext = secureSSLContext)
  try:
    let url: string = fmt"https://min-api.cryptocompare.com/data/price?fsym={crypto}&tsyms={fiat}"
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    let response = client.request(url)
    result = $parseJson(response.body)[fiat.toUpper]
  except Exception as e:
    error "Error getting price", message = e.msg
    result = "0.0"
  finally:
    client.close()

type
  Service* = ref object of service_interface.ServiceInterface
    settingService: setting_service.Service
    tokenService: token_service.Service
    accounts: Table[string, WalletAccountDto]

method delete*(self: Service) =
  discard

proc newService*(settingService: setting_service.Service, tokenService: token_service.Service): Service =
  result = Service()
  result.settingService = settingService
  result.tokenService = tokenService
  result.accounts = initTable[string, WalletAccountDto]()

method buildTokens(
  self: Service,
  account: WalletAccountDto,
  tokens: seq[TokenDto],
  prices: Table[string, float64]
): seq[WalletTokenDto] =
  let ethBalanceResponse = status_go_eth.getEthBalance(account.address)
  let balance = parsefloat(hex2Balance(ethBalanceResponse.result.getStr, 18))
  result = @[WalletTokenDto(
    name:"Ethereum",
    address: account.address,
    symbol: "ETH",
    decimals: 18,
    hasIcon: true,
    color: "blue",
    isCustom: false,
    balance: balance,
    currencyBalance: balance * prices["ETH"]
  )]

  for token in tokens:
    let tokenBalanceResponse = status_go_eth.getTokenBalance($token.address, account.address)
    let balance = parsefloat(hex2Balance(tokenBalanceResponse.result.getStr, token.decimals))
    result.add(
      WalletTokenDto(
        name: token.name,
        address: $token.address,
        symbol: token.symbol,
        decimals: token.decimals,
        hasIcon: token.hasIcon,
        color: token.color,
        isCustom: token.isCustom,
        balance: balance,
        currencyBalance: balance * prices[token.symbol]
      )
    )

method init*(self: Service) =
  try:
    let response = status_go_accounts.getAccounts()
    let accounts = map(
      response.result.getElems(),
      proc(x: JsonNode): WalletAccountDto = x.toWalletAccountDto()
    )
    let currency = self.settingService.getSetting().currency
    let tokens = self.tokenService.getTokens().filter(t => t.visible)
    var prices = {"ETH": parsefloat(getPrice("ETH", currency))}.toTable
    for token in tokens:
      prices[token.symbol] = parsefloat(getPrice(token.symbol, currency))

    for account in accounts:
      account.tokens = self.buildTokens(account, tokens, prices)
      self.accounts[account.address] = account

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getAccounts*(self: Service): seq[WalletAccountDto] =
  return toSeq(self.accounts.values).filter(a => a.isChat)

method getCurrencyBalance*(self: Service): float64 =
  return 0.0