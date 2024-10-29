import stew/shims/strformat
import ../../../app_service/common/types
import ../../../app_service/service/contacts/dto/contacts

type
  ContactRequest* {.pure.} = enum
    None = 0
    Mutual = 1
    Sent = 2
    Received = 3
    Dismissed = 4

#TODO: #14964 - To check if this is needed
proc toContactStatus*(value: ContactRequestState): ContactRequest =
  case value:
  of ContactRequestState.None: return ContactRequest.None
  of ContactRequestState.Mutual: return ContactRequest.Mutual
  of ContactRequestState.Sent: return ContactRequest.Sent
  of ContactRequestState.Received: return ContactRequest.Received
  of ContactRequestState.Dismissed: return ContactRequest.Dismissed
  else: return ContactRequest.None

type
  UserItem* = ref object of RootObj
    pubKey: string
    displayName: string
    ensName: string
    isEnsVerified: bool
    localNickname: string
    alias: string
    icon: string
    colorId: int
    colorHash: string
    onlineStatus: OnlineStatus
    isContact: bool
    isBlocked: bool
    contactRequest: ContactRequest
    #Contact extra details
    isCurrentUser: bool
    defaultDisplayName: string
    optionalName: string
    lastUpdated: int64
    lastUpdatedLocally: int64
    bio: string
    thumbnailImage: string
    largeImage: string
    isContactRequestReceived: bool
    isContactRequestSent: bool
    isSyncing: bool
    isRemoved: bool
    trustStatus: TrustStatus

proc setup*(self: UserItem,
  pubKey: string,
  displayName: string,
  ensName: string,
  isEnsVerified: bool,
  localNickname: string,
  alias: string,
  icon: string,
  colorId: int,
  colorHash: string,
  onlineStatus: OnlineStatus,
  isContact: bool,
  isBlocked: bool,
  contactRequest: ContactRequest,
  #TODO: #14964 - remove defaults
  isCurrentUser: bool = false,
  defaultDisplayName: string = "",
  optionalName: string = "",
  lastUpdated: int64 = 0,
  lastUpdatedLocally: int64 = 0,
  bio: string = "",
  thumbnailImage: string = "",
  largeImage: string = "",
  isContactRequestReceived: bool = false,
  isContactRequestSent: bool = false,
  isSyncing: bool = false,
  isRemoved: bool = false,
  trustStatus: TrustStatus = TrustStatus.Unknown,
  ) =
  self.pubKey = pubKey
  self.displayName = displayName
  self.ensName = ensName
  self.isEnsVerified = isEnsVerified
  self.localNickname = localNickname
  self.alias = alias
  self.icon = icon
  self.colorId = colorId
  self.colorHash = colorHash
  self.onlineStatus = onlineStatus
  self.isContact = isContact
  self.isBlocked = isBlocked
  self.contactRequest = contactRequest
  self.isCurrentUser = isCurrentUser
  self.defaultDisplayName = defaultDisplayName
  self.optionalName = optionalName
  self.lastUpdated = lastUpdated
  self.lastUpdatedLocally = lastUpdatedLocally
  self.bio = bio
  self.thumbnailImage = thumbnailImage
  self.largeImage = largeImage
  self.isContactRequestReceived = isContactRequestReceived
  self.isContactRequestSent = isContactRequestSent
  self.isSyncing = isSyncing
  self.isRemoved = isRemoved
  self.trustStatus = trustStatus

