import libstatus
import core
import json
import utils as utils
import accounts/constants
import nimcrypto
import os
import uuids
import types as types
import json_serialization
import chronicles
import ../../signals/types as signal_types
import ../wallet/account

proc queryAccounts*(): string =
  var response = callPrivateRPC("eth_accounts")
  result = parseJson(response)["result"][0].getStr()

proc generateAddresses*(n = 5): seq[GeneratedAccount] =
  let multiAccountConfig = %* {
    "n": n,
    "mnemonicPhraseLength": 12,
    "bip39Passphrase": "",
    "paths": [PATH_WALLET_ROOT, PATH_EIP_1581, PATH_WHISPER, PATH_DEFAULT_WALLET]
  }
  let generatedAccounts = $libstatus.multiAccountGenerateAndDeriveAddresses($multiAccountConfig)
  result = Json.decode(generatedAccounts, seq[GeneratedAccount])

proc generateAlias*(publicKey: string): string =
  result = $libstatus.generateAlias(publicKey.toGoString)

proc generateIdenticon*(publicKey: string): string =
  result = $libstatus.identicon(publicKey.toGoString)

proc ensureDir(dirname: string) =
  if not existsDir(dirname):
    # removeDir(dirname)
    createDir(dirname)

proc initNode*() =
  ensureDir(DATADIR)
  ensureDir(KEYSTOREDIR)
  ensureDir(NOBACKUPDIR)

  discard $libstatus.initKeystore(KEYSTOREDIR)

proc openAccounts*(): seq[NodeAccount] =
  let strNodeAccounts = $libstatus.openAccounts(DATADIR)
  result = Json.decode(strNodeAccounts, seq[NodeAccount])

proc saveAccountAndLogin*(
  account: GeneratedAccount,
  accountData: string,
  password: string,
  configJSON: string,
  settingsJSON: string): types.Account =
  let hashedPassword = "0x" & $keccak_256.digest(password)
  let subaccountData = %* [
    {
      "public-key": account.derived.defaultWallet.publicKey,
      "address": account.derived.defaultWallet.address,
      "color": "#4360df",
      "wallet": true,
      "path": constants.PATH_DEFAULT_WALLET,
      "name": "Status account"
    },
    {
      "public-key": account.derived.whisper.publicKey,
      "address": account.derived.whisper.address,
      "name": account.name,
      "photo-path": account.photoPath,
      "path": constants.PATH_WHISPER,
      "chat": true
    }
  ]

  var savedResult = $libstatus.saveAccountAndLogin(accountData, hashedPassword, settingsJSON, configJSON, $subaccountData)
  let parsedSavedResult = savedResult.parseJson
  let error = parsedSavedResult["error"].getStr

  if error == "":
    debug "Account saved succesfully"
    result = account.toAccount
    return

  raise newException(StatusGoException, "Error saving account and logging in: " & error)

proc storeDerivedAccounts*(account: GeneratedAccount, password: string): MultiAccounts =
  let hashedPassword = "0x" & $keccak_256.digest(password)
  let multiAccount = %* {
    "accountID": account.id,
    "paths": [PATH_WALLET_ROOT, PATH_EIP_1581, PATH_WHISPER, PATH_DEFAULT_WALLET],
    "password": hashedPassword
  }
  let response = $libstatus.multiAccountStoreDerivedAccounts($multiAccount);
  
  try: 
    result = Json.decode($response, MultiAccounts)
  except: 
    let err = Json.decode($response, StatusGoError)
    raise newException(StatusGoException, "Error storing multiaccount derived accounts: " & err.error)

proc getAccountData*(account: GeneratedAccount): JsonNode =
  result = %* {
    "name": account.name,
    "address": account.address,
    "photo-path": account.photoPath,
    "key-uid": account.keyUid,
    "keycard-pairing": nil
  }

proc getAccountSettings*(account: GeneratedAccount, defaultNetworks: JsonNode, installationId: string): JsonNode =
  result = %* {
    "key-uid": account.keyUid,
    "mnemonic": account.mnemonic,
    "public-key": account.derived.whisper.publicKey,
    "name": account.name,
    "address": account.address,
    "eip1581-address": account.derived.eip1581.address,
    "dapps-address": account.derived.defaultWallet.address,
    "wallet-root-address": account.derived.walletRoot.address,
    "preview-privacy?": true,
    "signing-phrase": generateSigningPhrase(3),
    "log-level": "INFO",
    "latest-derived-path": 0,
    "networks/networks": defaultNetworks,
    "currency": "usd",
    "photo-path": account.photoPath,
    "waku-enabled": true,
    "wallet/visible-tokens": {
      "mainnet": ["SNT"]
    },
    "appearance": 0,
    "networks/current-network": "mainnet_rpc",
    "installation-id": installationId
  }

