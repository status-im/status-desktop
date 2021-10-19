import Tables, json, sequtils, strutils, strformat, uuids
import json_serialization, chronicles

import service_interface
import ./dto/accounts
import ./dto/generated_accounts
import status/statusgo_backend_new/accounts as status_go
import status/statusgo_backend_new/general as status_go_general

import ../../common/[account_constants, utils, string_utils]
import ../../../constants as main_constants
export service_interface

logScope:
  topics = "accounts-service"

const PATHS = @[PATH_WALLET_ROOT, PATH_EIP_1581, PATH_WHISPER, PATH_DEFAULT_WALLET]

type 
  Service* = ref object of ServiceInterface
    generatedAccounts: seq[GeneratedAccountDto]
    loggedInAccount: AccountDto
    importedAccount: GeneratedAccountDto
    isFirstTimeAccountLogin: bool

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.isFirstTimeAccountLogin = false

method getLoggedInAccount*(self: Service): AccountDto =
  return self.loggedInAccount

method getImportedAccount*(self: Service): GeneratedAccountDto =
  return self.importedAccount

method isFirstTimeAccountLogin*(self: Service): bool =
  return self.isFirstTimeAccountLogin

method generateAlias*(self: Service, publicKey: string): string =
  return status_go.generateAlias(publicKey).result.getStr

method init*(self: Service) =
  try:
    let response = status_go.generateAddresses(PATHS)

    self.generatedAccounts = map(response.result.getElems(), 
    proc(x: JsonNode): GeneratedAccountDto = toGeneratedAccountDto(x))

    for account in self.generatedAccounts.mitems:
      account.alias = self.generateAlias(account.derivedAccounts.whisper.publicKey)
      
      let responseIdenticon = status_go.generateIdenticon(
        account.derivedAccounts.whisper.publicKey)
      account.identicon = responseIdenticon.result.getStr
  
  except Exception as e:
    error "error: ", methodName="init", errName = e.name, errDesription = e.msg

method validateMnemonic*(self: Service, mnemonic: string): string =
  try:
    let response = status_go_general.validateMnemonic(mnemonic)
    
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
    let response = status_go.openedAccounts(main_constants.STATUSGODIR)

    let accounts = map(response.result.getElems(), 
    proc(x: JsonNode): AccountDto = toAccountDto(x))

    return accounts

  except Exception as e:
    error "error: ", methodName="openedAccounts", errName = e.name, errDesription = e.msg

proc storeDerivedAccounts(self: Service, accountId, hashedPassword: string, 
  paths: seq[string]): DerivedAccounts =
  try:
    let response = status_go.storeDerivedAccounts(accountId, hashedPassword, paths)
    result = toDerivedAccounts(response.result)

  except Exception as e:
    error "error: ", methodName="storeDerivedAccounts", errName = e.name, errDesription = e.msg

proc saveAccountAndLogin(self: Service, hashedPassword: string, account, 
  subaccounts, settings, config: JsonNode): AccountDto =
  try:
    let response = status_go.saveAccountAndLogin(hashedPassword, account, 
    subaccounts, settings, config)

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

proc prepareAccountJsonObject(self: Service, account: GeneratedAccountDto): JsonNode =
  result = %* {
    "name": account.alias,
    "address": account.address,
    "identicon": account.identicon,
    "key-uid": account.keyUid,
    "keycard-pairing": nil
  }

proc getAccountDataForAccountId(self: Service, accountId: string): JsonNode =
  for acc in self.generatedAccounts:
    if(acc.id == accountId):
      return self.prepareAccountJsonObject(acc)

  if(self.importedAccount.isValid()):
    if(self.importedAccount.id == accountId):
      return self.prepareAccountJsonObject(self.importedAccount)

proc prepareSubaccountJsonObject(self: Service, account: GeneratedAccountDto):
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
      "name": account.alias,
      "identicon": account.identicon,
      "path": PATH_WHISPER,
      "chat": true
    }
  ]

proc getSubaccountDataForAccountId(self: Service, accountId: string): JsonNode =
  for acc in self.generatedAccounts:
    if(acc.id == accountId):
      return self.prepareSubaccountJsonObject(acc)

  if(self.importedAccount.isValid()):
    if(self.importedAccount.id == accountId):
      return self.prepareSubaccountJsonObject(self.importedAccount)
  
proc prepareAccountSettingsJsonObject(self: Service, account: GeneratedAccountDto,
  installationId: string): JsonNode =
  result = %* {
    "key-uid": account.keyUid,
    "mnemonic": account.mnemonic,
    "public-key": account.derivedAccounts.whisper.publicKey,
    "name": account.alias,
    "address": account.address,
    "eip1581-address": account.derivedAccounts.eip1581.address,
    "dapps-address": account.derivedAccounts.defaultWallet.address,
    "wallet-root-address": account.derivedAccounts.walletRoot.address,
    "preview-privacy?": true,
    "signing-phrase": generateSigningPhrase(3),
    "log-level": "INFO",
    "latest-derived-path": 0,
    "networks/networks": DEFAULT_NETWORKS,
    "currency": "usd",
    "identicon": account.identicon,
    "waku-enabled": true,
    "wallet/visible-tokens": {
      "mainnet": ["SNT"]
    },
    "appearance": 0,
    "networks/current-network": DEFAULT_NETWORK_NAME,
    "installation-id": installationId
  }

