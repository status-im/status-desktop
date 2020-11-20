import NimQml, Tables
import ../../../status/chat/[chat, message]
import ../../../status/status
import ../../../status/ens
import ../../../status/accounts
import strutils

type
  CommunityRoles {.pure.} = enum
    Id = UserRole + 1,
    Name = UserRole + 2
    Description = UserRole + 3
    # Color = UserRole + 4
    Access = UserRole + 5
    Admin = UserRole + 6
    Joined = UserRole + 7
    Verified = UserRole + 8

QtObject:
  type
    CommunityList* = ref object of QAbstractListModel
      communities*: seq[Community]
      status: Status
      fetched*: bool

  proc setup(self: CommunityList) = self.QAbstractListModel.setup

  proc delete(self: CommunityList) = 
    self.communities = @[]
    self.QAbstractListModel.delete

  proc newCommunityList*(status: Status): CommunityList =
    new(result, delete)
    result.communities = @[]
    result.status = status
    result.setup()

  method rowCount*(self: CommunityList, index: QModelIndex = nil): int = self.communities.len

  method data(self: CommunityList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.communities.len:
      return

    let communityItem = self.communities[index.row]
    let communityItemRole = role.CommunityRoles
    case communityItemRole:
      of CommunityRoles.Name: result = newQVariant(communityItem.name)
      of CommunityRoles.Description: result = newQVariant(communityItem.description)
      of CommunityRoles.Id: result = newQVariant(communityItem.id)
      # of CommunityRoles.Color: result = newQVariant(communityItem.color)
      of CommunityRoles.Access: result = newQVariant(communityItem.access.int)
      of CommunityRoles.Admin: result = newQVariant(communityItem.admin.bool)
      of CommunityRoles.Joined: result = newQVariant(communityItem.joined.bool)
      of CommunityRoles.Verified: result = newQVariant(communityItem.verified.bool)

  method roleNames(self: CommunityList): Table[int, string] =
    {
      #CommunityRoles.Name.int:"name",
      CommunityRoles.Description.int:"description",
      CommunityRoles.Id.int: "id",
      # CommunityRoles.Color.int: "color",
      CommunityRoles.Access.int: "access",
      CommunityRoles.Admin.int: "admin",
      CommunityRoles.Verified.int: "verified",
      CommunityRoles.Joined.int: "joined"
    }.toTable

  proc setNewData*(self: CommunityList, communityList: seq[Community]) =
    self.beginResetModel()
    self.communities = communityList
    self.endResetModel()

  proc addCommunityItemToList*(self: CommunityList, community: Community) =
    self.beginInsertRows(newQModelIndex(), self.communities.len, self.communities.len)
    self.communities.add(community)
    self.endInsertRows()

  # proc removeChatItemFromList*(self: CommunityList, channel: string): int =
  #   let idx = self.communities.findIndexById(channel)
  #   self.beginRemoveRows(newQModelIndex(), idx, idx)
  #   self.communities.delete(idx)
  #   self.endRemoveRows()

  #   result = self.communities.len

  # proc getChannel*(self: CommunityList, index: int): Chat = self.communities[index]

  # proc getChannelById*(self: CommunityList, chatId: string): Chat =
  #   for chat in self.communities:
  #     if chat.id == chatId:
  #       return chat
  
  # proc getChannelByName*(self: CommunityList, name: string): Chat =
  #   for chat in self.communities:
  #     if chat.name == name:
  #       return chat

  # proc upsertChannel(self: CommunityList, channel: Chat): int =
  #   let idx = self.communities.findIndexById(channel.id)
  #   if idx == -1:
  #       if channel.isActive:
  #         # We only want to add a channel to the list if it is active
  #         # otherwise, we'll end up with zombie channels on the list
  #         result = self.addChatItemToList(channel)
  #       else:
  #         result = -1
  #   else:
  #     result = idx

  # proc getChannelColor*(self: CommunityList, name: string): string =
  #   let channel = self.getChannelByName(name)
  #   if (channel == nil): return
  #   return channel.color
