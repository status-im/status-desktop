import NimQml
import chronicles
import std/wrapnils

import status/types/profile

import ./item as item

QtObject:
  type Model* = ref object of QObject
    username*: string
    identicon*: string
    address*: string
    identityImage*: item.IdentityImage
    pubKey*: string
    appearance*: int
    ensVerified*: bool
    messagesFromContactsOnly*: bool
    sendUserStatus*: bool
    currentUserStatus*: int

  proc setup(self: Model) =
    self.QObject.setup

  proc delete*(self: Model) =
    self.QObject.delete

  proc newModel*(): Model =
    new(result, delete)
    result = Model()
    result.pubKey = ""
    result.username = ""
    result.identicon = ""
    result.appearance = 0
    result.identityImage = item.IdentityImage(thumbnail: "", large: "")
    result.ensVerified = false
    result.messagesFromContactsOnly = false
    result.sendUserStatus = false
    result.currentUserStatus = 0
    result.setup

  proc identityImageChanged*(self: Model) {.signal.}
  proc sendUserStatusChanged*(self: Model) {.signal.}
  proc currentUserStatusChanged*(self: Model) {.signal.}
  proc appearanceChanged*(self: Model) {.signal.}
  proc messagesFromContactsOnlyChanged*(self: Model) {.signal.}

  proc setProfile*(self: Model, profile: item.Item) =
    self.username = profile.username
    self.identicon = profile.identicon
    self.messagesFromContactsOnly = profile.messagesFromContactsOnly
    self.appearance = profile.appearance
    self.pubKey = profile.id
    self.address = profile.address
    self.ensVerified = profile.ensVerified
    self.identityImage = item.IdentityImage(thumbnail: profile.identityImage.thumbnail, large: profile.identityImage.large)
    self.sendUserStatus = profile.sendUserStatus
    self.currentUserStatus = profile.currentUserStatus

  proc username*(self: Model): string {.slot.} = result = self.username
  
  QtProperty[string] username:
    read = username

  proc identicon*(self: Model): string {.slot.} = result = self.identicon
  
  QtProperty[string] identicon:
    read = identicon

  proc pubKey*(self: Model): string {.slot.} = self.pubKey
  
  QtProperty[string] pubKey:
    read = pubKey

  proc address*(self: Model): string {.slot.} = self.address
  
  QtProperty[string] address:
    read = address

  proc ensVerified*(self: Model): bool {.slot.} = self.ensVerified
  
  QtProperty[bool] ensVerified:
    read = ensVerified

  proc appearance*(self: Model): int {.slot.} = result = self.appearance
  proc setAppearance*(self: Model, appearance: int) {.slot.} =
    if self.appearance == appearance:
      return
    self.appearance = appearance
    self.appearanceChanged()
  
  QtProperty[int] appearance:
    read = appearance
    write = setAppearance
    notify = appearanceChanged

  proc messagesFromContactsOnly*(self: Model): bool {.slot.} = result = self.messagesFromContactsOnly
  proc setMessagesFromContactsOnly*(self: Model, messagesFromContactsOnly: bool) {.slot.} =
    if self.messagesFromContactsOnly == messagesFromContactsOnly:
      return
    self.messagesFromContactsOnly = messagesFromContactsOnly
    self.messagesFromContactsOnlyChanged()

  QtProperty[bool] messagesFromContactsOnly:
    read = messagesFromContactsOnly
    write = setMessagesFromContactsOnly
    notify = messagesFromContactsOnlyChanged

  proc setIdentityImage*(self: Model, identityImage: item.IdentityImage) =
    self.identityImage = identityImage
    self.identityImageChanged()

  proc removeIdentityImage*(self: Model) =
    self.identityImage = item.IdentityImage(thumbnail: "", large: "")
    self.identityImageChanged()

  proc thumbnailImage*(self: Model): string {.slot.} =
    if (?.self.identityImage.thumbnail != ""):
      result = self.identityImage.thumbnail
    else:
      result = self.identicon
      
  QtProperty[string] thumbnailImage:
    read = thumbnailImage
    notify = identityImageChanged

  proc largeImage*(self: Model): string {.slot.} =
    if (?.self.identityImage.large != ""):
      result = self.identityImage.large
    else:
      result = self.identicon

  QtProperty[string] largeImage:
    read = largeImage
    notify = identityImageChanged

  proc hasIdentityImage*(self: Model): bool {.slot.} =
    result = (?.self.identityImage.thumbnail != "")

  QtProperty[bool] hasIdentityImage:
    read = hasIdentityImage
    notify = identityImageChanged

  proc sendUserStatus*(self: Model): bool {.slot.} = result = self.sendUserStatus
  proc setSendUserStatus*(self: Model, sendUserStatus: bool) {.slot.} =
    if self.sendUserStatus == sendUserStatus:
      return
    self.sendUserStatus = sendUserStatus
    self.sendUserStatusChanged()

  QtProperty[bool] sendUserStatus:
    read = sendUserStatus
    write = setSendUserStatus
    notify = sendUserStatusChanged

  proc currentUserStatus*(self: Model): int {.slot.} = result = self.currentUserStatus
  proc setCurrentUserStatus*(self: Model, currentUserStatus: int) {.slot.} =
    if self.currentUserStatus == currentUserStatus:
      return
    self.currentUserStatus = currentUserStatus
    self.currentUserStatusChanged()

  QtProperty[int] currentUserStatus:
    read = currentUserStatus
    write = setCurrentUserStatus
    notify = currentUserStatusChanged
