import strformat, sequtils
import ../../../../../../app_service/service/community_tokens/dto/community_token
import ../../../../../../app_service/service/collectible/dto
import ../../../../../../app_service/service/network/dto

import token_owners_model
import token_owners_item

export community_token

type
  TokenItem* = object
    tokenDto*: CommunityTokenDto
    chainName*: string
    chainIcon*: string
    accountName*: string
    tokenOwnersModel*: token_owners_model.TokenOwnersModel

proc initTokenItem*(
  tokenDto: CommunityTokenDto,
  network: NetworkDto,
  tokenOwners: seq[CollectibleOwner],
  accountName: string
): TokenItem =
  result.tokenDto = tokenDto
  if network != nil:
    result.chainName = network.chainName
    result.chainIcon = network.iconURL
  result.accountName = accountName
  result.tokenOwnersModel = newTokenOwnersModel()
  result.tokenOwnersModel.setItems(tokenOwners.map(proc(owner: CollectibleOwner): TokenOwnersItem =
          # TODO find member with the address - later when airdrop to member will be added
          result = initTokenOwnersItem("", "", owner)
        ))

proc `$`*(self: TokenItem): string =
  result = fmt"""TokenItem(
    tokenDto: {self.tokenDto},
    chainName: {self.chainName},
    chainIcon: {self.chainIcon},
    tokenOwnersModel: {self.tokenOwnersModel}
    ]"""

