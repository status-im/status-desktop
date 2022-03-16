import json, sequtils, strutils, uuids
import json_serialization, chronicles

import service_interface
import ./dto/accounts
import ./dto/generated_accounts
import ../../../backend/accounts as status_account
import ../../../backend/general as status_general

import ../../../app/core/fleets/fleet_configuration
import ../../common/[account_constants, network_constants, utils, string_utils]
import ../../../constants as main_constants

export service_interface

logScope:
  topics = "accounts-service"

const PATHS = @[PATH_WALLET_ROOT, PATH_EIP_1581, PATH_WHISPER, PATH_DEFAULT_WALLET]

type
  Service* = ref object of ServiceInterface
    fleetConfiguration: FleetConfiguration
    generatedAccounts: seq[GeneratedAccountDto]
    loggedInAccount: AccountDto
    importedAccount: GeneratedAccountDto
    isFirstTimeAccountLogin: bool

method delete*(self: Service) =
  discard

proc newService*(fleetConfiguration: FleetConfiguration): Service =
  result = Service()
  result.fleetConfiguration = fleetConfiguration
  result.isFirstTimeAccountLogin = false

method getLoggedInAccount*(self: Service): AccountDto =
  return self.loggedInAccount

method getImportedAccount*(self: Service): GeneratedAccountDto =
  return self.importedAccount

method isFirstTimeAccountLogin*(self: Service): bool =
  return self.isFirstTimeAccountLogin

proc generateAliasFromPk*(publicKey: string): string =
  return status_account.generateAlias(publicKey).result.getStr

proc generateIdenticonFromPk*(publicKey: string): string =
  return status_account.generateIdenticon(publicKey).result.getStr

proc isAlias*(value: string): bool =
  return status_account.isAlias(value)

method init*(self: Service) =
  try:
    let response = status_account.generateAddresses(PATHS)

    self.generatedAccounts = map(response.result.getElems(),
    proc(x: JsonNode): GeneratedAccountDto = toGeneratedAccountDto(x))

    for account in self.generatedAccounts.mitems:
      account.alias = generateAliasFromPk(account.derivedAccounts.whisper.publicKey)
      account.identicon = generateIdenticonFromPk(account.derivedAccounts.whisper.publicKey)

  except Exception as e:
    error "error: ", methodName="init", errName = e.name, errDesription = e.msg

method clear*(self: Service) =
  self.generatedAccounts = @[]
  self.loggedInAccount = AccountDto()
  self.importedAccount = GeneratedAccountDto()
  self.isFirstTimeAccountLogin = false

method validateMnemonic*(self: Service, mnemonic: string): string =
  try:
    let response = status_general.validateMnemonic(mnemonic)

    var error = "response doesn't contain \"error\""
    if(response.result.contains("error")):
      error = response.result["error"].getStr

    # An empty error means that mnemonic is valid.
    return error

  except Exception as e:
    error "error: ", methodName="validateMnemonic", errName = e.name, errDesription = e.msg

method generatedAccounts*(self: Service): seq[GeneratedAccountDto] =
  if(self.generatedAccounts.len == 0):
    error "There was some issue initiating account service"
    return

  result = self.generatedAccounts

method openedAccounts*(self: Service): seq[AccountDto] =
  try:
    let response = status_account.openedAccounts(main_constants.STATUSGODIR)

    let accounts = map(response.result.getElems(), proc(x: JsonNode): AccountDto = toAccountDto(x))

    return accounts

  except Exception as e:
    error "error: ", methodName="openedAccounts", errName = e.name, errDesription = e.msg

proc storeDerivedAccounts(self: Service, accountId, hashedPassword: string,
  paths: seq[string]): DerivedAccounts =
  try:
    let response = status_account.storeDerivedAccounts(accountId, hashedPassword, paths)
    result = toDerivedAccounts(response.result)

  except Exception as e:
    error "error: ", methodName="storeDerivedAccounts", errName = e.name, errDesription = e.msg

proc saveAccountAndLogin(self: Service, hashedPassword: string, account,
  subaccounts, settings, config: JsonNode): AccountDto =
  try:
    let response = status_account.saveAccountAndLogin(hashedPassword, account, subaccounts, settings, config)

    var error = "response doesn't contain \"error\""
    if(response.result.contains("error")):
      error = response.result["error"].getStr
      if error == "":
        debug "Account saved succesfully"
        self.isFirstTimeAccountLogin = true
        result = toAccountDto(account)
        return

    let err = "Error saving account and logging in: " & error
    error "error: ", methodName="saveAccountAndLogin", errDesription = err

  except Exception as e:
    error "error: ", methodName="saveAccountAndLogin", errName = e.name, errDesription = e.msg

proc prepareAccountJsonObject(self: Service, account: GeneratedAccountDto, displayName: string): JsonNode =
  result = %* {
    "name": if displayName == "": account.alias else: displayName,
    "address": account.address,
    "identicon": account.identicon,
    "key-uid": account.keyUid,
    "keycard-pairing": nil
  }

