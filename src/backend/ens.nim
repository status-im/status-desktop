import sequtils
import strutils
import nimcrypto
import json
import json_serialization
import tables
import stew/byteutils
import web3/[ethtypes, conversions], stint
import chronicles, libp2p/[multihash, multicodec, cid]


import ./statusgo_backend/wallet
import ./statusgo_backend/accounts as status_accounts
import ./statusgo_backend/settings as status_settings
import ./statusgo_backend_new/ens as status_ens

import ./types/[transaction, setting, rpc_response, network_type, network, profile]
import ./utils
import ./transactions
import ./eth/contracts

const domain* = ".stateofus.eth"

proc userName*(ensName: string, removeSuffix: bool = false): string =
  if ensName != "" and ensName.endsWith(domain):
    if removeSuffix:
      result = ensName.split(".")[0]
    else:
      result = ensName
  else:
    if ensName.endsWith(".eth") and removeSuffix:
      return ensName.split(".")[0]
    result = ensName

proc addDomain*(username: string): string =
  if username.endsWith(".eth"):
    return username
  else:
    return username & domain

proc hasNickname*(contact: Profile): bool = contact.localNickname != ""

proc userNameOrAlias*(contact: Profile, removeSuffix: bool = false): string =
  if(contact.ensName != "" and contact.ensVerified):
    result = "@" & userName(contact.ensName, removeSuffix)
  elif(contact.localNickname != ""):
    result = contact.localNickname
  else:
    result = contact.alias

proc resolver*(username: string): string =
  let chainId = status_settings.getCurrentNetwork().toChainId()
  let res = status_ens.resolver(chainId, username)
  return res.result.getStr

proc owner*(username: string): string =
  let chainId = status_settings.getCurrentNetwork().toChainId()
  let res = status_ens.ownerOf(chainId, username)
  let address = res.result.getStr
  if address == "0x0000000000000000000000000000000000000000":
    return ""
  
  return address

proc pubkey*(username: string): string =
  try:
    let chainId = status_settings.getCurrentNetwork().toChainId()
    let res = status_ens.publicKeyOf(chainId, addDomain(username))
    var key = res.result.getStr
    key.removePrefix("0x")
    return "0x04" & key
  except:
    return ""

proc address*(username: string): string =
  let chainId = status_settings.getCurrentNetwork().toChainId()
  let res = status_ens.addressOf(chainId, username)
  return res.result.getStr

proc contenthash*(username: string): string =
  let chainId = status_settings.getCurrentNetwork().toChainId()
  let res = status_ens.contentHash(chainId, username)
  return res.result.getStr

proc getPrice*(): Stuint[256] =
  let chainId = status_settings.getCurrentNetwork().toChainId()
  let res = status_ens.price(chainId)
  return fromHex(Stuint[256], res.result.getStr)

proc releaseEstimateGas*(username: string, address: string, success: var bool): int =
  let
    chainId = status_settings.getCurrentNetwork().toChainId()
    txData = transactions.buildTransaction(parseAddress(address), 0.u256)
  
  try:
    let resp = status_ens.releaseEstimate(chainId, txData, username)
    result = resp.result.getInt
    success = true
  except:
    success = false
    result = 0

proc release*(username: string, address: string, gas, gasPrice,  password: string, success: var bool): string =
  let
    chainId = status_settings.getCurrentNetwork().toChainId()
    txData = transactions.buildTransaction(
      parseAddress(address), 0.u256, gas, gasPrice
    )
  
  try:
    let resp = status_ens.release(chainId, txData, password, username)
    result = resp.result.getStr
    success = true
    let ensUsernamesContract = contracts.findContract(chainId, "ens-usernames")
    trackPendingTransaction(result, address, $ensUsernamesContract.address, PendingTransactionType.ReleaseENS, username)
  except:
    success = false
    result = "failed to release the username"

proc getExpirationTime*(username: string, success: var bool): int =
  let chainId = status_settings.getCurrentNetwork().toChainId()
  let res = status_ens.expireAt(chainId, username)
  return fromHex[int](res.result.getStr)

proc registerUsernameEstimateGas*(username: string, address: string, pubKey: string, success: var bool): int =
  let
    chainId = status_settings.getCurrentNetwork().toChainId()
    txData = transactions.buildTransaction(parseAddress(address), 0.u256)
  
  try:
    let resp = status_ens.registerEstimate(chainId, txData, username, pubkey)
    result = resp.result.getInt
    success = true
  except:
    success = false
    result = 0

proc registerUsername*(username, pubKey, address, gas, gasPrice: string, isEIP1559Enabled: bool, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, success: var bool): string =
  let
    network = status_settings.getCurrentNetwork().toNetwork()
    chainId = network.chainId
    txData = transactions.buildTransaction(
      parseAddress(address), 0.u256, gas, gasPrice, isEIP1559Enabled, maxPriorityFeePerGas, maxFeePerGas
    )
  
  try:
    let resp = status_ens.register(chainId, txData, password, username, pubkey)
    result = resp.result.getStr
    success = true
    let sntContract = contracts.findErc20Contract(chainId, network.sntSymbol())
    trackPendingTransaction(result, address, $sntContract.address, PendingTransactionType.RegisterEns, username & domain)
  except:
    success = false
    result = "failed to register the username"

proc setPubKeyEstimateGas*(username: string, address: string, pubKey: string, success: var bool): int =
  let
    chainId = status_settings.getCurrentNetwork().toChainId()
    txData = transactions.buildTransaction(parseAddress(address), 0.u256)
  
  try:
    let resp = status_ens.setPubKeyEstimate(chainId, txData, username, pubkey)
    result = resp.result.getInt
    success = true
  except:
    success = false
    result = 0

proc setPubKey*(username, pubKey, address, gas, gasPrice: string, isEIP1559Enabled: bool, maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, success: var bool): string =
  let
    chainId = status_settings.getCurrentNetwork().toChainId()
    txData = transactions.buildTransaction(
      parseAddress(address), 0.u256, gas, gasPrice, isEIP1559Enabled, maxPriorityFeePerGas, maxFeePerGas
    )
  
  try:
    let resp = status_ens.setPubKey(chainId, txData, password, username, pubkey)
    result = resp.result.getStr
    success = true
    let resolverAddress = resolver(username)
    trackPendingTransaction(result, $address, resolverAddress, PendingTransactionType.SetPubKey, username)
  except:
    success = false
    result = "failed to set the pubkey"

proc statusRegistrarAddress*():string =
  let network = status_settings.getCurrentNetwork().toNetwork()
  let contract = contracts.findContract(network.chainId, "ens-usernames")
  if contract != nil:
     return $contract.address
  result = ""

proc validateEnsName*(ens: string, isStatus: bool, usernames: seq[string]): string =
  var username = ens & (if(isStatus): domain else: "")
  result = ""
  if usernames.filter(proc(x: string):bool = x == username).len > 0:
    result = "already-connected"
  else:
    let ownerAddr = owner(username)
    if ownerAddr == "" and isStatus:
      result = "available"
    else:
      let userPubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
      let userWallet = status_accounts.getWalletAccounts()[0].address
      let ens_pubkey = pubkey(ens)
      if ownerAddr != "":
        if ens_pubkey == "" and ownerAddr == userWallet:
          result = "owned" # "Continuing will connect this username with your chat key."
        elif ens_pubkey == userPubkey:
          result = "connected"
        elif ownerAddr == userWallet:
          result = "connected-different-key" #  "Continuing will require a transaction to connect the username with your current chat key.",
        else:
          result = "taken"
      else:
        result = "taken"
