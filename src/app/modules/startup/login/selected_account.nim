import NimQml
import item

QtObject:
  type SelectedAccount* = ref object of QObject
    item: Item

  proc setup(self: SelectedAccount) =
    self.QObject.setup

  proc delete*(self: SelectedAccount) =
    self.QObject.delete

  proc newSelectedAccount*(): SelectedAccount =
    new(result, delete)
    result.setup

  proc setSelectedAccountData*(self: SelectedAccount, item: Item) =
    self.item = item

  proc getName(self: SelectedAccount): string {.slot.} = 
    return self.item.getName()

  QtProperty[string] username:
    read = getName

  proc getIdenticon(self: SelectedAccount): string {.slot.} =
    return self.item.getIdenticon()

  QtProperty[string] identicon:
    read = getIdenticon

  proc getKeyUid(self: SelectedAccount): string {.slot.} =
    return self.item.getKeyUid()

  QtProperty[string] keyUid:
    read = getKeyUid

  proc getThumbnailImage(self: SelectedAccount): string {.slot.} = 
    return self.item.getThumbnailImage()

  QtProperty[string] thumbnailImage:
    read = getThumbnailImage

  proc getLargeImage(self: SelectedAccount): string {.slot.} = 
    return self.item.getLargeImage()

  QtProperty[string] largeImage:
    read = getLargeImage