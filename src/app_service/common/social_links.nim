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

  SocialLinks* = seq[SocialLink]

proc toSocialLinks*(jsonObj: JsonNode): SocialLinks =
  result = map(jsonObj.getElems(),
               node => SocialLink(text: node["text"].getStr(),
                                  url: node["url"].getStr())
              )
  return

proc toJsonNode*(links: SocialLinks): JsonNode =
  %*links
