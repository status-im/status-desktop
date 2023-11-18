import options
import backend/collectibles as backend
import collectibles_item
import ../../../app_service/service/community_tokens/dto/community_token 

proc collectibleToItem*(c: backend.Collectible, isPinned: bool = false) : Item =
  var collectibleName = ""
  var collectibleDescription = ""
  var collectibleMediaUrl = ""
  var collectibleMediaType = ""
  var collectibleImageUrl = ""
  var collectibleBackgroundColor = ""
  if isSome(c.collectibleData):
    let collectibleData = c.collectibleData.get()
    collectibleName = collectibleData.name
    if isSome(collectibleData.description):
      collectibleDescription = collectibleData.description.get()
    if isSome(collectibleData.animationUrl):
      collectibleMediaUrl = collectibleData.animationUrl.get()
    if isSome(collectibleData.animationMediaType):
      collectibleMediaType = collectibleData.animationMediaType.get()
    if isSome(collectibleData.imageUrl):
      collectibleImageUrl = collectibleData.imageUrl.get()
    if isSome(collectibleData.backgroundColor):
      collectibleBackgroundColor = collectibleData.backgroundColor.get()
  if collectibleMediaUrl == "":
    collectibleMediaUrl = collectibleImageUrl
    collectibleMediaType = "image"

  var collectionName = ""
  var collectionSlug = ""
  var collectionImageUrl = ""
  if isSome(c.collectionData):
    let collectionData = c.collectionData.get()
    collectionName = collectionData.name
    collectionSlug = collectionData.slug
    collectionImageUrl = collectionData.imageUrl

  var communityId = ""
  var communityName = ""
  var communityColor = ""
  var communityPrivilegesLevel = PrivilegesLevel.Community.int
  if isSome(c.communityData):
    let communityData = c.communityData.get() 
    communityId = communityData.id
    communityName = communityData.name
    communityColor = communityData.color
    communityPrivilegesLevel = int(communityData.privilegesLevel)

  return initItem(
    c.id.contractID.chainID,
    c.id.contractID.address,
    c.id.tokenID,
    collectibleName,
    collectibleMediaUrl,
    collectibleMediaType,
    collectibleImageUrl,
    collectibleBackgroundColor,
    collectionName,
    collectionSlug,
    collectionImageUrl,
    isPinned,
    communityId,
    communityName,
    communityColor,
    communityPrivilegesLevel
  )
