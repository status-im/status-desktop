import strformat

type
  CuratedCommunityItem* = object
    id: string
    name: string
    description: string
    available: bool
    icon: string
    color: string
    tags: string
    members: int

proc initCuratedCommunityItem*(
  id: string,
  name: string,
  description: string,
  available: bool,
  icon: string,
  color: string,
  tags: string,
  members: int
): CuratedCommunityItem =
  result.id = id
  result.name = name
  result.description = description
  result.available = available
  result.icon = icon
  result.color = color
  result.tags  = tags
  result.members = members

proc `$`*(self: CuratedCommunityItem): string =
  result = fmt"""CuratedCommunityItem(
    id: {self.id},
    name: {self.name},
    description: {self.description},
    available: {self.available},
    color: {self.color},
    tags: {self.tags},
    members: {self.members}
    ]"""

proc getId*(self: CuratedCommunityItem): string =
  return self.id

proc getName*(self: CuratedCommunityItem): string =
  return self.name

proc getDescription*(self: CuratedCommunityItem): string =
  return self.description

proc isAvailable*(self: CuratedCommunityItem): bool =
  return self.available

proc getIcon*(self: CuratedCommunityItem): string =
  return self.icon

proc getMembers*(self: CuratedCommunityItem): int =
  return self.members

proc getColor*(self: CuratedCommunityItem): string =
  return self.color

proc getTags*(self: CuratedCommunityItem): string =
  return self.tags