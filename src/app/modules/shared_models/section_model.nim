import NimQml, Tables, strutils, strformat

import section_item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    SectionType
    Name
    AmISectionAdmin
    Description
    Image
    Icon
    Color
    HasNotification
    NotificationsCount
    Active
    Enabled
    Joined
    IsMember
    CanJoin
    CanManageUsers
    CanRequestAccess
    Access
    EnsOnly
    MembersModel
    PendingRequestsToJoinModel

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
      ModelRole.AmISectionAdmin.int: "amISectionAdmin",
      ModelRole.Description.int:"description",
      ModelRole.Image.int:"image",
      ModelRole.Icon.int:"icon",
      ModelRole.Color.int:"color",
      ModelRole.HasNotification.int:"hasNotification",
      ModelRole.NotificationsCount.int:"notificationsCount",
      ModelRole.Active.int:"active",
      ModelRole.Enabled.int:"enabled",
      ModelRole.Joined.int:"joined",
      ModelRole.IsMember.int:"isMember",
      ModelRole.CanJoin.int:"canJoin",
      ModelRole.CanManageUsers.int:"canManageUsers",
      ModelRole.CanRequestAccess.int:"canRequestAccess",
      ModelRole.Access.int:"access",
      ModelRole.EnsOnly.int:"ensOnly",
      ModelRole.MembersModel.int:"members",
      ModelRole.PendingRequestsToJoinModel.int:"pendingRequestsToJoin",
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
    of ModelRole.AmISectionAdmin:
      result = newQVariant(item.amISectionAdmin)
    of ModelRole.Description:
      result = newQVariant(item.description)
    of ModelRole.Image:
      result = newQVariant(item.image)
    of ModelRole.Icon:
      result = newQVariant(item.icon)
    of ModelRole.Color:
      result = newQVariant(item.color)
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
    of ModelRole.MembersModel:
      result = newQVariant(item.members)
    of ModelRole.PendingRequestsToJoinModel:
      result = newQVariant(item.pendingRequestsToJoin)

  proc addItem*(self: SectionModel, item: SectionItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

    self.countChanged()

  proc addItem*(self: SectionModel, item: SectionItem, index: int) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, index, index)
    self.items.insert(item, index)
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

  proc editItem*(self: SectionModel, item: SectionItem) =
    let index = self.getItemIndex(item.id)
    if (index == -1):
      return

    self.items[index] = item
    let dataIndex = self.createIndex(index, 0, nil)
    self.dataChanged(dataIndex, dataIndex, @[
      ModelRole.Name.int,
      ModelRole.Description.int,
      ModelRole.Image.int,
      ModelRole.Icon.int,
      ModelRole.Color.int,
      ModelRole.HasNotification.int,
      ModelRole.NotificationsCount.int,
      ModelRole.IsMember.int,
      ModelRole.CanJoin.int,
      ModelRole.Joined.int,
      ModelRole.MembersModel.int,
      ModelRole.PendingRequestsToJoinModel.int
      ])

  proc getItemById*(self: SectionModel, id: string): SectionItem =
    for it in self.items:
      if(it.id == id):
        return it

  proc getItemBySectionType*(self: SectionModel, sectionType: SectionType): SectionItem =
    for it in self.items:
      if(it.sectionType == sectionType):
        return it

  proc setActiveSection*(self: SectionModel, id: string) =
    for i in 0 ..< self.items.len:
      if(self.items[i].active):
        let index = self.createIndex(i, 0, nil)
        self.items[i].active = false
        self.dataChanged(index, index, @[ModelRole.Active.int])

      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].active = true
        self.dataChanged(index, index, @[ModelRole.Active.int])

  proc sectionVisibilityUpdated*(self: SectionModel) {.signal.}

  proc enableDisableSection(self: SectionModel, sectionType: SectionType, value: bool) =
    if(sectionType != SectionType.Community):
      for i in 0 ..< self.items.len:
        if(self.items[i].sectionType == sectionType):
          let index = self.createIndex(i, 0, nil)
          self.items[i].enabled = value
          self.dataChanged(index, index, @[ModelRole.Enabled.int])
    else:
      var topInd = -1
      var bottomInd = -1
      for i in 0 ..< self.items.len:
        if(self.items[i].sectionType == sectionType):
          self.items[i].enabled = value
          if(topInd == -1):
            topInd = i

          bottomInd = i

      let topIndex = self.createIndex(topInd, 0, nil)
      let bottomIndex = self.createIndex(bottomInd, 0, nil)
      self.dataChanged(topIndex, bottomIndex, @[ModelRole.Enabled.int])

    # This signal is emitted to update buttons visibility in the left navigation bar,
    # `dataChanged` signal doesn't do the job because of `DelegateModel` used in `StatusAppNavBar` component
    self.sectionVisibilityUpdated()

  proc enableSection*(self: SectionModel, sectionType: SectionType) =
    self.enableDisableSection(sectionType, true)

  proc disableSection*(self: SectionModel, sectionType: SectionType) =
    self.enableDisableSection(sectionType, false)

  proc udpateNotifications*(self: SectionModel, id: string, hasNotification: bool, notificationsCount: int) =
    for i in 0 ..< self.items.len:
      if(self.items[i].id == id):
        let index = self.createIndex(i, 0, nil)
        self.items[i].hasNotification = hasNotification
        self.items[i].notificationsCount = notificationsCount
        self.dataChanged(index, index, @[ModelRole.HasNotification.int, ModelRole.NotificationsCount.int])
        return
