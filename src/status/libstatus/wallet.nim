import core as status
import json
# import utils
import httpclient, json
import strformat
import stint
import strutils

proc getAccounts*(): seq[string] =
  var response = callPrivateRPC("eth_accounts")
  result = parseJson(response)["result"].to(seq[string])

proc getAccount*(): string =
  var accounts = getAccounts()
  result = accounts[0]

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

  let response = client.request(url)
  $parseJson(response.body)["USD"]

proc getBalance*(address: string): string =
  let payload = %* [address, "latest"]
  parseJson(status.callPrivateRPC("eth_getBalance", payload))["result"].str

proc hex2Eth*(input: string): string =
  var value = fromHex(Stuint[256], input)
  var one_eth = fromHex(Stuint[256], "DE0B6B3A7640000")

  var (eth, remainder) = divmod(value, one_eth)
  fmt"{eth}.{remainder}"
