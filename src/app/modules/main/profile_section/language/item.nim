type
  Item* = object
    locale: string
    name: string
    native: string
    flag: string # unicode emoji

proc initItem*(locale, name, native, flag: string): Item =
  result.locale = locale
  result.name = name
  result.native = native
  result.flag = flag

proc locale*(self: Item): string {.inline.} =
  self.locale

proc name*(self: Item): string {.inline.} =
  self.name

proc native*(self: Item): string {.inline.} =
  self.native

proc flag*(self: Item): string {.inline.} =
  self.flag
