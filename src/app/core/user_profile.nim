import NimQml

QtObject:
  type UserProfile* = ref object of QObject
    # fields which cannot change
    username: string
    address: string
    identicon: string
    pubKey: string
    # fieds which may be change during runtime
    ensName: string
    thumbnailImage: string
    largeImage: string
    sendUserStatus: bool
    currentUserStatus: int
    
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
  
  proc getUsername*(self: UserProfile): string {.slot.} = 
    self.username
  
  QtProperty[string] username:
    read = getUsername


  proc getAddress*(self: UserProfile): string {.slot.} = 
    self.address
  
  QtProperty[string] address:
    read = getAddress


  proc getPubKey*(self: UserProfile): string {.slot.} = 
    self.pubKey
  
  QtProperty[string] pubKey:
    read = getPubKey


  proc ensNameChanged*(self: UserProfile) {.signal.}

  proc getEnsName*(self: UserProfile): string {.slot.} =
    self.ensName

  # this is not a slot
  proc setEnsName*(self: UserProfile, name: string) = 
    if(self.ensName == name):
      return
    self.ensName = name
    self.ensNameChanged()
      
  QtProperty[string] ensName:
    read = getEnsName
    notify = ensNameChanged


  proc thumbnailImageChanged*(self: UserProfile) {.signal.}

  proc getThumbnailImage*(self: UserProfile): string {.slot.} =
    if(self.thumbnailImage.len > 0):
      return self.thumbnailImage

    return self.identicon

  # this is not a slot
  proc setThumbnailImage*(self: UserProfile, image: string) = 
    if(self.thumbnailImage == image):
      return

    self.thumbnailImage = image
    self.thumbnailImageChanged()
      
  QtProperty[string] thumbnailImage:
    read = getThumbnailImage
    notify = thumbnailImageChanged

  
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


  proc sendUserStatusChanged*(self: UserProfile) {.signal.}
  
  proc getSendUserStatus*(self: UserProfile): bool {.slot.} = 
    self.sendUserStatus

  # this is not a slot
  proc setSendUserStatus*(self: UserProfile, status: bool) =
    if(self.sendUserStatus == status):
      return
    self.sendUserStatus = status
    self.sendUserStatusChanged()

  QtProperty[bool] sendUserStatus:
    read = getSendUserStatus
    notify = sendUserStatusChanged


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
