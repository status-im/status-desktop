import unittest
import ../../src/app/modules/shared_models/collectible_trait_model
import ../../src/backend/collectibles_types
import ../../src/app/modules/shared/qt_model_spy

suite "CollectibleTraitModel - Granular Updates":
  
  setup:
    var model = newTraitModel()
    var spy = newQtModelSpy()
  
  teardown:
    spy.disable()

  test "Empty model initialization":
    check model.getCount() == 0

  test "Insert traits - bulk insert":
    spy.enable()
    
    var traits: seq[CollectibleTrait]
    traits.add(CollectibleTrait(trait_type: "Background", value: "Blue", display_type: "", max_value: ""))
    traits.add(CollectibleTrait(trait_type: "Eyes", value: "Green", display_type: "", max_value: ""))
    traits.add(CollectibleTrait(trait_type: "Rarity", value: "Common", display_type: "string", max_value: ""))
    
    model.setItems(traits)
    
    # Verify bulk insert
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 2  # 3 items (0, 1, 2)
    
    check model.getCount() == 3
    spy.disable()

  test "Update traits - same count":
    # Initial setup
    var initial: seq[CollectibleTrait]
    initial.add(CollectibleTrait(trait_type: "Background", value: "Blue", display_type: "", max_value: ""))
    initial.add(CollectibleTrait(trait_type: "Eyes", value: "Green", display_type: "", max_value: ""))
    initial.add(CollectibleTrait(trait_type: "Rarity", value: "Common", display_type: "string", max_value: ""))
    model.setItems(initial)
    
    spy.enable()
    
    # Update: Change Background value and Eyes display_type
    var updated: seq[CollectibleTrait]
    updated.add(CollectibleTrait(trait_type: "Background", value: "Red", display_type: "", max_value: ""))
    updated.add(CollectibleTrait(trait_type: "Eyes", value: "Green", display_type: "boost", max_value: ""))
    updated.add(CollectibleTrait(trait_type: "Rarity", value: "Common", display_type: "string", max_value: ""))
    
    model.setItems(updated)
    
    # Should have dataChanged calls for Background (value) and Eyes (display_type)
    check spy.countDataChanged() == 2
    
    # No inserts or removes
    check spy.countInserts() == 0
    check spy.countRemoves() == 0
    
    check model.getCount() == 3
    spy.disable()

  test "Remove traits":
    # Initial setup
    var initial: seq[CollectibleTrait]
    initial.add(CollectibleTrait(trait_type: "Background", value: "Blue", display_type: "", max_value: ""))
    initial.add(CollectibleTrait(trait_type: "Eyes", value: "Green", display_type: "", max_value: ""))
    initial.add(CollectibleTrait(trait_type: "Rarity", value: "Common", display_type: "string", max_value: ""))
    model.setItems(initial)
    
    spy.enable()
    
    # Remove Eyes (middle item)
    var afterRemove: seq[CollectibleTrait]
    afterRemove.add(CollectibleTrait(trait_type: "Background", value: "Blue", display_type: "", max_value: ""))
    afterRemove.add(CollectibleTrait(trait_type: "Rarity", value: "Common", display_type: "string", max_value: ""))
    
    model.setItems(afterRemove)
    
    # Should remove 1 item
    check spy.countRemoves() == 1
    
    check model.getCount() == 2
    spy.disable()

  test "Add new traits":
    # Initial setup
    var initial: seq[CollectibleTrait]
    initial.add(CollectibleTrait(trait_type: "Background", value: "Blue", display_type: "", max_value: ""))
    model.setItems(initial)
    
    spy.enable()
    
    # Add two more traits
    var afterAdd: seq[CollectibleTrait]
    afterAdd.add(CollectibleTrait(trait_type: "Background", value: "Blue", display_type: "", max_value: ""))
    afterAdd.add(CollectibleTrait(trait_type: "Eyes", value: "Green", display_type: "", max_value: ""))
    afterAdd.add(CollectibleTrait(trait_type: "Rarity", value: "Common", display_type: "string", max_value: ""))
    
    model.setItems(afterAdd)
    
    # Should insert 2 items
    check spy.countInserts() == 2
    
    check model.getCount() == 3
    spy.disable()

  test "Large batch update - bulk operations efficiency":
    spy.enable()
    
    # Create 20 traits
    var traits: seq[CollectibleTrait]
    for i in 0..<20:
      traits.add(CollectibleTrait(
        trait_type: "Trait" & $i,
        value: "Value" & $i,
        display_type: if i mod 2 == 0: "number" else: "string",
        max_value: if i mod 3 == 0: "100" else: ""
      ))
    
    model.setItems(traits)
    
    # Should use bulk insert
    check spy.countInserts() == 1
    let inserts = spy.getInserts()
    check inserts[0].first == 0
    check inserts[0].last == 19
    
    check model.getCount() == 20
    spy.disable()

  test "Update max_value field":
    # Start with trait without max_value
    var initial: seq[CollectibleTrait]
    initial.add(CollectibleTrait(trait_type: "Power", value: "50", display_type: "number", max_value: ""))
    model.setItems(initial)
    
    spy.enable()
    
    # Update with max_value
    var withMax: seq[CollectibleTrait]
    withMax.add(CollectibleTrait(trait_type: "Power", value: "50", display_type: "number", max_value: "100"))
    
    model.setItems(withMax)
    
    # Should have dataChanged for MaxValue role update
    check spy.countDataChanged() == 1
    let changes = spy.getDataChanged()
    check ModelRole.MaxValue.int in changes[0].roles
    
    spy.disable()

  test "Mixed operations - remove, update, add":
    # Initial: Background, Eyes, Rarity
    var initial: seq[CollectibleTrait]
    initial.add(CollectibleTrait(trait_type: "Background", value: "Blue", display_type: "", max_value: ""))
    initial.add(CollectibleTrait(trait_type: "Eyes", value: "Green", display_type: "", max_value: ""))
    initial.add(CollectibleTrait(trait_type: "Rarity", value: "Common", display_type: "string", max_value: ""))
    model.setItems(initial)
    
    spy.enable()
    
    # New: Background (updated value), Hat (new), Accessory (new) - Eyes and Rarity removed
    var mixed: seq[CollectibleTrait]
    mixed.add(CollectibleTrait(trait_type: "Background", value: "Red", display_type: "", max_value: ""))
    mixed.add(CollectibleTrait(trait_type: "Hat", value: "Wizard", display_type: "string", max_value: ""))
    mixed.add(CollectibleTrait(trait_type: "Accessory", value: "Glasses", display_type: "", max_value: ""))
    
    model.setItems(mixed)
    
    # Should have removes (Eyes, Rarity), updates (Background), and inserts (Hat, Accessory)
    check spy.countRemoves() == 2
    check spy.countDataChanged() >= 1  # Background updated
    check spy.countInserts() == 2
    
    check model.getCount() == 3
    spy.disable()

  test "Display type changes":
    var initial: seq[CollectibleTrait]
    initial.add(CollectibleTrait(trait_type: "Power", value: "50", display_type: "number", max_value: "100"))
    model.setItems(initial)
    
    spy.enable()
    
    # Change display_type
    var updated: seq[CollectibleTrait]
    updated.add(CollectibleTrait(trait_type: "Power", value: "50", display_type: "boost_number", max_value: "100"))
    
    model.setItems(updated)
    
    # Should update DisplayType role
    check spy.countDataChanged() == 1
    let changes = spy.getDataChanged()
    check ModelRole.DisplayType.int in changes[0].roles
    
    spy.disable()
