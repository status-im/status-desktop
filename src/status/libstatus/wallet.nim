import json, httpclient, json, strformat, stint, strutils, sequtils, chronicles, parseutils, tables
import nim_status, core, types, utils
import ../wallet/account
from ./accounts/constants import ZERO_ADDRESS
import ./contracts as contractMethods
from eth/common/utils as eth_utils import parseAddress

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

proc getTransfersByAddress*(address: string): seq[types.Transaction] =
  try:
    let response = getBlockByNumber("latest")
    let latestBlock = parseJson(response)["result"]
    
    let transactionsResponse = getTransfersByAddress(address, latestBlock["number"].getStr, "0x14")
    let transactions = parseJson(transactionsResponse)["result"]
    var accountTransactions: seq[types.Transaction] = @[]

    for transaction in transactions:
      accountTransactions.add(types.Transaction(
        typeValue: transaction["type"].getStr,
        address: transaction["address"].getStr,
        contract: transaction["contract"].getStr,
        blockNumber: transaction["blockNumber"].getStr,
        blockHash: transaction["blockhash"].getStr,
        timestamp: transaction["timestamp"].getStr,
        gasPrice: transaction["gasPrice"].getStr,
        gasLimit: transaction["gasLimit"].getStr,
        gasUsed: transaction["gasUsed"].getStr,
        nonce: transaction["nonce"].getStr,
        txStatus: transaction["txStatus"].getStr,
        value: transaction["value"].getStr,
        fromAddress: transaction["from"].getStr,
        to: transaction["to"].getStr
      ))
    result = accountTransactions
  except:
    let msg = getCurrentExceptionMsg()
    error "Failed getting wallet account transactions", msg
    

proc sendTransaction*(from_address: string, to: string, assetAddress: string, value: string, password: string): string =
  try:
    var args: JsonNode
    if (assetAddress == ZERO_ADDRESS or assetAddress == ""):
      var weiValue = value.parseFloat() * float(1000000000000000000)
      var stringValue =  fmt"{weiValue:<.0f}"
      stringValue.removeSuffix('.')
      var hexValue = parseBiggestInt(stringValue).toHex()
      hexValue.removePrefix('0')
      args = %* {
        "value": fmt"0x{hexValue}",
        "from": from_address,
        "to": to
      }
    else:
      var bigIntValue = u256(value)
      # TODO get decimals from the token
      bigIntValue = bigIntValue * u256(1000000000000000000)
      # Just using mainnet SNT to get the method ABI
      let
        contract = getContract("snt")
        transfer = Transfer(to: parseAddress(to), value: bigIntValue)
        transferEncoded = contract.methods["transfer"].encodeAbi(transfer)
      
      args = %* {
        "from": from_address,
        "to": assetAddress,
        "data": transferEncoded
      }

    let response = sendTransaction($args, password)
    let parsedResponse = parseJson(response)
    
    result = parsedResponse["result"].getStr
    trace "Transaction sent succesfully", hash=result
  except Exception as e:
    error "Error submitting transaction", msg=e.msg
    result = e.msg

proc getBalance*(address: string): string =
  let payload = %* [address, "latest"]
  let response = parseJson(callPrivateRPC("eth_getBalance", payload))
  if response.hasKey("error"):
    raise newException(RpcException, "Error getting balance: " & $response["error"])
  else:  
    result = response["result"].str

proc hex2Eth*(input: string): string =
  var value = fromHex(Stuint[256], input)
  result = utils.wei2Eth(value)

proc validateMnemonic*(mnemonic: string): string =
  result = $nim_status.validateMnemonic(mnemonic)
