import nimqml

import backend/backend as backend

QtObject:
  type TransactionIdentity* = ref object of QObject
    identity: backend.TransactionIdentity

  proc setup(self: TransactionIdentity)
  proc delete*(self: TransactionIdentity)
  proc newTransactionIdentity*(identity: backend.TransactionIdentity): TransactionIdentity =
    new(result, delete)
    result.setup
    result.identity = identity

  proc getChainId*(self: TransactionIdentity): int {.slot.} =
    return self.identity.chainId
  QtProperty[int] chainId:
    read = getChainId

  proc getHash*(self: TransactionIdentity): string {.slot.} =
    return self.identity.hash
  QtProperty[string] hash:
    read = getHash

  proc getAddress*(self: TransactionIdentity): string {.slot.} =
    return self.identity.address
  QtProperty[string] address:
    read = getAddress

  proc setup(self: TransactionIdentity) =
    self.QObject.setup

  proc delete*(self: TransactionIdentity) =
    self.QObject.delete