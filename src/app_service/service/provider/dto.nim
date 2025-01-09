import json

const HTTPS_SCHEME* = "https"
const IPFS_GATEWAY* = ".infura.status.im"
const SWARM_GATEWAY* = "swarm-gateways.net"

type
  RequestTypes* {.pure.} = enum
    Web3SendAsyncReadOnly = "web3-send-async-read-only"
    HistoryStateChanged = "history-state-changed"
    APIRequest = "api-request"
    Unknown = "unknown"

  ResponseTypes* {.pure.} = enum
    Web3SendAsyncCallback = "web3-send-async-callback"
    APIResponse = "api-response"
    Web3ResponseError = "web3-response-error"

type
  Payload* = ref object
    id*: JsonNode
    rpcproc*: string

  Web3SendAsyncReadOnly* = ref object
    messageId*: JsonNode
    payload*: Payload
    request*: string
    hostname*: string

  APIRequest* = ref object
    isAllowed*: bool
    messageId*: JsonNode
    permission*: Permission
    hostname*: string
