import NimQml

import ../../../../../../../app_service/service/gif/dto


method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method sendChatMessage*(self: AccessInterface, msg: string, replyTo: string, contentType: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method sendImages*(self: AccessInterface, imagePathsJson: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method requestAddressForTransaction*(self: AccessInterface, fromAddress: string, amount: string, tokenAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method requestTransaction*(self: AccessInterface, fromAddress: string, amount: string, tokenAddress: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method declineRequestTransaction*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method declineRequestAddressForTransaction*(self: AccessInterface, messageId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptRequestAddressForTransaction*(self: AccessInterface, messageId: string, address: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method acceptRequestTransaction*(self: AccessInterface, transactionHash: string, messageId: string, signature: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method searchGifs*(self: AccessInterface, query: string): seq[GifDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getTrendingsGifs*(self: AccessInterface): seq[GifDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getRecentsGifs*(self: AccessInterface): seq[GifDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getFavoritesGifs*(self: AccessInterface): seq[GifDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleFavoriteGif*(self: AccessInterface, item: GifDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method addToRecentsGif*(self: AccessInterface, item: GifDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method isFavorite*(self: AccessInterface, item: GifDto): bool {.base.} =
  raise newException(ValueError, "No implementation available")