import json, json, options, json_serialization, stint, chronicles
import core, types, utils, strutils, strformat
from nim_status import validateMnemonic, startWallet
import ../wallet/account
import ./contracts as contractMethods
import eth/common/eth_types
import ./types
import ../signals/types as signal_types

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

proc getTransactionReceipt*(transactionHash: string): string =
  result = callPrivateRPC("eth_getTransactionReceipt", %* [transactionHash])

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

proc sendTransaction*(tx: EthSend, password: string): RpcResponse =
  let responseStr = core.sendTransaction($(%tx), password)
  result = Json.decode(responseStr, RpcResponse)
  if not result.error.isNil:
    raise newException(RpcException, "Error sending transaction: " & result.error.message)

  trace "Transaction sent succesfully", hash=result

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

proc startWallet*() =
  discard nim_status.startWallet()

proc hex2Token*(input: string, decimals: int): string =
  var value = fromHex(Stuint[256], input)
  var p = u256(10).pow(decimals)
  var i = value.div(p)
  var r = value.mod(p)
  var leading_zeros = "0".repeat(decimals - ($r).len)
  var d = fmt"{leading_zeros}{$r}"             
  result = $i
  if(r > 0): result = fmt"{result}.{d}"
  
proc trackPendingTransaction*(transactionHash: string, fromAddress: string, toAddress: string, trxType: PendingTransactionType, data: string) =
  let blockNumber = parseInt($fromHex(Stuint[256], getBlockByNumber("latest").parseJson()["result"]["number"].getStr))
  let payload = %* [{"transactionHash": transactionHash, "blockNumber": blockNumber, "from_address": fromAddress, "to_address": toAddress, "type": $trxType, "data": data}]
  discard callPrivateRPC("wallet_storePendingTransaction", payload)

proc getPendingTransactions*(): string =
  let payload = %* []
  result = callPrivateRPC("wallet_getPendingTransactions", payload)

proc getPendingOutboundTransactionsByAddress*(address: string): string =
  let payload = %* [address]
  result = callPrivateRPC("wallet_getPendingOutboundTransactionsByAddress", payload)

proc deletePendingTransaction*(transactionHash: string) =
  let payload = %* [transactionHash]
  discard callPrivateRPC("wallet_deletePendingTransaction", payload)
