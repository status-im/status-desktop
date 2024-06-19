#################################################
# Async get chats
#################################################

type
  AsyncGetActiveChatsTaskArg = ref object of QObjectTaskArg

proc asyncGetActiveChatsTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetActiveChatsTaskArg](argEncoded)
  try:
    let response = status_chat.getActiveChats()

    arg.finish(%*{
      "chats": response.result,
      "error": response.error,
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
    })

type
  AsyncCheckChannelPermissionsTaskArg = ref object of QObjectTaskArg
    communityId: string
    chatId: string

proc asyncCheckChannelPermissionsTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckChannelPermissionsTaskArg](argEncoded)
  try:
    let response = status_communities.checkCommunityChannelPermissions(arg.communityId, arg.chatId).result

    arg.finish(%* {
      "response": response,
      "communityId": arg.communityId,
      "chatId": arg.chatId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "chatId": arg.chatId,
      "error": e.msg,
    })

type
  AsyncCheckAllChannelsPermissionsTaskArg = ref object of QObjectTaskArg
    communityId: string
    addresses: seq[string]

proc asyncCheckAllChannelsPermissionsTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncCheckAllChannelsPermissionsTaskArg](argEncoded)
  try:
    let result = status_communities.checkAllCommunityChannelsPermissions(arg.communityId, arg.addresses).result
    let allChannelsPermissions = result.toCheckAllChannelsPermissionsResponseDto()
    arg.finish(%* {
      "response": allChannelsPermissions,
      "communityId": arg.communityId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "communityId": arg.communityId,
      "error": e.msg,
    })

type
  AsyncSendMessageTaskArg = ref object of QObjectTaskArg
    chatId: string
    processedMsg: string
    replyTo: string
    contentType: int
    preferredUsername: string
    communityId: string
    standardLinkPreviews: JsonNode
    statusLinkPreviews: JsonNode

const asyncSendMessageTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncSendMessageTaskArg](argEncoded)
  try:
    
    let response = status_chat.sendChatMessage(
      arg.chatId,
      arg.processedMsg,
      arg.replyTo,
      arg.contentType,
      arg.preferredUsername,
      arg.standardLinkPreviews,
      arg.statusLinkPreviews,
      arg.communityId)

    arg.finish(%* {
      "response": response,
      "chatId": arg.chatId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "chatId": arg.chatId,
    })

type
  AsyncSendImagesTaskArg = ref object of QObjectTaskArg
    chatId: string
    imagePathsAndDataJson: string
    tempDir: string
    msg: string
    replyTo: string
    preferredUsername: string
    linkPreviews: JsonNode

const asyncSendImagesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncSendImagesTaskArg](argEncoded)
  try:
    var images = Json.decode(arg.imagePathsAndDataJson, seq[string])
    var imagePaths: seq[string] = @[]

    for imagePathOrSource in images.mitems:
      let imagePath = image_resizer(imagePathOrSource, 2000, arg.tempDir)
      if imagePath != "":
        imagePaths.add(imagePath)

    let response = status_chat.sendImages(arg.chatId, imagePaths, arg.msg, arg.replyTo, arg.preferredUsername,
      arg.linkPreviews)

    for imagePath in imagePaths:
      removeFile(imagePath)

    arg.finish(%* {
      "response": response,
      "chatId": arg.chatId,
      "error": "",
    })
  except Exception as e:
    arg.finish(%* {
      "error": e.msg,
      "chatId": arg.chatId,
    })
