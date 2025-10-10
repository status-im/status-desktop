import stint

type BalanceItem* = ref object of RootObj
  account*: string
  tokenKey*: string
  chainId*: int
  tokenAddress*: string
  balance*: Uint256

type
  GroupedTokenItem* = ref object of RootObj
    key*: string # crossChainId or tokenKey if crossChainId is empty
    balancesPerAccount*: seq[BalanceItem]
