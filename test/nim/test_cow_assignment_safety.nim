## Test: Service Layer Assignment Safety
## Critical test to prove that model data is safe when service reassigns its CowSeq

import unittest
import ../../src/app/core/cow_seq
import std/[strformat, strutils]

suite "CowSeq - Assignment Safety (Service Layer Pattern)":
  
  test "Model data is safe when service reassigns container":
    echo "\n========================================="
    echo "CRITICAL TEST: Service Reassignment Safety"
    echo "=========================================\n"
    
    # Simulate service layer
    var serviceContainer = @[1, 2, 3, 4, 5].toCowSeq()
    echo "Service created container: ", serviceContainer.toSeq()
    echo "Service refCount: ", serviceContainer.getRefCount()
    
    # Simulate model layer copying from service
    var modelContainer = serviceContainer
    echo "\nModel copied from service"
    echo "Service refCount: ", serviceContainer.getRefCount()
    echo "Model refCount: ", modelContainer.getRefCount()
    echo "Model data: ", modelContainer.toSeq()
    
    check serviceContainer.getRefCount() == 2
    check modelContainer.getRefCount() == 2
    
    # CRITICAL: Service reassigns to new data
    echo "\n SERVICE REASSIGNS TO NEW DATA:"
    serviceContainer = @[99, 88, 77].toCowSeq()
    
    echo "Service new data: ", serviceContainer.toSeq()
    echo "Service refCount: ", serviceContainer.getRefCount()
    echo "Model data: ", modelContainer.toSeq()
    echo "Model refCount: ", modelContainer.getRefCount()
    
    # MODEL MUST STILL HAVE OLD DATA!
    check modelContainer.toSeq() == @[1, 2, 3, 4, 5]
    check modelContainer.getRefCount() == 1  # Now exclusive owner
    
    # Service has new data
    check serviceContainer.toSeq() == @[99, 88, 77]
    check serviceContainer.getRefCount() == 1
    
    echo "\n MODEL DATA IS SAFE!"
    echo "   Model still has: [1, 2, 3, 4, 5]"
    echo "   Service now has: [99, 88, 77]"
    echo "   They are INDEPENDENT! ✅"
  
  test "Multiple models are safe when service reassigns":
    echo "\n========================================="
    echo "TEST: Multiple Models + Service Reassignment"
    echo "=========================================\n"
    
    # Service with original data
    var serviceContainer = @[10, 20, 30].toCowSeq()
    echo "Service: ", serviceContainer.toSeq()
    
    # Model 1 copies
    var model1 = serviceContainer
    echo "Model1 copied"
    check serviceContainer.getRefCount() == 2
    
    # Model 2 copies
    var model2 = serviceContainer
    echo "Model2 copied"
    check serviceContainer.getRefCount() == 3
    
    # Model 3 copies
    var model3 = serviceContainer
    echo "Model3 copied"
    check serviceContainer.getRefCount() == 4
    
    echo "\nAll containers share data, refCount = 4"
    
    # Service reassigns TWICE
    echo "\n Service reassignment #1:"
    serviceContainer = @[100, 200].toCowSeq()
    echo "Service now: ", serviceContainer.toSeq()
    echo "Model1 still: ", model1.toSeq()
    echo "Model2 still: ", model2.toSeq()
    echo "Model3 still: ", model3.toSeq()
    
    check model1.toSeq() == @[10, 20, 30]
    check model2.toSeq() == @[10, 20, 30]
    check model3.toSeq() == @[10, 20, 30]
    check model1.getRefCount() == 3  # Models still share original
    
    echo "\n Service reassignment #2:"
    serviceContainer = @[999].toCowSeq()
    echo "Service now: ", serviceContainer.toSeq()
    echo "Model1 still: ", model1.toSeq()
    
    check model1.toSeq() == @[10, 20, 30]
    check serviceContainer.toSeq() == @[999]
    
    echo "\n ALL MODELS ARE SAFE!"
    echo "   Models have: [10, 20, 30] (original)"
    echo "   Service has: [999] (latest)"
  
  test "Model mutates after service reassigns - both safe":
    echo "\n========================================="
    echo "TEST: Model Mutation After Service Reassignment"
    echo "=========================================\n"
    
    var serviceContainer = @[1, 2, 3].toCowSeq()
    var modelContainer = serviceContainer
    
    echo "Initial state:"
    echo "  Service: ", serviceContainer.toSeq()
    echo "  Model: ", modelContainer.toSeq()
    echo "  Shared refCount: ", serviceContainer.getRefCount()
    
    # Service reassigns
    serviceContainer = @[99, 88].toCowSeq()
    echo "\nAfter service reassigns:"
    echo "  Service: ", serviceContainer.toSeq()
    echo "  Model: ", modelContainer.toSeq()
    
    # Model now mutates its (old) data
    modelContainer.add(4)
    echo "\nAfter model mutates (add 4):"
    echo "  Service: ", serviceContainer.toSeq()
    echo "  Model: ", modelContainer.toSeq()
    
    check serviceContainer.toSeq() == @[99, 88]  # Unchanged
    check modelContainer.toSeq() == @[1, 2, 3, 4]  # Modified
    
    echo "\n BOTH ARE INDEPENDENT!"
  
  test "Real-world service pattern - multiple updates":
    echo "\n========================================="
    echo "TEST: Real Service Update Pattern"
    echo "=========================================\n"
    
    type Item = object
      id: int
      value: string
    
    # Initial service data
    var serviceData = @[
      Item(id: 1, value: "A"),
      Item(id: 2, value: "B")
    ].toCowSeq()
    
    # Model gets initial copy
    var modelData = serviceData
    echo "Model copied initial data: ", modelData.len, " items"
    
    # Service receives update #1
    serviceData = @[
      Item(id: 1, value: "A"),
      Item(id: 2, value: "B_updated"),
      Item(id: 3, value: "C")
    ].toCowSeq()
    
    echo "\nService update #1:"
    echo "  Service items: ", serviceData.len
    echo "  Model items: ", modelData.len
    check modelData.len == 2  # Still has old data
    
    # Model THEN updates from service
    var modelDataNew = serviceData
    echo "\nModel updates from service:"
    echo "  Model old: ", modelData.len, " items"
    echo "  Model new: ", modelDataNew.len, " items"
    
    check modelData.len == 2  # Old copy unchanged
    check modelDataNew.len == 3  # New copy has new data
    
    # Service receives update #2
    serviceData = @[
      Item(id: 1, value: "A_v2")
    ].toCowSeq()
    
    echo "\nService update #2:"
    echo "  Service items: ", serviceData.len
    echo "  Model old: ", modelData.len
    echo "  Model new: ", modelDataNew.len
    
    check modelData.len == 2  # Original still intact!
    check modelDataNew.len == 3  # Previous still intact!
    check serviceData.len == 1  # Latest data
    
    echo "\n PERFECT! Each copy maintains its data!"
    echo "   This is exactly what we need for model diffing!"

echo "\n" & repeat("=", 50)
echo "Assignment Safety Tests"
echo repeat("=", 50)
echo "\nThese tests prove that model data is SAFE"
echo "when the service layer reassigns its CowSeq!"
echo repeat("=", 50)

