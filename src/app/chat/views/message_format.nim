import NimQml, Tables, sets, json, sugar, re
import ../../../status/status
import ../../../status/accounts
import ../../../status/chat
import ../../../status/chat/[message,stickers]
import ../../../status/profile/profile
import ../../../status/ens
import strformat, strutils, sequtils

let NEW_LINE = re"\n|\r"

proc sectionIdentifier*(message: Message): string =
  result = message.fromAuthor
  # Force section change, because group status messages are sent with the
  # same fromAuthor, and ends up causing the header to not be shown
  if message.contentType == ContentType.Group:
    result = "GroupChatMessage"

proc mention*(pubKey: string, contacts: Table[string, Profile]): string =
  if contacts.hasKey(pubKey):
    return ens.userNameOrAlias(contacts[pubKey], true)
  generateAlias(pubKey)


# See render-inline in status-react/src/status_im/ui/screens/chat/message/message.cljs
proc renderInline*(elem: TextItem, contacts: Table[string, Profile]): string =
  let value = escape_html(elem.literal).multiReplace(("\r\n", "<br/>")).multiReplace(("\n", "<br/>")).multiReplace(("  ", "&nbsp;&nbsp;"))
  case elem.textType:
  of "": result = value
  of "code": result = fmt("<code>{value}</code>")
  of "emph": result = fmt("<em>{value}</em>")
  of "strong": result = fmt("<strong>{value}</strong>")
  of "strong-emph": result = fmt(" <strong><em>{value}</em></strong> ")
  of "link": result = fmt("{elem.destination}")
  of "mention": result = fmt("<a href=\"//{value}\" class=\"mention\">{mention(value, contacts)}</a>")
  of "status-tag": result = fmt("<a href=\"#{value}\" class=\"status-tag\">#{value}</a>")
  of "del": result = fmt("<del>{value}</del>")
  else: result = fmt(" {value} ")

# See render-block in status-react/src/status_im/ui/screens/chat/message/message.cljs
proc renderBlock*(message: Message, contacts: Table[string, Profile]): string =
  for pMsg in message.parsedText:
    case pMsg.textType:
      of "paragraph": 
        result = result & "<p>"
        for children in pMsg.children:
          result = result & renderInline(children, contacts)
        result = result & "</p>"
      of "blockquote":
        var
          blockquote = escape_html(pMsg.literal)
          lines = toSeq(blockquote.split(NEW_LINE))
        for i in 0..(lines.len - 1):
          if i + 1 >= lines.len:
            continue
          if lines[i + 1] != "":
            lines[i] = lines[i] & "<br/>"
        blockquote = lines.join("")
        result = result & fmt(
          "<table class=\"blockquote\">" &
            "<tr>" &
              "<td class=\"quoteline\" valign=\"middle\"></td>" &
              "<td>{blockquote}</td>" &
            "</tr>" &
          "</table>")
      of "codeblock":
        result = result & "<code>" & escape_html(pMsg.literal) & "</code>"
    result = result.strip()
