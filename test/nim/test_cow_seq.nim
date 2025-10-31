## Comprehensive test suite for CowSeq
## Tests all operations, CoW semantics, edge cases, and performance

import unittest
import ../../src/app/core/cow_seq
import std/[times, monotimes, strformat, strutils]

suite "CowSeq - Basic Operations":
  
  test "Empty CowSeq creation":
    var empty = newCowSeq[int]()
    check empty.len == 0
    check empty.high == -1
    check empty.low == 0
  
  test "CowSeq from seq":
    let data = @[1, 2, 3, 4, 5]
    var cow = data.toCowSeq()
    check cow.len == 5
    check cow[0] == 1
    check cow[4] == 5
  
  test "CowSeq with pre-allocated size":
    var cow = newCowSeq[int](10)
    check cow.len == 10
    check cow[0] == 0  # Default value
  
  test "Add elements":
    var cow = newCowSeq[int]()
    cow.add(1)
    cow.add(2)
    cow.add(3)
    check cow.len == 3
    check cow[0] == 1
    check cow[2] == 3
  
  test "Index assignment":
    var cow = @[1, 2, 3].toCowSeq()
    cow[1] = 99
    check cow[1] == 99
    check cow.asSeq() == @[1, 99, 3]
  
  test "Delete element":
    var cow = @[1, 2, 3, 4, 5].toCowSeq()
    cow.delete(2)  # Delete 3
    check cow.len == 4
    check cow.asSeq() == @[1, 2, 4, 5]
  
  test "Delete range":
    var cow = @[1, 2, 3, 4, 5].toCowSeq()
    cow.delete(1, 3)  # Delete 2, 3, 4
    check cow.len == 2
    check cow.asSeq() == @[1, 5]
  
  test "Insert element":
    var cow = @[1, 3, 4].toCowSeq()
    cow.insert(2, 1)  # Insert 2 at index 1
    check cow.asSeq() == @[1, 2, 3, 4]
  
  test "SetLen grow":
    var cow = @[1, 2, 3].toCowSeq()
    cow.setLen(5)
    check cow.len == 5
    check cow[0] == 1
    check cow[4] == 0  # New elements are default
  
  test "SetLen shrink":
    var cow = @[1, 2, 3, 4, 5].toCowSeq()
    cow.setLen(3)
    check cow.len == 3
    check cow.asSeq() == @[1, 2, 3]

suite "CowSeq - Iteration":
  
  test "Iterate items":
    let cow = @[1, 2, 3, 4, 5].toCowSeq()
    var sum = 0
    for item in cow:
      sum += item
    check sum == 15
  
  test "Iterate pairs":
    let cow = @[10, 20, 30].toCowSeq()
    var indices: seq[int] = @[]
    var values: seq[int] = @[]
    for i, val in cow:
      indices.add(i)
      values.add(val)
    check indices == @[0, 1, 2]
    check values == @[10, 20, 30]
  
  test "Mutable iteration":
    var cow = @[1, 2, 3].toCowSeq()
    for item in cow.mitems:
      item *= 2
    check cow.asSeq() == @[2, 4, 6]

suite "CowSeq - Copy-on-Write Semantics":
  
  test "Copy shares memory (O(1))":
    var original = @[1, 2, 3, 4, 5].toCowSeq()
    var copy = original
    
    # Both should share the same data
    check original.getRefCount() == 2
    check copy.getRefCount() == 2
    check original.isShared() == true
    check copy.isShared() == true
  
  test "Mutation triggers CoW":
    var original = @[1, 2, 3].toCowSeq()
    var copy = original
    
    echo "\nBefore mutation:"
    echo fmt"  original refCount: {original.getRefCount()}"
    echo fmt"  copy refCount: {copy.getRefCount()}"
    
    # Trigger CoW
    copy[0] = 99
    
    echo "After mutation:"
    echo fmt"  original refCount: {original.getRefCount()}"
    echo fmt"  copy refCount: {copy.getRefCount()}"
    echo fmt"  original[0]: {original[0]}"
    echo fmt"  copy[0]: {copy[0]}"
    
    # Original unchanged
    check original[0] == 1
    check original.asSeq() == @[1, 2, 3]
    
    # Copy modified
    check copy[0] == 99
    check copy.asSeq() == @[99, 2, 3]
    
    # Now independent
    check original.getRefCount() == 1
    check copy.getRefCount() == 1
    check original.isShared() == false
    check copy.isShared() == false
  
  test "Add triggers CoW":
    var original = @[1, 2, 3].toCowSeq()
    var copy = original
    
    copy.add(4)
    
    check original.asSeq() == @[1, 2, 3]
    check copy.asSeq() == @[1, 2, 3, 4]
  
  test "Delete triggers CoW":
    var original = @[1, 2, 3, 4, 5].toCowSeq()
    var copy = original
    
    copy.delete(2)
    
    check original.asSeq() == @[1, 2, 3, 4, 5]
    check copy.asSeq() == @[1, 2, 4, 5]
  
  test "Multiple copies share memory":
    var original = @[1, 2, 3].toCowSeq()
    var copy1 = original
    var copy2 = original
    var copy3 = original
    
    check original.getRefCount() == 4
    check copy1.isShared() == true
    check copy2.isShared() == true
    check copy3.isShared() == true
  
  test "Mutation isolates only one copy":
    var original = @[1, 2, 3].toCowSeq()
    var copy1 = original
    var copy2 = original
    
    # copy1 mutates - splits off
    copy1[0] = 99
    
    # original and copy2 still share
    check original.getRefCount() == 2
    check copy2.getRefCount() == 2
    check copy1.getRefCount() == 1
    
    check original[0] == 1
    check copy2[0] == 1
    check copy1[0] == 99

