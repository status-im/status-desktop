import strformat

type
  TokenPermissionChatListItem* = object
    key: string
    name: string

proc `$`*(self: TokenPermissionChatListItem): string =
  result = fmt"""TokenPermissionChatListItem(
    key: {self.key},
    name: {self.name},
    ]"""

proc initTokenPermissionChatListItem*(
  key: string,
  name: string,
): TokenPermissionChatListItem =
  result.key = key
  result.name = name

proc getKey*(self: TokenPermissionChatListItem): string =
  return self.key

proc getName*(self: TokenPermissionChatListItem): string =
  return self.name
