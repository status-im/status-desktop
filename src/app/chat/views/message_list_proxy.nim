import NimQml, strutils

import message_list
import status/[status]
import status/chat/[message]

QtObject:
  type
    MessageListProxyModel* = ref object of ChatMessageList
      sourceMessages: seq[Message]

  proc delete(self: MessageListProxyModel) =
    self.ChatMessageList.delete

  proc setup(self: MessageListProxyModel, status: Status) =
    self.ChatMessageList.setup("", status, false)

  proc newMessageListProxyModel*(status: Status): MessageListProxyModel =
    new(result, delete)
    result.setup(status)

  proc setSourceMessages*(self: MessageListProxyModel, messages: seq[Message]) =
    ## Sets source messages which will be filtered.
    self.sourceMessages = messages

  proc setFilter*(self: MessageListProxyModel, filter: string, caseSensitive: bool) =
    ## This proc filters messages that contain passed "filter" from the previously 
    ## set source model, respecting case sensitivity or not, based on the passed 
    ## "caseSensitive" parameter.

    self.clear(false)

    if (filter.len == 0):
      return

    let pattern  = if(caseSensitive): filter else: filter.toLowerAscii

    var matchedMessages: seq[Message] = @[]
    for message in self.sourceMessages:
      if (caseSensitive and message.text.contains(pattern) or 
      not caseSensitive and message.text.toLowerAscii.contains(pattern)):
          matchedMessages.add(message)

    if (matchedMessages.len == 0):
      return

    self.add(matchedMessages)

  proc setFilteredMessages*(self: MessageListProxyModel, messages: seq[Message]) =
    ## Sets filtered messages. Messages passed to this proc will be immediately
    ## added to the view model and displayed to user. Method is convenient for 
    ## displaying already filtered messages (for example filtered response from DB)
    self.clear(false)
    self.add(messages)

