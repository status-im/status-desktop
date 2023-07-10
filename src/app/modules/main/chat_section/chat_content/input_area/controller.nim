import io_interface, chronicles, tables

import ../../../../../../app_service/service/message/service as message_service
import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/gif/service as gif_service
import ../../../../../../app_service/service/gif/dto
import ../../../../../../app_service/service/message/dto/link_preview
import ../../../../../core/eventemitter
import ../../../../../core/unique_event_emitter
import ./link_preview_cache

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    sectionId: string
    events: UniqueUUIDEventEmitter
    chatId: string
    belongsToCommunity: bool
    communityService: community_service.Service
    chatService: chat_service.Service
    gifService: gif_service.Service
    messageService: message_service.Service
    linkPreviewCache: LinkPreviewCache

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    sectionId: string,
    chatId: string,
    belongsToCommunity: bool,
    chatService: chat_service.Service,
    communityService: community_service.Service,
    gifService: gif_service.Service,
    messageService: message_service.Service
    ): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = initUniqueUUIDEventEmitter(events)
  result.sectionId = chatId
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.chatService = chatService
  result.communityService = communityService
  result.gifService = gifService
  result.messageService = messageService
  result.linkPreviewCache = newLinkPreiewCache()

proc onUrlsUnfurled(self: Controller, args: LinkPreviewV2DataArgs)

proc delete*(self: Controller) =
  self.events.disconnect()

proc init*(self: Controller) =
  self.events.on(SIGNAL_LOAD_RECENT_GIFS_DONE) do(e:Args):
    let args = GifsArgs(e)
    self.delegate.loadRecentGifsDone(args.gifs)

  self.events.on(SIGNAL_LOAD_FAVORITE_GIFS_DONE) do(e:Args):
    let args = GifsArgs(e)
    self.delegate.loadFavoriteGifsDone(args.gifs)

  self.events.on(SIGNAL_LOAD_TRENDING_GIFS_STARTED) do(e:Args):
    self.delegate.loadTrendingGifsStarted()

  self.events.on(SIGNAL_LOAD_TRENDING_GIFS_DONE) do(e:Args):
    let args = GifsArgs(e)
    self.delegate.loadTrendingGifsDone(args.gifs)

  self.events.on(SIGNAL_LOAD_TRENDING_GIFS_ERROR) do(e:Args):
    self.delegate.loadTrendingGifsError()

  self.events.on(SIGNAL_SEARCH_GIFS_STARTED) do(e:Args):
    self.delegate.searchGifsStarted()

  self.events.on(SIGNAL_SEARCH_GIFS_DONE) do(e:Args):
    let args = GifsArgs(e)
    self.delegate.serachGifsDone(args.gifs)

  self.events.on(SIGNAL_SEARCH_GIFS_ERROR) do(e:Args):
    self.delegate.searchGifsError()

  self.events.on(SIGNAL_URLS_UNFURLED) do(e:Args):
    let args = LinkPreviewV2DataArgs(e)
    self.onUrlsUnfurled(args)

proc getChatId*(self: Controller): string =
  return self.chatId

proc belongsToCommunity*(self: Controller): bool =
  return self.belongsToCommunity

proc sendImages*(self: Controller, imagePathsAndDataJson: string, msg: string, replyTo: string): string =
  self.chatService.sendImages(self.chatId, imagePathsAndDataJson, msg, replyTo)

proc sendChatMessage*(
    self: Controller,
    msg: string,
    replyTo: string,
    contentType: int,
    preferredUsername: string = "") =

  let urls = self.messageService.getTextUrls(msg)
  let linkPreviews = self.linkPreviewCache.linkPreviewsSeq(urls)
  
  self.chatService.sendChatMessage(self.chatId, 
    msg, 
    replyTo, 
    contentType, 
    preferredUsername,
    linkPreviews
  )

proc requestAddressForTransaction*(self: Controller, fromAddress: string, amount: string, tokenAddress: string) =
  self.chatService.requestAddressForTransaction(self.chatId, fromAddress, amount, tokenAddress)

proc requestTransaction*(self: Controller, fromAddress: string, amount: string, tokenAddress: string) =
  self.chatService.requestTransaction(self.chatId, fromAddress, amount, tokenAddress)

proc declineRequestTransaction*(self: Controller, messageId: string) =
  self.chatService.declineRequestTransaction(messageId)

proc declineRequestAddressForTransaction*(self: Controller, messageId: string) =
  self.chatService.declineRequestAddressForTransaction(messageId)

proc acceptRequestAddressForTransaction*(self: Controller, messageId: string, address: string) =
  self.chatService.acceptRequestAddressForTransaction(messageId, address)

proc acceptRequestTransaction*(self: Controller, transactionHash: string, messageId: string, signature: string) =
  self.chatService.acceptRequestTransaction(transactionHash, messageId, signature)

proc searchGifs*(self: Controller, query: string) =
  self.gifService.search(query)

proc getTrendingsGifs*(self: Controller) =
  self.gifService.getTrending()

proc getRecentsGifs*(self: Controller): seq[GifDto] =
  return self.gifService.getRecents()

proc loadRecentGifs*(self: Controller) =
  self.gifService.asyncLoadRecentGifs()

proc loadFavoriteGifs*(self: Controller) =
  self.gifService.asyncLoadFavoriteGifs()

proc getFavoritesGifs*(self: Controller): seq[GifDto] =
  return self.gifService.getFavorites()

proc toggleFavoriteGif*(self: Controller, item: GifDto) =
  self.gifService.toggleFavorite(item)

proc addToRecentsGif*(self: Controller, item: GifDto) =
  self.gifService.addToRecents(item)

proc isFavorite*(self: Controller, item: GifDto): bool =
  return self.gifService.isFavorite(item)

proc setText*(self: Controller, text: string) =
  let urls = self.messageService.getTextUrls(text)
  self.delegate.setUrls(urls)
  if len(urls) > 0:
    let newUrls = self.linkPreviewCache.unknownUrls(urls)
    self.messageService.asyncUnfurlUrls(newUrls)
    
proc linkPreviewsFromCache*(self: Controller, urls: seq[string]): Table[string, LinkPreview] =
  return self.linkPreviewCache.linkPreviews(urls)

proc clearLinkPreviewCache*(self: Controller) =
  self.linkPreviewCache.clear()

proc onUrlsUnfurled(self: Controller, args: LinkPreviewV2DataArgs) =
  let urls = self.linkPreviewCache.add(args.linkPreviews)
  self.delegate.updateLinkPreviewsFromCache(urls)
