proc isWakuEnabled(): bool =
  true # TODO:

proc prefix*(methodName: string): string =
  result = if isWakuEnabled(): "wakuext_" else: "shhext_" 
  result = result & methodName