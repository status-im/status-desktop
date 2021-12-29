import NimQml

import ../../app_service/common/utils

QtObject:
  type UserProfile* = ref object of QObject
    # fields which cannot change
    username: string
    address: string
    identicon: string
    pubKey: string
    # fields which may change during runtime
    isIdenticon: bool
    ensName: string
    firstEnsName: string
    preferredName: string
    thumbnailImage: string
    largeImage: string
    userStatus: bool
    #currentUserStatus: int
    
  proc setup(self: UserProfile) =
    self.QObject.setup

  proc delete*(self: UserProfile) =
    self.QObject.delete

  proc newUserProfile*(): UserProfile =
    new(result, delete)
    result.setup

  proc setFixedData*(self: UserProfile, username: string, address: string, identicon: string, pubKey: string) =
    self.username = username
    self.address = address
    self.identicon = identicon
    self.pubKey = pubKey
    self.isIdenticon = true

  proc getAddress*(self: UserProfile): string {.slot.} = 
    self.address
  
  QtProperty[string] address:
    read = getAddress


  proc getPubKey*(self: UserProfile): string {.slot.} = 
    self.pubKey
  
  QtProperty[string] pubKey:
    read = getPubKey


  proc nameChanged*(self: UserProfile) {.signal.}

  proc getUsername*(self: UserProfile): string {.slot.} = 
    self.username
  
  QtProperty[string] username:
    read = getUsername
    notify = nameChanged

  # this is not a slot
  proc setEnsName*(self: UserProfile, name: string) = 
    if(self.ensName == name):
      return
    self.ensName = name
    self.nameChanged()

  proc getEnsName*(self: UserProfile): string {.slot.} =
    self.ensName      
  QtProperty[string] ensName:
    read = getEnsName
    notify = nameChanged

  proc getPrettyEnsName*(self: UserProfile): string {.slot.} =
    utils.prettyEnsName(self.ensName)
  QtProperty[string] prettyEnsName:
    read = getPrettyEnsName
    notify = nameChanged


  # this is not a slot
  proc setFirstEnsName*(self: UserProfile, name: string) = 
    if(self.firstEnsName == name):
      return
    self.firstEnsName = name
    self.nameChanged()

  proc getFirstEnsName*(self: UserProfile): string {.slot.} =
    self.firstEnsName      
  QtProperty[string] firstEnsName:
    read = getFirstEnsName
    notify = nameChanged

  proc getPrettyFirstEnsName*(self: UserProfile): string {.slot.} =
    utils.prettyEnsName(self.firstEnsName)
  QtProperty[string] prettyFirstEnsName:
    read = getPrettyFirstEnsName
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

  proc getPrettyPreferredName*(self: UserProfile): string {.slot.} =
    utils.prettyEnsName(self.preferredName)
  QtProperty[string] prettyPreferredName:
    read = getPrettyPreferredName
    notify = nameChanged


  proc getName*(self: UserProfile): string {.slot.} =
    if(self.preferredName.len > 0):
      return self.getPrettyPreferredName()
    elif(self.firstEnsName.len > 0):
      return self.getPrettyFirstEnsName()
    elif(self.ensName.len > 0):
      return self.getPrettyEnsName()
    return self.username
      
  QtProperty[string] name:
    read = getName
    notify = nameChanged


  proc imageChanged*(self: UserProfile) {.signal.}

  proc getIsIdenticon*(self: UserProfile): bool {.slot.} =
    return self.isIdenticon

  proc getIdenticon*(self: UserProfile): string {.slot.} =
    self.identicon

  proc getThumbnailImage*(self: UserProfile): string {.slot.} =
    return self.thumbnailImage

  QtProperty[bool] isIdenticon:
    read = getIsIdenticon
    notify = imageChanged

  proc getIcon*(self: UserProfile): string {.slot.} =
    if(self.thumbnailImage.len > 0):
      return self.thumbnailImage

    return self.identicon

  # this is not a slot
  proc setThumbnailImage*(self: UserProfile, image: string) = 
    if(self.thumbnailImage == image):
      return

    self.thumbnailImage = image
    self.isIdenticon = self.thumbnailImage.len == 0
    self.imageChanged()

  QtProperty[string] icon:
    read = getIcon
    notify = imageChanged

  QtProperty[string] identicon:
    read = getIdenticon
    notify = imageChanged

  QtProperty[string] thumbnailImage:
    read = getThumbnailImage
    notify = imageChanged
  
  proc largeImageChanged*(self: UserProfile) {.signal.}

  proc getLargeImage*(self: UserProfile): string {.slot.} =
    if(self.largeImage.len > 0):
      return self.largeImage

    return self.identicon

  # this is not a slot
  proc setLargeImage*(self: UserProfile, image: string) =
    if(self.largeImage == image):
      return
    self.largeImage = image
    self.largeImageChanged()

  QtProperty[string] largeImage:
    read = getLargeImage
    notify = largeImageChanged


  proc userStatusChanged*(self: UserProfile) {.signal.}
  
  proc getUserStatus*(self: UserProfile): bool {.slot.} = 
    self.userStatus

  # this is not a slot
  proc setUserStatus*(self: UserProfile, status: bool) =
    if(self.userStatus == status):
      return
    self.userStatus = status
    self.userStatusChanged()

  QtProperty[bool] userStatus:
    read = getUserStatus
    notify = userStatusChanged


  ## This is still not in use.
  ## Once we decide to differ more than Online/Offline statuses we shouldn't use this code below, 
  ## but update current `userStatus` which is a bool to something like the code bellow (`currentUserStatus`).
  ## 
  ## Proposal - some statuses we may have:
  ## type
  ##   OnlineStatus* {.pure.} = enum
  ##     Online = 0
  ##     Idle
  ##     DoNotDisturb
  ##     Invisible
  ##     Offline
  ## 
  ## 
  ## proc currentUserStatusChanged*(self: UserProfile) {.signal.}

  ## proc getCurrentUserStatus*(self: UserProfile): int {.slot.} =
  ##   self.currentUserStatus

  ## # this is not a slot
  ## proc setCurrentUserStatus*(self: UserProfile, status: int) =
  ##   if(self.currentUserStatus == status):
  ##     return
  ##   self.currentUserStatus = status
  ##   self.currentUserStatusChanged()

  ## QtProperty[int] currentUserStatus:
  ##   read = getCurrentUserStatus
  ##   notify = currentUserStatusChanged