suite "CowSeq - seq API Compatibility":
  
  test "Slicing":
    let cow = @[0, 1, 2, 3, 4, 5].toCowSeq()
    let slice1: seq[int] = @[1, 2, 3]
    let slice2: seq[int] = @[0]
    let slice3: seq[int] = @[5]
    check cow[1..3] == slice1
    check cow[0..0] == slice2
    check cow[5..5] == slice3
  
  test "Contains":
    let cow = @[1, 2, 3, 4, 5].toCowSeq()
    check cow.contains(3) == true
    check cow.contains(99) == false
  
  test "Find":
    let cow = @[10, 20, 30, 40].toCowSeq()
    check cow.find(20) == 1
    check cow.find(40) == 3
    check cow.find(99) == -1
  
  test "Equality":
    let cow1 = @[1, 2, 3].toCowSeq()
    let cow2 = @[1, 2, 3].toCowSeq()
    let cow3 = @[1, 2, 4].toCowSeq()
    
    check cow1 == cow2
    check cow1 != cow3
  
  test "Equality with shared reference":
    var cow1 = @[1, 2, 3].toCowSeq()
    var cow2 = cow1  # Same reference
    
    check cow1 == cow2  # Should be O(1)
  
  test "String representation":
    let cow = @[1, 2, 3].toCowSeq()
    check $cow == "@[1, 2, 3]"
    
    let empty = newCowSeq[int]()
    check $empty == "@[]"
  
  test "Add seq to CowSeq":
    var cow = @[1, 2].toCowSeq()
    cow.add(@[3, 4, 5])
    check cow.asSeq() == @[1, 2, 3, 4, 5]
  
  test "Add CowSeq to CowSeq":
    var cow1 = @[1, 2].toCowSeq()
    let cow2 = @[3, 4].toCowSeq()
    cow1.add(cow2)
    check cow1.asSeq() == @[1, 2, 3, 4]

suite "CowSeq - Edge Cases":
  
  test "Operations on empty CowSeq":
    var empty = newCowSeq[int]()
    check empty.len == 0
    check empty.contains(1) == false
    check empty.find(1) == -1
    let emptySeq: seq[int] = @[]
    check empty.asSeq() == emptySeq
    check $empty == "@[]"
  
  test "Add to empty":
    var empty = newCowSeq[int]()
    empty.add(1)
    check empty.len == 1
    check empty[0] == 1
  
  test "Copy empty CowSeq":
    var empty1 = newCowSeq[int]()
    var empty2 = empty1
    empty2.add(1)
    
    check empty1.len == 0
    check empty2.len == 1
  
  test "Boundary access":
    let cow = @[1, 2, 3].toCowSeq()
    check cow[0] == 1
    check cow[2] == 3
    # Note: Out of bounds should raise, not test here
  
  test "Large dataset":
    var cow = newCowSeq[int]()
    for i in 0..<1000:
      cow.add(i)
    
    check cow.len == 1000
    check cow[0] == 0
    check cow[999] == 999
    
    var sum = 0
    for item in cow:
      sum += item
    check sum == 499500  # Sum of 0..999

