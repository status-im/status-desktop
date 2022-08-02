
type
  Item* = ref object
    nodeAddress: string

proc initItem*(nodeAddress: string): Item =
  result = Item()
  result.nodeAddress = nodeAddress

proc nodeAddress*(self: Item): string =
  self.nodeAddress
