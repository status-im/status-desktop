import NimQml
import models/login_account_item

QtObject:
  type SelectedLoginAccount* = ref object of QObject
    item: Item

  proc setup(self: SelectedLoginAccount) =
    self.QObject.setup

  proc delete*(self: SelectedLoginAccount) =
    self.QObject.delete

  proc newSelectedLoginAccount*(): SelectedLoginAccount =
    new(result, delete)
    result.setup

  proc setData*(self: SelectedLoginAccount, item: Item) =
    self.item = item

  proc getName(self: SelectedLoginAccount): string {.slot.} =
    return self.item.getName()

  QtProperty[string] username:
    read = getName

  proc getKeyUid(self: SelectedLoginAccount): string {.slot.} =
    return self.item.getKeyUid()

  QtProperty[string] keyUid:
    read = getKeyUid

  proc getColorHash(self: SelectedLoginAccount): QVariant {.slot.} =
    return self.item.getColorHashVariant()

  QtProperty[QVariant] colorHash:
    read = getColorHash

  proc getColorId(self: SelectedLoginAccount): int {.slot.} =
    return self.item.getColorId()

  QtProperty[int] colorId:
    read = getColorId

  proc getThumbnailImage(self: SelectedLoginAccount): string {.slot.} =
    return self.item.getThumbnailImage()

  QtProperty[string] thumbnailImage:
    read = getThumbnailImage

  proc getLargeImage(self: SelectedLoginAccount): string {.slot.} =
    return self.item.getLargeImage()

  QtProperty[string] largeImage:
    read = getLargeImage
