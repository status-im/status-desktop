import json
import eventemitter
import ../status/libstatus
import ../status/accounts as status_accounts
import ../status/accounts/constants
import ../status/utils
import nimcrypto
import ../status/utils
# import "../../status/core" as status
import ../app/signals/types
import uuids

type
  GeneratedAccount* = object
    publicKey*: string
    address*: string
    id*: string
    keyUid*: string
    mnemonic*: string
    derived*: JsonNode
    username*: string
    key*: string
    identicon*: string

type
  AccountModel* = ref object
    generatedAddresses*: seq[GeneratedAccount]
    events*: EventEmitter

proc newAccountModel*(): AccountModel =
  result = AccountModel()
  result.events = createEventEmitter()
  result.generatedAddresses = @[]

proc delete*(self: AccountModel) =
  # delete self.generatedAddresses
  discard

proc generateAddresses*(self: AccountModel): seq[GeneratedAccount] =
  let accounts = parseJson(status_accounts.generateAddresses())
  for account in accounts:
    var generatedAccount = GeneratedAccount()

    generatedAccount.publicKey = account["publicKey"].str
    generatedAccount.address = account["address"].str
    generatedAccount.id = account["id"].str
    generatedAccount.keyUid = account["keyUid"].str
    generatedAccount.mnemonic = account["mnemonic"].str
    generatedAccount.derived = account["derived"]

    generatedAccount.username = $libstatus.generateAlias(account["publicKey"].str.toGoString)
    generatedAccount.identicon = $libstatus.identicon(account["publicKey"].str.toGoString)
    generatedAccount.key = account["address"].str

    self.generatedAddresses.add(generatedAccount)
  self.generatedAddresses

# TODO: this is temporary and will be removed once accounts import and creation is working
proc generateRandomAccountAndLogin*(self: AccountModel) =
  discard status_accounts.setupRandomTestAccount()
  self.events.emit("accountsReady", Args())

proc storeAccountAndLogin*(self: AccountModel, selectedAccountIndex: int, password: string): string =
  let account: GeneratedAccount = self.generatedAddresses[selectedAccountIndex]
  let password = "0x" & $keccak_256.digest(password)
  let multiAccount = %* {
    "accountID": account.id,
    "paths": [constants.PATH_WALLET_ROOT, constants.PATH_EIP_1581, constants.PATH_WHISPER,
      constants.PATH_DEFAULT_WALLET],
    "password": password
  }
  let storeResult = $libstatus.multiAccountStoreDerivedAccounts($multiAccount);
  let multiAccounts = storeResult.parseJson
  let whisperPubKey = account.derived[constants.PATH_WHISPER]["publicKey"].getStr
  let alias = $libstatus.generateAlias(whisperPubKey.toGoString)
  let identicon = $libstatus.identicon(whisperPubKey.toGoString)
  let accountData = %* {
    "name": alias,
    "address": account.address,
    "photo-path": identicon,
    "key-uid": account.keyUid,
    "keycard-pairing": nil
  }
  var nodeConfig = constants.NODE_CONFIG
  let defaultNetworks = constants.DEFAULT_NETWORKS
  let settingsJSON = %* {
    "key-uid": account.keyUid,
    "mnemonic": account.mnemonic,
    "public-key": multiAccounts[constants.PATH_WHISPER]["publicKey"].getStr,
    "name": alias,
    "address": account.address,
    "eip1581-address": multiAccounts[constants.PATH_EIP_1581]["address"].getStr,
    "dapps-address": multiAccounts[constants.PATH_DEFAULT_WALLET]["address"].getStr,
    "wallet-root-address": multiAccounts[constants.PATH_WALLET_ROOT]["address"].getStr,
    "preview-privacy?": true,
    "signing-phrase": generateSigningPhrase(3),
    "log-level": "INFO",
    "latest-derived-path": 0,
    "networks/networks": $defaultNetworks,
    "currency": "usd",
    "photo-path": identicon,
    "waku-enabled": true,
    "wallet/visible-tokens": {
      "mainnet": ["SNT"]
    },
    "appearance": 0,
    "networks/current-network": "mainnet_rpc",
    "installation-id": $genUUID()
  }

  discard saveAccountAndLogin(multiAccounts, alias, identicon, $accountData, password, $nodeConfig, $settingsJSON)

  self.events.emit("accountsReady", Args())
  ""
