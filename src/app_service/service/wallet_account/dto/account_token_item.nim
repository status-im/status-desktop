import stint, stew/shims/strformat

type BalanceItem* = ref object of RootObj
  account*: string
  chainId*: int
  balance*: Uint256
  balance1DayAgo*: Uint256

proc `$`*(self: BalanceItem): string =
  result =
    fmt"""BalanceItem[
    account: {self.account},
    chainId: {self.chainId},
    balance: {self.balance},
    balance1DayAgo: {self.balance1DayAgo}]"""

type GroupedTokenItem* = ref object of RootObj
  tokensKey*: string
  symbol*: string
  balancesPerAccount*: seq[BalanceItem]

proc `$`*(self: GroupedTokenItem): string =
  result =
    fmt"""GroupedTokenItem[
    tokensKey: {self.tokensKey},
    symbol: {self.symbol},
    balancesPerAccount: {self.balancesPerAccount}]"""
