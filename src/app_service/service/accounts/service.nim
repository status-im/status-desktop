import Tables, json, sequtils, strutils, strformat, uuids, chronicles

import service_interface
import ./dto/accounts
import ./dto/generated_accounts
import status/statusgo_backend_new/accounts as status_go

import ../../common/[account_constants, utils, string_utils]
import ../../../constants as main_constants
export service_interface

logScope:
  topics = "accounts-service"

const PATHS = @[PATH_WALLET_ROOT, PATH_EIP_1581, PATH_WHISPER, PATH_DEFAULT_WALLET]

type 
  Service* = ref object of ServiceInterface
    generatedAccounts: seq[GeneratedAccountDto]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

method init*(self: Service) =
  try:
    let response = status_go.generateAddresses(PATHS)

    self.generatedAccounts = map(response.result.getElems(), 
    proc(x: JsonNode): GeneratedAccountDto = toGeneratedAccountDto(x))

    for account in self.generatedAccounts.mitems:
      let responseAlias = status_go.generateAlias(
        account.derivedAccounts.whisper.publicKey)
      account.alias = responseAlias.result.getStr
      
      let responseIdenticon = status_go.generateIdenticon(
        account.derivedAccounts.whisper.publicKey)
      account.identicon = responseIdenticon.result.getStr
  
  except Exception as e:
    error "error: ", methodName="init", errName = e.name, errDesription = e.msg

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
        result = toAccountDto(account)
        return

    let err = "Error saving account and logging in: " & error
    error "error: ", methodName="saveAccountAndLogin", errDesription = err

  except Exception as e:
    error "error: ", methodName="saveAccountAndLogin", errName = e.name, errDesription = e.msg

proc getAccountDataForAccountId(self: Service, accountId: string): JsonNode =
  for acc in self.generatedAccounts:
    if(acc.id == accountId):
      result = %* {
        "name": acc.alias,
        "address": acc.address,
        "identicon": acc.identicon,
        "key-uid": acc.keyUid,
        "keycard-pairing": nil
      }

proc getSubaccountDataForAccountId(self: Service, accountId: string): JsonNode =
  for acc in self.generatedAccounts:
    if(acc.id == accountId):
      result = %* [
        {
          "public-key": acc.derivedAccounts.defaultWallet.publicKey,
          "address": acc.derivedAccounts.defaultWallet.address,
          "color": "#4360df",
          "wallet": true,
          "path": PATH_DEFAULT_WALLET,
          "name": "Status account"
        },
        {
          "public-key": acc.derivedAccounts.whisper.publicKey,
          "address": acc.derivedAccounts.whisper.address,
          "name": acc.alias,
          "identicon": acc.identicon,
          "path": PATH_WHISPER,
          "chat": true
        }
      ]
  
proc getAccountSettings(self: Service, accountId: string, 
  installationId: string): JsonNode =
  for acc in self.generatedAccounts:
    if(acc.id == accountId):
      result = %* {
        "key-uid": acc.keyUid,
        "mnemonic": acc.mnemonic,
        "public-key": acc.derivedAccounts.whisper.publicKey,
        "name": acc.alias,
        "address": acc.address,
        "eip1581-address": acc.derivedAccounts.eip1581.address,
        "dapps-address": acc.derivedAccounts.defaultWallet.address,
        "wallet-root-address": acc.derivedAccounts.walletRoot.address,
        "preview-privacy?": true,
        "signing-phrase": generateSigningPhrase(3),
        "log-level": "INFO",
        "latest-derived-path": 0,
        "networks/networks": DEFAULT_NETWORKS,
        "currency": "usd",
        "identicon": acc.identicon,
        "waku-enabled": true,
        "wallet/visible-tokens": {
          "mainnet": ["SNT"]
        },
        "appearance": 0,
        "networks/current-network": DEFAULT_NETWORK_NAME,
        "installation-id": installationId
      }

proc getDefaultNodeConfig*(self: Service, fleetConfig: FleetConfig, installationId: string):
  JsonNode =
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
  password: string): AccountDto =
  try:
    let installationId = $genUUID()
    let accountDataJson = self.getAccountDataForAccountId(accountId)
    let subaccountDataJson = self.getSubaccountDataForAccountId(accountId)
    let settingsJSON = self.getAccountSettings(accountId, installationId)
    let nodeConfig = self.getDefaultNodeConfig(fleetConfig, installationId)

    let hashedPassword = hashString(password)
    discard self.storeDerivedAccounts(accountId, hashedPassword, PATHS)
    return self.saveAccountAndLogin(hashedPassword, accountDataJson, 
    subaccountDataJson, settingsJSON, nodeConfig)

  except Exception as e:
    error "error: ", methodName="setupAccount", errName = e.name, errDesription = e.msg
