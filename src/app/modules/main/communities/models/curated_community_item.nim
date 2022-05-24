import strformat

type
  CuratedCommunityItem* = object
    id: string
    name: string
    description: string
    available: bool
    icon: string
    
proc initCuratedCommunityItem*(
  id: string,
  name: string,
  description: string,
  available: bool,
  icon: string
): CuratedCommunityItem =
  result.id = id
  result.name = name
  result.description = description
  result.available = available
  result.icon = icon

proc `$`*(self: CuratedCommunityItem): string =
  result = fmt"""CuratedCommunityItem(
    id: {self.id},
    name: {self.name},
    description: {self.description},
    available: {self.available}
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
