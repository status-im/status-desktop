import libstatus/accounts as status_accounts
import libstatus/types
import options

type
  AccountModel* = ref object
    generatedAddresses*: seq[GeneratedAccount]
    nodeAccounts*: seq[NodeAccount]
    currentLoginAccount*: Account
    currentOnboardingAccount*: Account

proc newAccountModel*(): AccountModel =
  result = AccountModel()
  result.currentLoginAccount = nil
  result.currentOnboardingAccount = nil

proc generateAddresses*(self: AccountModel): seq[GeneratedAccount] =
  var accounts = status_accounts.generateAddresses()
  for account in accounts.mitems:
    account.name = status_accounts.generateAlias(account.derived.whisper.publicKey)
    account.photoPath = status_accounts.generateIdenticon(account.derived.whisper.publicKey)
    self.generatedAddresses.add(account)
  self.generatedAddresses

proc login*(self: AccountModel, selectedAccountIndex: int, password: string): NodeAccount =
  let currentNodeAccount = self.nodeAccounts[selectedAccountIndex]
  self.currentLoginAccount = currentNodeAccount.toAccount
  result = status_accounts.login(currentNodeAccount, password)

proc storeAccountAndLogin*(self: AccountModel, selectedAccountIndex: int, password: string): Account =
  let generatedAccount: GeneratedAccount = self.generatedAddresses[selectedAccountIndex]
  result = status_accounts.setupAccount(generatedAccount, password)
  self.currentOnboardingAccount = generatedAccount.toAccount

proc storeDerivedAndLogin*(self: AccountModel, importedAccount: GeneratedAccount, password: string): Account =
  result = status_accounts.setupAccount(importedAccount, password)
  self.currentOnboardingAccount = importedAccount.toAccount

proc importMnemonic*(self: AccountModel, mnemonic: string): GeneratedAccount =
  let importedAccount = status_accounts.multiAccountImportMnemonic(mnemonic)
  importedAccount.derived = status_accounts.deriveAccounts(importedAccount.id)
  importedAccount.name = status_accounts.generateAlias(importedAccount.derived.whisper.publicKey)
  importedAccount.photoPath = status_accounts.generateIdenticon(importedAccount.derived.whisper.publicKey)
  result = importedAccount
