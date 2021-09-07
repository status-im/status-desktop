{.used.}

type 
  RpcError* = ref object
    code*: int
    message*: string

type
  RpcResponse* = ref object
    jsonrpc*: string
    result*: string
    id*: int
    error*: RpcError

  # TODO: replace all RpcResponse and RpcResponseTyped occurances with a generic
  # form of RpcReponse. IOW, rename RpceResponseTyped*[T] to RpcResponse*[T] and
  # remove RpcResponse.
type
  RpcResponseTyped*[T] = object
    jsonrpc*: string
    result*: T
    id*: int
    error*: RpcError

type
  StatusGoException* = object of CatchableError

type
  RpcException* = object of CatchableError