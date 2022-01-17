method ensUsernameAvailabilityChecked*(self: AccessInterface, availabilityStatus: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onDetailsForEnsUsername*(self: AccessInterface, ensUsername: string, address: string, pubkey: string, 
  isStatus: bool, expirationTime: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method gasPriceFetched*(self: AccessInterface, gasPrice: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method ensTransactionConfirmed*(self: AccessInterface, trxType: string, ensUsername: string, transactionHash: string) 
  {.base.} =
  raise newException(ValueError, "No implementation available")

method ensTransactionReverted*(self: AccessInterface, trxType: string, ensUsername: string, transactionHash: string, 
  revertReason: string) {.base.} =
  raise newException(ValueError, "No implementation available")