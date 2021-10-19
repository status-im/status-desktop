import NimQml, Tables, strutils, strformat

import item

type
  ModelRole {.pure.} = enum
    Id = UserRole + 1
    SectionType
    Name
    Image
    Icon
    Color
    HasNotification
    NotificationsCount
    Active
    Enabled

QtObject:
  type
    Model* = ref object of QAbstractListModel
      items: seq[Item]

  proc delete(self: Model) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: Model) =
    self.QAbstractListModel.setup

  proc newModel*(): Model =
    new(result, delete)
    result.setup

  proc `$`*(self: Model): string =
    for i in 0 ..< self.items.len:
      result &= fmt"""
      [{i}]:({$self.items[i]})
      """

  proc countChanged(self: Model) {.signal.}

  proc getCount(self: Model): int {.slot.} =
    self.items.len

  QtProperty[int] count:
    read = getCount
    notify = countChanged

  method rowCount(self: Model, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: Model): Table[int, string] =
    {
      ModelRole.Id.int:"id",
      ModelRole.SectionType.int:"sectionType",
      ModelRole.Name.int:"name",
      ModelRole.Image.int:"image",
      ModelRole.Icon.int:"icon",
      ModelRole.Color.int:"color",
      ModelRole.HasNotification.int:"hasNotification",
      ModelRole.NotificationsCount.int:"notificationsCount",
      ModelRole.Active.int:"active",
      ModelRole.Enabled.int:"enabled"
    }.toTable

  method data(self: Model, index: QModelIndex, role: int): QVariant =
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

  proc addItem*(self: Model, item: Item) =
    let parentModelIndex = newQModelIndex()
    defer: parentModelIndex.delete

    self.beginInsertRows(parentModelIndex, self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

    self.countChanged()

  proc getItemById*(self: Model, id: string): Item =
    for it in self.items:
      if(it.id == id):
        return it

  proc getItemBySectionType*(self: Model, sectionType: SectionType): Item =
    for it in self.items:
      if(it.sectionType == sectionType):
        return it

  proc setActiveSection*(self: Model, id: string) =
    for i in 0 ..< self.items.len:
      if(self.items[i].active):
        let index = self.createIndex(i, 0, nil)
        self.items[i].active = false
        self.dataChanged(index, index, @[ModelRole.Active.int])

      if(self.items[i].id == id):        
        let index = self.createIndex(i, 0, nil)
        self.items[i].active = true
        self.dataChanged(index, index, @[ModelRole.Active.int])

  proc enableDisableSection(self: Model, sectionType: SectionType, value: bool) =
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

  proc enableSection*(self: Model, sectionType: SectionType) =
    self.enableDisableSection(sectionType, true)

  proc disableSection*(self: Model, sectionType: SectionType) =
    self.enableDisableSection(sectionType, false)
