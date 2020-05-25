import eventemitter
import json_serialization
import ../status/accounts as status_accounts
import ../status/types
import ../status/libstatus

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
  # TODO this is needed for now for the retrieving of past messages. We'll either move or remove it later
  let peer = "enode://44160e22e8b42bd32a06c1532165fa9e096eebedd7fa6d6e5f8bbef0440bc4a4591fe3651be68193a7ec029021cdb496cfe1d7f9f1dc69eb99226e6f39a7a5d4@35.225.221.245:443"
  discard libstatus.addPeer(peer)
  self.events.emit("accountsReady", AccountArgs(account: account))

proc storeAccountAndLogin*(self: AccountModel, selectedAccountIndex: int, password: string): Account =
  let generatedAccount: GeneratedAccount = self.generatedAddresses[selectedAccountIndex]
  result = status_accounts.setupAccount(generatedAccount, password)
  # TODO this is needed for now for the retrieving of past messages. We'll either move or remove it later
  let peer = "enode://44160e22e8b42bd32a06c1532165fa9e096eebedd7fa6d6e5f8bbef0440bc4a4591fe3651be68193a7ec029021cdb496cfe1d7f9f1dc69eb99226e6f39a7a5d4@35.225.221.245:443"
  discard libstatus.addPeer(peer)
  self.events.emit("accountsReady", AccountArgs(account: result))
