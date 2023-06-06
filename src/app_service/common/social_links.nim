import json, sequtils, sugar

include json_utils

const SOCIAL_LINK_TWITTER_ID* = "__twitter"
const SOCIAL_LINK_PERSONAL_SITE_ID* = "__personal_site"
const SOCIAL_LINK_GITHUB_ID* = "__github"
const SOCIAL_LINK_YOUTUBE_ID* = "__youtube"
const SOCIAL_LINK_DISCORD_ID* = "__discord"
const SOCIAL_LINK_TELEGRAM_ID* = "__telegram"

type
  SocialLink* = object
    text*: string
    url*: string
    icon*: string

  SocialLinks* = seq[SocialLink]

  SocialLinksInfo* = object
    links*: seq[SocialLink]
    removed*: bool

proc socialLinkTextToIcon(text: string): string =
  if (text == SOCIAL_LINK_TWITTER_ID): return "twitter"
  if (text == SOCIAL_LINK_PERSONAL_SITE_ID): return "language"
  if (text == SOCIAL_LINK_GITHUB_ID): return "github"
  if (text == SOCIAL_LINK_YOUTUBE_ID): return "youtube"
  if (text == SOCIAL_LINK_DISCORD_ID): return "discord"
  if (text == SOCIAL_LINK_TELEGRAM_ID): return "telegram"
  return "link"

proc toSocialLinks*(jsonObj: JsonNode): SocialLinks =
  result = map(jsonObj.getElems(),
               node => SocialLink(text: node["text"].getStr(),
                                  url: node["url"].getStr(),
                                  icon: socialLinkTextToIcon(node["text"].getStr()))
              )

proc toSocialLinksInfo*(jsonObj: JsonNode): SocialLinksInfo =
  discard jsonObj.getProp("removed", result.removed)
  var linksObj: JsonNode
  if jsonObj.getProp("links", linksObj):
    result.links = toSocialLinks(linksObj)

proc toJsonNode*(links: SocialLinks): JsonNode =
  %*links
