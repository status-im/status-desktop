import # vendor libs
  NimQml

import gif_list
import ../../../status/gif


QtObject:
  type GifView* = ref object of QObject
    items*: GifList
    client: GifClient
    
  proc setup(self: GifView) =
    self.QObject.setup

  proc delete*(self: GifView) =
    self.QObject.delete

  proc newGifView*(): GifView =
    new(result, delete)
    result = GifView()
    result.client = newGifClient()
    result.items = newGifList()
    result.setup()

  proc getItemsList*(self: GifView): QVariant {.slot.} =
    result = newQVariant(self.items)

  proc itemsLoaded*(self: GifView) {.signal.}

  QtProperty[QVariant] items:
    read = getItemsList
    notify = itemsLoaded

  proc load*(self: GifView) {.slot.} =
    let data = self.client.getTrendings()
    self.items.setNewData(data)
    self.itemsLoaded()

  proc search*(self: GifView, query: string) {.slot.} = 
    let data = self.client.search(query)
    self.items.setNewData(data)
    self.itemsLoaded()
  