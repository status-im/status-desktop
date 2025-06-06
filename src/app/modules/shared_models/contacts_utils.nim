proc resolvePreferredDisplayName*(localNickName: string, ensName: string, displayName: string, alias: string): string =
    if localNickname != "":
      return localNickname
    if ensName != "":
      return ensName
    if displayName != "":
      return displayName
    if alias != "":
      return alias
    # This makes sure that people with no name are sorted last
    # This fake name is never shown to the user
    return "zzz"

proc resolveUsesDefaultName*(localNickName: string, ensName: string, displayName: string): bool =
  return displayName == "" and localNickname == "" and ensName == ""