proc getAccountDataForAccountId(self: Service, accountId: string, displayName: string): JsonNode =
  for acc in self.generatedAccounts:
    if(acc.id == accountId):
      return self.prepareAccountJsonObject(acc, displayName)

  if(self.importedAccount.isValid()):
    if(self.importedAccount.id == accountId):
      return self.prepareAccountJsonObject(self.importedAccount, displayName)

proc prepareSubaccountJsonObject(self: Service, account: GeneratedAccountDto, displayName: string):
  JsonNode =
  result = %* [
    {
      "public-key": account.derivedAccounts.defaultWallet.publicKey,
      "address": account.derivedAccounts.defaultWallet.address,
      "color": "#4360df",
      "wallet": true,
      "path": PATH_DEFAULT_WALLET,
      "name": "Status account"
    },
    {
      "public-key": account.derivedAccounts.whisper.publicKey,
      "address": account.derivedAccounts.whisper.address,
      "name": if displayName == "": account.alias else: displayName,
      "identicon": account.identicon,
      "path": PATH_WHISPER,
      "chat": true
    }
  ]

proc getSubaccountDataForAccountId(self: Service, accountId: string, displayName: string): JsonNode =
  for acc in self.generatedAccounts:
    if(acc.id == accountId):
      return self.prepareSubaccountJsonObject(acc, displayName)

  if(self.importedAccount.isValid()):
    if(self.importedAccount.id == accountId):
      return self.prepareSubaccountJsonObject(self.importedAccount, displayName)

proc prepareAccountSettingsJsonObject(self: Service, account: GeneratedAccountDto,
  installationId: string, displayName: string): JsonNode =
  result = %* {
    "key-uid": account.keyUid,
    "mnemonic": account.mnemonic,
    "public-key": account.derivedAccounts.whisper.publicKey,
    "name": account.alias,
    "display-name": displayName,
    "address": account.address,
    "eip1581-address": account.derivedAccounts.eip1581.address,
    "dapps-address": account.derivedAccounts.defaultWallet.address,
    "wallet-root-address": account.derivedAccounts.walletRoot.address,
    "preview-privacy?": true,
    "signing-phrase": generateSigningPhrase(3),
    "log-level": $LogLevel.INFO,
    "latest-derived-path": 0,
    "networks/networks": DEFAULT_NETWORKS,
    "currency": "usd",
    "identicon": account.identicon,
    "waku-enabled": true,
    "wallet/visible-tokens": {
      DEFAULT_NETWORK_NAME: ["SNT"]
    },
    "appearance": 0,
    "networks/current-network": DEFAULT_NETWORK_NAME,
    "installation-id": installationId
  }

proc getAccountSettings(self: Service, accountId: string,
  installationId: string,
  displayName: string): JsonNode =
  for acc in self.generatedAccounts:
    if(acc.id == accountId):
      return self.prepareAccountSettingsJsonObject(acc, installationId, displayName)

  if(self.importedAccount.isValid()):
    if(self.importedAccount.id == accountId):
      return self.prepareAccountSettingsJsonObject(self.importedAccount, installationId, displayName)

proc getDefaultNodeConfig*(self: Service, installationId: string): JsonNode =
  let networkConfig = getNetworkConfig(DEFAULT_NETWORK_NAME)
  let upstreamUrl = networkConfig["config"]["UpstreamConfig"]["URL"]
  let fleet = Fleet.Prod

  var newDataDir = networkConfig["config"]["DataDir"].getStr
  newDataDir.removeSuffix("_rpc")
  result = NODE_CONFIG.copy()
  result["ClusterConfig"]["Fleet"] = newJString($fleet)
  result["ClusterConfig"]["BootNodes"] = %* self.fleetConfiguration.getNodes(fleet, FleetNodes.Bootnodes)
  result["ClusterConfig"]["TrustedMailServers"] = %* self.fleetConfiguration.getNodes(fleet, FleetNodes.Mailservers)
  result["ClusterConfig"]["StaticNodes"] = %* self.fleetConfiguration.getNodes(fleet, FleetNodes.Whisper)
  result["ClusterConfig"]["RendezvousNodes"] = %* self.fleetConfiguration.getNodes(fleet, FleetNodes.Rendezvous)
  result["NetworkId"] = networkConfig["config"]["NetworkId"]
  result["DataDir"] = newDataDir.newJString()
  result["UpstreamConfig"]["Enabled"] = networkConfig["config"]["UpstreamConfig"]["Enabled"]
  result["UpstreamConfig"]["URL"] = upstreamUrl
  result["ShhextConfig"]["InstallationID"] = newJString(installationId)

  # TODO: fleet.status.im should have different sections depending on the node type
  #       or maybe it's not necessary because a node has the identify protocol
  result["ClusterConfig"]["RelayNodes"] =  %* self.fleetConfiguration.getNodes(fleet, FleetNodes.Waku)
  result["ClusterConfig"]["StoreNodes"] =  %* self.fleetConfiguration.getNodes(fleet, FleetNodes.Waku)
  result["ClusterConfig"]["FilterNodes"] =  %* self.fleetConfiguration.getNodes(fleet, FleetNodes.Waku)
  result["ClusterConfig"]["LightpushNodes"] =  %* self.fleetConfiguration.getNodes(fleet, FleetNodes.Waku)

  # TODO: commented since it's not necessary (we do the connections thru C bindings). Enable it thru an option once status-nodes are able to be configured in desktop
  # result["ListenAddr"] = if existsEnv("STATUS_PORT"): newJString("0.0.0.0:" & $getEnv("STATUS_PORT")) else: newJString("0.0.0.0:30305")

