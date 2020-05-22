import json
import eventemitter
import ../status/accounts as status_accounts

type
  GeneratedAccount* = object
    publicKey*: string
    address*: string
    id*: string
    keyUid*: string
    mnemonic*: string
    derived*: JsonNode
    username*: string
    key*: string
    identicon*: string

type
  AccountModel* = ref object
    generatedAddresses*: seq[GeneratedAccount]
    events*: EventEmitter
    subaccounts*: JsonNode #TODO use correct account, etc..

proc newAccountModel*(): AccountModel =
  result = AccountModel()
  result.events = createEventEmitter()
  result.generatedAddresses = @[]
  result.subaccounts = %*{}

proc delete*(self: AccountModel) =
  # delete self.generatedAddresses
  discard

proc generateAddresses*(self: AccountModel): seq[GeneratedAccount] =
  let accounts = status_accounts.generateAddresses().parseJson
  for account in accounts:
    var generatedAccount = account.toGeneratedAccount

    generatedAccount.name = status_accounts.generateAlias(account["publicKey"].str)
    generatedAccount.photoPath = status_accounts.generateIdenticon(account["publicKey"].str)

    self.generatedAddresses.add(generatedAccount)
  self.generatedAddresses

# TODO: this is temporary and will be removed once accounts import and creation is working
proc generateRandomAccountAndLogin*(self: AccountModel) =
  let generatedAccounts = status_accounts.generateAddresses().parseJson
  self.subaccounts = status_accounts.setupAccount(generatedAccounts[0], "qwerty").parseJson
  self.events.emit("accountsReady", AccountArgs(account: self.subaccounts[1].toAccount))

proc storeAccountAndLogin*(self: AccountModel, selectedAccountIndex: int, password: string): string =
  let generatedAccount: GeneratedAccount = self.generatedAddresses[selectedAccountIndex]
  result = status_accounts.setupAccount(%generatedAccount, password)
  self.subaccounts = result.parseJson
  self.events.emit("accountsReady", AccountArgs(account: generatedAccount.toAccount))
