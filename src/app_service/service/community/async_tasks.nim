include ../../common/json_utils
include ../../../app/core/tasks/common

type
  AsyncLoadCommunitiesDataTaskArg = ref object of QObjectTaskArg

const asyncLoadCommunitiesDataTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoadCommunitiesDataTaskArg](argEncoded)
  try:
    let responseTags = status_go.getCommunityTags()
    let responseCommunities = status_go.getAllCommunities()
    let responseSettings = status_go.getCommunitiesSettings()
    let responseNonApprovedRequestsToJoin = status_go.allNonApprovedCommunitiesRequestsToJoin()

    arg.finish(%* {
      "tags": responseTags,
      "communities": responseCommunities,
      "settings": responseSettings,
      "nonAprrovedRequestsToJoin": responseNonApprovedRequestsToJoin,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncCollectCommunityMetricsTaskArg = ref object of QObjectTaskArg
    communityId: string
    metricsType: CommunityMetricsType
    intervals: JsonNode

const asyncCollectCommunityMetricsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCollectCommunityMetricsTaskArg](argEncoded)
  try:
    let response = status_go.collectCommunityMetrics(arg.communityId, arg.metricsType.int, arg.intervals)
    arg.finish(%* {
      "communityId": arg.communityId,
      "metricsType": arg.metricsType,
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "metricsType": arg.metricsType,
      "error": e.msg,
    })

type
  AsyncRequestCommunityInfoTaskArg = ref object of QObjectTaskArg
    communityId: string
    importing: bool
    tryDatabase: bool
    shardCluster: int
    shardIndex: int

const asyncRequestCommunityInfoTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncRequestCommunityInfoTaskArg](argEncoded)
  try:
    let response = status_go.requestCommunityInfo(arg.communityId, arg.tryDatabase, arg.shardCluster, arg.shardIndex)
    arg.finish(%* {
      "communityId": arg.communityId,
      "importing": arg.importing,
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "importing": arg.importing,
      "error": e.msg,
    })

type
  AsyncLoadCuratedCommunitiesTaskArg = ref object of QObjectTaskArg

const asyncLoadCuratedCommunitiesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncLoadCuratedCommunitiesTaskArg](argEncoded)
  try:
    let response = status_go.getCuratedCommunities()
    arg.finish(%* {
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncAcceptRequestToJoinCommunityTaskArg = ref object of QObjectTaskArg
    communityId: string
    requestId: string

const asyncAcceptRequestToJoinCommunityTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncAcceptRequestToJoinCommunityTaskArg](argEncoded)
  try:
    let response = status_go.acceptRequestToJoinCommunity(arg.requestId)
    let tpl: tuple[communityId: string, requestId: string, response: RpcResponse[JsonNode], error: string] = (arg.communityId, arg.requestId, response, "")
    arg.finish(tpl)
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "communityId": arg.communityId,
      "requestId": arg.requestId
    })

type
  AsyncCommunityMemberActionTaskArg = ref object of QObjectTaskArg
    communityId: string
    pubKey: string

const asyncRemoveUserFromCommunityTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCommunityMemberActionTaskArg](argEncoded)
  try:
    let response = status_go.removeUserFromCommunity(arg.communityId, arg.pubKey)
    arg.finish(%* {
      "communityId": arg.communityId,
      "pubKey": arg.pubKey,
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "pubKey": arg.pubKey,
      "error": e.msg,
    })

const asyncBanUserFromCommunityTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCommunityMemberActionTaskArg](argEncoded)
  try:
    let response = status_go.banUserFromCommunity(arg.communityId, arg.pubKey)
    let tpl: tuple[communityId: string, pubKey: string, response: RpcResponse[JsonNode], error: string] = (arg.communityId, arg.pubKey, response, "")
    arg.finish(tpl)
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "communityId": arg.communityId,
      "pubKey": arg.pubKey
    })

const asyncUnbanUserFromCommunityTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCommunityMemberActionTaskArg](argEncoded)
  try:
    let response = status_go.unbanUserFromCommunity(arg.communityId, arg.pubKey)
    let tpl: tuple[communityId: string, pubKey: string, response: RpcResponse[JsonNode], error: string] = (arg.communityId, arg.pubKey, response, "")
    arg.finish(tpl)
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "communityId": arg.communityId,
      "pubKey": arg.pubKey
    })

type
  AsyncRequestToJoinCommunityTaskArg = ref object of QObjectTaskArg
    communityId: string
    ensName: string
    addressesToShare: seq[string]
    signatures: seq[string]
    airdropAddress: string

const asyncRequestToJoinCommunityTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncRequestToJoinCommunityTaskArg](argEncoded)
  try:
    let response = status_go.requestToJoinCommunity(arg.communityId, arg.ensName, arg.addressesToShare,
      arg.signatures, arg.airdropAddress)
    arg.finish(%* {
      "response": response,
      "communityId": arg.communityId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "communityId": arg.communityId,
    })

type
  AsyncEditSharedAddressesTaskArg = ref object of QObjectTaskArg
    communityId: string
    addressesToShare: seq[string]
    signatures: seq[string]
    airdropAddress: string

const asyncEditSharedAddressesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncEditSharedAddressesTaskArg](argEncoded)
  try:
    let response = status_go.editSharedAddresses(arg.communityId, arg.addressesToShare, arg.signatures,
      arg.airdropAddress)
    arg.finish(%* {
      "response": response,
      "communityId": arg.communityId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "communityId": arg.communityId,
    })

type
  AsyncCheckPermissionsToJoinTaskArg = ref object of QObjectTaskArg
    communityId: string
    addresses: seq[string]

const asyncCheckPermissionsToJoinTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckPermissionsToJoinTaskArg](argEncoded)
  try:
    let response = status_go.checkPermissionsToJoinCommunity(arg.communityId, arg.addresses)
    arg.finish(%* {
      "response": response,
      "communityId": arg.communityId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "error": e.msg,
    })

type
  AsyncImportCommunityTaskArg = ref object of QObjectTaskArg
    communityKey: string

const asyncImportCommunityTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncImportCommunityTaskArg](argEncoded)
  try:
    let response = status_go.importCommunity(arg.communityKey)
    arg.finish(%* {
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncGetRevealedAccountsArg = ref object of QObjectTaskArg
    communityId: string
    memberPubkey: string

const asyncGetRevealedAccountsForMemberTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetRevealedAccountsArg](argEncoded)
  try:
    let response = status_go.getRevealedAccountsForMember(arg.communityId, arg.memberPubkey)
    arg.finish(%* {
      "communityId": arg.communityId,
      "memberPubkey": arg.memberPubkey,
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "memberPubkey": arg.memberPubkey,
      "error": e.msg,
    })

const asyncGetRevealedAccountsForAllMembersTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetRevealedAccountsArg](argEncoded)
  try:
    let response = status_go.getRevealedAccountsForAllMembers(arg.communityId)
    arg.finish(%* {
      "communityId": arg.communityId,
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "error": e.msg,
    })

type
  AsyncReevaluateCommunityMembersPermissionsArg = ref object of QObjectTaskArg
    communityId: string

const asyncReevaluateCommunityMembersPermissionsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncReevaluateCommunityMembersPermissionsArg](argEncoded)
  try:
    let response = status_go.reevaluateCommunityMembersPermissions(arg.communityId)
    arg.finish(%* {
      "communityId": arg.communityId,
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "error": e.msg,
    })


type
  AsyncSetCommunityShardArg = ref object of QObjectTaskArg
    communityId: string
    shardIndex: int

const asyncSetCommunityShardTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncSetCommunityShardArg](argEncoded)
  try:
    let response = status_go.setCommunityShard(arg.communityId, arg.shardIndex)
    arg.finish(%* {
      "communityId": arg.communityId,
      "response": response,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "error": e.msg,
    })
