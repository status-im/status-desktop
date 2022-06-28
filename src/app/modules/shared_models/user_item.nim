import strformat
import ../../../app_service/common/types

type
  OnlineStatus* {.pure.} = enum
    Inactive = 0
    Online

  ContactRequest* {.pure.} = enum
    None = 0
    IncomingPending
    IncomingRejected
    OutgoingPending
    OutgoingRejected

  VerificationRequestStatus* {.pure.} = enum
    None = 0
    Pending
    Answered
    Declined
    Canceled
    Trusted

type
  UserItem* = ref object of RootObj
    pubKey: string
    displayName: string
    ensName: string
    localNickname: string
    alias: string
    icon: string
    colorId: int
    colorHash: string
    onlineStatus: OnlineStatus
    isContact: bool
    isVerified: bool
    isUntrustworthy: bool
    isBlocked: bool
    contactRequest: ContactRequest
    incomingVerificationStatus: VerificationRequestStatus
    outgoingVerificationStatus: VerificationRequestStatus

proc setup*(self: UserItem,
  pubKey: string,
  displayName: string,
  ensName: string,
  localNickname: string,
  alias: string,
  icon: string,
  colorId: int,
  colorHash: string,
  onlineStatus: OnlineStatus,
  isContact: bool,
  isVerified: bool,
  isUntrustworthy: bool,
  isBlocked: bool,
  contactRequest: ContactRequest,
  incomingVerificationStatus: VerificationRequestStatus,
  outgoingVerificationStatus: VerificationRequestStatus,
  ) =
  self.pubKey = pubKey
  self.displayName = displayName
  self.ensName = ensName
  self.localNickname = localNickname
  self.alias = alias
  self.icon = icon
  self.colorId = colorId
  self.colorHash = colorHash
  self.onlineStatus = onlineStatus
  self.isContact = isContact
  self.isVerified = isVerified
  self.isUntrustworthy = isUntrustworthy
  self.isBlocked = isBlocked
  self.contactRequest = contactRequest
  self.incomingVerificationStatus = incomingVerificationStatus
  self.outgoingVerificationStatus = outgoingVerificationStatus

# FIXME: remove defaults
proc initUserItem*(
    pubKey: string,
    displayName: string,
    ensName: string = "",
    localNickname: string = "",
    alias: string = "",
    icon: string,
    colorId: int = 0,
    colorHash: string = "",
    onlineStatus: OnlineStatus = OnlineStatus.Inactive,
    isContact: bool,
    isVerified: bool,
    isUntrustworthy: bool,
    isBlocked: bool,
    contactRequest: ContactRequest = ContactRequest.None,
    incomingVerificationStatus: VerificationRequestStatus = VerificationRequestStatus.None,
    outgoingVerificationStatus: VerificationRequestStatus = VerificationRequestStatus.None,
    ): UserItem =
  result = UserItem()
  result.setup(
    pubKey = pubKey,
    displayName = displayName,
    ensName = ensName,
    localNickname = localNickname,
    alias = alias,
    icon = icon,
    colorId = colorId,
    colorHash = colorHash,
    onlineStatus = onlineStatus,
    isContact = isContact,
    isVerified = isVerified,
    isUntrustworthy = isUntrustworthy,
    isBlocked = isBlocked,
    contactRequest = contactRequest,
    incomingVerificationStatus = incomingVerificationStatus,
    outgoingVerificationStatus = outgoingVerificationStatus)

proc toOnlineStatus*(statusType: StatusType): OnlineStatus =
  if(statusType == StatusType.AlwaysOnline or statusType == StatusType.Automatic):
    return OnlineStatus.Online
  else:
    return OnlineStatus.Inactive

proc `$`*(self: UserItem): string =
  result = fmt"""User Item(
    pubKey: {self.pubkey},
    displayName: {self.displayName},
    ensName: {self.ensName},
    localNickname: {self.localNickname},
    alias: {self.alias},
    icon: {self.icon},
    colorId: {self.colorId},
    colorHash: {self.colorHash},
    onlineStatus: {$self.onlineStatus.int},
    isContact: {self.isContact},
    isVerified: {self.isVerified},
    isUntrustworthy: {self.isUntrustworthy},
    isBlocked: {self.isBlocked},
    contactRequest: {$self.contactRequest.int},
    incomingVerificationStatus: {$self.incomingVerificationStatus.int},
    outgoingVerificationStatus: {$self.outgoingVerificationStatus.int},
    ]"""

proc pubKey*(self: UserItem): string {.inline.} =
  self.pubKey

proc displayName*(self: UserItem): string {.inline.} =
  self.displayName

proc `displayName=`*(self: UserItem, value: string) {.inline.} =
  self.displayName = value

proc ensName*(self: UserItem): string {.inline.} =
  self.ensName

proc `ensName=`*(self: UserItem, value: string) {.inline.} =
  self.ensName = value

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
  self.colorHash

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

proc isVerified*(self: UserItem): bool {.inline.} =
  self.isVerified

proc `isVerified=`*(self: UserItem, value: bool) {.inline.} =
  self.isVerified = value

proc isUntrustworthy*(self: UserItem): bool {.inline.} =
  self.isUntrustworthy

proc `isUntrustworthy=`*(self: UserItem, value: bool) {.inline.} =
  self.isUntrustworthy = value

proc isBlocked*(self: UserItem): bool {.inline.} =
  self.isBlocked

proc `isBlocked=`*(self: UserItem, value: bool) {.inline.} =
  self.isBlocked = value

proc contactRequest*(self: UserItem): ContactRequest {.inline.} =
  self.contactRequest

proc `contactRequest=`*(self: UserItem, value: ContactRequest) {.inline.} =
  self.contactRequest = value

proc incomingVerificationStatus*(self: UserItem): VerificationRequestStatus {.inline.} =
  self.incomingVerificationStatus

proc `incomingVerificationStatus=`*(self: UserItem, value: VerificationRequestStatus) {.inline.} =
  self.incomingVerificationStatus = value

proc outgoingVerificationStatus*(self: UserItem): VerificationRequestStatus {.inline.} =
  self.outgoingVerificationStatus

proc `outgoingVerificationStatus=`*(self: UserItem, value: VerificationRequestStatus) {.inline.} =
  self.outgoingVerificationStatus = value
