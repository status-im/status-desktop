import locale_table

type
  Item* = object
    locale: string
    name: string
    native: string
    flag: string # unicode emoji
    state: locale_table.State

proc initItem*(locale, name, native, flag: string, state: locale_table.State): Item =
  result.locale = locale
  result.name = name
  result.native = native
  result.flag = flag
  result.state = state

proc locale*(self: Item): string {.inline.} =
  self.locale

proc name*(self: Item): string {.inline.} =
  self.name

proc native*(self: Item): string {.inline.} =
  self.native

proc flag*(self: Item): string {.inline.} =
  self.flag

proc state*(self: Item): locale_table.State {.inline.} =
  self.state
