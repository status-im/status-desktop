type
  Item* = object
    id: string
    name: string
    icon: string
    isIdenticon: bool
    color: string

proc initItem*(id, name, icon: string, isIdenticon: bool, color: string): Item =
  result = Item()
  result.id = id
  result.name = name
  result.icon = icon
  result.isIdenticon = isIdenticon
  result.color = color

proc id*(self: Item): string =
  self.id

proc name*(self: Item): string =
  self.name

proc icon*(self: Item): string =
  self.icon

proc isIdenticon*(self: Item): bool =
  self.isIdenticon

proc color*(self: Item): string =
  self.color
