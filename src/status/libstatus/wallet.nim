import core as status
import json
# import utils
import httpclient, json
import strformat
import stint
import strutils, sequtils
import chronicles
import ../wallet/account

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
          walletType: if (account.hasKey("type")): $account["type"].getStr else: "",
          # Watch accoutns don't have a public key
          publicKey: if (account.hasKey("public-key")): $account["public-key"].getStr else: "",
          name: $account["name"].getStr,
          iconColor: $account["color"].getStr,
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

proc getBalance*(address: string): string =
  let payload = %* [address, "latest"]
  parseJson(status.callPrivateRPC("eth_getBalance", payload))["result"].str

proc hex2Eth*(input: string): string =
  var value = fromHex(Stuint[256], input)
  var one_eth = fromHex(Stuint[256], "DE0B6B3A7640000")

  var (eth, remainder) = divmod(value, one_eth)
  fmt"{eth}.{remainder}"
