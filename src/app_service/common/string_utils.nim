import nimcrypto

proc hashString*(text: string): string =
  result = "0x" & $keccak_256.digest(text)
