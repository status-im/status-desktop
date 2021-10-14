import NimQml

QtObject:
  type AccountItem* = ref object of QObject
    name: string
    identicon: string
    keyUid: string
    thumbnailImage: string
    largeImage: string

  proc setup(self: AccountItem) =
    self.QObject.setup

  proc delete*(self: AccountItem) =
    self.QObject.delete

  proc setAccountItemData*(self: AccountItem, name, identicon, keyUid, 
    thumbnailImage, largeImage: string) =
    self.name = name
    self.identicon = identicon
    self.keyUid = keyUid
    self.thumbnailImage = thumbnailImage
    self.largeImage = largeImage

  proc newAccountItem*(): AccountItem =
    new(result, delete)
    result.setup

  proc newAccountItem*(name, identicon, keyUid, thumbnailImage,
    largeImage: string): AccountItem =
    new(result, delete)
    result.setup
    result.setAccountItemData(name, identicon, keyUid, thumbnailImage, largeImage)

  proc getName(self: AccountItem): string {.slot.} = 
    result = self.name

  QtProperty[string] name:
    read = getName

  proc getIdenticon(self: AccountItem): string {.slot.} =
    result = self.identicon

  QtProperty[string] identicon:
    read = getIdenticon

  proc getKeyUid(self: AccountItem): string {.slot.} =
    result = self.keyUid

  QtProperty[string] keyUid:
    read = getKeyUid

  proc getThumbnailImage(self: AccountItem): string {.slot.} = 
    result = self.thumbnailImage

  QtProperty[string] thumbnailImage:
    read = getThumbnailImage

  proc getLargeImage(self: AccountItem): string {.slot.} = 
    result = self.largeImage

  QtProperty[string] largeImage:
    read = getLargeImage