import ../types/[chat, community]

export chat, community

proc findIndexById*(self: seq[Chat], id: string): int =
  result = -1
  var idx = -1
  for item in self:
    inc idx
    if(item.id == id):
      result = idx
      break

proc findIndexById*(self: seq[Community], id: string): int =
  result = -1
  var idx = -1
  for item in self:
    inc idx
    if(item.id == id):
      result = idx
      break

proc findIndexById*(self: seq[CommunityMembershipRequest], id: string): int =
  result = -1
  var idx = -1
  for item in self:
    inc idx
    if(item.id == id):
      result = idx
      break

proc findIndexById*(self: seq[CommunityCategory], id: string): int =
  result = -1
  var idx = -1
  for item in self:
    inc idx
    if(item.id == id):
      result = idx
      break

proc isMember*(self: Chat, pubKey: string): bool =
  for member in self.members:
    if member.id == pubKey:
      return member.joined
  return false

proc isMemberButNotJoined*(self: Chat, pubKey: string): bool =
  for member in self.members:
    if member.id == pubKey:
      return not member.joined
  return false

proc contains*(self: Chat, pubKey: string): bool =
  for member in self.members:
    if member.id == pubKey: return true
  return false

proc isAdmin*(self: Chat, pubKey: string): bool =
  for member in self.members:
    if member.id == pubKey:
      return member.joined and member.admin
  return false

proc recalculateUnviewedMessages*(community: var Community) =
  var total = 0
  for chat in community.chats:
    total += chat.unviewedMessagesCount
  
  community.unviewedMessagesCount = total

proc recalculateMentions*(community: var Community) =
  var total = 0
  for chat in community.chats:
    total += chat.unviewedMentionsCount
    
  community.unviewedMentionsCount = total
