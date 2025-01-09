import unittest

import stint
import backend/collectibles_types
import app_service/service/community_tokens/community_collectible_owner
include app_service/common/json_utils

suite "collectibles types":
  test "CollectibleOwner json conversion":
    let oldBalance1 =
      CollectibleBalance(tokenId: stint.u256(23), balance: stint.u256(41))
    let oldBalance2 = CollectibleBalance(
      tokenId: stint.u256(24), balance: stint.u256(123456789123456789)
    )
    let oldBalances = @[oldBalance1, oldBalance2]
    let oldOwner = CollectibleOwner(address: "abc", balances: oldBalances)

    let ownerJson = %oldOwner

    let newOwner = getCollectibleOwner(ownerJson)

    check(oldOwner.address == newOwner.address)
    check(oldOwner.balances.len == newOwner.balances.len)
    check(oldOwner.balances[0].tokenId == newOwner.balances[0].tokenId)
    check(oldOwner.balances[0].balance == newOwner.balances[0].balance)
    check(oldOwner.balances[1].tokenId == newOwner.balances[1].tokenId)
    check(oldOwner.balances[1].balance == newOwner.balances[1].balance)

  test "CommunityCollectibleOwner json conversion":
    let oldBalance =
      CollectibleBalance(tokenId: stint.u256(23), balance: stint.u256(41))
    let oldCollOwner = CollectibleOwner(address: "abc", balances: @[oldBalance])
    let oldCommOwner = CommunityCollectibleOwner(
      contactId: "id1", name: "abc", imageSource: "xyz", collectibleOwner: oldCollOwner
    )

    let oldCommOwners = @[oldCommOwner]
    let commOwnersJson = %(oldCommOwners)

    let newCommOwners = toCommunityCollectibleOwners(commOwnersJson)

    check(oldCommOwners.len == newCommOwners.len)
    check(oldCommOwners[0].contactId == newCommOwners[0].contactId)
    check(oldCommOwners[0].name == newCommOwners[0].name)
    check(oldCommOwners[0].imageSource == newCommOwners[0].imageSource)
    check(
      oldCommOwners[0].collectibleOwner.address ==
        newCommOwners[0].collectibleOwner.address
    )

  test "ContractID string conversion":
    let oldContractID = ContractID(chainID: 321, address: "0x123")
    let contractIDString = oldContractID.toString()

    let newContractID = contractIDString.toContractID()

    check(oldContractID == newContractID)

  test "CollectibleUniqueID string conversion":
    let oldUniqueID = CollectibleUniqueID(
      contractID: ContractID(chainID: 321, address: "0x123"), tokenId: stint.u256(23)
    )
    let uniqueIDString = oldUniqueID.toString()

    let newUniqueID = uniqueIDString.toCollectibleUniqueID()

    check(oldUniqueID == newUniqueID)
