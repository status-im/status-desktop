import json
import core
import response_type

export response_type

proc createOneToOneChat*(communityID: string, id: string, ensName: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityID, id, ensName]

  return core.callPrivateRPC("chat_createOneToOneChat", payload)

proc createGroupChat*(communityID: string, name: string, members: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityID, name, members]

  return core.callPrivateRPC("chat_createGroupChat", payload)

proc createGroupChatFromInvitation*(name: string, chatID: string, adminPK: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [name, chatID, adminPK]

  return core.callPrivateRPC("chat_createGroupChatFromInvitation", payload)

proc leaveChat*(communityID: string, chatID: string, remove: bool): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityID, chatID, remove]

  return core.callPrivateRPC("chat_leaveChat", payload)

proc addMembers*(communityID: string, chatID: string, members: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityID, chatID, members]

  return core.callPrivateRPC("chat_addMembers", payload)

proc removeMember*(communityID: string, chatID: string, member: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityID, chatID, member]

  return core.callPrivateRPC("chat_removeMember", payload)

proc makeAdmin*(communityID: string, chatID: string, member: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityID, chatID, member]

  return core.callPrivateRPC("chat_makeAdmin", payload)

proc renameChat*(communityID: string, chatID: string, name: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityID, chatID, name]

  return core.callPrivateRPC("chat_renameChat", payload)

proc sendGroupChatInvitationRequest*(communityID: string, chatID: string, adminPK: string, message: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityID, chatID, adminPK, message]

  return core.callPrivateRPC("chat_sendGroupChatInvitationRequest", payload)

proc getGroupChatInvitations*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* []

  return core.callPrivateRPC("chat_getGroupChatInvitations", payload)

proc sendGroupChatInvitationRejection*(invitationRequestID: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [invitationRequestID]

  return core.callPrivateRPC("chat_sendGroupChatInvitationRejection", payload)

proc startGroupChat*(communityID: string, name: string, members: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [communityID, name, members]

  return core.callPrivateRPC("chat_startGroupChat", payload)
