import strformat
import ../../../shared_models/currency_amount

type
  Item* = object
    name: string
    mixedCaseAddress: string
    ens: string
    balanceLoading: bool
    hasBalanceCache: bool

proc initItem*(
  name: string = "",
  mixedCaseAddress: string = "",
  ens: string = "",
  balanceLoading: bool  = true,
  hasBalanceCache: bool = false,
): Item =
  result.name = name
  result.mixedCaseAddress = mixedCaseAddress
  result.ens = ens
  result.balanceLoading = balanceLoading
  result.hasBalanceCache = hasBalanceCache

proc `$`*(self: Item): string =
  result = fmt"""OverviewItem(
    name: {self.name},
    mixedCaseAddress: {self.mixedCaseAddress},
    ens: {self.ens},
    balanceLoading: {self.balanceLoading},
    hasBalanceCache: {self.hasBalanceCache},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getMixedCaseAddress*(self: Item): string =
  return self.mixedCaseAddress

proc getEns*(self: Item): string =
  return self.ens

proc getBalanceLoading*(self: Item): bool =
  return self.balanceLoading

proc getHasBalanceCache*(self: Item): bool =
  return self.hasBalanceCache