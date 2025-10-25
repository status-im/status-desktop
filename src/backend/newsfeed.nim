from ./gen import rpc

proc enabled*(): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_enabled")

proc rssEnabled*(): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_rssEnabled")

proc notificationsEnabled*(): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_notificationsEnabled")

proc toggleNewsFeedEnabled*(value: bool): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_toggleNewsFeedEnabled", %*[value])

proc toggleNewsRSSEnabled*(value: bool): RpcResponse[JsonNode] =
    return core.callPrivateRPC("newsfeed_toggleNewsRSSEnabled", %*[ value ])