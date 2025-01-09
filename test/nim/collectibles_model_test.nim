import unittest

import stint, strutils, random

import backend/collectibles_types
import app/modules/shared_models/collectibles_model
import app/modules/shared_models/collectibles_entry

proc createTestCollectible(seed: int): CollectiblesEntry =
  let data = Collectible(
    dataType: UniqueID,
    id: CollectibleUniqueID(
      contractID: ContractID(address: seed.toHex, chainID: seed mod 4),
      tokenID: u256(seed),
    ),
  )
  let extradata = ExtraData(
    networkShortName: "Chain" & seed.toHex,
    networkColor: "Color" & seed.toHex,
    networkIconURL: "URL" & seed.toHex,
  )
  return newCollectibleDetailsFullEntry(data, extradata)

proc createTestCollectibles(seed: int, count: int): seq[CollectiblesEntry] =
  result = @[]
  for i in 0 ..< count:
    result.add(createTestCollectible(seed + i))

suite "collectibles model":
  test "Collectible list set":
    let collectibles = createTestCollectibles(0, 15)
    let moreCollectibles = createTestCollectibles(100, 10)
    let model = newModel()

    model.setItems(collectibles, 0, false)
    check(model.getItems() == collectibles)

    # Wrong offset, should not change the list
    model.setItems(collectibles, 20, false)
    check(model.getItems() == collectibles)

    # Right offset, should append
    model.setItems(moreCollectibles, 15, false)
    check(model.getItems() == collectibles & moreCollectibles)

    # 0 offset, should replace
    model.setItems(moreCollectibles, 0, false)
    check(model.getItems() == moreCollectibles)

  test "Collectible list update":
    let oldCollectibles = createTestCollectibles(0, 15)
    let model = newModel()

    model.updateItems(oldCollectibles)
    check(model.getItems() == oldCollectibles)

    model.updateItems(oldCollectibles)
    check(model.getItems() == oldCollectibles)

    var newCollectibles = oldCollectibles
    newCollectibles.del(0)
    newCollectibles.del(2)
    newCollectibles.del(7)
    for newC in createTestCollectibles(100, 7):
      newCollectibles.add(newC)

    var r = initRand(678)
    r.shuffle(newCollectibles)

    model.updateItems(newCollectibles)

    for c in model.getItems():
      check(c in newCollectibles)

    for c in newCollectibles:
      check(c in model.getItems())

    model.updateItems(@[])
    check(model.getItems().len == 0)
