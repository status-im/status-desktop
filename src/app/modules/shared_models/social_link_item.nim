import uuids

type
  LinkType* {.pure.} = enum
    Custom,
    Twitter,
    PersonalSite,
    Github,
    Youtube,
    Discord,
    Telegram

  SocialLinkItem* = object
    uuid: string
    text*: string
    url*: string
    linkType: LinkType
    icon*: string

proc initSocialLinkItem*(text, url: string, linkType: LinkType, icon: string = ""): SocialLinkItem =
  result = SocialLinkItem()
  result.uuid = $genUUID()
  result.text = text
  result.url = url
  result.linkType = linkType
  result.icon = icon

proc uuid*(self: SocialLinkItem): string {.inline.} =
  self.uuid

proc linkType*(self: SocialLinkItem): LinkType {.inline.} =
  self.linkType
