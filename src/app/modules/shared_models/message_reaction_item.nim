import json, stew/shims/strformat

type
  EmojiId* {.pure.} = enum
    Heart = 1,
    Thumbsup,
    Thumbsdown,
    Laughing,
    Cry,
    Angry

type
  ReactionDetails* = object
    publicKey: string
    displayName: string
    reactionId: string

type
  MessageReactionItem* = object
    emojiId: EmojiId
    emoji: string
    didIReactWithThisEmoji: bool
    reactions: seq[ReactionDetails]

proc toEmojiIdAsEnum*(emojiId: int, emojiIdAsEnum: var EmojiId): bool =
  if(emojiId >= ord(low(EmojiId)) or emojiId <= ord(high(EmojiId))):
    emojiIdAsEnum = EmojiId(emojiId)
    return true
  return false

proc initMessageReactionItem*(emojiId: EmojiId, emoji: string): MessageReactionItem =
  result.emojiId = emojiId
  result.emoji = emoji
  result.didIReactWithThisEmoji = false

proc `$`*(self: MessageReactionItem): string =
  var reactions = ""
  for r in self.reactions:
    reactions = reactions & "displayName: " & r.displayName &  "  publicKey: " & r.publicKey & "  reactionId: " &
    r.reactionId & "\n"

  result = fmt"""MessageReactionItem(
    emojiId: {self.emojiId},
    emoji: {self.emoji},
    didIReactWithThisEmoji: {self.didIReactWithThisEmoji},
    reactionsCount: {self.reactions.len},
    reactions: {reactions}
    ]"""

proc emojiId*(self: MessageReactionItem): EmojiId {.inline.} =
  self.emojiId

proc emoji*(self: MessageReactionItem): string {.inline.} =
  self.emoji

proc didIReactWithThisEmoji*(self: MessageReactionItem): bool {.inline.} =
  self.didIReactWithThisEmoji

proc numberOfReactions*(self: MessageReactionItem): int {.inline.} =
  self.reactions.len

proc jsonArrayOfUsersReactedWithThisEmoji*(self: MessageReactionItem): JsonNode {.inline.} =
  var users: seq[string]
  for r in self.reactions:
    users.add(r.displayName)
  return %* users

proc shouldAddReaction*(self: MessageReactionItem, userPublicKey: string): bool =
  for r in self.reactions:
    if (r.publicKey == userPublicKey):
      return false
  return true

proc getReactionId*(self: MessageReactionItem, userPublicKey: string): string =
  for r in self.reactions:
    if (r.publicKey == userPublicKey):
      return r.reactionId
  return ""

proc addReaction*(self: var MessageReactionItem, didIReactWithThisEmoji: bool, userPublicKey: string,
  userDisplayName: string, reactionId: string) =
  if(didIReactWithThisEmoji):
    self.didIReactWithThisEmoji = true
  self.reactions.add(ReactionDetails(publicKey: userPublicKey, displayName: userDisplayName, reactionId: reactionId))

proc removeReaction*(self: var MessageReactionItem, reactionId: string, didIRemoveThisReaction: bool) =
  var index = -1
  for i in 0..<self.reactions.len:
    if (self.reactions[i].reactionId == reactionId):
      index = i
      break

  if(didIRemoveThisReaction):
    self.didIReactWithThisEmoji = false

  if(index == -1):
    return

  self.reactions.delete(index)
