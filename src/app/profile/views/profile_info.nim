import NimQml
import chronicles
import ../../../status/profile/profile
import ../../../status/types
import std/wrapnils

QtObject:
  type ProfileInfoView* = ref object of QObject
    username*: string
    identicon*: string
    address*: string
    identityImage*: IdentityImage
    pubKey*: string
    appearance*: int
    ensVerified*: bool
    messagesFromContactsOnly*: bool
    sendUserStatus*: bool

  proc setup(self: ProfileInfoView) =
    self.QObject.setup

  proc delete*(self: ProfileInfoView) =
    self.QObject.delete

  proc newProfileInfoView*(): ProfileInfoView =
    new(result, delete)
    result = ProfileInfoView()
    result.pubKey = ""
    result.username = ""
    result.identicon = ""
    result.appearance = 0
    result.identityImage = IdentityImage()
    result.ensVerified = false
    result.messagesFromContactsOnly = false
    result.sendUserStatus = false
    result.setup

  proc identityImageChanged*(self: ProfileInfoView) {.signal.}
  proc sendUserStatusChanged*(self: ProfileInfoView) {.signal.}
  proc appearanceChanged*(self: ProfileInfoView) {.signal.}
  proc messagesFromContactsOnlyChanged*(self: ProfileInfoView) {.signal.}

  proc setProfile*(self: ProfileInfoView, profile: Profile) =
    self.username = profile.username
    self.identicon = profile.identicon
    self.appearance = profile.appearance
    self.pubKey = profile.id
    self.address = profile.address
    self.ensVerified = profile.ensVerified
    self.identityImage = profile.identityImage
    self.messagesFromContactsOnly = profile.messagesFromContactsOnly
    self.sendUserStatus = profile.sendUserStatus

  proc username*(self: ProfileInfoView): string {.slot.} = result = self.username
  
  QtProperty[string] username:
    read = username

  proc identicon*(self: ProfileInfoView): string {.slot.} = result = self.identicon
  
  QtProperty[string] identicon:
    read = identicon

  proc pubKey*(self: ProfileInfoView): string {.slot.} = self.pubKey
  
  QtProperty[string] pubKey:
    read = pubKey

  proc address*(self: ProfileInfoView): string {.slot.} = self.address
  
  QtProperty[string] address:
    read = address

  proc ensVerified*(self: ProfileInfoView): bool {.slot.} = self.ensVerified
  
  QtProperty[bool] ensVerified:
    read = ensVerified

  proc appearance*(self: ProfileInfoView): int {.slot.} = result = self.appearance
  proc setAppearance*(self: ProfileInfoView, appearance: int) {.slot.} =
    if self.appearance == appearance:
      return
    self.appearance = appearance
    self.appearanceChanged()
  
  QtProperty[int] appearance:
    read = appearance
    write = setAppearance
    notify = appearanceChanged

  proc messagesFromContactsOnly*(self: ProfileInfoView): bool {.slot.} = result = self.messagesFromContactsOnly
  proc setMessagesFromContactsOnly*(self: ProfileInfoView, messagesFromContactsOnly: bool) {.slot.} =
    if self.messagesFromContactsOnly == messagesFromContactsOnly:
      return
    self.messagesFromContactsOnly = messagesFromContactsOnly
    self.messagesFromContactsOnlyChanged()

  QtProperty[bool] messagesFromContactsOnly:
    read = messagesFromContactsOnly
    write = setMessagesFromContactsOnly
    notify = messagesFromContactsOnlyChanged

  proc setIdentityImage*(self: ProfileInfoView, identityImage: IdentityImage) =
    self.identityImage = identityImage
    self.identityImageChanged()

  proc removeIdentityImage*(self: ProfileInfoView) =
    self.identityImage = IdentityImage()
    self.identityImageChanged()

  proc thumbnailImage*(self: ProfileInfoView): string {.slot.} =
    if (?.self.identityImage.thumbnail != ""):
      result = self.identityImage.thumbnail
    else:
      result = self.identicon
      
  QtProperty[string] thumbnailImage:
    read = thumbnailImage
    notify = identityImageChanged

  proc largeImage*(self: ProfileInfoView): string {.slot.} =
    if (?.self.identityImage.large != ""):
      result = self.identityImage.large
    else:
      result = self.identicon

  QtProperty[string] largeImage:
    read = largeImage
    notify = identityImageChanged

  proc hasIdentityImage*(self: ProfileInfoView): bool {.slot.} =
    result = (?.self.identityImage.thumbnail != "")
  
  QtProperty[bool] hasIdentityImage:
    read = hasIdentityImage
    notify = identityImageChanged

  proc sendUserStatus*(self: ProfileInfoView): bool {.slot.} = result = self.sendUserStatus
  proc setSendUserStatus*(self: ProfileInfoView, sendUserStatus: bool) {.slot.} =
    if self.sendUserStatus == sendUserStatus:
      return
    self.sendUserStatus = sendUserStatus
    self.sendUserStatusChanged()

  QtProperty[bool] sendUserStatus:
    read = sendUserStatus
    write = setSendUserStatus
    notify = sendUserStatusChanged