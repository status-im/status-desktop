import NimQml, Tables, std/wrapnils
import ../../../status/[chat/chat, status]
import community_chats

QtObject:
  type CommunityItemView* = ref object of QObject
    communityItem*: Community
    chats*: CommunityChatsList
    status*: Status

  proc setup(self: CommunityItemView) =
    self.QObject.setup

  proc delete*(self: CommunityItemView) =
    if not self.chats.isNil: self.chats.delete
    self.QObject.delete

  proc newCommunityItemView*(status: Status): CommunityItemView =
    new(result, delete)
    result = CommunityItemView()
    result.status = status
    result.chats = newCommunityChatsView(status)
    result.setup

  proc setCommunityItem*(self: CommunityItemView, communityItem: Community) =
    self.communityItem = communityItem
    self.chats.setChats(communityItem.chats)

  proc id*(self: CommunityItemView): string {.slot.} = result = ?.self.communityItem.id
  
  QtProperty[string] id:
    read = id

  proc name*(self: CommunityItemView): string {.slot.} = result = ?.self.communityItem.name
  
  QtProperty[string] name:
    read = name

  proc description*(self: CommunityItemView): string {.slot.} = result = ?.self.communityItem.description
  
  QtProperty[string] description:
    read = description

  proc access*(self: CommunityItemView): int {.slot.} = result = ?.self.communityItem.access
  
  QtProperty[int] access:
    read = access

  proc admin*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.admin
  
  QtProperty[bool] admin:
    read = admin

  proc joined*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.joined
  
  QtProperty[bool] joined:
    read = joined

  proc verified*(self: CommunityItemView): bool {.slot.} = result = ?.self.communityItem.verified
  
  QtProperty[bool] verified:
    read = verified

  proc getChats*(self: CommunityItemView): QVariant {.slot.} =
    result = newQVariant(self.chats)

  QtProperty[QVariant] chats:
    read = getChats
