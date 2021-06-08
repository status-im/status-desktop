import typetraits
import edn, chronicles
import ../types # FIXME: there should be no type deps

# forward declaration:
proc parseNode[T](node: EdnNode, searchName: string): T
proc parseMap[T](map: HMap, searchName: string,): T

proc getValueFromNode[T](node: EdnNode): T =
  if node.kind == EdnSymbol:
    when T is string:
      result = node.symbol.name
  elif node.kind == EdnKeyword:
    when T is string:
      result = node.keyword.name
  elif node.kind == EdnString:
    when T is string:
      result = node.str
  elif node.kind == EdnCharacter:
    when T is string:
      result = node.character
  elif node.kind == EdnBool:
    when T is bool:
      result = node.boolVal
  elif node.kind == EdnInt:
    when T is int:
      try:
        result = cast[int](node.num)
      except:
        warn "Returned 0 value for node, when value should have been ", val = $node.num
        result = 0
  else:
    raise newException(ValueError, "couldn't get '" & T.type.name & "'value from node: " & repr(node))

proc parseVector[T: seq[Sticker]](node: EdnNode, searchName: string): seq[Sticker] =
  # TODO: make this generic to accept any seq[T]. Issue is that instantiating result 
  # like `result = T()` is not allowed when T is `seq[Sticker]`
  # because seq[Sticker] isn't an object, whereas it works when T is
  # an object type (like Sticker). IOW, Sticker is an object type, but seq[Sticker]
  # is not
  result = newSeq[Sticker]()

  for i in 0..<node.vec.len:
    var sticker: Sticker = Sticker()
    let child = node.vec[i]
    if child.kind == EdnMap:
      for k, v in sticker.fieldPairs:
        v = parseMap[v.type](child.map, k)
      result.add(sticker)

proc parseMap[T](map: HMap, searchName: string): T =
  for iBucket in 0..<map.buckets.len:
    let bucket = map.buckets[iBucket]
    if bucket.len > 0:
      for iChild in 0..<bucket.len:
        let child = bucket[iChild]
        let isRoot = child.key.kind == EdnSymbol and child.key.symbol.name == "meta"
        if child.key.kind != EdnKeyword and not isRoot:
          continue
        if isRoot or child.key.keyword.name == searchName:
          if child.value.kind == EdnMap:
            result = parseMap[T](child.value.map, searchName)
            break
          elif child.value.kind == EdnVector:
            when T is seq[Sticker]:
              result = parseVector[T](child.value, searchName)
              break
          result = getValueFromNode[T](child.value)
          break

proc parseNode[T](node: EdnNode, searchName: string): T =
  if node.kind == EdnMap:
    result = parseMap[T](node.map, searchName)
  else:
    result = getValueFromNode[T](node)

proc decode*[T](node: EdnNode): T =
  result = T()
  for k, v in result.fieldPairs:
    v = parseNode[v.type](node, k)

proc decode*[T](edn: string): T =
  decode[T](read(edn))