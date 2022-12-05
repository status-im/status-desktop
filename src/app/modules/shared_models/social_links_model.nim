import NimQml, tables, sequtils, sugar

import ../../../app_service/common/social_links

import social_link_item

proc toSocialLinkItems*(source: SocialLinks): seq[SocialLinkItem] =
  proc textToType(text: string): LinkType =
    if (text == SOCIAL_LINK_TWITTER_ID): return LinkType.Twitter
    if (text == SOCIAL_LINK_PERSONAL_SITE_ID): return LinkType.PersonalSite
    if (text == SOCIAL_LINK_GITHUB_ID): return LinkType.Github
    if (text == SOCIAL_LINK_YOUTUBE_ID): return LinkType.Youtube
    if (text == SOCIAL_LINK_DISCORD_ID): return LinkType.Discord
    if (text == SOCIAL_LINK_TELEGRAM_ID): return LinkType.Telegram
    return LinkType.Custom
  result = map(source, x => initSocialLinkItem(x.text, x.url, textToType(x.text), x.icon))

type
  ModelRole {.pure.} = enum
    Uuid = UserRole + 1
    Text
    Url
    LinkType
    Icon

QtObject:
  type
    SocialLinksModel* = ref object of QAbstractListModel
      items: seq[SocialLinkItem]

  proc delete(self: SocialLinksModel) =
    self.items = @[]
    self.QAbstractListModel.delete

  proc setup(self: SocialLinksModel) =
    self.QAbstractListModel.setup

  proc newSocialLinksModel*(): SocialLinksModel =
    new(result, delete)
    result.setup

  proc setItems*(self: SocialLinksModel, items: seq[SocialLinkItem]) =
    self.beginResetModel()
    self.items = items
    self.endResetModel()

  proc appendItem*(self: SocialLinksModel, item: SocialLinkItem) =
    self.beginInsertRows(newQModelIndex(), self.items.len, self.items.len)
    self.items.add(item)
    self.endInsertRows()

  proc removeItem*(self: SocialLinksModel, uuid: string): bool =
    for i in 0 ..< self.items.len:
      if (self.items[i].uuid == uuid):
        if (self.items[i].linkType == LinkType.Custom):
          self.beginRemoveRows(newQModelIndex(), i, i)
          self.items.delete(i)
          self.endRemoveRows()
          return true
        return false
    return false

  proc updateItem*(self: SocialLinksModel, uuid, text, url: string): bool =
    for i in 0 ..< self.items.len:
      if (self.items[i].uuid == uuid):
        var changedRoles: seq[int] = @[]

        if (self.items[i].text != text):
          self.items[i].text = text
          changedRoles.add(ModelRole.Text.int)

        if (self.items[i].url != url):
          self.items[i].url = url
          changedRoles.add(ModelRole.Url.int)

        if changedRoles.len > 0:
          let index = self.createIndex(i, 0, nil)
          self.dataChanged(index, index, changedRoles)
          return true

    return false

  proc items*(self: SocialLinksModel): seq[SocialLinkItem] =
    self.items

  method rowCount(self: SocialLinksModel, index: QModelIndex = nil): int =
    return self.items.len

  method roleNames(self: SocialLinksModel): Table[int, string] =
    {
      ModelRole.Uuid.int: "uuid",
      ModelRole.Text.int: "text",
      ModelRole.Url.int: "url",
      ModelRole.LinkType.int: "linkType",
      ModelRole.Icon.int: "icon"
    }.toTable

  method data(self: SocialLinksModel, index: QModelIndex, role: int): QVariant =
    if (not index.isValid):
      return

    if (index.row < 0 or index.row >= self.items.len):
      return

    let item = self.items[index.row]
    let enumRole = role.ModelRole

    case enumRole:
    of ModelRole.Uuid:
      result = newQVariant(item.uuid)
    of ModelRole.Text:
      result = newQVariant(item.text)
    of ModelRole.Url:
      result = newQVariant(item.url)
    of ModelRole.LinkType:
      result = newQVariant(item.linkType.int)
    of ModelRole.Icon:
      result = newQVariant(item.icon)
