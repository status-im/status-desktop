import sequtils, sugar, times, options
import backend/collectibles as backend
import collectibles_item

proc collectibleToItem*(c: backend.CollectibleHeader, isPinned: bool = false) : Item =
  var mediaUrl = c.animationUrl
  var mediaType = c.animationMediaType
  if mediaUrl == "":
    mediaUrl = c.imageUrl
    mediaType = "image"

  var communityId = ""
  var communityName = ""
  var communityColor = ""
  var communityPrivilegesLevel = 0
  if isSome(c.communityHeader):
    let communityHeader = c.communityHeader.get() 
    communityId = communityHeader.communityId
    communityName = communityHeader.communityName
    communityColor = communityHeader.communityColor
    communityPrivilegesLevel = int(communityHeader.privilegesLevel)

  return initItem(
    c.id.contractID.chainID,
    c.id.contractID.address,
    c.id.tokenID,
    c.name,
    mediaUrl,
    mediaType,
    c.imageUrl,
    c.backgroundColor,
    c.collectionName,
    c.collectionSlug,
    c.collectionImageUrl,
    isPinned,
    communityId,
    communityName,
    communityColor,
    communityPrivilegesLevel
  )
