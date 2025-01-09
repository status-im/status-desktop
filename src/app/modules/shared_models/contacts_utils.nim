proc resolvePreferredDisplayName*(
    localNickName: string, ensName: string, displayName: string, alias: string
): string =
  if localNickname != "":
    return localNickname
  if ensName != "":
    return ensName
  if displayName != "":
    return displayName
  return alias
