## Test: CoW with ref object vs object
## Critical test to understand if ref objects inside CoW seqs are safe

import unittest
import stint

# Simplified DTOs for testing
type
  BalanceItemRef* = ref object of RootObj
    account*: string
    chainId*: int
    balance*: Uint256

  BalanceItemValue* = object
    account*: string
    chainId*: int
    balance*: Uint256

  GroupedTokenItemRef* = ref object of RootObj
    tokensKey*: string
    symbol*: string
    balancesPerAccount*: seq[BalanceItemRef]

  GroupedTokenItemValue* = object
    tokensKey*: string
    symbol*: string
    balancesPerAccount*: seq[BalanceItemValue]

# Simple CoW implementation for testing
type
  CowSeqData[T] = ref object
    data: seq[T]
    refCount: int

  CowSeq*[T] = object
    dataRef: CowSeqData[T]

proc newCowSeq*[T](initialData: seq[T] = @[]): CowSeq[T] =
  result.dataRef = CowSeqData[T](data: initialData, refCount: 1)

proc `=copy`*[T](dest: var CowSeq[T], src: CowSeq[T]) =
  dest.dataRef = src.dataRef
  if not dest.dataRef.isNil:
    dest.dataRef.refCount.inc

proc `=destroy`*[T](x: var CowSeq[T]) =
  if not x.dataRef.isNil:
    x.dataRef.refCount.dec
    if x.dataRef.refCount <= 0:
      x.dataRef = nil

proc ensureUnique[T](self: var CowSeq[T]) =
  if self.dataRef.isNil:
    self.dataRef = CowSeqData[T](data: @[], refCount: 1)
  elif self.dataRef.refCount > 1:
    # Copy-on-Write happens here!
    let newData = self.dataRef.data  # This copies the seq
    self.dataRef.refCount.dec
    self.dataRef = CowSeqData[T](data: newData, refCount: 1)

proc len*[T](self: CowSeq[T]): int =
  if self.dataRef.isNil: 0
  else: self.dataRef.data.len

proc `[]`*[T](self: CowSeq[T], idx: int): lent T =
  self.dataRef.data[idx]

proc getMutable*[T](self: var CowSeq[T]): var seq[T] =
  self.ensureUnique()
  return self.dataRef.data

proc toSeq*[T](self: CowSeq[T]): seq[T] =
  if self.dataRef.isNil: @[]
  else: self.dataRef.data

