import strformat, stint
import ../../../../../../app_service/service/collectible/dto

type
  TokenOwnersItem* = object
    name*: string
    imageSource*: string
    ownerDetails*: CollectibleOwner
    amount*: int

proc initTokenOwnersItem*(
  name: string,
  imageSource: string,
  ownerDetails: CollectibleOwner
): TokenOwnersItem =
  result.name = name
  result.imageSource = imageSource
  result.ownerDetails = ownerDetails
  for balance in ownerDetails.balances:
    result.amount = result.amount + balance.balance.truncate(int)

proc `$`*(self: TokenOwnersItem): string =
  result = fmt"""TokenOwnersItem(
    name: {self.name},
    amount: {self.amount},
    ownerDetails: {self.ownerDetails}
    ]"""

