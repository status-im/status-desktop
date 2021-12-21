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
      ModelRole.IsMember.int:"isMember"
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

  proc addItem*(self: SectionModel, item: SectionItem) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

    self.countChanged()

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

  proc enableSection*(self: SectionModel, sectionType: SectionType) =
    self.enableDisableSection(sectionType, true)

  proc disableSection*(self: SectionModel, sectionType: SectionType) =
    self.enableDisableSection(sectionType, false)
