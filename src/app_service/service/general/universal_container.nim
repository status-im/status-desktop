
type
  ItemKind* = enum
    vkInt, vkString, vkFloat, vkBool, vkSeqInt, vkSeqString

  Item* = object
    case kind: ItemKind
    of vkInt: intVal: int
    of vkString: strVal: string
    of vkFloat: floatVal: float
    of vkBool: boolVal: bool
    of vkSeqInt: seqIntVal: seq[int]
    of vkSeqString: seqStringVal: seq[string]

  Container* = ref object
    items: seq[Item]

proc newContainer*(): Container =
  return new(Container)

proc clear*(self: Container) =
  self.items = @[]

proc add*(self: Container, item: int) =
  self.items.add(Item(kind: vkInt, intVal: item))

proc add*(self: Container, item: string) =
  self.items.add(Item(kind: vkString, strVal: item))

proc add*(self: Container, item: float) =
  self.items.add(Item(kind: vkFloat, floatVal: item))

proc add*(self: Container, item: bool) =
  self.items.add(Item(kind: vkBool, boolVal: item))

proc add*(self: Container, item: seq[int]) =
  self.items.add(Item(kind: vkSeqInt, seqIntVal: item))

proc add*(self: Container, item: seq[string]) =
  self.items.add(Item(kind: vkSeqString, seqStringVal: item))

proc getInt(v: Item): int =
  assert v.kind == vkInt, "Expected int but got " & $v.kind
  return v.intVal

proc getStr(v: Item): string =
  assert v.kind == vkString, "Expected string but got " & $v.kind
  return v.strVal

proc getFloat(v: Item): float =
  assert v.kind == vkFloat, "Expected float but got " & $v.kind
  return v.floatVal

proc getBool(v: Item): bool =
  assert v.kind == vkBool, "Expected bool but got " & $v.kind
  return v.boolVal

proc getSeqInt(v: Item): seq[int] =
  assert v.kind == vkSeqInt, "Expected seq[int] but got " & $v.kind
  return v.seqIntVal

proc getSeqString(v: Item): seq[string] =
  assert v.kind == vkSeqString, "Expected seq[string] but got " & $v.kind
  return v.seqStringVal

proc extract*[T](v: Item): T =
  when T is int:
    return v.getInt()
  elif T is string:
    return v.getStr()
  elif T is float:
    return v.getFloat()
  elif T is bool:
    return v.getBool()
  elif T is seq[int]:
    return v.getSeqInt()
  elif T is seq[string]:
    return v.getSeqString()
  else:
    raise "Unsupported type for extraction"

proc getItemAtPosition*(self: Container, position: int): Item =
  assert position >= 0 and position < self.items.len
  return self.items[position]

proc getValueAtPosition*[T](self: Container, position: int): T =
  let item = self.getItemAtPosition(position)
  return extract[T](item)