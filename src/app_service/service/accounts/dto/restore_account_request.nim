import json
import create_account_request, keycard_data

export create_account_request, keycard_data

type
  RestoreAccountRequest* = object
    mnemonic*: string
    keycard*: KeycardData
    fetchBackup*: bool
    createAccountRequest*: CreateAccountRequest

proc toJson*(self: RestoreAccountRequest): JsonNode =

  result = %*{
    "mnemonic": self.mnemonic,
    "fetchBackup": self.fetchBackup,
  }

  if self.keycard != nil:
    result["keycard"] = self.keycard.toJson()

  for key, value in self.createAccountRequest.toJson().pairs():
    result[key] = value

