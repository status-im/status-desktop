import json
import eventemitter
import ../status/libstatus
import ../status/accounts as status_accounts
import ../status/accounts/constants
import ../status/utils
import nimcrypto
import ../status/utils
# import "../../status/core" as status
import ../app/signals/types
import uuids

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

proc newAccountModel*(): AccountModel =
  result = AccountModel()
  result.events = createEventEmitter()
  result.generatedAddresses = @[]

proc delete*(self: AccountModel) =
  # delete self.generatedAddresses
  discard

proc generateAddresses*(self: AccountModel): seq[GeneratedAccount] =
  let accounts = parseJson(status_accounts.generateAddresses())
  for account in accounts:
    var generatedAccount = GeneratedAccount()

    generatedAccount.publicKey = account["publicKey"].str
    generatedAccount.address = account["address"].str
    generatedAccount.id = account["id"].str
    generatedAccount.keyUid = account["keyUid"].str
    generatedAccount.mnemonic = account["mnemonic"].str
    generatedAccount.derived = account["derived"]

    generatedAccount.username = $libstatus.generateAlias(account["publicKey"].str.toGoString)
    generatedAccount.identicon = $libstatus.identicon(account["publicKey"].str.toGoString)
    generatedAccount.key = account["address"].str

    self.generatedAddresses.add(generatedAccount)
  self.generatedAddresses

# TODO: this is temporary and will be removed once accounts import and creation is working
proc generateRandomAccountAndLogin*(self: AccountModel) =
  discard status_accounts.setupRandomTestAccount()
  self.events.emit("accountsReady", Args())

proc storeAccountAndLogin*(self: AccountModel, selectedAccountIndex: int, password: string): string =
  let account: GeneratedAccount = self.generatedAddresses[selectedAccountIndex]
  result = status_accounts.setupAccount(%account, password)
  self.events.emit("accountsReady", Args())