proc getAccountSettings(self: Service, accountId: string, 
  installationId: string): JsonNode =
  for acc in self.generatedAccounts:
    if(acc.id == accountId):
      return self.prepareAccountSettingsJsonObject(acc, installationId)

  if(self.importedAccount.isValid()):
    if(self.importedAccount.id == accountId):
      return self.prepareAccountSettingsJsonObject(self.importedAccount, installationId)

proc getDefaultNodeConfig*(self: Service, fleetConfig: FleetConfig, 
  installationId: string): JsonNode =
  let networkConfig = getNetworkConfig(DEFAULT_NETWORK_NAME)
  let upstreamUrl = networkConfig["config"]["UpstreamConfig"]["URL"]
  let fleet = Fleet.PROD

  var newDataDir = networkConfig["config"]["DataDir"].getStr
  newDataDir.removeSuffix("_rpc")
  result = NODE_CONFIG.copy()
  result["ClusterConfig"]["Fleet"] = newJString($fleet)
  result["ClusterConfig"]["BootNodes"] = %* fleetConfig.getNodes(fleet, FleetNodes.Bootnodes)
  result["ClusterConfig"]["TrustedMailServers"] = %* fleetConfig.getNodes(fleet, FleetNodes.Mailservers)
  result["ClusterConfig"]["StaticNodes"] = %* fleetConfig.getNodes(fleet, FleetNodes.Whisper)
  result["ClusterConfig"]["RendezvousNodes"] = %* fleetConfig.getNodes(fleet, FleetNodes.Rendezvous)
  result["NetworkId"] = networkConfig["config"]["NetworkId"]
  result["DataDir"] = newDataDir.newJString()
  result["UpstreamConfig"]["Enabled"] = networkConfig["config"]["UpstreamConfig"]["Enabled"]
  result["UpstreamConfig"]["URL"] = upstreamUrl
  result["ShhextConfig"]["InstallationID"] = newJString(installationId)

  # TODO: fleet.status.im should have different sections depending on the node type
  #       or maybe it's not necessary because a node has the identify protocol
  result["ClusterConfig"]["RelayNodes"] =  %* fleetConfig.getNodes(fleet, FleetNodes.Waku)
  result["ClusterConfig"]["StoreNodes"] =  %* fleetConfig.getNodes(fleet, FleetNodes.Waku)
  result["ClusterConfig"]["FilterNodes"] =  %* fleetConfig.getNodes(fleet, FleetNodes.Waku)
  result["ClusterConfig"]["LightpushNodes"] =  %* fleetConfig.getNodes(fleet, FleetNodes.Waku)

  # TODO: commented since it's not necessary (we do the connections thru C bindings). Enable it thru an option once status-nodes are able to be configured in desktop
  # result["ListenAddr"] = if existsEnv("STATUS_PORT"): newJString("0.0.0.0:" & $getEnv("STATUS_PORT")) else: newJString("0.0.0.0:30305")

method setupAccount*(self: Service, fleetConfig: FleetConfig, accountId, 
  password: string): bool =
  try:
    let installationId = $genUUID()
    let accountDataJson = self.getAccountDataForAccountId(accountId)
    let subaccountDataJson = self.getSubaccountDataForAccountId(accountId)
    let settingsJson = self.getAccountSettings(accountId, installationId)
    let nodeConfigJson = self.getDefaultNodeConfig(fleetConfig, installationId)

    if(accountDataJson.isNil or subaccountDataJson.isNil or settingsJson.isNil or 
      nodeConfigJson.isNil):
      let description = "at least one json object is not prepared well"
      error "error: ", methodName="setupAccount", errDesription = description
      return false

    let hashedPassword = hashString(password)
    discard self.storeDerivedAccounts(accountId, hashedPassword, PATHS)
    
    self.loggedInAccount = self.saveAccountAndLogin(hashedPassword, 
    accountDataJson, subaccountDataJson, settingsJson, nodeConfigJson)

    return self.getLoggedInAccount.isValid()

  except Exception as e:
    error "error: ", methodName="setupAccount", errName = e.name, errDesription = e.msg
    return false

method importMnemonic*(self: Service, mnemonic: string): bool =
  try:
    let response = status_go.multiAccountImportMnemonic(mnemonic)
    self.importedAccount = toGeneratedAccountDto(response.result)
    
    let responseDerived = status_go.deriveAccounts(self.importedAccount.id, PATHS)
    self.importedAccount.derivedAccounts = toDerivedAccounts(responseDerived.result)

    self.importedAccount.alias= self.generateAlias(self.importedAccount.derivedAccounts.whisper.publicKey)
    
    let responseIdenticon = status_go.generateIdenticon(
      self.importedAccount.derivedAccounts.whisper.publicKey)
    self.importedAccount.identicon = responseIdenticon.result.getStr

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

    let response = status_go.login(account.name, account.keyUid, hashedPassword,
    account.identicon, thumbnailImage, largeImage)

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