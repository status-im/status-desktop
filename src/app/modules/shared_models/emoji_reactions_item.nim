type
    EmojiReactionItem* = ref object
        emoji: string
        filename: string
        didIReactWithThisEmoji: bool

proc initItem*(emoji: string, filename: string, didIReactWithThisEmoji: bool): EmojiReactionItem =
    result = EmojiReactionItem()
    result.emoji = emoji
    result.filename = filename
    result.didIReactWithThisEmoji = didIReactWithThisEmoji

proc emoji*(self: EmojiReactionItem): string =
    self.emoji

proc filename*(self: EmojiReactionItem): string =
    self.filename

proc didIReactWithThisEmoji*(self: EmojiReactionItem): bool =
    self.didIReactWithThisEmoji

proc `didIReactWithThisEmoji=`*(self: EmojiReactionItem, value: bool) {.inline.} =
  self.didIReactWithThisEmoji = value
