import options, logging
import json, json_serialization
import core, response_type

from gen import rpc

const
  EventConnectorSendRequestAccounts* = "connector.sendRequestAccounts"
  EventConnectorSendTransaction* = "connector.sendTransaction"

  # TODO: improve on the way to handle the same errors in status-go
  RequestAccountNoError* = ""
  RequestAccountRejectError* = "connector.RequestAccountRejectError"
  RequestAccountGenericError* = "connector.RequestAccountGenericError"

# type RequestAccountsFinishedArgs struct {
# 	Accounts []types.Address
# 	Error    *error
# }
# implement above in nim
type RequestAccountsFinishedArgs* = ref object of RootObj
  accounts* {.serializedFieldName("accounts").}: seq[string]
  error* {.serializedFieldName("error").}: string


# TODO This file is the bridge between nim and RPC calls. We should define all the connector-related RPCs here.

# TODO Adjust the namespace as you see fit.
rpc(requestAccountsFinished, "connector"):
  args: RequestAccountsFinishedArgs

proc isSuccessResponse(rpcResponse: RpcResponse[JsonNode]): bool =
  return rpcResponse.error.isNil

# accountsJson is a stringified JS array
proc requestAccountsFinishedRpc*(accountsJson: string, error: string): bool =
  try:
    let args = RequestAccountsFinishedArgs()
    if error.len > 0:
      args.error = error
    else:
      let accountsJN = parseJson(accountsJson)
      # TODO fill in args.accounts with the parsed accountsJN

    let rpcRes = requestAccountsFinished(args)
    return isSuccessResponse(rpcRes):
  except Exception as e:
    error "TODO failed: ", "msg", e.msg
    return false

# TODO rendTransactionFinishedRpc
# TODO recallDAppPermissionRpc