method setupAccount*(self: Service, accountId, password, displayName: string): bool =
  try:
    let installationId = $genUUID()
    let accountDataJson = self.getAccountDataForAccountId(accountId, displayName)
    let subaccountDataJson = self.getSubaccountDataForAccountId(accountId, displayName)
    let settingsJson = self.getAccountSettings(accountId, installationId, displayName)
    let nodeConfigJson = self.getDefaultNodeConfig(installationId)

    if(accountDataJson.isNil or subaccountDataJson.isNil or settingsJson.isNil or
      nodeConfigJson.isNil):
      let description = "at least one json object is not prepared well"
      error "error: ", methodName="setupAccount", errDesription = description
      return false

    let hashedPassword = hashString(password)
    discard self.storeDerivedAccounts(accountId, hashedPassword, PATHS)

    self.loggedInAccount = self.saveAccountAndLogin(hashedPassword, accountDataJson, subaccountDataJson, settingsJson,
    nodeConfigJson)

    return self.getLoggedInAccount.isValid()

  except Exception as e:
    error "error: ", methodName="setupAccount", errName = e.name, errDesription = e.msg
    return false

method importMnemonic*(self: Service, mnemonic: string): bool =
  try:
    let response = status_account.multiAccountImportMnemonic(mnemonic)
    self.importedAccount = toGeneratedAccountDto(response.result)

    let responseDerived = status_account.deriveAccounts(self.importedAccount.id, PATHS)
    self.importedAccount.derivedAccounts = toDerivedAccounts(responseDerived.result)

    self.importedAccount.alias= generateAliasFromPk(self.importedAccount.derivedAccounts.whisper.publicKey)
    self.importedAccount.identicon = generateIdenticonFromPk(self.importedAccount.derivedAccounts.whisper.publicKey)

    return self.importedAccount.isValid()

  except Exception as e:
    error "error: ", methodName="importMnemonic", errName = e.name, errDesription = e.msg
    return false

method login*(self: Service, account: AccountDto, password: string): string =
  try:
    let hashedPassword = hashString(password)
    var thumbnailImage: string
    var largeImage: string
    for img in account.images:
      if(img.imgType == "thumbnail"):
        thumbnailImage = img.uri
      elif(img.imgType == "large"):
        largeImage = img.uri

    # This is moved from `status-lib` here
    # TODO:
    # If you added a new value in the nodeconfig in status-go, old accounts will not have this value, since the node config
    # is stored in the database, and it's not easy to migrate using .sql
    # While this is fixed, you can add here any missing attribute on the node config, and it will be merged with whatever
    # the account has in the db
    var nodeCfg = %* {
      "ShhextConfig": %* {
        "EnableMailserverCycle": true
      },
      "Web3ProviderConfig": %* {
        "Enabled": true
      },
      "EnsConfig": %* {
        "Enabled": true
      },
      "WalletConfig": {
        "Enabled": true,
        "OpenseaAPIKey": OPENSEA_API_KEY_RESOLVED
      },
    }

    let response = status_account.login(account.name, account.keyUid, hashedPassword, account.identicon, thumbnailImage,
    largeImage, $nodeCfg)

    var error = "response doesn't contain \"error\""
    if(response.result.contains("error")):
      error = response.result["error"].getStr
      if error == "":
        debug "Account logged in"
        self.loggedInAccount = account

    return error

  except Exception as e:
    error "error: ", methodName="setupAccount", errName = e.name, errDesription = e.msg
    return e.msg

method verifyAccountPassword*(self: Service, account: string, password: string): bool =
  try:
    let response = status_account.verifyAccountPassword(account, password, main_constants.KEYSTOREDIR)
    if(response.result.contains("error")):
      let errMsg = response.result["error"].getStr
      if(errMsg.len == 0):
        return true
      else:
        error "error: ", methodName="verifyAccountPassword", errDesription = errMsg
    return false
  except Exception as e:
    error "error: ", methodName="verifyAccountPassword", errName = e.name, errDesription = e.msg
