import libstatus
import core
import json
import utils
import accounts/constants
import nimcrypto
import os
import uuids
import types
import json_serialization
import chronicles

proc queryAccounts*(): string =
  var response = callPrivateRPC("eth_accounts")
  result = parseJson(response)["result"][0].getStr()

proc generateAddresses*(): seq[GeneratedAccount] =
  let multiAccountConfig = %* {
    "n": 5,
    "mnemonicPhraseLength": 12,
    "bip39Passphrase": "",
    "paths": [PATH_WHISPER, PATH_WALLET_ROOT, PATH_DEFAULT_WALLET]
  }
  result = Json.decode($libstatus.multiAccountGenerateAndDeriveAddresses($multiAccountConfig), seq[GeneratedAccount])

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

proc saveAccountAndLogin*(multiAccounts: MultiAccounts, alias: string, identicon: string, accountData: string, password: string, configJSON: string, settingsJSON: string): Account =
  let hashedPassword = "0x" & $keccak_256.digest(password)
  let subaccountData = %* [
    {
      "public-key": multiAccounts.defaultWallet.publicKey,
      "address": multiAccounts.defaultWallet.address,
      "color": "#4360df",
      "wallet": true,
      "path": constants.PATH_DEFAULT_WALLET,
      "name": "Status account"
    },
    {
      "public-key": multiAccounts.whisper.publicKey,
      "address": multiAccounts.whisper.address,
      "name": alias,
      "photo-path": identicon,
      "path": constants.PATH_WHISPER,
      "chat": true
    }
  ]

  var savedResult = $libstatus.saveAccountAndLogin(accountData, hashedPassword, settingsJSON, configJSON, $subaccountData)
  let parsedSavedResult = savedResult.parseJson

  if parsedSavedResult["error"].getStr == "":
    debug "Account saved succesfully"

  result = Account(name: alias, photoPath: identicon)

proc generateMultiAccounts*(account: GeneratedAccount, password: string): MultiAccounts =
  let hashedPassword = "0x" & $keccak_256.digest(password)
  let multiAccount = %* {
    "accountID": account.id,
    "paths": [PATH_WALLET_ROOT, PATH_EIP_1581, PATH_WHISPER, PATH_DEFAULT_WALLET],
    "password": hashedPassword
  }
  var response = $libstatus.multiAccountStoreDerivedAccounts($multiAccount);
  result = Json.decode($response, MultiAccounts)

proc getAccountData*(account: GeneratedAccount, alias: string, identicon: string): JsonNode =
  result = %* {
    "name": alias,
    "address": account.address,
    "photo-path": identicon,
    "key-uid": account.keyUid,
    "keycard-pairing": nil
  }

proc getAccountSettings*(account: GeneratedAccount, alias: string, identicon: string, multiAccounts: MultiAccounts, defaultNetworks: JsonNode): JsonNode =
  result = %* {
    "key-uid": account.keyUid,
    "mnemonic": account.mnemonic,
    "public-key": multiAccounts.whisper.publicKey,
    "name": alias,
    "address": account.address,
    "eip1581-address": multiAccounts.eip1581.address,
    "dapps-address": multiAccounts.defaultWallet.address,
    "wallet-root-address": multiAccounts.walletRoot.address,
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

proc setupAccount*(account: GeneratedAccount, password: string): Account =
  let multiAccounts = generateMultiAccounts(account, password)

  let whisperPubKey = account.derived.whisper.publicKey
  let alias = generateAlias(whisperPubKey)
  let identicon =generateIdenticon(whisperPubKey)

  let accountData = getAccountData(account, alias, identicon)
  var settingsJSON = getAccountSettings(account, alias, identicon, multiAccounts, constants.DEFAULT_NETWORKS)

  result = saveAccountAndLogin(multiAccounts, alias, identicon, $accountData, password, $constants.NODE_CONFIG, $settingsJSON)

  # TODO this is needed for now for the retrieving of past messages. We'll either move or remove it later
  let peer = "enode://44160e22e8b42bd32a06c1532165fa9e096eebedd7fa6d6e5f8bbef0440bc4a4591fe3651be68193a7ec029021cdb496cfe1d7f9f1dc69eb99226e6f39a7a5d4@35.225.221.245:443"
  discard libstatus.addPeer(peer)
