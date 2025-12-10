## Copy-on-Write Sequence Container
## 
## Provides a seq-like container with transparent Copy-on-Write semantics.
## Memory is shared until a mutation occurs, at which point a copy is made.
##
## Key features:
## - Transparent CoW via =copy hook
## - seq-compatible API
## - O(1) copy operations
## - O(n) mutation operations (only when shared)
## - Value type semantics (can be copied, no GC pressure)
##
## Example:
## ```nim
## var original = @[1, 2, 3].toCowSeq()
## var copy = original  # O(1) - shares memory
## copy.add(4)          # Copy-on-Write triggered
## # original: [1, 2, 3]
## # copy: [1, 2, 3, 4]
## ```

import std/[hashes]

type
  CowSeqData*[T] = ref object
    ## Internal data container with reference counting
    data: seq[T]
    refCount: int

  CowSeq*[T] = object
    ## Copy-on-Write sequence container
    ## Behaves like seq[T] but shares memory until mutation
    dataRef: CowSeqData[T]

#
# Constructors
#

proc newCowSeq*[T](initialData: seq[T] = @[]): CowSeq[T] =
  ## Create a new CowSeq from a regular seq
  ## Time: O(1) - just wraps the seq
  result.dataRef = CowSeqData[T](data: initialData, refCount: 1)

proc newCowSeq*[T](size: int): CowSeq[T] =
  ## Create a new CowSeq with pre-allocated size
  ## Time: O(n)
  result.dataRef = CowSeqData[T](data: newSeq[T](size), refCount: 1)

proc toCowSeq*[T](s: seq[T]): CowSeq[T] {.inline.} =
  ## Convert a regular seq to CowSeq
  ## Time: O(1)
  newCowSeq(s)

#
# Lifecycle hooks (transparent CoW!)
#

proc `=copy`*[T](dest: var CowSeq[T], src: CowSeq[T]) =
  ## Copy hook - implements transparent Copy-on-Write
  ## This makes copies O(1) by sharing the reference
  if dest.dataRef == src.dataRef:
    return  # Self-assignment
  
  # Release old reference
  if not dest.dataRef.isNil:
    dest.dataRef.refCount.dec
    if dest.dataRef.refCount <= 0:
      dest.dataRef = nil
  
  # Share new reference
  dest.dataRef = src.dataRef
  if not dest.dataRef.isNil:
    dest.dataRef.refCount.inc

proc `=destroy`*[T](x: var CowSeq[T]) =
  ## Destructor - decrements reference count
  if not x.dataRef.isNil:
    x.dataRef.refCount.dec
    if x.dataRef.refCount <= 0:
      # Last reference, clean up
      x.dataRef = nil

proc `=sink`*[T](dest: var CowSeq[T], src: CowSeq[T]) =
  ## Sink hook - transfers ownership without incrementing refcount
  if dest.dataRef == src.dataRef:
    return
  
  if not dest.dataRef.isNil:
    dest.dataRef.refCount.dec
    if dest.dataRef.refCount <= 0:
      dest.dataRef = nil
  
  dest.dataRef = src.dataRef

#
# Internal: Copy-on-Write trigger
#

proc ensureUnique[T](self: var CowSeq[T]) =
  ## Ensure this CowSeq has exclusive ownership of its data
  ## Triggers Copy-on-Write if data is shared
  ## Time: O(1) if not shared, O(n) if shared
  if self.dataRef.isNil:
    self.dataRef = CowSeqData[T](data: @[], refCount: 1)
  elif self.dataRef.refCount > 1:
    # Copy-on-Write happens here!
    let newData = self.dataRef.data  # Deep copy of seq
    self.dataRef.refCount.dec
    self.dataRef = CowSeqData[T](data: newData, refCount: 1)

#
# Read-only operations (O(1), no CoW)
#

proc len*[T](self: CowSeq[T]): int {.inline.} =
  ## Return the number of elements
  ## Time: O(1)
  if self.dataRef.isNil: 0
  else: self.dataRef.data.len

proc high*[T](self: CowSeq[T]): int {.inline.} =
  ## Return the highest valid index
  ## Time: O(1)
  self.len - 1

proc low*[T](self: CowSeq[T]): int {.inline.} =
  ## Return the lowest valid index (always 0)
  ## Time: O(1)
  0

proc `[]`*[T](self: CowSeq[T], idx: int): lent T {.inline.} =
  ## Access element at index (read-only)
  ## Time: O(1)
  self.dataRef.data[idx]

proc `[]`*[T](self: CowSeq[T], slice: HSlice[int, int]): seq[T] =
  ## Return a slice as a regular seq
  ## Time: O(k) where k is slice size
  if self.dataRef.isNil:
    return @[]
  self.dataRef.data[slice]

#
# Mutable operations (trigger CoW if shared)
#

proc `[]=`*[T](self: var CowSeq[T], idx: int, val: T) =
  ## Set element at index
  ## Time: O(1) if not shared, O(n) if shared (CoW)
  self.ensureUnique()
  self.dataRef.data[idx] = val

