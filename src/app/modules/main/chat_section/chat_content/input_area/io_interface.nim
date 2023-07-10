import NimQml, tables

import ../../../../../../app_service/service/gif/dto
import ../../../../../../app_service/service/message/dto/link_preview

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

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

method sendImages*(self: AccessInterface, imagePathsJson: string, msg: string, replyTo: string): string {.base.} =
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

method searchGifs*(self: AccessInterface, query: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getTrendingsGifs*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getRecentsGifs*(self: AccessInterface): seq[GifDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method loadRecentGifs*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadRecentGifsDone*(self: AccessInterface, gifs: seq[GifDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadTrendingGifsStarted*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadTrendingGifsError*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadTrendingGifsDone*(self: AccessInterface, gifs: seq[GifDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method searchGifsStarted*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method searchGifsError*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method serachGifsDone*(self: AccessInterface, gifs: seq[GifDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method getFavoritesGifs*(self: AccessInterface): seq[GifDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method loadFavoriteGifs*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method loadFavoriteGifsDone*(self: AccessInterface, gifs: seq[GifDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleFavoriteGif*(self: AccessInterface, item: GifDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method addToRecentsGif*(self: AccessInterface, item: GifDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method isFavorite*(self: AccessInterface, item: GifDto): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setText*(self: AccessInterface, text: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setUrls*(self: AccessInterface, urls: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method updateLinkPreviewsFromCache*(self: AccessInterface, urls: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method clearLinkPreviewCache*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method linkPreviewsFromCache*(self: AccessInterface, urls: seq[string]): Table[string, LinkPreview] {.base.} =
  raise newException(ValueError, "No implementation available")
