import strformat
import user_item

export user_item

type
  MemberItem* = ref object of UserItem
    isAdmin: bool
    joined: bool

# FIXME: remove defaults
proc initMemberItem*(
  pubKey: string,
  displayName: string,
  ensName: string,
  localNickname: string,
  alias: string,
  icon: string,
  colorId: int = 0,
  colorHash: string = "",
  onlineStatus: OnlineStatus = OnlineStatus.Inactive,
  isContact: bool = false,
  isVerified: bool = false,
  isUntrustworthy: bool = false,
  isBlocked: bool = false,
  contactRequest: ContactRequest = ContactRequest.None,
  incomingVerificationStatus: VerificationRequestStatus = VerificationRequestStatus.None,
  outgoingVerificationStatus: VerificationRequestStatus = VerificationRequestStatus.None,
  isAdmin: bool = false,
  joined: bool = false,
): MemberItem =
  result = MemberItem()
  result.isAdmin = isAdmin
  result.joined = joined
  result.UserItem.setup(
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
    outgoingVerificationStatus = outgoingVerificationStatus
  )

proc `$`*(self: MemberItem): string =
  result = fmt"""Member Item(
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
    isAdmin: {self.isAdmin},
    joined: {self.joined}
    ]"""

proc isAdmin*(self: MemberItem): bool {.inline.} =
  self.isAdmin

proc `isAdmin=`*(self: MemberItem, value: bool) {.inline.} =
  self.isAdmin = value

proc joined*(self: MemberItem): bool {.inline.} =
  self.joined

proc `joined=`*(self: MemberItem, value: bool) {.inline.} =
  self.joined = value
