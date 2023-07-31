import sequtils, sugar, times
import backend/collectibles as backend
import collectibles_item

proc collectibleToItem*(c: backend.CollectibleHeader, isPinned: bool = false) : Item =
  var mediaUrl = c.animationUrl
  var mediaType = c.animationMediaType
  if mediaUrl == "":
    mediaUrl = c.imageUrl
    mediaType = "image"

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
    isPinned
  )
