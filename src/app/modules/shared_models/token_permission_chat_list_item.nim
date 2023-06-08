import strformat

type
  TokenPermissionChatListItem* = object
    key: string

proc `$`*(self: TokenPermissionChatListItem): string =
  result = fmt"""TokenPermissionChatListItem(
    key: {self.key}
    ]"""

proc initTokenPermissionChatListItem*(
  key: string
): TokenPermissionChatListItem =
  result.key = key

proc getKey*(self: TokenPermissionChatListItem): string =
  return self.key

