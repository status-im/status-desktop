import strformat
type
  DiscordImportErrorItem* = object
    code*: int
    message*: string

proc initDiscordImportErrorItem*(
  code: int,
  message: string,
): DiscordImportErrorItem =
  result.code = code
  result.message = message

proc `$`*(self: DiscordImportErrorItem): string =
  result = fmt"""DiscordImportErrorItem(
    code: {self.code},
    message: {self.message}
    ]"""

proc getCode*(self: DiscordImportErrorItem): int =
  return self.code

proc getMessage*(self: DiscordImportErrorItem): string =
  return self.message
