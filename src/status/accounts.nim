import libstatus
import core
import json
import utils
import accounts/constants
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

# const datadir = "./data/"
# const keystoredir = "./data/keystore/"
# const nobackupdir = "./noBackup/"

proc recreateDir(dirname: string) =
  if existsDir(dirname):
    removeDir(dirname)
  createDir(dirname)

proc ensureDir(dirname: string) =
  if not existsDir(dirname):
    # removeDir(dirname)
    createDir(dirname)

proc initNodeAccounts*() =
  const datadir = "./data/"
  const keystoredir = "./data/keystore/"
  const nobackupdir = "./noBackup/"

  ensureDir(datadir)
  ensureDir(keystoredir)
  ensureDir(nobackupdir)

  discard $libstatus.initKeystore(keystoredir);
  discard $libstatus.openAccounts(datadir);

proc saveAccountAndLogin*(multiAccounts: JsonNode, alias: string, identicon: string, accountData: string, password: string, configJSON: string, settingsJSON: string): JsonNode =
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

  var savedResult = $libstatus.saveAccountAndLogin(accountData, password, settingsJSON, configJSON, $subaccountData)
  let parsedSavedResult = savedResult.parseJson

  if parsedSavedResult["error"].getStr == "":
    echo "Account saved succesfully"
  subaccountData

proc generateMultiAccounts*(account: JsonNode, password: string): JsonNode =
  let multiAccount = %* {
    "accountID": account["id"].getStr,
    "paths": ["m/44'/60'/0'/0", "m/43'/60'/1581'", "m/43'/60'/1581'/0'/0", "m/44'/60'/0'/0/0"],
    "password": password
  }
  var response = $libstatus.multiAccountStoreDerivedAccounts($multiAccount);
  result = response.parseJson

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

proc setupRandomTestAccount*(): string =
  var result: string

  let generatedAddresses = generateAddresses().parseJson

  let account0 = generatedAddresses[0]
  let password = "0x2cd9bf92c5e20b1b410f5ace94d963a96e89156fbe65b70365e8596b37f1f165" #qwertyh
  let multiAccounts = generateMultiAccounts(account0, password)

  # 5
  let accountData = %* {
    "name": "Delectable Overjoyed Nauplius",
    "address": account0["address"].getStr,
    "photo-path": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAmElEQVR4nOzX4QmAIBBA4Yp2aY52aox2ao6mqf+SoajwON73M0J4HBy6TEEYQmMIjSE0htCECVlbDziv+/n6fuzb3OP/UmEmYgiNITRNm+LPqO2UE2YihtAYQlN818ptoZzau1btOakwEzGExhCa5hdi7d2p1zZLhZmIITSG0PhCpDGExhANEmYihtAYQmMIjSE0bwAAAP//kHQdRIWYzToAAAAASUVORK5CYII=",
    "key-uid": account0["keyUid"].getStr,
    "keycard-pairing": nil
  }

  # let alias = $libstatus.generateAlias(whisperPubKey.toGoString)
  # let identicon = $libstatus.identicon(whisperPubKey.toGoString)
  var alias = "Delectable Overjoyed Nauplius"
  var identicon = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAAmElEQVR4nOzX4QmAIBBA4Yp2aY52aox2ao6mqf+SoajwON73M0J4HBy6TEEYQmMIjSE0htCECVlbDziv+/n6fuzb3OP/UmEmYgiNITRNm+LPqO2UE2YihtAYQlN818ptoZzau1btOakwEzGExhCa5hdi7d2p1zZLhZmIITSG0PhCpDGExhANEmYihtAYQmMIjSE0bwAAAP//kHQdRIWYzToAAAAASUVORK5CYII="

  var settingsJSON = getAccountSettings(account0, alias, identicon, multiAccounts, constants.DEFAULT_NETWORKS)

  let configJSON = constants.NODE_CONFIG

  var subaccountdata = saveAccountAndLogin(multiAccounts, alias, identicon, $accountData, password, $configJSON, $settingsJSON)
  $subaccountData

