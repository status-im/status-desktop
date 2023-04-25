import strformat

type
  Item* = object
    name: string
    mixedCaseAddress: string
    ens: string
    balanceLoading: bool

proc initItem*(
  name: string = "",
  mixedCaseAddress: string = "",
  ens: string = "",
  balanceLoading: bool  = true,
): Item =
  result.name = name
  result.mixedCaseAddress = mixedCaseAddress
  result.ens = ens
  result.balanceLoading = balanceLoading

proc `$`*(self: Item): string =
  result = fmt"""OverviewItem(
    name: {self.name},
    mixedCaseAddress: {self.mixedCaseAddress},
    ens: {self.ens},
    balanceLoading: {self.balanceLoading},
    ]"""

proc getName*(self: Item): string =
  return self.name

proc getMixedCaseAddress*(self: Item): string =
  return self.mixedCaseAddress

proc getEns*(self: Item): string =
  return self.ens

proc getBalanceLoading*(self: Item): bool =
  return self.balanceLoading