import strformat

type
  TokenType* {.pure.} = enum
    #ERC20,
    ERC721

type
  MintingState* {.pure.} = enum
    InProgress,
    Minted,
    Failed

type
  TokenItem* = ref object
    tokenType: TokenType
    tokenAddress: string
    name: string
    description: string
    icon: string
    supply: int
    infiniteSupply: bool
    transferable: bool
    remoteSelfDestruct: bool
    networkId: string
    mintingState: MintingState
    # TODO holders

proc initCollectibleTokenItem*(
  tokenAddress: string,
  name: string,
  description: string,
  icon: string,
  supply: int,
  infiniteSupply: bool,
  transferable: bool,
  remoteSelfDestruct: bool,
  networkId: string,
  mintingState: MintingState
): TokenItem =
  result = TokenItem()
  result.tokenType = TokenType.ERC721
  result.tokenAddress = tokenAddress
  result.name = name
  result.description = description
  result.icon = icon
  result.supply = supply
  result.infiniteSupply = infiniteSupply
  result.transferable  = transferable
  result.remoteSelfDestruct = remoteSelfDestruct
  result.networkId = networkId
  result.mintingState = mintingState

proc `$`*(self: TokenItem): string =
  result = fmt"""TokenItem(
    tokenType: {$self.tokenType.int},
    tokenAddress: {self.tokenAddress},
    name: {self.name},
    description: {self.description},
    icon: {self.icon},
    supply: {self.supply},
    infiniteSupply: {self.infiniteSupply},
    transferable: {self.transferable},
    remoteSelfDestruct: {self.remoteSelfDestruct},
    networkId: {self.networkId},
    mintingState: {$self.mintingState.int}
    ]"""

proc getTokenType*(self: TokenItem): TokenType =
  return self.tokenType

proc getTokenAddress*(self: TokenItem): string =
  return self.tokenAddress

proc getName*(self: TokenItem): string =
  return self.name

proc getDescription*(self: TokenItem): string =
  return self.description

proc getIcon*(self: TokenItem): string =
  return self.icon

proc getSupply*(self: TokenItem): int =
  return self.supply

proc getInfiniteSupply*(self: TokenItem): bool =
  return self.infiniteSupply

proc isTransferrable*(self: TokenItem): bool =
  return self.transferable

proc isRemoteSelfDestruct*(self: TokenItem): bool =
  return self.remoteSelfDestruct

proc getNetworkId*(self: TokenItem): string =
  return self.networkId

proc getMintingState*(self: TokenItem): MintingState =
  return self.mintingState