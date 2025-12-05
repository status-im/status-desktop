import stint

type
  BalanceItem* = ref object of RootObj
    account*: string
    groupKey*: string
    tokenKey*: string
    chainId*: int
    tokenAddress*: string
    balance*: Uint256

type
  AssetGroupItem* = ref object of RootObj
    key*: string # crossChainId or tokenKey if crossChainId is empty
    balancesPerAccount*: seq[BalanceItem]
