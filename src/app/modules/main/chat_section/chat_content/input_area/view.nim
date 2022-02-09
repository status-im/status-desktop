import NimQml
import ./model
import ./io_interface
import ./gif_column_model
import ../../../../../../app_service/service/gif/dto

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      gifColumnAModel: GifColumnModel
      gifColumnBModel: GifColumnModel
      gifColumnCModel: GifColumnModel

  proc delete*(self: View) =
    self.model.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.gifColumnAModel = newGifColumnModel()
    result.gifColumnBModel = newGifColumnModel()
    result.gifColumnCModel = newGifColumnModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc sendMessage*(
      self: View,
      msg: string,
      replyTo: string,
      contentType: int) {.slot.} =
    self.delegate.sendChatMessage(msg, replyTo, contentType)

  proc sendImages*(self: View, sendImages: string): string {.slot.} =
    self.delegate.sendImages(sendImages)

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

  proc updateGifColumns(self: View, data: seq[GifDto]) =
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

  proc searchGifs*(self: View, query: string) {.slot.} =
    let data = self.delegate.searchGifs(query)
    self.updateGifColumns(data)

  proc getTrendingsGifs*(self: View) {.slot.} =
    let data = self.delegate.getTrendingsGifs()
    self.updateGifColumns(data)

  proc getRecentsGifs*(self: View) {.slot.} =
    let data = self.delegate.getRecentsGifs()
    self.updateGifColumns(data)

  proc getFavoritesGifs*(self: View) {.slot.} =
    let data = self.delegate.getFavoritesGifs()
    self.updateGifColumns(data)

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