# FIXME: remove defaults
# TODO: #14964
proc initUserItem*(
    pubKey: string,
    displayName: string,
    ensName: string,
    isEnsVerified: bool,
    localNickname: string,
    alias: string,
    icon: string,
    colorId: int,
    colorHash: string = "",
    onlineStatus: OnlineStatus,
    isContact: bool,
    isBlocked: bool,
    contactRequest: ContactRequest = ContactRequest.None,
    isCurrentUser: bool = false,
    defaultDisplayName: string = "",
    optionalName: string = "",
    lastUpdated: int64 = 0,
    lastUpdatedLocally: int64 = 0,
    bio: string = "",
    thumbnailImage: string = "",
    largeImage: string = "",
    isContactRequestReceived: bool = false,
    isContactRequestSent: bool = false,
    isSyncing: bool = false,
    isRemoved: bool = false,
    trustStatus: TrustStatus = TrustStatus.Unknown,
    ): UserItem =
  result = UserItem()
  result.setup(
    pubKey = pubKey,
    displayName = displayName,
    ensName = ensName,
    isEnsVerified = isEnsVerified,
    localNickname = localNickname,
    alias = alias,
    icon = icon,
    colorId = colorId,
    colorHash = colorHash,
    onlineStatus = onlineStatus,
    isContact = isContact,
    isBlocked = isBlocked,
    contactRequest = contactRequest,
    isCurrentUser = isCurrentUser,
    defaultDisplayName = defaultDisplayName,
    optionalName = optionalName,
    lastUpdated = lastUpdated,
    lastUpdatedLocally = lastUpdatedLocally,
    bio = bio,
    thumbnailImage = thumbnailImage,
    largeImage = largeImage,
    isContactRequestReceived = isContactRequestReceived,
    isContactRequestSent = isContactRequestSent,
    isSyncing = isSyncing,
    isRemoved = isRemoved,
    trustStatus = trustStatus,
    )

proc `$`*(self: UserItem): string =
  result = fmt"""User Item(
    pubKey: {self.pubkey},
    displayName: {self.displayName},
    ensName: {self.ensName},
    isEnsVerified: {self.isEnsVerified},
    localNickname: {self.localNickname},
    alias: {self.alias},
    icon: {self.icon},
    colorId: {self.colorId},
    colorHash: {self.colorHash},
    onlineStatus: {$self.onlineStatus.int},
    isContact: {self.isContact},
    isBlocked: {self.isBlocked},
    contactRequest: {$self.contactRequest.int},
    isCurrentUser: {self.isCurrentUser},
    defaultDisplayName: {self.defaultDisplayName},
    optionalName: {self.optionalName},
    lastUpdated: {self.lastUpdated},
    lastUpdatedLocally: {self.lastUpdatedLocally},
    bio: {self.bio},
    thumbnailImage: {self.thumbnailImage},
    largeImage: {self.largeImage},
    isContactRequestReceived: {self.isContactRequestReceived},
    isContactRequestSent: {self.isContactRequestSent},
    isSyncing: {self.isSyncing},
    isRemoved: {self.isRemoved},
    trustStatus: {$self.trustStatus.int},
    ]"""

proc pubKey*(self: UserItem): string {.inline.} =
  self.pubKey

proc displayName*(self: UserItem): string {.inline.} =
  self.displayName

proc `displayName=`*(self: UserItem, value: string) {.inline.} =
  self.displayName = value

proc ensName*(self: UserItem): string {.inline.} =
  if self.isEnsVerified: self.ensName else: ""

proc `ensName=`*(self: UserItem, value: string) {.inline.} =
  self.ensName = value

proc isEnsVerified*(self: UserItem): bool {.inline.} =
  self.isEnsVerified

proc `isEnsVerified=`*(self: UserItem, value: bool) {.inline.} =
  self.isEnsVerified = value

proc localNickname*(self: UserItem): string {.inline.} =
  self.localNickname

proc `localNickname=`*(self: UserItem, value: string) {.inline.} =
  self.localNickname = value

proc alias*(self: UserItem): string {.inline.} =
  self.alias

proc `alias=`*(self: UserItem, value: string) {.inline.} =
  self.alias = value

proc icon*(self: UserItem): string {.inline.} =
  self.icon

proc `icon=`*(self: UserItem, value: string) {.inline.} =
  self.icon = value

