import NimQml
import ./io_interface
import ./gif_column_model
import ./preserved_properties
import ./link_preview_model as link_preview_model
import ../../../../../../app_service/service/gif/dto

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      gifColumnAModel: GifColumnModel
      gifColumnBModel: GifColumnModel
      gifColumnCModel: GifColumnModel
      gifLoading: bool
      preservedProperties: PreservedProperties
      preservedPropertiesVariant: QVariant
      linkPreviewModel: link_preview_model.Model
      linkPreviewModelVariant: QVariant

  proc delete*(self: View) =
    self.QObject.delete
    self.gifColumnAModel.delete
    self.gifColumnBModel.delete
    self.gifColumnCModel.delete
    self.preservedProperties.delete
    self.preservedPropertiesVariant.delete
    self.linkPreviewModel.delete
    self.linkPreviewModelVariant.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.gifColumnAModel = newGifColumnModel()
    result.gifColumnBModel = newGifColumnModel()
    result.gifColumnCModel = newGifColumnModel()
    result.gifLoading = false
    result.preservedProperties = newPreservedProperties()
    result.preservedPropertiesVariant = newQVariant(result.preservedProperties)
    result.linkPreviewModel = newLinkPreviewModel()
    result.linkPreviewModelVariant = newQVariant(result.linkPreviewModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc sendMessage*(
      self: View,
      msg: string,
      replyTo: string,
      contentType: int) {.slot.} =
    self.delegate.sendChatMessage(msg, replyTo, contentType)

  proc sendImages*(self: View, imagePathsAndDataJson: string, msg: string, replyTo: string): string {.slot.} =
    self.delegate.sendImages(imagePathsAndDataJson, msg, replyTo)

  proc acceptAddressRequest*(self: View, messageId: string , address: string) {.slot.} =
    self.delegate.acceptRequestAddressForTransaction(messageId, address)

  proc declineAddressRequest*(self: View, messageId: string) {.slot.} =
    self.delegate.declineRequestAddressForTransaction(messageId)

  proc requestAddress*(self: View, fromAddress: string, amount: string, tokenAddress: string) {.slot.} =
    self.delegate.requestAddressForTransaction(fromAddress, amount, tokenAddress)

  proc request*(self: View, fromAddress: string, amount: string, tokenAddress: string) {.slot.} =
    self.delegate.requestTransaction(fromAddress, amount, tokenAddress)

  proc declineRequest*(self: View, messageId: string) {.slot.} =
    self.delegate.declineRequestTransaction(messageId)

  proc acceptRequestTransaction*(self: View, transactionHash: string, messageId: string, signature: string) {.slot.} =
    self.delegate.acceptRequestTransaction(transactionHash, messageId, signature)

  proc gifLoaded*(self: View) {.signal.}

  proc getGifColumnA*(self: View): QVariant {.slot.} =
    result = newQVariant(self.gifColumnAModel)

  QtProperty[QVariant] gifColumnA:
    read = getGifColumnA
    notify = gifLoaded

  proc getGifColumnB*(self: View): QVariant {.slot.} =
    result = newQVariant(self.gifColumnBModel)

  QtProperty[QVariant] gifColumnB:
    read = getGifColumnB
    notify = gifLoaded

  proc getGifColumnC*(self: View): QVariant {.slot.} =
    result = newQVariant(self.gifColumnCModel)

  QtProperty[QVariant] gifColumnC:
    read = getGifColumnC
    notify = gifLoaded

  proc updateGifColumns*(self: View, data: seq[GifDto]) =
    var columnAData: seq[GifDto] = @[]
    var columnAHeight = 0
    var columnBData: seq[GifDto] = @[]
    var columnBHeight = 0
    var columnCData: seq[GifDto] = @[]
    var columnCHeight = 0

    for item in data:
      if columnAHeight <= columnBHeight:
        columnAData.add(item)
        columnAHeight += item.height
      elif columnBHeight <= columnCHeight:
        columnBData.add(item)
        columnBHeight += item.height
      else:
        columnCData.add(item)
        columnCHeight += item.height


    self.gifColumnAModel.setNewData(columnAData)
    self.gifColumnBModel.setNewData(columnBData)
    self.gifColumnCModel.setNewData(columnCData)
    self.gifLoaded()

  proc gifLoadingChanged*(self: View) {.signal.}
  proc setGifLoading*(self: View, value: bool) =
    self.gifLoading = value
    self.gifLoadingChanged()
  proc getGifLoading*(self: View): bool {.slot.} =
    result = self.gifLoading

  QtProperty[bool] gifLoading:
    read = getGifLoading
    notify = gifLoadingChanged

  proc searchGifs*(self: View, query: string) {.slot.} =
    self.delegate.searchGifs(query)

  proc getTrendingsGifs*(self: View) {.slot.} =
    self.delegate.getTrendingsGifs()

  proc getRecentsGifs*(self: View) {.slot.} =
    let data = self.delegate.getRecentsGifs()
    if data.len > 0:
      self.updateGifColumns(data)
      return

    # recent gifs were not loaded yet, so we do it now
    self.delegate.loadRecentGifs()

  proc getFavoritesGifs*(self: View) {.slot.} =
    let data = self.delegate.getFavoritesGifs()
    if data.len > 0:
      self.updateGifColumns(data)
      return

    # favorite gifs were not loaded yet, so we do it now
    self.delegate.loadFavoriteGifs()

  proc findGifDto(self: View, id: string): GifDto =
    for item in self.gifColumnAModel.gifs:
      if item.id == id:
        return item

    for item in self.gifColumnBModel.gifs:
      if item.id == id:
        return item

    for item in self.gifColumnCModel.gifs:
      if item.id == id:
        return item

    raise newException(ValueError, "Invalid id " & $id)

  proc toggleFavoriteGif*(self: View, id: string, reload: bool = false) {.slot.} =
    let gifItem = self.findGifDto(id)
    self.delegate.toggleFavoriteGif(gifItem)

    if reload:
      self.getFavoritesGifs()

  proc addToRecentsGif*(self: View, id: string) {.slot.} =
    let gifItem = self.findGifDto(id)
    self.delegate.addToRecentsGif(gifItem)

  proc isFavorite*(self: View, id: string): bool {.slot.} =
    let gifItem = self.findGifDto(id)
    return self.delegate.isFavorite(gifItem)

  proc getPreservedProperties(self: View): QVariant {.slot.} =
    return self.preservedPropertiesVariant

  QtProperty[QVariant] preservedProperties:
    read = getPreservedProperties

  proc getLinkPreviewModel*(self: View): QVariant {.slot.} =
    return self.linkPreviewModelVariant

  QtProperty[QVariant] linkPreviewModel:
    read = getLinkPreviewModel

  # Currently used to fetch link previews, but could be used elsewhere
  proc setText*(self: View, text: string) {.slot.} =
    self.delegate.setText(text)

  proc updateLinkPreviewsFromCache*(self: View, urls: seq[string]) =
    let linkPreviews = self.delegate.linkPreviewsFromCache(urls)
    self.linkPreviewModel.updateLinkPreviews(linkPreviews)

  proc setUrls*(self: View, urls: seq[string]) =
    self.linkPreviewModel.setUrls(urls)
    self.updateLinkPreviewsFromCache(urls)

  proc clearLinkPreviewCache*(self: View) {.slot.} =
    self.delegate.clearLinkPreviewCache()
  
