from backend/collectibles_types import CollectibleOwner

type
  CommunityCollectibleOwner* = object
    contactId*: string
    name*: string
    imageSource*: string
    collectibleOwner*: CollectibleOwner
