import chronicles
import ../stickers as status_stickers

logScope:
  topics = "sticker-decoding"

# TODO: this is for testing purposes, the correct function should decode the hash
proc decodeContentHash*(value: string): string =
  status_stickers.decodeContentHash(value)
