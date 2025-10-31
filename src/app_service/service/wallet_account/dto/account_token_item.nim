import stint, stew/shims/strformat

# Value types (object) instead of ref object for CoW compatibility
# This ensures that copies are independent and don't share memory
type BalanceItem* = object
  account*: string
  chainId*: int
  balance*: Uint256

proc `$`*(self: BalanceItem): string =
  result = fmt"""BalanceItem[
    account: {self.account},
    chainId: {self.chainId},
    balance: {self.balance}]"""

proc `==`*(a, b: BalanceItem): bool =
  ## Equality comparison for BalanceItem
  ## Required for model_sync to detect changes
  a.account == b.account and
  a.chainId == b.chainId and
  a.balance == b.balance

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

proc `==`*(a, b: GroupedTokenItem): bool =
  ## Equality comparison for GroupedTokenItem
  ## Required for model_sync to detect changes
  a.tokensKey == b.tokensKey and
  a.symbol == b.symbol and
  a.balancesPerAccount == b.balancesPerAccount

