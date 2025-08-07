import json
import chronicles
import strutils
include ../../../common/json_utils

type
  Permission* {.pure.} = enum
    Web3 = "web3",
    ContactCode = "contact-code"
    Unknown = "unknown"

proc toPermission*(value: string): Permission =
  result = Permission.Unknown
  try:
    result = parseEnum[Permission](value)
  except:
    warn "Unknown permission requested", value
