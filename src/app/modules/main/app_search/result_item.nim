import strformat

type Item* = object
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

proc initItem*(itemId, content, time, titleId, title, sectionName: string, image, color, badgePrimaryText, 
  badgeSecondaryText, badgeImage, badgeIconColor: string = "", badgeIsLetterIdenticon: bool = false): 
  Item =

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

proc `$`*(self: Item): string =
  result = "SearchResultItem("
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

method itemId*(self: Item): string {.inline.} =
  return self.itemId

method content*(self: Item): string {.inline.} =
  return self.content

method time*(self: Item): string {.inline.} =
  return self.time

method titleId*(self: Item): string {.inline.} =
  return self.titleId

method title*(self: Item): string {.inline.} =
  return self.title

method sectionName*(self: Item): string {.inline.} =
  return self.sectionName

method image*(self: Item): string {.inline.} =
  return self.image

method color*(self: Item): string {.inline.} =
  return self.color

method badgePrimaryText*(self: Item): string {.inline.} =
  return self.badgePrimaryText

method badgeSecondaryText*(self: Item): string {.inline.} =
  return self.badgeSecondaryText

method badgeImage*(self: Item): string {.inline.} =
  return self.badgeImage

method badgeIconColor*(self: Item): string {.inline.} =
  return self.badgeIconColor

method badgeIsLetterIdenticon*(self: Item): bool {.inline.} =
  return self.badgeIsLetterIdenticon