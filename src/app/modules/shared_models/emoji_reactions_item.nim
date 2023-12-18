import NimQml

type
    EmojiReactionItem* = ref object
        emojiId: int
        filename: string
        didIReactWithThisEmoji: bool

proc initItem*(emojiId: int, filename: string, didIReactWithThisEmoji: bool): EmojiReactionItem =
    result = EmojiReactionItem()
    result.emojiId = emojiId
    result.filename = filename
    result.didIReactWithThisEmoji = didIReactWithThisEmoji

proc emojiId*(self: EmojiReactionItem): int =
    self.emojiId

proc filename*(self: EmojiReactionItem): string =
    self.filename

proc didIReactWithThisEmoji*(self: EmojiReactionItem): bool =
    self.didIReactWithThisEmoji

proc `didIReactWithThisEmoji=`*(self: EmojiReactionItem, value: bool) {.inline.} =
  self.didIReactWithThisEmoji = value