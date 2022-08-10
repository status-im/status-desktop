import uuids

type
  LinkType* {.pure.} = enum
    Custom,
    Twitter,
    PersonalSite,
    Github,
    Youtbue,
    Discord,
    Telegram

  SocialLinkItem* = object
    uuid: string
    text*: string
    url*: string
    linkType: LinkType

proc initSocialLinkItem*(text, url: string, linkType: LinkType): SocialLinkItem =
  result = SocialLinkItem()
  result.uuid = $genUUID()
  result.text = text
  result.url = url
  result.linkType = linkType

proc uuid*(self: SocialLinkItem): string {.inline.} =
  self.uuid

proc linkType*(self: SocialLinkItem): LinkType {.inline.} =
  self.linkType
