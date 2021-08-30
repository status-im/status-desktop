import strformat

type SearchResultItem* = object
  itemId: string
  content: string
  time: string
  titleId: string
  title: string  
  sectionName: string
  image: string
  color: string
  badgePrimaryText: string
  badgeSecondaryText: string
  badgeImage: string
  badgeIconColor: string
  badgeIsLetterIdenticon: bool

proc initSearchResultItem*(itemId, content, time, titleId, title,
  sectionName: string, image, color, badgePrimaryText, badgeSecondaryText, 
  badgeImage, badgeIconColor: string = "", badgeIsLetterIdenticon: bool = false): 
  SearchResultItem =

  result.itemId = itemId
  result.content = content
  result.time = time
  result.titleId = titleId
  result.title = title
  result.sectionName = sectionName
  result.image = image
  result.color = color
  result.badgePrimaryText = badgePrimaryText
  result.badgeSecondaryText = badgeSecondaryText
  result.badgeImage = badgeImage
  result.badgeIconColor = badgeIconColor
  result.badgeIsLetterIdenticon = badgeIsLetterIdenticon

proc `$`*(self: SearchResultItem): string =
  result = "MessageSearchResultItem("
  result &= fmt"itemId:{self.itemId}, "
  result &= fmt"content:{self.content}, "
  result &= fmt"time:{self.time}, "
  result &= fmt"titleId:{self.titleId}, "
  result &= fmt"title:{self.title}"
  result &= fmt"sectionName:{self.sectionName}"  
  result &= fmt"image:{self.image}"
  result &= fmt"color:{self.color}"
  result &= fmt"badgePrimaryText:{self.badgePrimaryText}"
  result &= fmt"badgeSecondaryText:{self.badgeSecondaryText}"
  result &= fmt"badgeImage:{self.badgeImage}"
  result &= fmt"badgeIconColor:{self.badgeIconColor}"
  result &= fmt"badgeIsLetterIdenticon:{self.badgeIsLetterIdenticon}"
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

method getImage*(self: SearchResultItem): string {.base.} =
  return self.image

method getColor*(self: SearchResultItem): string {.base.} =
  return self.color

method getBadgePrimaryText*(self: SearchResultItem): string {.base.} =
  return self.badgePrimaryText

method getBadgeSecondaryText*(self: SearchResultItem): string {.base.} =
  return self.badgeSecondaryText

method getBadgeImage*(self: SearchResultItem): string {.base.} =
  return self.badgeImage

method getBadgeIconColor*(self: SearchResultItem): string {.base.} =
  return self.badgeIconColor

method getBadgeIsLetterIdenticon*(self: SearchResultItem): bool {.base.} =
  return self.badgeIsLetterIdenticon