suite "CowSeq - Value Types (Critical for DTOs)":
  
  type
    SimpleItem = object
      id: int
      value: string
    
    NestedItem = object
      id: int
      items: seq[SimpleItem]
  
  test "Value type isolation - simple":
    let originalSeq: seq[SimpleItem] = @[
      SimpleItem(id: 1, value: "A"),
      SimpleItem(id: 2, value: "B")
    ]
    var original = originalSeq.toCowSeq()
    
    var copy = original
    var mutableCopy = copy.asSeq()
    mutableCopy[0].value = "MODIFIED"
    copy = mutableCopy.toCowSeq()
    
    check original[0].value == "A"
    check copy[0].value == "MODIFIED"
    echo "Value types provide isolation!"
  
  test "Value type isolation - nested":
    let originalSeq: seq[NestedItem] = @[
      NestedItem(id: 1, items: @[
        SimpleItem(id: 10, value: "X"),
        SimpleItem(id: 20, value: "Y")
      ])
    ]
    var original = originalSeq.toCowSeq()
    
    var copy = original
    var mutableSeq = copy.asSeq()
    mutableSeq[0].items[0].value = "CHANGED"
    copy = mutableSeq.toCowSeq()
    
    check original[0].items[0].value == "X"
    check copy[0].items[0].value == "CHANGED"
    echo "Nested value types provide isolation!"

suite "CowSeq - Performance":
  
  test "Copy performance (should be O(1))":
    let size = 10000
    var original = newCowSeq[int]()
    for i in 0..<size:
      original.add(i)
    
    let iterations = 1000
    let start = getMonoTime()
    for i in 0..<iterations:
      let copy = original  # Should be O(1)
    let elapsed = (getMonoTime() - start).inMicroseconds
    
    let avgTime = elapsed div iterations
    echo fmt"\nCopy performance ({size} items):"
    echo fmt"  Total: {elapsed} μs for {iterations} copies"
    echo fmt"  Average: {avgTime} μs per copy"
    
    # Should be near-instant (< 10 μs per copy)
    check avgTime < 10
    echo "Copy is O(1)!"
  
  test "CoW trigger performance":
    let size = 10000
    var original = newCowSeq[int]()
    for i in 0..<size:
      original.add(i)
    
    var copy = original
    
    let start = getMonoTime()
    copy[0] = 999  # Triggers CoW (O(n))
    let elapsed = (getMonoTime() - start).inMicroseconds
    
    echo fmt"\nCoW trigger ({size} items):"
    echo fmt"  Time: {elapsed} μs"
    echo fmt"  Per item: {elapsed div size} μs"
    
    # Should be linear
    check copy[0] == 999
    check original[0] == 0
    echo "CoW works correctly!"
  
  test "Sequential access performance":
    let size = 100000
    var cow = newCowSeq[int]()
    for i in 0..<size:
      cow.add(i)
    
    let start = getMonoTime()
    var sum = 0
    for item in cow:
      sum += item
    let elapsed = (getMonoTime() - start).inMicroseconds
    
    echo fmt"\nSequential access ({size} items):"
    echo fmt"  Time: {elapsed} μs"
    echo fmt"  Per item: {float(elapsed) / float(size):.2f} μs"
    
    check sum == 4999950000
    echo "Sequential access is efficient!"

suite "CowSeq - Memory Behavior":
  
  test "Reference counting":
    var cow1 = @[1, 2, 3].toCowSeq()
    check cow1.getRefCount() == 1
    
    var cow2 = cow1
    check cow1.getRefCount() == 2
    check cow2.getRefCount() == 2
    
    var cow3 = cow1
    check cow1.getRefCount() == 3
    
    # Trigger CoW on cow2
    cow2.add(4)
    check cow1.getRefCount() == 2  # cow1 and cow3
    check cow2.getRefCount() == 1  # cow2 is now independent
    check cow3.getRefCount() == 2
  
  test "Scope and cleanup":
    var outer = @[1, 2, 3].toCowSeq()
    check outer.getRefCount() == 1
    
    block:
      var inner = outer
      check outer.getRefCount() == 2
      # inner goes out of scope here
    
    # Reference count should be back to 1
    check outer.getRefCount() == 1
  
  test "Multiple mutations don't accumulate copies":
    var cow = @[1, 2, 3].toCowSeq()
    check cow.getRefCount() == 1
    
    # Multiple mutations on exclusive owner (no CoW)
    cow[0] = 10
    cow[1] = 20
    cow[2] = 30
    
    check cow.getRefCount() == 1
    check cow.asSeq() == @[10, 20, 30]

echo "\n" & repeat("=", 50)
echo "CowSeq Comprehensive Test Suite"
echo repeat("=", 50)
echo ""

