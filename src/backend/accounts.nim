import json, json_serialization, chronicles, strutils, std/os
import ./core, ../app_service/common/utils
import ../app_service/service/wallet_account/dto/account_dto
import ../app_service/service/accounts/dto/login_request
import ../app_service/service/accounts/dto/create_account_request
import ../app_service/service/accounts/dto/restore_account_request
import ./response_type
import ../constants as status_const

import status_go

export response_type

logScope:
  topics = "rpc-accounts"

const PK_LENGTH_0X_INCLUDED = 132

const GENERATED* = "generated"
const SEED* = "seed"
const KEY* = "key"
const WATCH* = "watch"

proc getAccounts*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("accounts_getAccounts")

proc getWatchOnlyAccounts*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("accounts_getWatchOnlyAccounts")

proc getKeypairs*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("accounts_getKeypairs")

proc getKeypairByKeyUid*(keyUid: string): RpcResponse[JsonNode] =
  let payload = %* [keyUid]
  return core.callPrivateRPC("accounts_getKeypairByKeyUID", payload)

proc deleteAccount*(address: string): RpcResponse[JsonNode] =
  let payload = %* [address]
  return core.callPrivateRPC("accounts_deleteAccount", payload)

proc deleteKeypair*(keyUid: string): RpcResponse[JsonNode] =
  let payload = %* [keyUid]
  return core.callPrivateRPC("accounts_deleteKeypair", payload)

## Adds a new account and creates a Keystore file if password is provided, otherwise it only creates a new account. Notifies paired devices.
proc addAccount*(password, name, address, path, publicKey, keyUid, accountType, colorId, emoji: string, hideFromTotalBalance: bool):
  RpcResponse[JsonNode] =
  let payload = %* [
    password,
    {
      "address": address,
      "key-uid": keyUid,
      "wallet": false, #this refers to the default wallet account and it's set at the moment of Status chat account creation, cannot be changed later
      "chat": false, #this refers to Status chat account, set when the Status account is created, cannot be changed later
      "type": accountType,
      "path": path,
      "public-key": publicKey,
      "name": name,
      "emoji": emoji,
      "colorId": colorId,
      "hidden": hideFromTotalBalance
      #"clock" we leave this empty, set on the status-go side
      #"removed" present on the status-go side, used for synchronization, no need to set it here
    }
  ]
  return core.callPrivateRPC("accounts_addAccount", payload)

## Adds a new keypair and creates a Keystore file if password is provided, otherwise it only creates a new keypair. Notifies paired devices.
proc addKeypair*(password, keyUid, keypairName, keypairType, rootWalletMasterKey: string, accounts: seq[WalletAccountDto]):
  RpcResponse[JsonNode] =
  var kpJson = %* {
    "key-uid": keyUid,
    "name": keypairName,
    "type": keypairType,
    "derived-from": rootWalletMasterKey,
    "last-used-derivation-index": 0, #when adding new keypair it's always 0
    #"synced-from": "", present on the status-go side, used for synchronization, no need to set it here
    #"clock": 0, we leave this empty, set on the status-go side
    "accounts": []
  }

  for acc in accounts:
    kpJson["accounts"].add(
      %*{
          "address": acc.address,
          "key-uid": keyUid,
          "wallet": false, #this refers to the default wallet account and it's set at the moment of Status chat account creation, cannot be changed later
          "chat": false, #this refers to Status chat account, set when the Status account is created, cannot be changed later
          "type": acc.walletType,
          "path": acc.path,
          "public-key": acc.publicKey,
          "name": acc.name,
          "emoji": acc.emoji,
          "colorId": acc.colorId,
          "hidden": acc.hideFromTotalBalance
          #"clock" we leave this empty, set on the status-go side
          #"removed" present on the status-go side, used for synchronization, no need to set it here
        }
    )

  let payload = %* [password, kpJson]
  return core.callPrivateRPC("accounts_addKeypair", payload)

## Adds a new account without creating a Keystore file and notifies paired devices
proc addAccountWithoutKeystoreFileCreation*(name, address, path, publicKey, keyUid, accountType, colorId, emoji: string, hideFromTotalBalance: bool):
  RpcResponse[JsonNode] =
  return addAccount(password = "", name, address, path, publicKey, keyUid, accountType, colorId, emoji, hideFromTotalBalance)

