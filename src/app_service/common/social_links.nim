import json, sequtils, sugar

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

proc socialLinkTextToIcon(text: string): string =
  if (text == SOCIAL_LINK_TWITTER_ID): return "twitter"
  if (text == SOCIAL_LINK_PERSONAL_SITE_ID): return "language"
  if (text == SOCIAL_LINK_GITHUB_ID): return "github"
  if (text == SOCIAL_LINK_YOUTUBE_ID): return "youtube"
  if (text == SOCIAL_LINK_DISCORD_ID): return "discord"
  if (text == SOCIAL_LINK_TELEGRAM_ID): return "telegram"
  return ""

proc toSocialLinks*(jsonObj: JsonNode): SocialLinks =
  result = map(jsonObj.getElems(),
               node => SocialLink(text: node["text"].getStr(),
                                  url: node["url"].getStr(),
                                  icon: socialLinkTextToIcon(node["text"].getStr()))
              )
  return

proc toJsonNode*(links: SocialLinks): JsonNode =
  %*links
