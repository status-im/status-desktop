import strformat, sequtils, sugar

import ./emojis_model, ./color_hash_model, ./color_hash_item

type
  OnlineStatus* {.pure.} = enum
    Offline = 0
    Online
    DoNotDisturb
    Idle
    Invisible

type
  ColorHashSegment* = tuple[len, colorIdx: int]

# TODO add role when it is needed
type
  Item* = ref object
    id: string
    displayName: string
    ensName: string
    localNickname: string
    alias: string
    onlineStatus: OnlineStatus
    icon: string
    identicon: string
    isIdenticon: bool
    emojiHashModel: emojis_model.Model
    colorHashModel: color_hash_model.Model
    isAdded: bool
    isAdmin: bool
    joined: bool

proc initItem*(
  id: string,
  displayName: string,
  ensName: string,
  localNickname: string,
  alias: string,
  onlineStatus: OnlineStatus,
  icon: string,
  identicon: string,
  isidenticon: bool,
  emojiHash: seq[string],
  colorHash: seq[ColorHashSegment],
  isAdded: bool = false,
  isAdmin: bool = false,
  joined: bool = false,
): Item =
  result = Item()
  result.id = id
  result.displayName = displayName
  result.ensName = ensName
  result.localNickname = localNickname
  result.alias = alias
  result.onlineStatus = onlineStatus
  result.icon = icon
  result.identicon = identicon
  result.isIdenticon = isidenticon
  result.emojiHashModel = emojis_model.newModel()
  result.emojiHashModel.setItems(emojiHash)
  result.colorHashModel = color_hash_model.newModel()
  result.colorHashModel.setItems(map(colorHash, x => color_hash_item.initItem(x.len, x.colorIdx)))
  result.isAdded = isAdded
  result.isAdmin = isAdmin
  result.joined = joined

proc `$`*(self: Item): string =
  result = fmt"""User Item(
    id: {self.id},
    displayName: {self.displayName},
    localNickname: {self.localNickname},
    alias: {self.alias},
    onlineStatus: {$self.onlineStatus.int},
    icon: {self.icon},
    identicon: {self.identicon},
    isIdenticon: {$self.isIdenticon},
    isAdded: {$self.isAdded},
    isAdmin: {$self.isAdmin},
    joined: {$self.joined},
    ]"""

proc id*(self: Item): string {.inline.} =
  self.id

proc name*(self: Item): string {.inline.} =
  self.displayName

proc `name=`*(self: Item, value: string) {.inline.} =
  self.displayName = value

proc ensName*(self: Item): string {.inline.} =
  self.ensName

proc `ensName=`*(self: Item, value: string) {.inline.} =
  self.ensName = value

proc localNickname*(self: Item): string {.inline.} =
  self.localNickname

proc `localNickname=`*(self: Item, value: string) {.inline.} =
  self.localNickname = value

proc alias*(self: Item): string {.inline.} =
  self.alias

proc `alias=`*(self: Item, value: string) {.inline.} =
  self.alias = value

proc onlineStatus*(self: Item): OnlineStatus {.inline.} =
  self.onlineStatus

proc `onlineStatus=`*(self: Item, value: OnlineStatus) {.inline.} =
  self.onlineStatus = value

proc icon*(self: Item): string {.inline.} =
  self.icon

proc `icon=`*(self: Item, value: string) {.inline.} =
  self.icon = value

proc identicon*(self: Item): string {.inline.} =
  self.identicon

proc isIdenticon*(self: Item): bool {.inline.} =
  self.isIdenticon

proc `isIdenticon=`*(self: Item, value: bool) {.inline.} =
  self.isIdenticon = value

proc isAdmin*(self: Item): bool {.inline.} =
  self.isAdmin

proc `isAdmin=`*(self: Item, value: bool) {.inline.} =
  self.isAdmin = value

proc isAdded*(self: Item): bool {.inline.} =
  self.isAdded

proc `isAdded=`*(self: Item, value: bool) {.inline.} =
  self.isAdded = value

proc joined*(self: Item): bool {.inline.} =
  self.joined

proc `joined=`*(self: Item, value: bool) {.inline.} =
  self.joined = value

proc emojiHashModel*(self: Item): emojis_model.Model {.inline.} =
  self.emojiHashModel

proc colorHashModel*(self: Item): color_hash_model.Model {.inline.} =
  self.colorHashModel
