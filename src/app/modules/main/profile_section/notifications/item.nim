type
  Item* = object
    id: string
    name: string
    icon: string
    color: string

proc initItem*(id, name, icon: string, color: string): Item =
  result = Item()
  result.id = id
  result.name = name
  result.icon = icon
  result.color = color

proc id*(self: Item): string =
  self.id

proc name*(self: Item): string =
  self.name

proc icon*(self: Item): string =
  self.icon

proc color*(self: Item): string =
  self.color
