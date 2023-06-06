import json
import ./core, ./response_type

export response_type

proc getSettings*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_getSettings")

proc saveSettings*(key: string, value: string | JsonNode | bool | int): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [key, value]
  result = core.callPrivateRPC("settings_saveSetting", payload)

proc getAllowNotifications*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetAllowNotifications")

proc setAllowNotifications*(value: bool): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetAllowNotifications", %* [value])

proc getOneToOneChats*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetOneToOneChats")

proc setOneToOneChats*(value: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetOneToOneChats", %* [value])

proc getGroupChats*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetGroupChats")

proc setGroupChats*(value: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetGroupChats", %* [value])

proc getPersonalMentions*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetPersonalMentions")

proc setPersonalMentions*(value: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetPersonalMentions", %* [value])

proc getGlobalMentions*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetGlobalMentions")

proc setGlobalMentions*(value: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetGlobalMentions", %* [value])

proc getAllMessages*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetAllMessages")

proc setAllMessages*(value: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetAllMessages", %* [value])

proc getContactRequests*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetContactRequests")

proc setContactRequests*(value: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetContactRequests", %* [value])

proc getIdentityVerificationRequests*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetIdentityVerificationRequests")

proc setIdentityVerificationRequests*(value: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetIdentityVerificationRequests", %* [value])

proc getSoundEnabled*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetSoundEnabled")

proc setSoundEnabled*(value: bool): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetSoundEnabled", %* [value])

proc getVolume*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetVolume")

proc setVolume*(value: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetVolume", %* [value])

proc getMessagePreview*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetMessagePreview")

proc setMessagePreview*(value: int): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsSetMessagePreview", %* [value])

proc getExemptionMuteAllMessages*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetExMuteAllMessages", %* [id])

proc getExemptionPersonalMentions*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetExPersonalMentions", %* [id])

proc getExemptionGlobalMentions*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetExGlobalMentions", %* [id])

proc getExemptionOtherMessages*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_notificationsGetExOtherMessages", %* [id])

proc setExemptions*(id: string, muteAllMessages: bool, personalMentions: string, globalMentions: string,
  otherMessages: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  let payload = %* [id, muteAllMessages, personalMentions, globalMentions, otherMessages]
  return core.callPrivateRPC("settings_notificationsSetExemptions", payload)

proc deleteExemptions*(id: string): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_deleteExemptions", %* [id])

proc addOrReplaceSocialLinks*(value: JsonNode): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_addOrReplaceSocialLinks", %* [value])

proc getSocialLinks*(): RpcResponse[JsonNode] {.raises: [Exception].} =
  return core.callPrivateRPC("settings_getSocialLinks")
