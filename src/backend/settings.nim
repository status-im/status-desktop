import json
import ./core, ./response_type, ../app_service/common/utils

export response_type

proc getSettings*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_getSettings")

proc saveSettings*(key: string, value: string | JsonNode | bool | int | int64): RpcResponse[JsonNode] =
  let payload = %* [key, value]
  result = core.callPrivateRPC("settings_saveSetting", payload)

proc getAllowNotifications*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetAllowNotifications")

proc setAllowNotifications*(value: bool): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsSetAllowNotifications", %* [value])

proc getOneToOneChats*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetOneToOneChats")

proc setOneToOneChats*(value: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsSetOneToOneChats", %* [value])

proc getGroupChats*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetGroupChats")

proc setGroupChats*(value: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsSetGroupChats", %* [value])

proc getPersonalMentions*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetPersonalMentions")

proc setPersonalMentions*(value: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsSetPersonalMentions", %* [value])

proc getGlobalMentions*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetGlobalMentions")

proc setGlobalMentions*(value: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsSetGlobalMentions", %* [value])

proc getAllMessages*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetAllMessages")

proc setAllMessages*(value: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsSetAllMessages", %* [value])

proc getContactRequests*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetContactRequests")

proc setContactRequests*(value: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsSetContactRequests", %* [value])

proc getSoundEnabled*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetSoundEnabled")

proc setSoundEnabled*(value: bool): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsSetSoundEnabled", %* [value])

proc getVolume*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetVolume")

proc setVolume*(value: int): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsSetVolume", %* [value])

proc getMessagePreview*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetMessagePreview")

proc setMessagePreview*(value: int): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsSetMessagePreview", %* [value])

proc getExemptionMuteAllMessages*(id: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetExMuteAllMessages", %* [id])

proc getExemptionPersonalMentions*(id: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetExPersonalMentions", %* [id])

proc getExemptionGlobalMentions*(id: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetExGlobalMentions", %* [id])

proc getExemptionOtherMessages*(id: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_notificationsGetExOtherMessages", %* [id])

proc setExemptions*(id: string, muteAllMessages: bool, personalMentions: string, globalMentions: string,
  otherMessages: string): RpcResponse[JsonNode] =
  let payload = %* [id, muteAllMessages, personalMentions, globalMentions, otherMessages]
  return core.callPrivateRPC("settings_notificationsSetExemptions", payload)

proc deleteExemptions*(id: string): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_deleteExemptions", %* [id])

proc mnemonicWasShown*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_mnemonicWasShown")

proc lastTokensUpdate*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_lastTokensUpdate")

proc backupPath*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_backupPath")

proc messagesBackupEnabled*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_messagesBackupEnabled")

proc thirdpartyServicesEnabled*(): RpcResponse[JsonNode] =
  return core.callPrivateRPC("settings_thirdpartyServicesEnabled")
