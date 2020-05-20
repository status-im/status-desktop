import NimQml
import json
import ../../status/accounts as status_accounts
import nimcrypto
import ../../status/utils
import ../../status/libstatus
import ../../models/accounts as Models
import ../../constants/constants
import uuids
import eventemitter
import ../../status/test as status_test

QtObject:
  type OnboardingView* = ref object of QObject
    m_generatedAddresses: string
    events: EventEmitter

  proc setup(self: OnboardingView) =
    self.QObject.setup

  proc delete*(self: OnboardingView) =
    self.QObject.delete

  proc newOnboardingView*(events: EventEmitter): OnboardingView =
    new(result, delete)
    result.events = events
    result.setup()

  proc getGeneratedAddresses*(self: OnboardingView): string {.slot.} =
    result = self.m_generatedAddresses

  proc generatedAddressesChanged*(self: OnboardingView,
      generatedAddresses: string) {.signal.}

  proc setGeneratedAddresses*(self: OnboardingView, generatedAddresses: string) {.slot.} =
    if self.m_generatedAddresses == generatedAddresses:
      return
    self.m_generatedAddresses = generatedAddresses
    self.generatedAddressesChanged(generatedAddresses)

  QtProperty[string]generatedAddresses:
    read = getGeneratedAddresses
    write = setGeneratedAddresses
    notify = generatedAddressesChanged

  # QML functions
  proc generateAddresses*(self: OnboardingView) {.slot.} =
    self.setGeneratedAddresses(status_accounts.generateAddresses())

  proc generateAlias*(self: OnboardingView, publicKey: string): string {.slot.} =
    result = $libstatus.generateAlias(publicKey.toGoString)

  proc identicon*(self: OnboardingView, publicKey: string): string {.slot.} =
    result = $libstatus.identicon(publicKey.toGoString)

  proc storeAccountAndLogin(self: OnboardingView, selectedAccount: string, password: string): string {.slot.} =
    let account = to(json.parseJson(selectedAccount), Models.GeneratedAccount)
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

    result = $libstatus.saveAccountAndLogin($accountData, password, $settingsJSON,
      $nodeConfig, $subaccountData)

    let saveResult = result.parseJson

    if saveResult["error"].getStr == "":
      self.events.emit("node:ready", Args())
      echo "Account saved succesfully"

  proc generateRandomAccountAndLogin*(self: OnboardingView) {.slot.} =
    discard status_test.setupNewAccount()
    self.events.emit("node:ready", Args())
