import std/[importutils, json, tables, unittest]

import app/core/eventemitter
import app_service/service/community/service as community_service
import app_service/service/community/dto/community

privateAccess(community_service.Service)

const
  communityId = "0x02b5bdaf5a25fcfe2ee14c501fab1836b8de57f61621080c3d52073d16de0d98d6"
  requestId = "0x01"
  requesterKey = "0x0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8"

proc acceptedResponse(): string =
  $(%*{
    "communityId": communityId,
    "requestId": requestId,
    "error": "",
    "response": {"result": {
      "communities": [{"id": communityId, "joined": true}],
      "requestsToJoinCommunity": [{"id": requestId, "publicKey": requesterKey,
        "communityId": communityId, "state": RequestToJoinType.Accepted.int}],
      "communityChanges": [{"communityId": communityId, "clock": 2,
        "rosterAdded": {requesterKey: {"pubKey": requesterKey, "roles": []}}}],
    }},
  })

suite "accepting a request to join":
  setup:
    let events = createEventEmitter()
    let service = community_service.newService(events, nil, nil, nil, nil)
    var community = CommunityDto(id: communityId, joined: true)
    community.pendingRequestsToJoin = @[CommunityMembershipRequestDto(id: requestId,
      publicKey: requesterKey, communityId: communityId, state: RequestToJoinType.Pending.int)]
    service.communities[communityId] = community

    var failed, approved, statusChanges = 0
    events.on(SIGNAL_ACCEPT_REQUEST_TO_JOIN_FAILED, proc(e: Args) = inc failed)
    events.on(SIGNAL_COMMUNITY_MEMBER_APPROVED, proc(e: Args) = inc approved)
    events.on(SIGNAL_COMMUNITY_MEMBER_STATUS_CHANGED, proc(e: Args) = inc statusChanges)

  test "an acceptance that adds the requester to the roster succeeds once":
    service.onAsyncAcceptRequestToJoinCommunityDone(acceptedResponse())

    check failed == 0
    check approved == 1
    check statusChanges == 1
    check service.communities[communityId].pendingRequestsToJoin.len == 0
