import json
import ./core, ./response_type

proc enabled*(): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_enabled")

proc rssEnabled*(): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_rSSEnabled")

proc notificationsEnabled*(): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_notificationsEnabled")

proc setEnabled*(value: bool): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_setEnabled", %*[value])

proc setRSSEnabled*(value: bool): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_setRSSEnabled", %*[ value ])

proc setNotificationsEnabled*(value: bool): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_setNotificationsEnabled", %*[ value ])