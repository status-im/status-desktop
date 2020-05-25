import eventemitter
import json_serialization
import ../status/accounts as status_accounts
import ../status/types

type
  Address* = ref object
    username*, identicon*, key*: string

proc toAddress*(account: GeneratedAccount): Address =
  result = Address(username: account.name, identicon: account.photoPath, key: account.address)

type
  AccountModel* = ref object
    generatedAddresses*: seq[GeneratedAccount]
    events*: EventEmitter

proc newAccountModel*(): AccountModel =
  result = AccountModel()
  result.events = createEventEmitter()
  result.generatedAddresses = @[]

proc delete*(self: AccountModel) =
  # delete self.generatedAddresses
  discard

proc generateAddresses*(self: AccountModel): seq[GeneratedAccount] =
  var accounts = status_accounts.generateAddresses()
  for account in accounts.mitems:
    account.name = status_accounts.generateAlias(account.derived.whisper.publicKey)
    account.photoPath = status_accounts.generateIdenticon(account.derived.whisper.publicKey)
    self.generatedAddresses.add(account)
  self.generatedAddresses

# TODO: this is temporary and will be removed once accounts import and creation is working
proc generateRandomAccountAndLogin*(self: AccountModel) =
  let generatedAccounts = status_accounts.generateAddresses()
  let account = status_accounts.setupAccount(generatedAccounts[0], "qwerty")
  self.events.emit("accountsReady", AccountArgs(account: account))

proc storeAccountAndLogin*(self: AccountModel, selectedAccountIndex: int, password: string): Account =
  let generatedAccount: GeneratedAccount = self.generatedAddresses[selectedAccountIndex]
  result = status_accounts.setupAccount(generatedAccount, password)
  self.events.emit("accountsReady", AccountArgs(account: result))
