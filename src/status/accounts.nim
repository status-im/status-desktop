import eventemitter, options, chronicles, json
import libstatus/accounts as status_accounts
import libstatus/settings as status_settings
import libstatus/types
import libstatus/utils

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
    account.photoPath = status_accounts.generateIdenticon(account.derived.whisper.publicKey)
    self.generatedAddresses.add(account)
  result = self.generatedAddresses

proc openAccounts*(self: AccountModel): seq[NodeAccount] =
  result = status_accounts.openAccounts()

proc login*(self: AccountModel, selectedAccountIndex: int, password: string): NodeAccount =
  let currentNodeAccount = self.nodeAccounts[selectedAccountIndex]
  result = status_accounts.login(currentNodeAccount, password)

proc storeAccountAndLogin*(self: AccountModel, selectedAccountIndex: int, password: string): Account =
  let generatedAccount: GeneratedAccount = self.generatedAddresses[selectedAccountIndex]
  result = status_accounts.setupAccount(generatedAccount, password)

proc storeDerivedAndLogin*(self: AccountModel, importedAccount: GeneratedAccount, password: string): Account =
  result = status_accounts.setupAccount(importedAccount, password)

proc importMnemonic*(self: AccountModel, mnemonic: string): GeneratedAccount =
  let importedAccount = status_accounts.multiAccountImportMnemonic(mnemonic)
  importedAccount.derived = status_accounts.deriveAccounts(importedAccount.id)
  importedAccount.name = status_accounts.generateAlias(importedAccount.derived.whisper.publicKey)
  importedAccount.photoPath = status_accounts.generateIdenticon(importedAccount.derived.whisper.publicKey)
  result = importedAccount

proc reset*(self: AccountModel) =
  self.nodeAccounts = @[]
  self.generatedAddresses = @[]

proc generateAlias*(publicKey: string): string =
  result = status_accounts.generateAlias(publicKey)

proc generateIdenticon*(publicKey: string): string =
  result = status_accounts.generateIdenticon(publicKey)

proc changeNetwork*(self: AccountModel, network: string) =

  # 1. update current network setting
  var statusGoResult = status_settings.saveSetting(Setting.Networks_CurrentNetwork, network)
  if statusGoResult.error != "":
    error "Error saving current network setting", msg=statusGoResult.error

  # 2. update node config setting
  let installationId = status_settings.getSetting[string](Setting.InstallationId)
  let updatedNodeConfig = status_accounts.getNodeConfig(installationId, network)
  statusGoResult = status_settings.saveSetting(Setting.NodeConfig, updatedNodeConfig)
  if statusGoResult.error != "":
    error "Error saving updated node config", msg=statusGoResult.error

  # 3. remove all installed sticker packs (pack ids do not match across networks)
  statusGoResult = status_settings.saveSetting(Setting.Stickers_PacksInstalled, %* {})
  if statusGoResult.error != "":
    error "Error removing all installed sticker packs", msg=statusGoResult.error

  # 4. remove all recent stickers (pack ids do not match across networks)
  statusGoResult = status_settings.saveSetting(Setting.Stickers_Recent, %* {})
  if statusGoResult.error != "":
    error "Error removing all recent stickers", msg=statusGoResult.error