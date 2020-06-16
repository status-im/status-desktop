import strutils

let domain* = ".statusnet.eth"

proc userName*(ensName: string): string =
  if ensName != "" and ensName.endsWith(domain):
    result = ensName.split(".")[0]
  else:
    result = ensName
