import libstatus
import core
import json
import utils
import accounts/constants
import nimcrypto
import os
import uuids

proc queryAccounts*(): string =
  var payload = %* {
    "jsonrpc": "2.0",
    "method": "eth_accounts",
    "params": [
      []
    ]
  }
  var response = callPrivateRPC($payload)
  echo response
  result = parseJson(response)["result"][0].getStr()

proc generateAddresses*(): string =
  let multiAccountConfig = %* {
    "n": 5,
    "mnemonicPhraseLength": 12,
    "bip39Passphrase": "",
    "paths": ["m/43'/60'/1581'/0'/0", "m/44'/60'/0'/0/0"]
  }
  result = $libstatus.multiAccountGenerateAndDeriveAddresses($multiAccountConfig)

proc generateAlias*(publicKey: string): string =
  result = $libstatus.generateAlias(publicKey.toGoString)

proc generateIdenticon*(publicKey: string): string =
  result = $libstatus.identicon(publicKey.toGoString)

proc ensureDir(dirname: string) =
  if not existsDir(dirname):
    # removeDir(dirname)
    createDir(dirname)

proc initNodeAccounts*(): string =
  const datadir = "./data/"
  const keystoredir = "./data/keystore/"
  const nobackupdir = "./noBackup/"

  ensureDir(datadir)
  ensureDir(keystoredir)
  ensureDir(nobackupdir)

  discard $libstatus.initKeystore(keystoredir);
  result = $libstatus.openAccounts(datadir);

proc saveAccountAndLogin*(multiAccounts: JsonNode, alias: string, identicon: string, accountData: string, password: string, configJSON: string, settingsJSON: string): JsonNode =
  let hashedPassword = "0x" & $keccak_256.digest(password)
  let subaccountData = %* [
    {
      "public-key": multiAccounts[constants.PATH_DEFAULT_WALLET]["publicKey"],
      "address": multiAccounts[constants.PATH_DEFAULT_WALLET]["address"],
      "color": "#4360df",
      "wallet": true,
      "path": constants.PATH_DEFAULT_WALLET,
      "name": "Status account"
    },
    {
      "public-key": multiAccounts[constants.PATH_WHISPER]["publicKey"],
      "address": multiAccounts[constants.PATH_WHISPER]["address"],
      "name": alias,
      "photo-path": identicon,
      "path": constants.PATH_WHISPER,
      "chat": true
    }
  ]

  var savedResult = $libstatus.saveAccountAndLogin(accountData, hashedPassword, settingsJSON, configJSON, $subaccountData)
  let parsedSavedResult = savedResult.parseJson

  if parsedSavedResult["error"].getStr == "":
    echo "Account saved succesfully"
  subaccountData

proc generateMultiAccounts*(account: JsonNode, password: string): JsonNode =
  let hashedPassword = "0x" & $keccak_256.digest(password)
  let multiAccount = %* {
    "accountID": account["id"].getStr,
    "paths": ["m/44'/60'/0'/0", "m/43'/60'/1581'", "m/43'/60'/1581'/0'/0", "m/44'/60'/0'/0/0"],
    "password": hashedPassword
  }
  var response = $libstatus.multiAccountStoreDerivedAccounts($multiAccount);
  result = response.parseJson

proc getAccountData*(account: JsonNode, alias: string, identicon: string): JsonNode =
  result = %* {
    "name": alias,
    "address": account["address"].getStr,
    "photo-path": identicon,
    "key-uid": account["keyUid"].getStr,
    "keycard-pairing": nil
  }

proc getAccountSettings*(account: JsonNode, alias: string, identicon: string, multiAccounts: JsonNode, defaultNetworks: JsonNode): JsonNode =
  result = %* {
    "key-uid": account["keyUid"].getStr,
    "mnemonic": account["mnemonic"].getStr,
    "public-key": multiAccounts[constants.PATH_WHISPER]["publicKey"].getStr,
    "name": alias,
    "address": account["address"].getStr,
    "eip1581-address": multiAccounts[constants.PATH_EIP_1581]["address"].getStr,
    "dapps-address": multiAccounts[constants.PATH_DEFAULT_WALLET]["address"].getStr,
    "wallet-root-address": multiAccounts[constants.PATH_WALLET_ROOT]["address"].getStr,
    "preview-privacy?": true,
    "signing-phrase": generateSigningPhrase(3),
    "log-level": "INFO",
    "latest-derived-path": 0,
    "networks/networks": defaultNetworks,
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

proc setupAccount*(account: JsonNode, password: string): string =
  let multiAccounts = generateMultiAccounts(account, password)

  let whisperPubKey = account["derived"][constants.PATH_WHISPER]["publicKey"].getStr
  let alias = $libstatus.generateAlias(whisperPubKey.toGoString)
  let identicon = $libstatus.identicon(whisperPubKey.toGoString)

  let accountData = getAccountData(account, alias, identicon)
  var settingsJSON = getAccountSettings(account, alias, identicon, multiAccounts, constants.DEFAULT_NETWORKS)

  $saveAccountAndLogin(multiAccounts, alias, identicon, $accountData, password, $constants.NODE_CONFIG, $settingsJSON)
