import json
import create_account_request

type
  RestoreAccountRequest* = object
    mnemonic*: string
    fetchBackup*: bool
    createAccountRequest*: CreateAccountRequest

proc toJson*(self: RestoreAccountRequest): JsonNode =
  result = %*{
    "mnemonic": self.mnemonic,
    "fetchBackup": self.fetchBackup,
  }

  for key, value in self.createAccountRequest.toJson().pairs():
    result[key] = value

