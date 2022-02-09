type
  BaseItem* {.pure inheritable.} = ref object of RootObj
    value: string
    text: string
    image: string
    icon: string
    iconColor: string
    isIdenticon: bool

proc setup*(self: BaseItem, value, text, image, icon, iconColor: string, isIdenticon: bool) =
  self.value = value
  self.text = text
  self.image = image
  self.icon = icon
  self.iconColor = iconColor
  self.isIdenticon = isIdenticon

proc initBaseItem*(value, text, image, icon, iconColor: string, isIdenticon: bool): BaseItem =
  result = BaseItem()
  result.setup(value, text, image, icon, iconColor, isIdenticon)

proc delete*(self: BaseItem) =
  discard

method value*(self: BaseItem): string {.inline base.} =
  self.value

method text*(self: BaseItem): string {.inline base.} =
  self.text

method image*(self: BaseItem): string {.inline base.} =
  self.image

method icon*(self: BaseItem): string {.inline base.} =
  self.icon

method iconColor*(self: BaseItem): string {.inline base.} =
  self.iconColor

method isIdenticon*(self: BaseItem): bool {.inline base.} =
  self.isIdenticon
