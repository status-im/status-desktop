import status/ens as status_ens

include ../../common/json_utils
include ../../../app/core/tasks/common

#################################################
# Async lookup ENS contact
#################################################

type
  LookupContactTaskArg = ref object of QObjectTaskArg
    value: string

const lookupContactTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[LookupContactTaskArg](argEncoded)
  var id = arg.value
  if not id.startsWith("0x"):
    id = status_ens.pubkey(id)
  arg.finish(id)