proc colorId*(self: UserItem): int {.inline.} =
  self.colorId

proc `colorId=`*(self: UserItem, value: int) {.inline.} =
  self.colorId = value

proc colorHash*(self: UserItem): string {.inline.} =
  if not self.isEnsVerified: self.colorHash else: ""

proc `colorHash=`*(self: UserItem, value: string) {.inline.} =
  self.colorHash = value

proc onlineStatus*(self: UserItem): OnlineStatus {.inline.} =
  self.onlineStatus

proc `onlineStatus=`*(self: UserItem, value: OnlineStatus) {.inline.} =
  self.onlineStatus = value

proc isContact*(self: UserItem): bool {.inline.} =
  self.isContact

proc `isContact=`*(self: UserItem, value: bool) {.inline.} =
  self.isContact = value

proc isBlocked*(self: UserItem): bool {.inline.} =
  self.isBlocked

proc `isBlocked=`*(self: UserItem, value: bool) {.inline.} =
  self.isBlocked = value

proc contactRequest*(self: UserItem): ContactRequest {.inline.} =
  self.contactRequest

proc `contactRequest=`*(self: UserItem, value: ContactRequest) {.inline.} =
  self.contactRequest = value

proc isCurrentUser*(self: UserItem): bool {.inline.} =
  self.isCurrentUser

proc `isCurrentUser=`*(self: UserItem, value: bool) {.inline.} =
  self.isCurrentUser = value

proc defaultDisplayName*(self: UserItem): string {.inline.} =
  self.defaultDisplayName

proc `defaultDisplayName=`*(self: UserItem, value: string) {.inline.} =
  self.defaultDisplayName = value

proc optionalName*(self: UserItem): string {.inline.} =
  self.optionalName

proc `optionalName=`*(self: UserItem, value: string) {.inline.} =
  self.optionalName = value

proc lastUpdated*(self: UserItem): int64 {.inline.} =
  self.lastUpdated

proc `lastUpdated=`*(self: UserItem, value: int64) {.inline.} =
  self.lastUpdated = value

proc lastUpdatedLocally*(self: UserItem): int64 {.inline.} =
  self.lastUpdatedLocally

proc `lastUpdatedLocally=`*(self: UserItem, value: int64) {.inline.} =
  self.lastUpdatedLocally = value

proc bio*(self: UserItem): string {.inline.} =
  self.bio

proc `bio=`*(self: UserItem, value: string) {.inline.} =
  self.bio = value

proc thumbnailImage*(self: UserItem): string {.inline.} =
  self.thumbnailImage

proc `thumbnailImage=`*(self: UserItem, value: string) {.inline.} =
  self.thumbnailImage = value

proc largeImage*(self: UserItem): string {.inline.} =
  self.largeImage

proc `largeImage=`*(self: UserItem, value: string) {.inline.} =
  self.largeImage = value

proc isContactRequestReceived*(self: UserItem): bool {.inline.} =
  self.isContactRequestReceived

proc `isContactRequestReceived=`*(self: UserItem, value: bool) {.inline.} =
  self.isContactRequestReceived = value

proc isContactRequestSent*(self: UserItem): bool {.inline.} =
  self.isContactRequestSent

proc `isContactRequestSent=`*(self: UserItem, value: bool) {.inline.} =
  self.isContactRequestSent = value

proc isSyncing*(self: UserItem): bool {.inline.} =
  self.isSyncing

proc `isSyncing=`*(self: UserItem, value: bool) {.inline.} =
  self.isSyncing = value

proc isRemoved*(self: UserItem): bool {.inline.} =
  self.isRemoved

proc `isRemoved=`*(self: UserItem, value: bool) {.inline.} =
  self.isRemoved = value

proc trustStatus*(self: UserItem): TrustStatus {.inline.} =
  self.trustStatus

proc `trustStatus=`*(self: UserItem, value: TrustStatus) {.inline.} =
  self.trustStatus = value
