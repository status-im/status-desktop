import json

type
  GeneratedAccount* = object
    publicKey*: string
    address*: string
    id*: string
    keyUid*: string
    mnemonic*: string
    derived*: JsonNode