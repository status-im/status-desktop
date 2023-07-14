import strformat, stint
import backend/collectibles_types
import ../../../../../../app_service/common/types

type
  TokenOwnersItem* = object
    name*: string
    imageSource*: string
    ownerDetails*: CollectibleOwner
    amount*: int
    remotelyDestructState*: ContractTransactionStatus

proc remoteDestructTransactionStatus*(remoteDestructedAddresses: seq[string], address: string): ContractTransactionStatus =
  if remoteDestructedAddresses.contains(address):
    return ContractTransactionStatus.InProgress
  return ContractTransactionStatus.Completed

proc initTokenOwnersItem*(
  name: string,
  imageSource: string,
  ownerDetails: CollectibleOwner,
  remoteDestructedAddresses: seq[string]
): TokenOwnersItem =
  result.name = name
  result.imageSource = imageSource
  result.ownerDetails = ownerDetails
  result.remotelyDestructState = remoteDestructTransactionStatus(remoteDestructedAddresses, ownerDetails.address)
  for balance in ownerDetails.balances:
    result.amount = result.amount + balance.balance.truncate(int)

proc `$`*(self: TokenOwnersItem): string =
  result = fmt"""TokenOwnersItem(
    name: {self.name},
    amount: {self.amount},
    ownerDetails: {self.ownerDetails}
    ]"""

