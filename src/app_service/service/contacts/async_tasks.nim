import os, parseutils
import ../ens/utils as ens_utils

include ../../common/json_utils
from ../../common/conversion import isCompressedPubKey
include ../../../app/core/tasks/common

#################################################
# Async lookup ENS contact
#################################################

type
  LookupContactTaskArg = ref object of QObjectTaskArg
    value: string
    uuid: string
    chainId: int
    reason: string

const lookupContactTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[LookupContactTaskArg](argEncoded)
  var pubkey = arg.value
  var address = ""

  if (pubkey.startsWith("0x") or isCompressedPubKey(pubkey)):
    if pubkey.startsWith("0x"):
      var num64: int64
      let parsedChars = parseHex(pubkey, num64)
      if(parsedChars != PK_LENGTH_0X_INCLUDED):
        pubkey = ""
        address = ""
  else:
    # TODO refactor those calls to use the new backend and also do it in a signle call
    pubkey = ens_utils.publicKeyOf(arg.chainId, arg.value)
    address = ens_utils.addressOf(arg.chainid, arg.value)
  
  let output = %*{
    "id": pubkey,
    "address": address,
    "uuid": arg.uuid,
    "reason": arg.reason
  }
  arg.finish(output)