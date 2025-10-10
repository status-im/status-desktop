import strutils

import app_service/common/wallet_constants as common_wallet_constants
import app_service/common/utils as common_utils

import ../dto/token

export token


type CommunityDataItem* = CommunityDataDto

type TokenDetailsItem* = TokenDetailsDto

type TokenItemObj = object of RootObj
  key: string
  groupKey: string
  crossChainId: string
  address: string
  name: string
  symbol: string
  decimals: int
  chainId: int
  logoUri: string
  customToken: bool
  communityData: CommunityDataItem

# TokenItem creation is enforced using `createTokenItem`
type TokenItem* = ref TokenItemObj

proc key*(t: TokenItem): string = t.key
proc groupKey*(t: TokenItem): string = t.groupKey
proc crossChainId*(t: TokenItem): string = t.crossChainId
proc address*(t: TokenItem): string = t.address
proc name*(t: TokenItem): string = t.name
proc symbol*(t: TokenItem): string = t.symbol
proc decimals*(t: TokenItem): int = t.decimals
proc chainId*(t: TokenItem): int = t.chainId
proc logoUri*(t: TokenItem): string = t.logoUri
proc customToken*(t: TokenItem): bool = t.customToken
proc communityData*(t: TokenItem): CommunityDataItem = t.communityData


proc createTokenItem*(dto: TokenDto): TokenItem =
  if dto.isNil or dto.chainId <= 0 or dto.address.isEmptyOrWhitespace:
    raise newException(ValueError, "invalid token dto")

  let key = $dto.chainId & "-" & dto. address.toLower()
  let groupKey = if dto.crossChainId.isEmptyOrWhitespace: key else: dto.crossChainId
  return TokenItem(
    key: key,
    groupKey: groupKey,
    crossChainId: dto.crossChainId,
    address: dto.address,
    name: dto.name,
    symbol: dto.symbol,
    decimals: dto.decimals,
    chainId: dto.chainId,
    logoUri: common_utils.resolveUri(dto.logoUri),
    customToken: dto.customToken,
    communityData: CommunityDataItem(
      id: dto.communityData.id,
      name: dto.communityData.name,
      color: dto.communityData.color,
      image: dto.communityData.image
    ),
  )

proc isNative*(self: TokenItem): bool =
  return self.address == common_wallet_constants.ZERO_ADDRESS
