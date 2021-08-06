import strformat

type SearchResultItem* = object
  itemId: string
  content: string
  time: string
  titleId: string
  title: string  
  sectionName: string
  isLetterIdenticon: bool
  badgeImage: string
  badgePrimaryText: string
  badgeSecondaryText: string
  badgeIdenticonColor: string

proc initSearchResultItem*(itemId, content, time, titleId, title,
  sectionName: string,
  isLetterIdenticon: bool = false,
  badgeImage, badgePrimaryText, badgeSecondaryText, 
  badgeIdenticonColor: string = ""): SearchResultItem =

  result.itemId = itemId
  result.content = content
  result.time = time
  result.titleId = titleId
  result.title = title
  result.sectionName = sectionName
  result.isLetterIdenticon = isLetterIdenticon
  result.badgeImage = badgeImage
  result.badgePrimaryText = badgePrimaryText
  result.badgeSecondaryText = badgeSecondaryText
  result.badgeIdenticonColor = badgeIdenticonColor

proc `$`*(self: SearchResultItem): string =
  result = "MessageSearchResultItem("
  result &= fmt"itemId:{self.itemId}, "
  result &= fmt"content:{self.content}, "
  result &= fmt"time:{self.time}, "
  result &= fmt"titleId:{self.titleId}, "
  result &= fmt"title:{self.title}"
  result &= fmt"sectionName:{self.sectionName}"  
  result &= fmt"isLetterIdenticon:{self.isLetterIdenticon}"
  result &= fmt"badgeImage:{self.badgeImage}"
  result &= fmt"badgePrimaryText:{self.badgePrimaryText}"
  result &= fmt"badgeSecondaryText:{self.badgeSecondaryText}"
  result &= fmt"badgeIdenticonColor:{self.badgeIdenticonColor}"
  result &= ")"

method getItemId*(self: SearchResultItem): string {.base.} =
  return self.itemId

method getContent*(self: SearchResultItem): string {.base.} =
  return self.content

method getTime*(self: SearchResultItem): string {.base.} =
  return self.time

method getTitleId*(self: SearchResultItem): string {.base.} =
  return self.titleId

method getTitle*(self: SearchResultItem): string {.base.} =
  return self.title

method getSectionName*(self: SearchResultItem): string {.base.} =
  return self.sectionName

method getIsLetterIdentIcon*(self: SearchResultItem): bool {.base.} =
  return self.isLetterIdenticon

method getBadgeImage*(self: SearchResultItem): string {.base.} =
  return self.badgeImage

method getBadgePrimaryText*(self: SearchResultItem): string {.base.} =
  return self.badgePrimaryText

method getBadgeSecondaryText*(self: SearchResultItem): string {.base.} =
  return self.badgeSecondaryText

method getBadgeIdenticonColor*(self: SearchResultItem): string {.base.} =
  return self.badgeIdenticonColor