proc setupAccount*(account: GeneratedAccount, password: string): types.Account =
  try:
    let storeDerivedResult = storeDerivedAccounts(account, password)
    let accountData = getAccountData(account)
    let installationId = $genUUID()
    var settingsJSON = getAccountSettings(account, constants.DEFAULT_NETWORKS, installationId)
    var nodeConfig = constants.NODE_CONFIG
    nodeConfig["ShhextConfig"]["InstallationID"] = newJString(installationId)

    result = saveAccountAndLogin(account, $accountData, password, $nodeConfig, $settingsJSON)

  except StatusGoException as e:
    raise newException(StatusGoException, "Error setting up account: " & e.msg)

  finally:
    # TODO this is needed for now for the retrieving of past messages. We'll either move or remove it later
    let peer = "enode://44160e22e8b42bd32a06c1532165fa9e096eebedd7fa6d6e5f8bbef0440bc4a4591fe3651be68193a7ec029021cdb496cfe1d7f9f1dc69eb99226e6f39a7a5d4@35.225.221.245:443"
    discard libstatus.addPeer(peer)

proc login*(nodeAccount: NodeAccount, password: string): NodeAccount =
  let hashedPassword = "0x" & $keccak_256.digest(password)
  let account = nodeAccount.toAccount
  let loginResult = $libstatus.login($toJson(account), hashedPassword)
  let error = parseJson(loginResult)["error"].getStr

  if error == "":
    debug "Login requested", user=nodeAccount.name
    result = nodeAccount
    return

  raise newException(StatusGoException, "Error logging in: " & error)

proc multiAccountImportMnemonic*(mnemonic: string): GeneratedAccount =
  let mnemonicJson = %* {
    "mnemonicPhrase": mnemonic,
    "Bip39Passphrase": ""
  }
  # libstatus.multiAccountImportMnemonic never results in an error given ANY input
  let importResult = $libstatus.multiAccountImportMnemonic($mnemonicJson)
  result = Json.decode(importResult, GeneratedAccount)

proc MultiAccountImportPrivateKey*(privateKey: string): GeneratedAccount =
  let privateKeyJson = %* {
    "privateKey": privateKey
  }
  # libstatus.MultiAccountImportPrivateKey never results in an error given ANY input
  try:
    let importResult = $libstatus.MultiAccountImportPrivateKey($privateKeyJson)
    result = Json.decode(importResult, GeneratedAccount)
  except Exception as e:
    error "Error getting account from private key", msg=e.msg

proc saveAccount*(account: GeneratedAccount, password: string, color: string, accountType: string, isADerivedAccount = true): DerivedAccount =
  try:
    # Only store derived accounts. Private key accounts are not multiaccounts
    if (isADerivedAccount):
      discard storeDerivedAccounts(account, password)

    var address = account.derived.defaultWallet.address
    var publicKey = account.derived.defaultWallet.publicKey

    if (address == ""):
      address = account.address
      publicKey = account.publicKey

    discard callPrivateRPC("accounts_saveAccounts", %* [
      [{
        "color": color,
        "name": account.name,
        "address": address,
        "public-key": publicKey,
        "type": accountType,
        "path": "m/44'/60'/0'/0/1"
      }]
    ])

    result = DerivedAccount(address: address, publicKey: publicKey)
  except:
    error "Error storing the new account. Bad password?"

proc changeAccount*(account: WalletAccount): string =
  try:
    let response = callPrivateRPC("accounts_saveAccounts", %* [
      [{
        "color": account.iconColor,
        "name": account.name,
        "address": account.address,
        "public-key": account.publicKey,
        "type": account.walletType,
        "path": "m/44'/60'/0'/0/1"
      }]
    ])

    utils.handleRPCErrors(response)
    return ""
  except Exception as e:
    error "Error saving the account", msg=e.msg
    result = e.msg

proc deleteAccount*(address: string): string =
  try:
    let response = callPrivateRPC("accounts_deleteAccount", %* [address])

    utils.handleRPCErrors(response)
    return ""
  except Exception as e:
    error "Error removing the account", msg=e.msg
    result = e.msg

proc deriveAccounts*(accountId: string): MultiAccounts =
  let deriveJson = %* {
    "accountID": accountId,
    "paths": [PATH_WALLET_ROOT, PATH_EIP_1581, PATH_WHISPER, PATH_DEFAULT_WALLET]
  }
  let deriveResult = $libstatus.multiAccountDeriveAddresses($deriveJson)
  result = Json.decode(deriveResult, MultiAccounts)

proc logout*(): StatusGoError =
  result = Json.decode($libstatus.logout(), StatusGoError)
