import core as status
import json
# import utils
import httpclient, json
import strformat
import stint
import strutils, sequtils
import chronicles

type WalletAccount* = object
  address*, path*, publicKey*, name*, color*: string
  wallet*, chat*: bool

proc getWalletAccounts*(): seq[WalletAccount] =
  try:
    var response = callPrivateRPC("accounts_getAccounts")
    let accounts = parseJson(response)["result"]

    var walletAccounts:seq[WalletAccount] = @[]
    for account in accounts:
      if (account["chat"].to(bool) == false): # Might need a better condition
        walletAccounts.add(WalletAccount(
          address: $account["address"].getStr,
          path: $account["path"].getStr,
          # Watch accoutns don't have a public key
          publicKey: if (account.hasKey("public-key")): $account["public-key"].getStr else: "",
          name: $account["name"].getStr,
          color: $account["color"].getStr,
          wallet: $account["wallet"].getStr == "true",
          chat: $account["chat"].getStr == "false",
        ))
    result = walletAccounts
  except:
    let msg = getCurrentExceptionMsg()
    error "Failed getting wallet accounts", msg


proc sendTransaction*(from_address: string, to: string, value: string, password: string): string =
  var args = %* {
    "value": fmt"0x{toHex(value)}",
    "from": from_address,
    "to": to
  }
  var response = status.sendTransaction($args, password)
  result = response

proc getPrice*(crypto: string, fiat: string): string =
  var url: string = fmt"https://min-api.cryptocompare.com/data/price?fsym={crypto}&tsyms={fiat}"
  let client = newHttpClient()
  client.headers = newHttpHeaders({ "Content-Type": "application/json" })

  try:
    let response = client.request(url)
    result = $parseJson(response.body)[fiat.toUpper]
  except:
    echo "error getting price"

proc getBalance*(address: string): string =
  let payload = %* [address, "latest"]
  parseJson(status.callPrivateRPC("eth_getBalance", payload))["result"].str

proc hex2Eth*(input: string): string =
  var value = fromHex(Stuint[256], input)
  var one_eth = fromHex(Stuint[256], "DE0B6B3A7640000")

  var (eth, remainder) = divmod(value, one_eth)
  fmt"{eth}.{remainder}"
