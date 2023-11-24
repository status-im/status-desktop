import stint,strformat

type
  AccountTokenItem* = object
    key*: string
    flatTokensKey*: string
    symbol*: string
    account*: string
    chainId*: int
    balance*: Uint256

proc `$`*(self: AccountTokenItem): string =
  result = fmt"""AccountTokenItem[
    key: {self.key},
    flatTokensKey: {self.flatTokensKey},
    symbol: {self.symbol},
    account: {self.account},
    chainId: {self.chainId},
    balance: {self.balance}]"""

type BalanceItem* = object
  account*: string
  chainId*: int
  balance*: Uint256

proc `$`*(self: BalanceItem): string =
  result = fmt"""BalanceItem[
    account: {self.account},
    chainId: {self.chainId},
    balance: {self.balance}]"""

type
  GroupedTokenItem* = object
    tokensKey*: string
    symbol*: string
    balancesPerAccount*: seq[BalanceItem]

proc `$`*(self: GroupedTokenItem): string =
  result = fmt"""GroupedTokenItem[
    tokensKey: {self.tokensKey},
    symbol: {self.symbol},
    balancesPerAccount: {self.balancesPerAccount}]"""

