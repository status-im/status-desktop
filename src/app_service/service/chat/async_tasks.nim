#################################################
# Async get chats (channel groups)
#################################################
type
  AsyncGetChatsTaskArg = ref object of QObjectTaskArg

const asyncGetChatsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetChatsTaskArg](argEncoded)

  let response = status_chat.getChats()

  let responseJson = %*{
    "channelGroups": response.result
  }
  arg.finish(responseJson)