proc add*[T](self: var CowSeq[T], val: T) =
  ## Add element to end
  ## Time: O(1) amortized if not shared, O(n) if shared (CoW)
  self.ensureUnique()
  self.dataRef.data.add(val)

proc add*[T](self: var CowSeq[T], other: CowSeq[T]) =
  ## Add all elements from another CowSeq
  ## Time: O(k) where k is other.len
  if other.len == 0:
    return
  self.ensureUnique()
  for item in other:
    self.dataRef.data.add(item)

proc add*[T](self: var CowSeq[T], other: seq[T]) =
  ## Add all elements from a regular seq
  ## Time: O(k) where k is other.len
  if other.len == 0:
    return
  self.ensureUnique()
  self.dataRef.data.add(other)

proc delete*[T](self: var CowSeq[T], idx: int) =
  ## Delete element at index
  ## Time: O(n)
  self.ensureUnique()
  self.dataRef.data.delete(idx)

proc delete*[T](self: var CowSeq[T], first: int, last: int) =
  ## Delete range of elements [first..last]
  ## Time: O(n)
  self.ensureUnique()
  # Nim's seq.delete doesn't have range, do it manually
  for i in countdown(last, first):
    self.dataRef.data.delete(i)

proc insert*[T](self: var CowSeq[T], val: T, idx: int = 0) =
  ## Insert element at index
  ## Time: O(n)
  self.ensureUnique()
  self.dataRef.data.insert(val, idx)

proc setLen*[T](self: var CowSeq[T], newLen: int) =
  ## Set length (grows or shrinks)
  ## Time: O(1) if shrinking, O(k) if growing
  self.ensureUnique()
  self.dataRef.data.setLen(newLen)

#
# Iteration
#

iterator items*[T](self: CowSeq[T]): lent T =
  ## Iterate over elements (read-only)
  if not self.dataRef.isNil:
    for item in self.dataRef.data:
      yield item

iterator mitems*[T](self: var CowSeq[T]): var T =
  ## Iterate over elements (mutable)
  ## Triggers CoW if shared
  self.ensureUnique()
  for item in self.dataRef.data.mitems:
    yield item

iterator pairs*[T](self: CowSeq[T]): tuple[key: int, val: lent T] =
  ## Iterate over (index, element) pairs
  if not self.dataRef.isNil:
    for i, item in self.dataRef.data.pairs:
      yield (i, item)

#
# Conversion
#

proc asSeq*[T](self: CowSeq[T]): seq[T] =
  ## Convert to regular seq (creates a copy)
  ## Named asSeq to avoid collision with sequtils.toSeq
  ## Time: O(1) if just reading, O(n) if copying
  if self.dataRef.isNil: @[]
  else: self.dataRef.data

proc toOpenArray*[T](self: CowSeq[T], first, last: int): seq[T] =
  ## Return a slice as a seq
  ## Time: O(k) where k is slice size
  if self.dataRef.isNil or first > last or first < 0:
    return @[]
  
  let lastIdx = min(last, self.high)
  result = newSeq[T](lastIdx - first + 1)
  for i in first..lastIdx:
    result[i - first] = self.dataRef.data[i]

#
# Comparison
#

proc `==`*[T](a, b: CowSeq[T]): bool =
  ## Equality comparison
  ## Time: O(1) if same reference, O(n) otherwise
  if a.dataRef == b.dataRef:
    return true  # Same reference, definitely equal
  
  if a.len != b.len:
    return false
  
  for i in 0..<a.len:
    if a[i] != b[i]:
      return false
  
  return true

proc hash*[T](self: CowSeq[T]): Hash =
  ## Hash function for use in tables/sets
  ## Time: O(n)
  var h: Hash = 0
  for item in self:
    h = h !& hash(item)
  result = !$h

#
# Utility
#

proc contains*[T](self: CowSeq[T], val: T): bool =
  ## Check if value exists in sequence
  ## Time: O(n)
  if self.dataRef.isNil:
    return false
  for item in self.dataRef.data:
    if item == val:
      return true
  return false

proc find*[T](self: CowSeq[T], val: T): int =
  ## Find index of value, returns -1 if not found
  ## Time: O(n)
  if self.dataRef.isNil:
    return -1
  for i, item in self.dataRef.data:
    if item == val:
      return i
  return -1

proc `$`*[T](self: CowSeq[T]): string =
  ## String representation
  if self.dataRef.isNil:
    return "@[]"
  result = "@["
  for i, item in self:
    if i > 0:
      result.add(", ")
    result.add($item)
  result.add("]")

#
# Debug helpers
#

proc getRefCount*[T](self: CowSeq[T]): int =
  ## Get current reference count (for debugging/testing)
  if self.dataRef.isNil: 0
  else: self.dataRef.refCount

proc isShared*[T](self: CowSeq[T]): bool =
  ## Check if this CowSeq shares data with others
  if self.dataRef.isNil: false
  else: self.dataRef.refCount > 1