suite "CoW Behavior: ref object vs object - CRITICAL TEST":
  
  test "ref object: Modifying nested item DOES affect original (PROBLEM!)":
    # Create with ref objects
    var balance1 = BalanceItemRef(account: "0x123", chainId: 1, balance: u256(100))
    var token1 = GroupedTokenItemRef(
      tokensKey: "ETH",
      symbol: "ETH",
      balancesPerAccount: @[balance1]
    )
    
    var originalCow = newCowSeq(@[token1])
    var copyCow = originalCow  # CoW copy
    
    echo "\n=== REF OBJECT TEST ==="
    echo "Original balance before: ", originalCow[0].balancesPerAccount[0].balance
    
    # Trigger CoW for the seq
    var mutableCopy = copyCow.getMutable()
    
    # Modify the balance in the copy
    mutableCopy[0].balancesPerAccount[0].balance = u256(999)
    
    echo "Copy balance after mutation: ", copyCow[0].balancesPerAccount[0].balance
    echo "Original balance after mutation: ", originalCow[0].balancesPerAccount[0].balance
    
    # CRITICAL: Check if original was affected
    if originalCow[0].balancesPerAccount[0].balance == u256(999):
      echo "PROBLEM: Original was modified! ref objects share memory!"
      check false  # This test SHOULD FAIL with ref objects
    else:
      echo "Original unchanged (unexpected for ref objects)"
      check true
  
  test "object (value type): Modifying nested item does NOT affect original (SAFE!)":
    # Create with value types
    var balance1 = BalanceItemValue(account: "0x123", chainId: 1, balance: u256(100))
    var token1 = GroupedTokenItemValue(
      tokensKey: "ETH",
      symbol: "ETH",
      balancesPerAccount: @[balance1]
    )
    
    var originalCow = newCowSeq(@[token1])
    var copyCow = originalCow  # CoW copy
    
    echo "\n=== VALUE TYPE TEST ==="
    echo "Original balance before: ", originalCow[0].balancesPerAccount[0].balance
    
    # Trigger CoW for the seq
    var mutableCopy = copyCow.getMutable()
    
    # Modify the balance in the copy
    mutableCopy[0].balancesPerAccount[0].balance = u256(999)
    
    echo "Copy balance after mutation: ", copyCow[0].balancesPerAccount[0].balance
    echo "Original balance after mutation: ", originalCow[0].balancesPerAccount[0].balance
    
    # CRITICAL: Check if original was affected
    if originalCow[0].balancesPerAccount[0].balance == u256(100):
      echo "SAFE: Original unchanged! Value types provide isolation!"
      check true
    else:
      echo "Original was modified (unexpected for value types)"
      check false
  
  test "ref object: Seq copy is shallow - items are shared!":
    var balance1 = BalanceItemRef(account: "0x123", chainId: 1, balance: u256(100))
    var token1 = GroupedTokenItemRef(tokensKey: "ETH", symbol: "ETH", balancesPerAccount: @[balance1])
    
    let originalSeq = @[token1]
    let copiedSeq = originalSeq  # Nim seq copy
    
    echo "\n=== REF OBJECT SEQ COPY ==="
    echo "Original address: ", cast[uint](originalSeq[0])
    echo "Copied address: ", cast[uint](copiedSeq[0])
    
    if cast[uint](originalSeq[0]) == cast[uint](copiedSeq[0]):
      echo "PROBLEM: Both seqs point to SAME ref object!"
      check true  # This is expected for ref objects
    else:
      echo "Different objects (unexpected)"
      check false
  
  test "object: Seq copy is deep - items are independent!":
    var balance1 = BalanceItemValue(account: "0x123", chainId: 1, balance: u256(100))
    var token1 = GroupedTokenItemValue(tokensKey: "ETH", symbol: "ETH", balancesPerAccount: @[balance1])
    
    let originalSeq = @[token1]
    var copiedSeq = originalSeq  # Nim seq copy
    
    echo "\n=== VALUE TYPE SEQ COPY ==="
    echo "Original balance: ", originalSeq[0].balancesPerAccount[0].balance
    echo "Copied balance: ", copiedSeq[0].balancesPerAccount[0].balance
    
    # Modify copy
    copiedSeq[0].balancesPerAccount[0].balance = u256(999)
    
    echo "After modification:"
    echo "Original balance: ", originalSeq[0].balancesPerAccount[0].balance
    echo "Copied balance: ", copiedSeq[0].balancesPerAccount[0].balance
    
    if originalSeq[0].balancesPerAccount[0].balance == u256(100):
      echo "SAFE: Original unchanged! Value types are independent!"
      check true
    else:
      echo "Original was modified"
      check false
  
  test "PROOF: ref object modification affects all references":
    var balance = BalanceItemRef(account: "0x123", chainId: 1, balance: u256(100))
    
    let ref1 = balance
    let ref2 = balance
    let ref3 = balance
    
    echo "\n=== REF SHARING TEST ==="
    echo "All refs point to same object: ", cast[uint](ref1) == cast[uint](ref2)
    
    # Modify via ref1
    ref1.balance = u256(999)
    
    echo "ref1 balance: ", ref1.balance
    echo "ref2 balance: ", ref2.balance
    echo "ref3 balance: ", ref3.balance
    echo "original balance: ", balance.balance
    
    # All should show 999!
    check ref1.balance == u256(999)
    check ref2.balance == u256(999)
    check ref3.balance == u256(999)
    check balance.balance == u256(999)
    
    echo "CONFIRMED: All references share the same object!"

echo "Running CoW ref vs value tests..."
echo "This will show if ref objects inside CoW containers are safe or not."





