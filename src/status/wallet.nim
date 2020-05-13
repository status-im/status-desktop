import core as status
import json
import utils
import httpclient, json
import strformat
import stint

proc getPrice*(crypto: string, fiat: string): string =
    var url: string = fmt"https://min-api.cryptocompare.com/data/price?fsym={crypto}&tsyms={fiat}"
    let client = newHttpClient()
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    let response = client.request(url)
    $parseJson(response.body)["USD"]

proc getBalance*(address: string): string =
  let payload = %* {
    "jsonrpc": "2.0",
    "id": 50,
    "method": "eth_getBalance",
    "params": [
        address,
        "latest"
    ]
  }
  parseJson(status.callPrivateRPC($payload))["result"].str

proc hex2Eth*(input: string): string =
  var value = fromHex(Stuint[256], input)
  var one_eth = fromHex(Stuint[256], "DE0B6B3A7640000")

  var (eth, remainder) = divmod(value, one_eth)
  fmt"{eth}.{remainder}"
