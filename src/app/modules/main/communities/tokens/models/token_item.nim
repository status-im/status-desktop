import strformat
import ../../../../../../app_service/service/community_tokens/dto/community_token

export community_token

type
  TokenItem* = object
    tokenDto*: CommunityTokenDto
    chainName*: string
    chainIcon*: string

proc initTokenItem*(
  tokenDto: CommunityTokenDto,
  chainName: string,
  chainIcon: string,
): TokenItem =
  result.tokenDto = tokenDto
  result.chainName = chainName
  result.chainIcon = chainIcon

proc `$`*(self: TokenItem): string =
  result = fmt"""TokenItem(
    tokenDto: {self.tokenDto},
    chainName: {self.chainName},
    chainIcon: {self.chainIcon}
    ]"""

