import sequtils

proc sectionIdentifier(message: Message): string =
  result = message.fromAuthor
  # Force section change, because group status messages are sent with the
  # same fromAuthor, and ends up causing the header to not be shown
  if message.contentType == ContentType.Group:
    result = "GroupChatMessage"

proc mention(self: ChatMessageList, pubKey: string): string =
  if self.status.chat.contacts.hasKey(pubKey):
    return ens.userNameOrAlias(self.status.chat.contacts[pubKey], true)
  generateAlias(pubKey)


# See render-inline in status-react/src/status_im/ui/screens/chat/message/message.cljs
proc renderInline(self: ChatMessageList, elem: TextItem): string =
  case elem.textType:
  of "": result = elem.literal
  of "code": result = fmt("<code>{elem.literal.strip}</code> ")
  of "emph": result = fmt("<em>{elem.literal}</em> ")
  of "strong": result = fmt("<strong>{elem.literal}</strong> ")
  of "link": result = elem.destination
  of "mention": result = fmt("<a href=\"//{elem.literal}\" class=\"mention\">{self.mention(elem.literal)}</a> ")
  of "status-tag": result = fmt("<a href=\"#{elem.literal}\" class=\"status-tag\">{elem.literal}</a> ")

# See render-block in status-react/src/status_im/ui/screens/chat/message/message.cljs
proc renderBlock(self: ChatMessageList, message: Message): string =
  for pMsg in message.parsedText:
    case pMsg.textType:
      of "paragraph": 
        result = result & "<p>"
        for children in pMsg.children:
          result = result & self.renderInline(children)
        result = result & "</p>"
      of "blockquote":
        result = result & pMsg.literal.strip.split("\n").mapIt("<span>▍ " & it & "</span>").join("<br />")
      of "codeblock":
        result = result & "<code>" & pMsg.literal.strip & "</code>"
    result = result.strip()
    
