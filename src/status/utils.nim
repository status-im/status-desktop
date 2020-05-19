import strutils

proc isWakuEnabled(): bool =
  true # TODO:

proc prefix*(methodName: string): string =
  result = if isWakuEnabled(): "wakuext_" else: "shhext_" 
  result = result & methodName

proc isOneToOneChat*(chatId: string): bool =
  result = chatId.startsWith("0x") # There is probably a better way to do this