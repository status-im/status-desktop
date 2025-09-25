import stint, stew/shims/strformat

type BalanceItem* = ref object of RootObj
  account*: string
  chainId*: int
  balance*: Uint256

proc `$`*(self: BalanceItem): string =
  result = fmt"""BalanceItem[
    account: {self.account},
    chainId: {self.chainId},
    balance: {self.balance}]"""

type
  GroupedTokenItem* = ref object of RootObj
    tokensKey*: string
    symbol*: string
    balancesPerAccount*: seq[BalanceItem]

proc `$`*(self: GroupedTokenItem): string =
  result = fmt"""GroupedTokenItem[
    tokensKey: {self.tokensKey},
    symbol: {self.symbol},
    balancesPerAccount: {self.balancesPerAccount}]"""

