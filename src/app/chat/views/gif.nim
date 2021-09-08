import # vendor libs
  NimQml

import gif_list
import status/gif


QtObject:
  type GifView* = ref object of QObject
    columnA*: GifList
    columnB*: GifList
    columnC*: GifList
    client: GifClient

  proc setup(self: GifView) =
    self.QObject.setup

  proc delete*(self: GifView) =
    self.QObject.delete

  proc newGifView*(): GifView =
    new(result, delete)
    result = GifView()
    result.client = newGifClient()
    result.columnA = newGifList(result.client)
    result.columnB = newGifList(result.client)
    result.columnC = newGifList(result.client)
    result.setup()

  proc dataLoaded*(self: GifView) {.signal.}

  proc getColumnAList*(self: GifView): QVariant {.slot.} =
    result = newQVariant(self.columnA)

  QtProperty[QVariant] columnA:
    read = getColumnAList
    notify = dataLoaded

  proc getColumnBList*(self: GifView): QVariant {.slot.} =
    result = newQVariant(self.columnB)

  QtProperty[QVariant] columnB:
    read = getColumnBList
    notify = dataLoaded

  proc getColumnCList*(self: GifView): QVariant {.slot.} =
    result = newQVariant(self.columnC)

  QtProperty[QVariant] columnC:
    read = getColumnCList
    notify = dataLoaded

  proc updateColumns(self: GifView, data: seq[GifItem]) =
    var columnAData: seq[GifItem] = @[]
    var columnAHeight = 0
    var columnBData: seq[GifItem] = @[]
    var columnBHeight = 0
    var columnCData: seq[GifItem] = @[]
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


    self.columnA.setNewData(columnAData)
    self.columnB.setNewData(columnBData)
    self.columnC.setNewData(columnCData)
    self.dataLoaded()

  proc findGifItem(self: GifView, id: string): GifItem =
    for item in self.columnA.gifs:
      if item.id == id:
        return item

    for item in self.columnB.gifs:
      if item.id == id:
        return item

    for item in self.columnC.gifs:
      if item.id == id:
        return item

    raise newException(ValueError, "Invalid id " & $id)

  proc getTrendings*(self: GifView) {.slot.} =
    let data = self.client.getTrendings()
    self.updateColumns(data)

  proc getFavorites*(self: GifView) {.slot.} =
    let data = self.client.getFavorites()
    self.updateColumns(data)

  proc getRecents*(self: GifView) {.slot.} =
    let data = self.client.getRecents()
    self.updateColumns(data)

  proc search*(self: GifView, query: string) {.slot.} =
    let data = self.client.search(query)
    self.updateColumns(data)

  proc toggleFavorite*(self: GifView, id: string, reload: bool = false) {.slot.} =
    let gifItem = self.findGifItem(id)
    self.client.toggleFavorite(gifItem)

    if reload:
      self.getFavorites()

  proc addToRecents*(self: GifView, id: string) {.slot.} =
    let gifItem = self.findGifItem(id)
    self.client.addToRecents(gifItem)
    