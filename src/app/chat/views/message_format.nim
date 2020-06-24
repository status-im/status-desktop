proc sectionIdentifier(message: Message): string =
  result = message.fromAuthor
  # Force section change, because group status messages are sent with the
  # same fromAuthor, and ends up causing the header to not be shown
  if message.contentType == ContentType.Group:
    result = "GroupChatMessage"



# See render-inline in status-react/src/status_im/ui/screens/chat/message/message.cljs
proc renderInline(elem: TextItem): string =
  case elem.textType:
  of "": result = elem.literal
  of "code": result = fmt("<span style=\"background-color: #1a356b; color: #FFFFFF\">{elem.literal}</span> ")
  of "emph": result = fmt("<span style=\"font-style: italic;\">{elem.literal}</span> ")
  of "strong": result = fmt("<span style=\"font-weight: bold;\">{elem.literal}</span> ")
  of "link": result = "TODO: write safe link here: " & elem.destination
  of "mention": result = elem.literal  

# See render-block in status-react/src/status_im/ui/screens/chat/message/message.cljs
proc renderBlock(message: Message): string =
  # TODO: find out how to extract the css styles
  for pMsg in message.parsedText:
    case pMsg.textType:
      of "paragraph": 
        result = "<p>"
        for children in pMsg.children:
          result = result & renderInline(children)
        result = result & "</p>"
      of "blockquote":
        # TODO: extract this from the theme somehow
        var color = if message.isCurrentUser: "#FFFFFF" else: "#666666" 
        result = result & fmt("<span style=\"color: {color}\">▍ ") & pMsg.literal[1 .. ^1] & "</span>"
      of "codeblock":
        result = "<table style=\"background-color: #1a356b;\"><tr><td style=\"padding: 5px;\"><code style=\"color: #ffffff\">" & pMsg.literal & "</code></td></tr></table>"
