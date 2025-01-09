include app_service/common/json_utils
include app/core/tasks/common

import backend/backend

type
  SavedAddressesTaskArg = ref object of QObjectTaskArg
    chainId*: int

  SavedAddressTaskArg = ref object of SavedAddressesTaskArg
    name: string
    address: string
    colorId: string
    ens: string
    isTestAddress: bool

  UpdateCriteria {.pure.} = enum
    AlwaysUpdate
    OnlyIfDifferent

proc isValidChainId(chainId: int): bool =
  return chainId == Mainnet or chainId == Sepolia

proc checkForEnsNameAndUpdate(
    chainId: int, savedAddress: var SavedAddressDto, updateCriteria: UpdateCriteria
): RpcResponse[JsonNode] {.raises: [RpcException].} =
  if savedAddress.isTest and chainId == Mainnet or
      not savedAddress.isTest and chainId != Mainnet:
    return
  try:
    var ensName: string
    try:
      let ensResponse = backend.getName(chainId, savedAddress.address)
      ensName = ensResponse.result.getStr()
    except:
      ensName = ""
    if updateCriteria == UpdateCriteria.OnlyIfDifferent and savedAddress.ens == ensName:
      return
    savedAddress.ens = ensName
    return backend.upsertSavedAddress(savedAddress)
  except Exception as e:
    raise newException(RpcException, e.msg)

proc fetchSavedAddressesAndResolveEnsNamesTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[SavedAddressesTaskArg](argEncoded)
  var response = %*{"response": [], "error": ""}
  try:
    if not isValidChainId(arg.chainId):
      raise newException(CatchableError, "invalid chainId: " & $arg.chainId)
    let rpcResponse = backend.getSavedAddresses()
    if not rpcResponse.error.isNil:
      raise newException(CatchableError, rpcResponse.error.message)
    for saJson in rpcResponse.result.getElems():
      if saJson.kind != JObject or not saJson.hasKey("address"):
        continue
      var savedAddress = saJson.toSavedAddressDto()
      try:
        discard checkForEnsNameAndUpdate(
          arg.chainId, savedAddress, UpdateCriteria.OnlyIfDifferent
        )
      except:
        discard
      response["response"].add(savedAddress.toJsonNode())
  except Exception as e:
    response["error"] = %*e.msg
  arg.finish(response)

proc upsertSavedAddressTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[SavedAddressTaskArg](argEncoded)
  var response =
    %*{
      "response": "",
      "name": %*arg.name,
      "address": %*arg.address,
      "isTestAddress": %*arg.isTestAddress,
      "ens": %*arg.ens,
      "error": "",
    }
  try:
    if not isValidChainId(arg.chainId):
      raise newException(CatchableError, "invalid chainId: " & $arg.chainId)
    var savedAddress = SavedAddressDto(
      name: arg.name,
      address: arg.address,
      colorId: arg.colorId,
      ens: arg.ens,
      isTest: arg.isTestAddress,
    )
    let rpcResponse =
      checkForEnsNameAndUpdate(arg.chainId, savedAddress, UpdateCriteria.AlwaysUpdate)
    if not rpcResponse.error.isNil:
      raise newException(CatchableError, rpcResponse.error.message)
    response["response"] = %*"ok"
  except Exception as e:
    response["error"] = %*e.msg
  arg.finish(response)

proc deleteSavedAddressTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[SavedAddressTaskArg](argEncoded)
  var response =
    %*{
      "response": "",
      "address": %*arg.address,
      "isTestAddress": %*arg.isTestAddress,
      "error": "",
    }
  try:
    let rpcResponse = backend.deleteSavedAddress(arg.address, arg.isTestAddress)
    if not rpcResponse.error.isNil:
      raise newException(CatchableError, rpcResponse.error.message)
    response["response"] = %*"ok"
  except Exception as e:
    response["error"] = %*e.msg
  arg.finish(response)