## Updates either regular or keycard account, without interaction to a Keystore file and notifies paired devices
proc updateAccount*(name, address, path: string, publicKey, keyUid, accountType, colorId, emoji: string,
  walletDefaultAccount: bool, chatDefaultAccount: bool, hideFromTotalBalance: bool):
  RpcResponse[JsonNode] =
  let payload = %* [
    {
      "address": address,
      "key-uid": keyUid,
      "wallet": walletDefaultAccount,
      "chat": chatDefaultAccount,
      "type": accountType,
      "path": path,
      "public-key": publicKey,
      "name": name,
      "emoji": emoji,
      "colorId": colorId,
      "hidden": hideFromTotalBalance
      #"clock" we leave this empty, set on the status-go side
      #"removed" present on the status-go side, used for synchronization, no need to set it here
    }
  ]
  return core.callPrivateRPC("accounts_saveAccount", payload)

proc decompressPk*(publicKey: string): RpcResponse[string] =
  discard
  if publicKey.startsWith("0x04") and publicKey.len == PK_LENGTH_0X_INCLUDED:
    # already decompressed
    result.result = publicKey
    return

  var response = status_go.multiformatDeserializePublicKey(publicKey, "f")
  # json response indicates error
  try:
    let jsonReponse = parseJson(response)
    result.error = RpcError(message: jsonReponse["error"].getStr())
  except JsonParsingError as e:
    let secp256k1Code = "fe701"
    response.removePrefix(secp256k1Code)
    result.result = "0x" & response

proc decompressCommunityKey*(publicKey: string): RpcResponse[string] =

  let response = status_go.decompressPublicKey(publicKey)

  # json response indicates error
  try:
    let jsonReponse = parseJson(response)
    result.error = RpcError(message: jsonReponse["error"].getStr())
  except JsonParsingError as e:
    result.result = response

proc compressCommunityKey*(publicKey: string): RpcResponse[string] =

  let response = status_go.compressPublicKey(publicKey)

  # json response indicates error
  try:
    let jsonReponse = parseJson(response)
    result.error = RpcError(message: jsonReponse["error"].getStr())
  except JsonParsingError as e:
    result.result = response

proc compressPk*(publicKey: string): RpcResponse[string] =
  let secp256k1Code = "0xe701"
  let base58btc = "z"
  var multiCodecKey = publicKey
  multiCodecKey.removePrefix("0x")
  multiCodecKey.insert(secp256k1Code)

  let response = status_go.multiformatSerializePublicKey(multiCodecKey, base58btc)

  # json response indicates error
  try:
    let jsonReponse = parseJson(response)
    result.error = RpcError(message: jsonReponse["error"].getStr())
  except JsonParsingError as e:
    result.result = response

proc generateAlias*(publicKey: string): RpcResponse[JsonNode] =
  try:
    let response = status_go.generateAlias(publicKey)
    result.result = %* response

  except RpcException as e:
    error "error doing rpc request", methodName = "generateAlias", exception=e.msg
    raise newException(RpcException, e.msg)

proc isAlias*(value: string): bool =
  let response = status_go.isAlias(value)
  let r = Json.decode(response, JsonNode)
  return r["result"].getBool()

proc getRandomMnemonic*(): RpcResponse[JsonNode] =
  let payload = %* []
  return core.callPrivateRPC("accounts_getRandomMnemonic", payload)

## Imports a new mnemonic and creates local keystore file.
proc importMnemonic*(mnemonic, password: string):
  RpcResponse[JsonNode] =
  let payload = %* [mnemonic, password]
  return core.callPrivateRPC("accounts_importMnemonic", payload)

proc makeSeedPhraseKeypairFullyOperable*(mnemonic, password: string):
  RpcResponse[JsonNode] =
  let payload = %* [mnemonic, password]
  return core.callPrivateRPC("accounts_makeSeedPhraseKeypairFullyOperable", payload)

proc makePartiallyOperableAccoutsFullyOperable*(password: string):
  RpcResponse[JsonNode] =
  let payload = %* [password]
  return core.callPrivateRPC("accounts_makePartiallyOperableAccoutsFullyOperable", payload)

proc migrateNonProfileKeycardKeypairToApp*(mnemonic: string, password: string):
  RpcResponse[JsonNode] =
  let payload = %* [mnemonic, password]
  return core.callPrivateRPC("accounts_migrateNonProfileKeycardKeypairToApp", payload)

proc createAccountFromMnemonicAndDeriveAccountsForPaths*(mnemonic: string, paths: seq[string]): RpcResponse[JsonNode] =
  let payload = %* {
    "mnemonicPhrase": mnemonic,
    "paths": paths,
    "Bip39Passphrase": ""
  }

  try:
    let response = status_go.createAccountFromMnemonicAndDeriveAccountsForPaths($payload)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "createAccountFromMnemonicAndDeriveAccountsForPaths", exception=e.msg
    raise newException(RpcException, e.msg)

## Imports a new private key and creates local keystore file.
proc importPrivateKey*(privateKey, password: string):
  RpcResponse[JsonNode] =
  let payload = %* [privateKey, password]
  return core.callPrivateRPC("accounts_importPrivateKey", payload)

