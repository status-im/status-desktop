import os, parseutils
import ../ens/utils as ens_utils

include ../../common/json_utils
include ../../../app/core/tasks/common

#################################################
# Async lookup ENS contact
#################################################

const PK_LENGTH_0X_INCLUDED = 132

type
  LookupContactTaskArg = ref object of QObjectTaskArg
    value: string
    uuid: string

const lookupContactTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[LookupContactTaskArg](argEncoded)
  var pubkey = arg.value
  var address = ""

  if (pubkey.startsWith("0x")):
    var num64: int64
    let parsedChars = parseHex(pubkey, num64)
    if(parsedChars != PK_LENGTH_0X_INCLUDED):
      pubkey = ""
      address = ""
  else:
    # TODO refactor those calls to use the new backend and also do it in a signle call
    pubkey = ens_utils.pubkey(arg.value)
    address = ens_utils.address(arg.value)
  
  let output = %*{
    "id": pubkey,
    "address": address,
    "uuid": arg.uuid
  }
  arg.finish(output)

#################################################
# Async timer
#################################################

type
  TimerTaskArg = ref object of QObjectTaskArg
    timeoutInMilliseconds: int

const timerTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[TimerTaskArg](argEncoded)
  sleep(arg.timeoutInMilliseconds)
  arg.finish("done")
