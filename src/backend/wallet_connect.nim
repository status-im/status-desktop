import options
import json
import core, response_type

from gen import rpc
import backend

# Declared in services/wallet/walletconnect/walletconnect.go
#const eventWCTODO*: string = "wallet-wc-todo"

# Declared in services/wallet/walletconnect/walletconnect.go
const ErrorChainsNotSupported*: string = "chains not supported"

rpc(wCPairSessionProposal, "wallet"):
  sessionProposalJson: string

# TODO #12434: async answer
proc pair*(sessionProposalJson: string, callback: proc(response: JsonNode): void): bool =
  try:
    let response = wCPairSessionProposal(sessionProposalJson)
    if response.error == nil and response.result != nil:
      callback(response.result)
    return response.error == nil
  except Exception as e:
    echo "@dd wCPairSessionProposal response: ", e.msg
    return false