proc makePrivateKeyKeypairFullyOperable*(privateKey, password: string):
  RpcResponse[JsonNode] =
  let payload = %* [privateKey, password]
  return core.callPrivateRPC("accounts_makePrivateKeyKeypairFullyOperable", payload)

proc createAccountFromPrivateKey*(privateKey: string): RpcResponse[JsonNode] =
  let payload = %* {"privateKey": privateKey}
  try:
    let response = status_go.createAccountFromPrivateKey($payload)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "createAccountFromPrivateKey", exception=e.msg
    raise newException(RpcException, e.msg)

proc openedAccounts*(path: string): RpcResponse[JsonNode] =
  try:
    let payload = %* {
      "dataDir": path,
      "mixpanelAppId": MIXPANEL_APP_ID,
      "mixpanelToken": MIXPANEL_TOKEN,
      "sentryDSN": SENTRY_DSN_STATUS_GO,
      "logEnabled": true,
      "logDir": "", # Empty value defaults to `dataDir`
      "logLevel": status_const.getStatusGoLogLevel(),
      "apiLoggingEnabled": status_const.API_LOGGING,
      "metricsEnabled": status_const.METRICS_ENABLED,
      "metricsAddress": status_const.METRICS_ADDRESS
    }
    # Do not remove the sleep 700
    # This sleep prevents a crash on intel MacOS
    # with errors like bad flushGen 12 in prepareForSweep; sweepgen 0
    if status_const.IS_MACOS and status_const.IS_INTEL:
      sleep 700
    let response = status_go.initializeApplication($payload)
    let jsonResponse = parseJson(response)
    let error = jsonResponse{"error"}.getStr()
    if error.len > 0:
      raise newException(RpcException, error)
    result.result = jsonResponse
  except RpcException as e:
    error "error doing rpc request", methodName = "openedAccounts", exception=e.msg
    raise newException(RpcException, e.msg)

proc addPeer*(peer: string): RpcResponse[JsonNode] =
  try:
    let response = status_go.addPeer(peer)
    result.result = %* response

  except RpcException as e:
    error "error doing rpc request", methodName = "addPeer", exception=e.msg
    raise newException(RpcException, e.msg)

proc createAccountAndLogin*(request: CreateAccountRequest): RpcResponse[JsonNode] =
  try:
    let payload = request.toJson()
    let response = status_go.createAccountAndLogin($payload)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "createAccountAndLogin", exception=e.msg
    raise newException(RpcException, e.msg)

proc restoreAccountAndLogin*(request: RestoreAccountRequest): RpcResponse[JsonNode] =
  try:
    let payload = request.toJson()
    let response = status_go.restoreAccountAndLogin($payload)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "restoreAccountAndLogin", exception=e.msg
    raise newException(RpcException, e.msg)

proc convertRegularProfileKeypairToKeycard*(account: JsonNode, settings: JsonNode, keycardUid: string, password: string, newPassword: string):
  RpcResponse[JsonNode] =
  try:
    let response = status_go.convertToKeycardAccount($account, $settings, keycardUid, password, newPassword)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "convertRegularProfileKeypairToKeycard", exception=e.msg
    raise newException(RpcException, e.msg)

proc convertKeycardProfileKeypairToRegular*(mnemonic: string, currPassword: string, newPassword: string):
  RpcResponse[JsonNode] =
  try:
    let response = status_go.convertToRegularAccount(mnemonic, currPassword, newPassword)
    result.result = Json.decode(response, JsonNode)
  except RpcException as e:
    error "error doing rpc request", methodName = "convertKeycardProfileKeypairToRegular", exception=e.msg
    raise newException(RpcException, e.msg)

proc loginAccount*(request: LoginAccountRequest): RpcResponse[JsonNode] =
  try:
    let payload = request.toJson()
    let response = status_go.loginAccount($payload)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "loginAccount failed", exception=e.msg
    raise newException(RpcException, e.msg)

proc verifyAccountPassword*(address: string, hashedPassword: string):
  RpcResponse[JsonNode] =
  try:
    let response = status_go.verifyAccountPassword(address, hashedPassword)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "verifyAccountPassword", exception=e.msg
    raise newException(RpcException, e.msg)

proc verifyDatabasePassword*(keyuid: string, hashedPassword: string):
  RpcResponse[JsonNode] =
  try:
    let response = status_go.verifyDatabasePassword(keyuid, hashedPassword)
    result.result = Json.decode(response, JsonNode)

  except RpcException as e:
    error "error doing rpc request", methodName = "verifyDatabasePassword", exception=e.msg
    raise newException(RpcException, e.msg)

