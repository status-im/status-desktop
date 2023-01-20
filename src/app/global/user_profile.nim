import NimQml

import ../../constants as main_constants
import local_account_settings

QtObject:
  type UserProfile* = ref object of QObject
    localAccountSettings: LocalAccountSettings
    # fields which cannot change
    username: string
    keyUid: string
    pubKey: string
    isKeycardUser: bool
    # fields which may change during runtime
    displayName: string
    preferredName: string
    thumbnailImage: string
    largeImage: string
    currentUserStatus: int

  proc setup(self: UserProfile) =
    self.QObject.setup

  proc delete*(self: UserProfile) =
    self.QObject.delete

  proc newUserProfile*(localAccountSettings: LocalAccountSettings): UserProfile =
    new(result, delete)
    result.setup
    result.localAccountSettings = localAccountSettings

  proc setFixedData*(self: UserProfile, username: string, keyUid: string, pubKey: string, isKeycardUser: bool) =
    self.username = username
    self.keyUid = keyUid
    self.pubKey = pubKey
    self.isKeycardUser = isKeycardUser

  proc getKeyUid*(self: UserProfile): string {.slot.} =
    self.keyUid
  QtProperty[string] keyUid:
    read = getKeyUid


  proc getPubKey*(self: UserProfile): string {.slot.} =
    self.pubKey
  QtProperty[string] pubKey:
    read = getPubKey

  proc getIsKeycardUser*(self: UserProfile): bool {.slot.} =
    self.isKeycardUser
  QtProperty[bool] isKeycardUser:
    read = getIsKeycardUser

  proc getUsingBiometricLogin*(self: UserProfile): bool {.slot.} =
    if(not main_constants.IS_MACOS):
      return false
    return self.localAccountSettings.getStoreToKeychainValue() == LS_VALUE_STORE
  QtProperty[bool] usingBiometricLogin:
    read = getUsingBiometricLogin


  proc nameChanged*(self: UserProfile) {.signal.}

  proc getUsername*(self: UserProfile): string {.slot.} =
    self.username

  QtProperty[string] username:
    read = getUsername
    notify = nameChanged

  # this is not a slot
  proc setPreferredName*(self: UserProfile, name: string) =
    if(self.preferredName == name):
      return
    self.preferredName = name
    self.nameChanged()

  proc getPreferredName*(self: UserProfile): string {.slot.} =
    self.preferredName

  QtProperty[string] preferredName:
    read = getPreferredName
    notify = nameChanged

  proc setDisplayName*(self: UserProfile, displayName: string) = # Not a slot
    if(self.displayName == displayName):
      return
    self.displayName = displayName
    self.nameChanged()

  proc getDisplayName*(self: UserProfile): string {.slot.} =
    self.displayName

  QtProperty[string] displayName:
    read = getDisplayName
    notify = nameChanged

  proc getName*(self: UserProfile): string {.slot.} =
    if(self.preferredName.len > 0):
      return self.getPreferredName()
    elif(self.displayName.len > 0):
      return self.getDisplayName()
    return self.username

  QtProperty[string] name:
    read = getName
    notify = nameChanged

  proc imageChanged*(self: UserProfile) {.signal.}

  proc getThumbnailImage*(self: UserProfile): string {.slot.} =
    return self.thumbnailImage


  proc getIcon*(self: UserProfile): string {.slot.} =
    return self.thumbnailImage

  # this is not a slot
  proc setThumbnailImage*(self: UserProfile, image: string) =
    if(self.thumbnailImage == image):
      return

    self.thumbnailImage = image
    self.imageChanged()

  QtProperty[string] icon:
    read = getIcon
    notify = imageChanged

  QtProperty[string] thumbnailImage:
    read = getThumbnailImage
    notify = imageChanged

  proc largeImageChanged*(self: UserProfile) {.signal.}

  proc getLargeImage*(self: UserProfile): string {.slot.} =
    return self.largeImage

  # this is not a slot
  proc setLargeImage*(self: UserProfile, image: string) =
    if(self.largeImage == image):
      return
    self.largeImage = image
    self.largeImageChanged()

  QtProperty[string] largeImage:
    read = getLargeImage
    notify = largeImageChanged

  proc currentUserStatusChanged*(self: UserProfile) {.signal.}

  proc getCurrentUserStatus*(self: UserProfile): int {.slot.} =
    self.currentUserStatus

  # this is not a slot
  proc setCurrentUserStatus*(self: UserProfile, status: int) =
    if(self.currentUserStatus == status):
      return
    self.currentUserStatus = status
    self.currentUserStatusChanged()

  QtProperty[int] currentUserStatus:
    read = getCurrentUserStatus
    notify = currentUserStatusChanged
