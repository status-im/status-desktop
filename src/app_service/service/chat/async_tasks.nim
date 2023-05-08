#################################################
# Async get chats (channel groups)
#################################################
type
  AsyncGetChannelGroupsTaskArg = ref object of QObjectTaskArg

const asyncGetChannelGroupsTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncGetChannelGroupsTaskArg](argEncoded)

  let response = status_chat.getChannelGroups()

  let responseJson = %*{
    "channelGroups": response.result
  }
  arg.finish(responseJson)
