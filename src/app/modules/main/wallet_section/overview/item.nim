import strformat

type
  Item* = object
    name: string
    mixedCaseAddress: string
    ens: string
    balanceLoading: bool
    color: string
    emoji: string
    # To do once we implement <All accounts> view
    isAllAccounts: bool
    hideWatchAccounts: bool

proc initItem*(
  name: string = "",
  mixedCaseAddress: string = "",
  ens: string = "",
  balanceLoading: bool  = true,
  color: string,
  emoji: string,
  isAllAccounts: bool = false,
  hideWatchAccounts: bool = false
): Item =
  result.name = name
  result.mixedCaseAddress = mixedCaseAddress
  result.ens = ens
  result.balanceLoading = balanceLoading
  result.color = color
  result.emoji = emoji
  result.isAllAccounts = isAllAccounts
  result.hideWatchAccounts = hideWatchAccounts

proc `$`*(self: Item): string =
  result = fmt"""OverviewItem(
    name: {self.name},
    mixedCaseAddress: {self.mixedCaseAddress},
    ens: {self.ens},
    balanceLoading: {self.balanceLoading},
    color: {self.color},
    emoji: {self.emoji},
    isAllAccounts: {self.isAllAccounts},
    hideWatchAccounts: {self.hideWatchAccounts}
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

