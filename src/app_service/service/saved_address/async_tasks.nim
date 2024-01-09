include app_service/common/json_utils
include app/core/tasks/common

import backend/backend

type
  SavedAddressTaskArg = ref object of QObjectTaskArg
    name: string
    address: string
    colorId: string
    chainShortNames: string
    ens: string
    isTestAddress: bool

const upsertSavedAddressTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[SavedAddressTaskArg](argEncoded)
  var response = %* {
    "response": "",
    "name": %* arg.name,
    "address": %* arg.address,
    "ens": %* arg.ens,
    "error": "",
  }
  try:
    let rpcResponse = backend.upsertSavedAddress(SavedAddressDto(
      name: arg.name,
      address: arg.address,
      colorId: arg.colorId,
      chainShortNames: arg.chainShortNames,
      ens: arg.ens,
      isTest: arg.isTestAddress)
    )
    if not rpcResponse.error.isNil:
      raise newException(CatchableError, rpcResponse.error.message)
    response["response"] = %* "ok"
  except Exception as e:
    response["error"] = %* e.msg
  arg.finish(response)

const deleteSavedAddressTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[SavedAddressTaskArg](argEncoded)
  var response = %* {
    "response": "",
    "address": %* arg.address,
    "ens": %* arg.ens,
    "error": "",
  }
  try:
    let rpcResponse = backend.deleteSavedAddress(arg.address, arg.ens, arg.isTestAddress)
    if not rpcResponse.error.isNil:
      raise newException(CatchableError, rpcResponse.error.message)
    response["response"] = %* "ok"
  except Exception as e:
    response["error"] = %* e.msg
  arg.finish(response)
