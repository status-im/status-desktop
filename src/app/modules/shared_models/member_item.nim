import strformat
import user_item

import ../../../app_service/common/types

export user_item

type
  MemberItem* = ref object of UserItem
    memberRole: MemberRole
    joined: bool
    requestToJoinId: string
    requestToJoinLoading*: bool
    airdropAddress*: string
    membershipRequestState*: MembershipRequestState

# FIXME: remove defaults
proc initMemberItem*(
  pubKey: string,
  displayName: string,
  ensName: string,
  isEnsVerified: bool,
  localNickname: string,
  alias: string,
  icon: string,
  colorId: int,
  colorHash: string = "",
  onlineStatus: OnlineStatus = OnlineStatus.Inactive,
  isContact: bool = false,
  isVerified: bool,
  isUntrustworthy: bool = false,
  isBlocked: bool = false,
  contactRequest: ContactRequest = ContactRequest.None,
  incomingVerificationStatus: VerificationRequestStatus = VerificationRequestStatus.None,
  outgoingVerificationStatus: VerificationRequestStatus = VerificationRequestStatus.None,
  memberRole: MemberRole = MemberRole.None,
  joined: bool = false,
  requestToJoinId: string = "",
  requestToJoinLoading: bool = false,
  airdropAddress: string = "",
  membershipRequestState: MembershipRequestState = MembershipRequestState.None
): MemberItem =
  result = MemberItem()
  result.memberRole = memberRole
  result.joined = joined
  result.requestToJoinId = requestToJoinId
  result.requestToJoinLoading = requestToJoinLoading
  result.airdropAddress = airdropAddress
  result.membershipRequestState = membershipRequestState
  result.UserItem.setup(
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
    isEnsVerified: {self.isEnsVerified},
    localNickname: {self.localNickname},
    alias: {self.alias},
    airdropAddress: {self.airdropAddress},
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
    memberRole: {self.memberRole},
    joined: {self.joined},
    requestToJoinId: {self.requestToJoinId},
    membershipRequestState: {$self.membershipRequestState.int}
    ]"""

proc memberRole*(self: MemberItem): MemberRole {.inline.} =
  self.memberRole

proc `memberRole=`*(self: MemberItem, value: MemberRole) {.inline.} =
  self.memberRole = value

proc joined*(self: MemberItem): bool {.inline.} =
  self.joined

proc `joined=`*(self: MemberItem, value: bool) {.inline.} =
  self.joined = value

proc requestToJoinId*(self: MemberItem): string {.inline.} =
  self.requestToJoinId

proc `requestToJoinId=`*(self: MemberItem, value: string) {.inline.} =
  self.requestToJoinId = value

proc requestToJoinLoading*(self: MemberItem): bool {.inline.} =
  self.requestToJoinLoading

proc airdropAddress*(self: MemberItem): string {.inline.} =
  self.airdropAddress

proc membershipRequestState*(self: MemberItem): MembershipRequestState {.inline.} =
  self.membershipRequestState