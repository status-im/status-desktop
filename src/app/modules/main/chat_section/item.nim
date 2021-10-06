import NimQml

QtObject:
  type
    Item* = ref object of QObject
      
  proc setup(self: Item) = 
    self.QObject.setup

  proc delete*(self: Item) =
    self.QObject.delete

  proc newItem*(): Item =
    new(result, delete)
    result.setup()

  proc id*(self: Item): string {.slot.} = 
    self.id

  QtProperty[string] id:
    read = id