proc storeIdentityImage*(keyUID: string, imagePath: string, aX, aY, bX, bY: int):
  RpcResponse[JsonNode] =
  let payload = %* [keyUID, imagePath, aX, aY, bX, bY]
  result = core.callPrivateRPC("multiaccounts_storeIdentityImage", payload)

proc deleteIdentityImage*(keyUID: string): RpcResponse[JsonNode] =
  let payload = %* [keyUID]
  result = core.callPrivateRPC("multiaccounts_deleteIdentityImage", payload)

proc setDisplayName*(displayName: string): RpcResponse[JsonNode] =
  let payload = %* [displayName]
  result = core.callPrivateRPC("setDisplayName".prefix, payload)

proc setBio*(bio: string): RpcResponse[JsonNode] =
  let payload = %* [bio]
  result = core.callPrivateRPC("setBio".prefix, payload)

proc getDerivedAddresses*(password: string, derivedFrom: string, paths: seq[string]): RpcResponse[JsonNode] =
  let payload = %* [password, derivedFrom, paths]
  result = core.callPrivateRPC("wallet_getDerivedAddresses", payload)

proc getDerivedAddressesForMnemonic*(mnemonic: string, paths: seq[string]): RpcResponse[JsonNode] =
  let payload = %* [mnemonic, paths]
  result = core.callPrivateRPC("wallet_getDerivedAddressesForMnemonic", payload)

proc getAddressDetails*(chainId: int, address: string): RpcResponse[JsonNode] =
  let payload = %* [chainId, address]
  result = core.callPrivateRPC("wallet_getAddressDetails", payload)

proc getAddressDetails*(address: string, chainIds: seq[uint64] = @[], timeoutInMilliseconds: int): RpcResponse[JsonNode] =
  let payload = %* [{
    "address": address,
    "chainIds": chainIds,
    "timeoutInMilliseconds": timeoutInMilliseconds,
  }]
  result = core.callPrivateRPC("wallet_addressDetails", payload)

proc addressExists*(address: string): RpcResponse[JsonNode] =
  let payload = %* [address]
  result = core.callPrivateRPC("wallet_addressExists", payload)

proc verifyPassword*(password: string): RpcResponse[JsonNode] =
  let payload = %* [password]
  return core.callPrivateRPC("accounts_verifyPassword", payload)

proc verifyKeystoreFileForAccount*(address, password: string): RpcResponse[JsonNode] =
  let payload = %* [address, password]
  return core.callPrivateRPC("accounts_verifyKeystoreFileForAccount", payload)

proc getProfileShowcaseAccountsByAddress*(address: string): RpcResponse[JsonNode] =
  let payload = %* [address]
  result = callPrivateRPC("getProfileShowcaseAccountsByAddress".prefix, payload)

proc getProfileShowcasePreferences*(): RpcResponse[JsonNode] =
  result = callPrivateRPC("getProfileShowcasePreferences".prefix, %*[])

proc setProfileShowcasePreferences*(preferences: JsonNode): RpcResponse[JsonNode] =
  result = callPrivateRPC("setProfileShowcasePreferences".prefix, preferences)

proc getProfileShowcaseSocialLinksLimit*(): RpcResponse[JsonNode] =
  let payload = %* []
  result = callPrivateRPC("getProfileShowcaseSocialLinksLimit".prefix, payload)

proc getProfileShowcaseEntriesLimit*(): RpcResponse[JsonNode] =
  let payload = %* []
  result = callPrivateRPC("getProfileShowcaseEntriesLimit".prefix, payload)

proc addressWasShown*(address: string): RpcResponse[JsonNode] =
  let payload = %* [address]
  return core.callPrivateRPC("accounts_addressWasShown", payload)

proc getNumOfAddressesToGenerateForKeypair*(keyUID: string): RpcResponse[JsonNode] =
  let payload = %* [keyUID]
  result = core.callPrivateRPC("accounts_getNumOfAddressesToGenerateForKeypair", payload)

proc resolveSuggestedPathForKeypair*(keyUID: string): RpcResponse[JsonNode] =
  let payload = %* [keyUID]
  result = core.callPrivateRPC("accounts_resolveSuggestedPathForKeypair", payload)

proc remainingAccountCapacity*(): RpcResponse[JsonNode] =
  let payload = %* []
  return core.callPrivateRPC("accounts_remainingAccountCapacity", payload)

proc remainingKeypairCapacity*(): RpcResponse[JsonNode] =
  let payload = %* []
  return core.callPrivateRPC("accounts_remainingKeypairCapacity", payload)

proc remainingWatchOnlyAccountCapacity*(): RpcResponse[JsonNode] =
  let payload = %* []
  return core.callPrivateRPC("accounts_remainingWatchOnlyAccountCapacity", payload)
