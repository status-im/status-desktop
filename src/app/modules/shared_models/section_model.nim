import NimQml, Tables, strutils, stew/shims/strformat

import json

import section_item, member_model, member_item
import ../main/communities/tokens/models/[token_item, token_model]

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    SectionType
    Name
    MemberRole
    IsControlNode
    Description
    IntroMessage
    OutroMessage
    Image
    BannerImageData
    Icon
    Color
    Tags
    HasNotification
    NotificationsCount
    Active
    Enabled
    Joined
    Spectated
    IsMember
    CanJoin
    CanManageUsers
    CanRequestAccess
    Access
    EnsOnly
    Muted
    MembersModel
    HistoryArchiveSupportEnabled
    PinMessageAllMembersEnabled
    BannedMembersModel
    Encrypted
    CommunityTokensModel
    PendingMemberRequestsModel
    DeclinedMemberRequestsModel
    AmIBanned
    PubsubTopic
    PubsubTopicKey
    ShardIndex
    IsPendingOwnershipRequest

QtObject:
  type
    SectionModel* = ref object of QAbstractListModel
      items: seq[SectionItem]

  proc delete(self: SectionModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: SectionModel) =
    self.QAbstractListModel.setup

  proc newModel*(): SectionModel =
    new(result, delete)
    result.setup

  proc `$`*(self: SectionModel): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """

  proc countChanged(self: SectionModel) {.signal.}

  proc getCount(self: SectionModel): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: SectionModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: SectionModel): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.SectionType.int:"sectionType",
      ModelRole.Name.int:"name",
      ModelRole.MemberRole.int: "memberRole",
      ModelRole.IsControlNode.int: "isControlNode",
      ModelRole.Description.int:"description",
      ModelRole.IntroMessage.int:"introMessage",
      ModelRole.OutroMessage.int:"outroMessage",
      ModelRole.Image.int:"image",
      ModelRole.BannerImageData.int:"bannerImageData",
      ModelRole.Icon.int:"icon",
      ModelRole.Color.int:"color",
      ModelRole.Tags.int:"tags",
      ModelRole.HasNotification.int:"hasNotification",
      ModelRole.NotificationsCount.int:"notificationsCount",
      ModelRole.Active.int:"active",
      ModelRole.Enabled.int:"enabled",
      ModelRole.Joined.int:"joined",
      ModelRole.Spectated.int:"spectated",
      ModelRole.IsMember.int:"isMember",
      ModelRole.CanJoin.int:"canJoin",
      ModelRole.CanManageUsers.int:"canManageUsers",
      ModelRole.CanRequestAccess.int:"canRequestAccess",
      ModelRole.Access.int:"access",
      ModelRole.EnsOnly.int:"ensOnly",
      ModelRole.Muted.int:"muted",
      ModelRole.MembersModel.int:"members",
      ModelRole.HistoryArchiveSupportEnabled.int:"historyArchiveSupportEnabled",
      ModelRole.PinMessageAllMembersEnabled.int:"pinMessageAllMembersEnabled",
      ModelRole.BannedMembersModel.int:"bannedMembers",
      ModelRole.Encrypted.int:"encrypted",
      ModelRole.CommunityTokensModel.int:"communityTokens",
      ModelRole.PendingMemberRequestsModel.int:"pendingMemberRequests",
      ModelRole.DeclinedMemberRequestsModel.int:"declinedMemberRequests",
      ModelRole.AmIBanned.int:"amIBanned",
      ModelRole.PubsubTopic.int:"pubsubTopic",
      ModelRole.PubsubTopicKey.int:"pubsubTopicKey",
      ModelRole.ShardIndex.int:"shardIndex",
      ModelRole.IsPendingOwnershipRequest.int:"isPendingOwnershipRequest",
    }.toTable

  method data(self: SectionModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Id:
      result = newQVariant(item.id)
    of ModelRole.SectionType:
      result = newQVariant(item.sectionType.int)
    of ModelRole.Name:
      result = newQVariant(item.name)
    of ModelRole.MemberRole:
      result = newQVariant(item.memberRole.int)
    of ModelRole.IsControlNode:
      result = newQVariant(item.isControlNode)
    of ModelRole.Description:
      result = newQVariant(item.description)
    of ModelRole.IntroMessage:
      result = newQVariant(item.introMessage)
    of ModelRole.OutroMessage:
      result = newQVariant(item.outroMessage)
    of ModelRole.Image:
      result = newQVariant(item.image)
    of ModelRole.BannerImageData:
      result = newQVariant(item.bannerImageData)
    of ModelRole.Icon:
      result = newQVariant(item.icon)
    of ModelRole.Color:
      result = newQVariant(item.color)
    of ModelRole.Tags:
      result = newQVariant(item.tags)
    of ModelRole.HasNotification:
      result = newQVariant(item.hasNotification)
    of ModelRole.NotificationsCount:
      result = newQVariant(item.notificationsCount)
    of ModelRole.Active:
      result = newQVariant(item.active)
    of ModelRole.Enabled:
      result = newQVariant(item.enabled)
    of ModelRole.Joined:
      result = newQVariant(item.joined)
    of ModelRole.Spectated:
      result = newQVariant(item.spectated)
    of ModelRole.IsMember:
      result = newQVariant(item.isMember)
    of ModelRole.CanJoin:
      result = newQVariant(item.canJoin)
    of ModelRole.CanManageUsers:
      result = newQVariant(item.canManageUsers)
    of ModelRole.CanRequestAccess:
      result = newQVariant(item.canRequestAccess)
    of ModelRole.Access:
      result = newQVariant(item.access)
    of ModelRole.EnsOnly:
      result = newQVariant(item.ensOnly)
    of ModelRole.Muted:
      result = newQVariant(item.muted)
    of ModelRole.MembersModel:
      result = newQVariant(item.members)
    of ModelRole.HistoryArchiveSupportEnabled:
      result = newQVariant(item.historyArchiveSupportEnabled)
    of ModelRole.PinMessageAllMembersEnabled:
      result = newQVariant(item.pinMessageAllMembersEnabled)
    of ModelRole.BannedMembersModel:
      result = newQVariant(item.bannedMembers)
    of ModelRole.Encrypted:
      result = newQVariant(item.encrypted)
    of ModelRole.CommunityTokensModel:
      result = newQVariant(item.communityTokens)
    of ModelRole.PendingMemberRequestsModel:
      result = newQVariant(item.pendingMemberRequests)
    of ModelRole.DeclinedMemberRequestsModel:
      result = newQVariant(item.declinedMemberRequests)
    of ModelRole.AmIBanned:
      result = newQVariant(item.amIBanned)
    of ModelRole.PubsubTopic:
      result = newQVariant(item.pubsubTopic)
    of ModelRole.PubsubTopicKey:
      result = newQVariant(item.pubsubTopicKey)
    of ModelRole.ShardIndex:
      result = newQVariant(item.shardIndex)
    of ModelRole.IsPendingOwnershipRequest:
      result = newQVariant(item.isPendingOwnershipRequest)

  proc itemExists*(self: SectionModel, id: string): bool =
    for it in self.items:
      if(it.id == id):
        return true
    return false

  proc addItem*(self: SectionModel, item: SectionItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    if not self.itemExists(item.id):
      self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
      self.items.add(item)
      self.endInsertRows()

      self.countChanged()

  proc addItem*(self: SectionModel, item: SectionItem, index: int) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    if not self.itemExists(item.id):
      self.beginInsertRows(parentModelIndex, index, index)
      self.items.insert(item, index)
      self.endInsertRows()

      self.countChanged()

  proc addItems*(self: SectionModel, items: seq[SectionItem]) =
    if items.len == 0:
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    let first = self.items.len
    let last = first + items.len - 1
    self.beginInsertRows(parentModelIndex, first, last)
    self.items.add(items)
    self.endInsertRows()
    self.countChanged()

  proc getItemIndex*(self: SectionModel, id: string): int =
    var i = 0
    for item in self.items:
      if item.id == id:
        return i
      i.inc()
    return -1

  proc removeItem*(self: SectionModel, itemId: string) =
    let index = self.getItemIndex(itemId)
    if (index == -1):
      return

    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginRemoveRows(parentModelIndex, index, index)
    self.items.delete(index)
    self.endRemoveRows()

    self.countChanged()

  proc setMuted*(self: SectionModel, id: string, muted: bool) = 
    let index = self.getItemIndex(id)
    if index == -1:
      return

    if self.items[index].muted == muted:
      return

    self.items[index].muted = muted 
    let dataIndex = self.createIndex(index, 0, nil)
    defer: dataIndex.delete
    self.dataChanged(dataIndex, dataIndex, @[ModelRole.Muted.int])

  proc editItem*(self: SectionModel, item: SectionItem) =
    let index = self.getItemIndex(item.id)
    if index == -1:
      return
    
    var roles: seq[int] = @[]

    if self.items[index].name != item.name:
      self.items[index].name = item.name
      roles.add(ModelRole.Name.int)

    if self.items[index].memberRole != item.memberRole:
      self.items[index].memberRole = item.memberRole
      roles.add(ModelRole.MemberRole.int)

    if self.items[index].isControlNode != item.isControlNode:
      self.items[index].isControlNode = item.isControlNode
      roles.add(ModelRole.IsControlNode.int)

    if self.items[index].description != item.description:
      self.items[index].description = item.description
      roles.add(ModelRole.Description.int)

    if self.items[index].introMessage != item.introMessage:
      self.items[index].introMessage = item.introMessage
      roles.add(ModelRole.IntroMessage.int)

    if self.items[index].outroMessage != item.outroMessage:
      self.items[index].outroMessage = item.outroMessage
      roles.add(ModelRole.OutroMessage.int)

    if self.items[index].image != item.image:
      self.items[index].image = item.image
      roles.add(ModelRole.Image.int)

    if self.items[index].bannerImageData != item.bannerImageData:
      self.items[index].bannerImageData = item.bannerImageData
      roles.add(ModelRole.BannerImageData.int)

    if self.items[index].icon != item.icon:
      self.items[index].icon = item.icon
      roles.add(ModelRole.Icon.int)

    if self.items[index].color != item.color:
      self.items[index].color = item.color
      roles.add(ModelRole.Color.int)

    if self.items[index].tags != item.tags:
      self.items[index].tags = item.tags
      roles.add(ModelRole.Tags.int)

    if self.items[index].hasNotification != item.hasNotification:
      self.items[index].hasNotification = item.hasNotification
      roles.add(ModelRole.HasNotification.int)

    if self.items[index].notificationsCount != item.notificationsCount:
      self.items[index].notificationsCount = item.notificationsCount
      roles.add(ModelRole.NotificationsCount.int)

    if self.items[index].active != item.active:
      self.items[index].active = item.active
      roles.add(ModelRole.Active.int)

    if self.items[index].enabled != item.enabled:
      self.items[index].enabled = item.enabled
      roles.add(ModelRole.Enabled.int)

    if self.items[index].joined != item.joined:
      self.items[index].joined = item.joined
      roles.add(ModelRole.Joined.int)

    if self.items[index].spectated != item.spectated:
      self.items[index].spectated = item.spectated
      roles.add(ModelRole.Spectated.int)

    if self.items[index].isMember != item.isMember:
      self.items[index].isMember = item.isMember
      roles.add(ModelRole.IsMember.int)

    if self.items[index].canJoin != item.canJoin:
      self.items[index].canJoin = item.canJoin
      roles.add(ModelRole.CanJoin.int)

    if self.items[index].canManageUsers != item.canManageUsers:
      self.items[index].canManageUsers = item.canManageUsers
      roles.add(ModelRole.CanManageUsers.int)

    if self.items[index].canRequestAccess != item.canRequestAccess:
      self.items[index].canRequestAccess = item.canRequestAccess
      roles.add(ModelRole.CanRequestAccess.int)

    if self.items[index].access != item.access:
      self.items[index].access = item.access
      roles.add(ModelRole.Access.int)

    if self.items[index].ensOnly != item.ensOnly:
      self.items[index].ensOnly = item.ensOnly
      roles.add(ModelRole.EnsOnly.int)

    if self.items[index].muted != item.muted:
      self.items[index].muted = item.muted
      roles.add(ModelRole.Muted.int)

    if self.items[index].historyArchiveSupportEnabled != item.historyArchiveSupportEnabled:
      self.items[index].historyArchiveSupportEnabled = item.historyArchiveSupportEnabled
      roles.add(ModelRole.HistoryArchiveSupportEnabled.int)

    if self.items[index].pinMessageAllMembersEnabled != item.pinMessageAllMembersEnabled:
      self.items[index].pinMessageAllMembersEnabled = item.pinMessageAllMembersEnabled
      roles.add(ModelRole.PinMessageAllMembersEnabled.int)

    if self.items[index].encrypted != item.encrypted:
      self.items[index].encrypted = item.encrypted
      roles.add(ModelRole.Encrypted.int)

    if self.items[index].pubsubTopic != item.pubsubTopic:
      self.items[index].pubsubTopic = item.pubsubTopic
      roles.add(ModelRole.PubsubTopic.int)

    if self.items[index].pubsubTopicKey != item.pubsubTopicKey:
      self.items[index].pubsubTopicKey = item.pubsubTopicKey
      roles.add(ModelRole.PubsubTopicKey.int)

    if self.items[index].shardIndex != item.shardIndex:
      self.items[index].shardIndex = item.shardIndex
      roles.add(ModelRole.ShardIndex.int)

    if self.items[index].isPendingOwnershipRequest != item.isPendingOwnershipRequest:
      self.items[index].isPendingOwnershipRequest = item.isPendingOwnershipRequest
      roles.add(ModelRole.IsPendingOwnershipRequest.int)

    self.items[index].members.updateToTheseItems(item.members.getItems())
    self.items[index].bannedMembers.updateToTheseItems(item.bannedMembers.getItems())
    self.items[index].pendingMemberRequests.updateToTheseItems(item.pendingMemberRequests.getItems())
    self.items[index].declinedMemberRequests.updateToTheseItems(item.declinedMemberRequests.getItems())

    if roles.len == 0:
      return

    let dataIndex = self.createIndex(index, 0, nil)
    defer: dataIndex.delete
    self.dataChanged(dataIndex, dataIndex, roles)

  proc updateMemberItems*(
      self: SectionModel,
      pubKey: string,
      displayName: string,
      ensName: string,
      isEnsVerified: bool,
      localNickname: string,
      alias: string,
      icon: string,
      isContact: bool,
      isVerified: bool,
      isUntrustworthy: bool,
    ) =
    for item in self.items:
      # TODO refactor to use only one model https://github.com/status-im/status-desktop/issues/16433
      item.members.updateItem(
        pubKey,
        displayName,
        ensName,
        isEnsVerified,
        localNickname,
        alias,
        icon,
        isContact,
        isVerified,
        isUntrustworthy,
      )
      item.bannedMembers.updateItem(
        pubKey,
        displayName,
        ensName,
        isEnsVerified,
        localNickname,
        alias,
        icon,
        isContact,
        isVerified,
        isUntrustworthy,
      )
      item.pendingMemberRequests.updateItem(
        pubKey,
        displayName,
        ensName,
        isEnsVerified,
        localNickname,
        alias,
        icon,
        isContact,
        isVerified,
        isUntrustworthy,
      )
      item.declinedMemberRequests.updateItem(
        pubKey,
        displayName,
        ensName,
        isEnsVerified,
        localNickname,
        alias,
        icon,
        isContact,
        isVerified,
        isUntrustworthy,
      )

  proc getNthEnabledItem*(self: SectionModel, nth: int): SectionItem =
    if nth >= 0 and nth < self.items.len:
      var counter = 0
      for i in 0 ..< self.items.len:
        if self.items[i].enabled:
          if counter == nth:
            return self.items[i]
          else:
            counter = counter + 1
    return SectionItem()

  proc getItemById*(self: SectionModel, id: string): SectionItem =
    for it in self.items:
      if(it.id == id):
        return it

  proc getItemBySectionType*(self: SectionModel, sectionType: SectionType): SectionItem =
    for it in self.items:
      if(it.sectionType == sectionType):
        return it

  proc getItemEnabledBySectionType*(self: SectionModel, sectionType: int): bool {.slot.} =
    let item = self.getItemBySectionType((SectionType)sectionType)
    return not item.isEmpty() and item.enabled()

  proc setActiveSection*(self: SectionModel, id: string) =
    for i in 0 ..< self.items.len:
      if self.items[i].active:
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].active = false
        self.dataChanged(index, index, @[ModelRole.Active.int])

      if self.items[i].id == id:
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].active = true

        self.dataChanged(index, index, @[ModelRole.Active.int])

  proc sectionVisibilityUpdated*(self: SectionModel) {.signal.}

  proc notificationsCountChanged*(self: SectionModel) {.signal.}

  proc enableDisableSection(self: SectionModel, sectionType: SectionType, value: bool) =
    if sectionType != SectionType.Community:
      for i in 0 ..< self.items.len:
        if self.items[i].sectionType == sectionType:
          if self.items[i].enabled == value:
            continue
          let index = self.createIndex(i, 0, nil)
          defer: index.delete
          self.items[i].enabled = value
          self.dataChanged(index, index, @[ModelRole.Enabled.int])
    else:
      var topInd = -1
      var bottomInd = -1
      for i in 0 ..< self.items.len:
        if self.items[i].sectionType == sectionType:
          self.items[i].enabled = value
          if topInd == -1:
            topInd = i

          bottomInd = i

      let topIndex = self.createIndex(topInd, 0, nil)
      let bottomIndex = self.createIndex(bottomInd, 0, nil)
      defer: topIndex.delete
      defer: bottomIndex.delete
      self.dataChanged(topIndex, bottomIndex, @[ModelRole.Enabled.int])

    # This signal is emitted to update buttons visibility in the left navigation bar,
    # `dataChanged` signal doesn't do the job because of `DelegateModel` used in `StatusAppNavBar` component
    self.sectionVisibilityUpdated()

  proc enableSection*(self: SectionModel, sectionType: SectionType) =
    self.enableDisableSection(sectionType, true)

  proc disableSection*(self: SectionModel, sectionType: SectionType) =
    self.enableDisableSection(sectionType, false)

  proc isAMessengerItem*(item: SectionItem): bool =
    return item.sectionType == SectionType.Chat or item.sectionType == SectionType.Community

  # Count all mentions from all chat&community sections
  proc allMentionsCount*(self: SectionModel): int =
    for item in self.items:
      if item.isAMessengerItem():
        result += item.notificationsCount

  proc updateIsPendingOwnershipRequest*(self: SectionModel, id: string, isPending: bool) =
    for i in 0 ..< self.items.len:
      if self.items[i].id == id:
        let index = self.createIndex(i, 0, nil)
        defer: index.delete

        if self.items[i].isPendingOwnershipRequest == isPending:
          return

        self.items[i].setIsPendingOwnershipRequest(isPending)
        self.dataChanged(index, index, @[ModelRole.IsPendingOwnershipRequest.int])
        return

  proc updateNotifications*(self: SectionModel, id: string, hasNotification: bool, notificationsCount: int) =
    for i in 0 ..< self.items.len:
      if self.items[i].id == id:
        let index = self.createIndex(i, 0, nil)
        defer: index.delete

        var roles: seq[int] = @[]

        if self.items[i].hasNotification != hasNotification:
          self.items[i].hasNotification = hasNotification
          roles.add(ModelRole.HasNotification.int)

        if self.items[i].notificationsCount != notificationsCount:
          self.items[i].notificationsCount = notificationsCount
          roles.add(ModelRole.NotificationsCount.int)

        if roles.len == 0:
          return

        self.dataChanged(index, index, roles)
        self.notificationsCountChanged()
        return

  proc isThereASectionWithUnreadMessages*(self: SectionModel): bool =
    for item in self.items:
      if item.isAMessengerItem() and item.hasNotification == true:
        return true
    return false

  proc appendCommunityToken*(self: SectionModel, id: string, item: TokenItem) =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        defer: index.delete
        self.items[i].appendCommunityToken(item)
        return

  proc getSectionNameById*(self: SectionModel, sectionId: string): string {.slot.} =
    for item in self.items:
      if item.id == sectionId:
        return item.name
    
  proc getSectionByIdJson(self: SectionModel, sectionId: string): string {.slot.} =
    for item in self.items:
      if (item.id == sectionId):
        let jsonObj = %* {
          "id": item.id,
          "name": item.name,
          "memberRole": item.memberRole.int,
          "isControlNode": item.isControlNode,
          "description": item.description,
          "introMessage": item.introMessage,
          "outroMessage": item.outroMessage,
          "image": item.image,
          "bannerImageData": item.bannerImageData,
          "icon": item.icon,
          "color": item.color,
          "tags": item.tags,
          "hasNotification": item.hasNotification,
          "notificationsCount": item.notificationsCount,
          "active": item.active,
          "enabled": item.enabled,
          "joined": item.joined,
          "spectated": item.spectated,
          "canJoin": item.canJoin,
          "canManageUsers": item.canManageUsers,
          "canRequestAccess": item.canRequestAccess,
          "isMember": item.isMember,
          "amIBanned": item.amIBanned,
          "access": item.access,
          "ensOnly": item.ensOnly,
          "nbMembers": item.members.getCount(),
          "encrypted": item.encrypted,
          "pubsubTopic": item.pubsubTopic,
          "pubsubTopicKey": item.pubsubTopicKey,
          "shardIndex": item.shardIndex,
        }
        return $jsonObj

  proc setMembersAirdropAddress*(self: SectionModel, id: string, communityMembersAirdropAddress: Table[string, string]) = 
    let index = self.getItemIndex(id)
    if (index == -1):
      return

    for pubkey, airdropAddress in communityMembersAirdropAddress.pairs:
      self.items[index].members.setAirdropAddress(pubkey, airdropAddress)

  proc setTokenItems*(self: SectionModel, id: string, communityTokensItems: seq[TokenItem]) =
    let index = self.getItemIndex(id)
    if (index == -1):
      return

    self.items[index].communityTokens.setItems(communityTokensItems)

  proc addPendingMember*(self: SectionModel, communityId: string, memberItem: MemberItem) =
    let i = self.getItemIndex(communityId)
    if i == -1:
      return

    self.items[i].pendingMemberRequests.addItem(memberItem)

  proc removePendingMember*(self: SectionModel, communityId: string, memberId: string) =
    let i = self.getItemIndex(communityId)
    if i == -1:
      return

    self.items[i].pendingMemberRequests.removeItemById(memberId)
