{.used.}

import json

type CommunityMembershipRequest* = object
  id*: string
  publicKey*: string
  chatId*: string
  communityId*: string
  state*: int
  our*: string

proc toCommunityMembershipRequest*(jsonCommunityMembershipRequest: JsonNode): CommunityMembershipRequest =
  result = CommunityMembershipRequest(
    id: jsonCommunityMembershipRequest{"id"}.getStr,
    publicKey: jsonCommunityMembershipRequest{"publicKey"}.getStr,
    chatId: jsonCommunityMembershipRequest{"chatId"}.getStr,
    state: jsonCommunityMembershipRequest{"state"}.getInt,
    communityId: jsonCommunityMembershipRequest{"communityId"}.getStr,
    our: jsonCommunityMembershipRequest{"our"}.getStr,
  )