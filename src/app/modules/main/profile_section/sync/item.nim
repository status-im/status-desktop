type Item* = ref object
  name: string
  nodeAddress: string

proc initItem*(name, nodeAddress: string): Item =
  result = Item()
  result.name = name
  result.nodeAddress = nodeAddress

proc name*(self: Item): string =
  self.name

proc nodeAddress*(self: Item): string =
  self.nodeAddress
