import nimcrypto

proc isWakuEnabled(): bool =
  true # TODO:

proc prefix*(methodName: string, isExt:bool = true): string =
  result = if isWakuEnabled(): "waku" else: "shh"
  result = result & (if isExt: "ext_" else: "_")
  result = result & methodName

proc hashPassword*(password: string): string =
  result = "0x" & $keccak_256.digest(password)
