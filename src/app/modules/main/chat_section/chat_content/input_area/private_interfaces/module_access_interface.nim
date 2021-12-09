import NimQml

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method sendImages*(self: AccessInterface, imagePathsJson: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method requestAddressForTransaction*(self: AccessInterface, chatId: string, fromAddress: string, amount: string, tokenAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestTransaction*(self: AccessInterface, chatId: string, fromAddress: string, amount: string, tokenAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method declineRequestTransaction*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method declineRequestAddressForTransaction*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptRequestAddressForTransaction*(self: AccessInterface, messageId: string, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptRequestTransaction*(self: AccessInterface, transactionHash: string, messageId: string, signature: string) {.base.} =
  raise newException(ValueError, "No implementation available")