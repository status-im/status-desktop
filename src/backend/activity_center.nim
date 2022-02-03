import json
import core, utils
import response_type

export response_type

proc rpcActivityCenterNotifications*(cursorVal: JsonNode, limit: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  callPrivateRPC("activityCenterNotifications".prefix, %* [cursorVal, limit])


proc markAllActivityCenterNotificationsRead*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  callPrivateRPC("markAllActivityCenterNotificationsRead".prefix, %*[])

proc markActivityCenterNotificationsRead*(ids: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  callPrivateRPC("markActivityCenterNotificationsRead".prefix, %*[ids])

proc markActivityCenterNotificationsUnread*(ids: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  callPrivateRPC("markActivityCenterNotificationsUnread".prefix, %*[ids])

proc acceptActivityCenterNotifications*(ids: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  callPrivateRPC("acceptActivityCenterNotifications".prefix, %*[ids])

proc dismissActivityCenterNotifications*(ids: seq[string]): RpcResponse[JsonNode] {.raises: [Exception].} =
  result =  callPrivateRPC("dismissActivityCenterNotifications".prefix, %*[ids])

proc unreadActivityCenterNotificationsCount*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  callPrivateRPC("unreadActivityCenterNotificationsCount".prefix, %*[])