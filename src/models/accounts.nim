import json
import eventemitter
import ../status/libstatus
import ../status/accounts as status_accounts
import ../constants/constants
import ../status/utils

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

proc newAccountModel*(events: EventEmitter): AccountModel =
  result = AccountModel()
  result.events = events
  result.generatedAddresses = @[]

proc delete*(self: AccountModel) =
  # delete self.generatedAddresses
  discard

proc generateAddresses*(self: AccountModel): seq[GeneratedAccount] =
  let accounts = parseJson(status_accounts.generateAddresses())

  echo "----- generating accounts"
  for account in accounts:
    echo account
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

    # var generatedAccount = cast[GeneratedAccount](account.to(GeneratedAccountBase))

    # generatedAccount.username = $libstatus.generateAlias(account["publicKey"].str.toGoString)
    # generatedAccount.identicon = $libstatus.identicon(account["publicKey"].str.toGoString)
    # generatedAccount.key = account["address"].str

    self.generatedAddresses.add(generatedAccount)

  self.generatedAddresses
