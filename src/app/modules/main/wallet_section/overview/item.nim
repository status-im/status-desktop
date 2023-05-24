import strformat, strutils

type
  Item* = object
    name: string
    mixedCaseAddress: string
    ens: string
    balanceLoading: bool
    color: string
    emoji: string
    isWatchOnlyAccount: bool
    isAllAccounts: bool
    hideWatchAccounts: bool
    colors: seq[string]

proc initItem*(
  name: string = "",
  mixedCaseAddress: string = "",
  ens: string = "",
  balanceLoading: bool  = true,
  color: string,
  emoji: string,
  isWatchOnlyAccount: bool=false,
  isAllAccounts: bool = false,
  hideWatchAccounts: bool = false,
  colors: seq[string] = @[]
): Item =
  result.name = name
  result.mixedCaseAddress = mixedCaseAddress
  result.ens = ens
  result.balanceLoading = balanceLoading
  result.color = color
  result.emoji = emoji
  result.isAllAccounts = isAllAccounts
  result.hideWatchAccounts = hideWatchAccounts
  result.colors = colors
  result.isWatchOnlyAccount = isWatchOnlyAccount

proc `$`*(self: Item): string =
  result = fmt"""OverviewItem(
    name: {self.name},
    mixedCaseAddress: {self.mixedCaseAddress},
    ens: {self.ens},
    balanceLoading: {self.balanceLoading},
    color: {self.color},
    emoji: {self.emoji},
    isWatchOnlyAccount: {self.isWatchOnlyAccount},
    isAllAccounts: {self.isAllAccounts},
    hideWatchAccounts: {self.hideWatchAccounts},
    colors: {self.colors}
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getMixedCaseAddress*(self: Item): string =
  return self.mixedCaseAddress

proc getEns*(self: Item): string =
  return self.ens

proc getBalanceLoading*(self: Item): bool =
  return self.balanceLoading

proc getColor*(self: Item): string =
  return self.color

proc getEmoji*(self: Item): string =
  return self.emoji

proc getIsAllAccounts*(self: Item): bool =
  return self.isAllAccounts

proc getHideWatchAccounts*(self: Item): bool =
  return self.hideWatchAccounts

proc getColors*(self: Item): string =
  for color in self.colors:
    if result.isEmptyOrWhitespace:
      result = color
    else:
      result = result & ";" & color
  return result

proc getIsWatchOnlyAccount*(self: Item): bool =
  return self.isWatchOnlyAccount
