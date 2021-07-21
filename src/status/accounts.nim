import options, chronicles, json, json_serialization, sequtils, sugar
import libstatus/accounts as status_accounts
import libstatus/settings as status_settings
import types
import utils
import ../eventemitter

const DEFAULT_NETWORK_NAME* = "mainnet_rpc"

type
  AccountModel* = ref object
    generatedAddresses*: seq[GeneratedAccount]
    nodeAccounts*: seq[NodeAccount]
    events: EventEmitter

proc newAccountModel*(events: EventEmitter): AccountModel =
  result = AccountModel()
  result.events = events

proc generateAddresses*(self: AccountModel): seq[GeneratedAccount] =
  var accounts = status_accounts.generateAddresses()
  for account in accounts.mitems:
    account.name = status_accounts.generateAlias(account.derived.whisper.publicKey)
    account.identicon = status_accounts.generateIdenticon(account.derived.whisper.publicKey)
    self.generatedAddresses.add(account)
  result = self.generatedAddresses

proc openAccounts*(self: AccountModel): seq[NodeAccount] =
  result = status_accounts.openAccounts()

proc login*(self: AccountModel, selectedAccountIndex: int, password: string): NodeAccount =
  let currentNodeAccount = self.nodeAccounts[selectedAccountIndex]
  result = status_accounts.login(currentNodeAccount, password)

proc storeAccountAndLogin*(self: AccountModel, fleetConfig: FleetConfig, selectedAccountIndex: int, password: string): Account =
  let generatedAccount: GeneratedAccount = self.generatedAddresses[selectedAccountIndex]
  result = status_accounts.setupAccount(fleetConfig, generatedAccount, password)

proc storeDerivedAndLogin*(self: AccountModel, fleetConfig: FleetConfig, importedAccount: GeneratedAccount, password: string): Account =
  result = status_accounts.setupAccount(fleetConfig, importedAccount, password)

proc importMnemonic*(self: AccountModel, mnemonic: string): GeneratedAccount =
  let importedAccount = status_accounts.multiAccountImportMnemonic(mnemonic)
  importedAccount.derived = status_accounts.deriveAccounts(importedAccount.id)
  importedAccount.name = status_accounts.generateAlias(importedAccount.derived.whisper.publicKey)
  importedAccount.identicon = status_accounts.generateIdenticon(importedAccount.derived.whisper.publicKey)
  result = importedAccount

proc reset*(self: AccountModel) =
  self.nodeAccounts = @[]
  self.generatedAddresses = @[]

proc generateAlias*(publicKey: string): string =
  result = status_accounts.generateAlias(publicKey)

proc generateIdenticon*(publicKey: string): string =
  result = status_accounts.generateIdenticon(publicKey)

proc generateAlias*(self: AccountModel, publicKey: string): string =
  result = generateAlias(publicKey)

proc generateIdenticon*(self: AccountModel, publicKey: string): string =
  result = generateIdenticon(publicKey)

proc changeNetwork*(self: AccountModel, fleetConfig: FleetConfig, network: string) =
  var statusGoResult = status_settings.setNetwork(network)
  if statusGoResult.error != "":
    error "Error saving updated node config", msg=statusGoResult.error

  # remove all installed sticker packs (pack ids do not match across networks)
  statusGoResult = status_settings.saveSetting(Setting.Stickers_PacksInstalled, %* {})
  if statusGoResult.error != "":
    error "Error removing all installed sticker packs", msg=statusGoResult.error

  # remove all recent stickers (pack ids do not match across networks)
  statusGoResult = status_settings.saveSetting(Setting.Stickers_Recent, %* {})
  if statusGoResult.error != "":
    error "Error removing all recent stickers", msg=statusGoResult.error
