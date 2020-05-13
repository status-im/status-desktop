import hashes

type SignalCallback* = proc(eventMessage: cstring): void

type SignalType* {.pure.} = enum
  Message = "messages.new"
  Wallet = "wallet"
  NodeStarted = "node.started"
  Unknown
  #TODO: add missing types
