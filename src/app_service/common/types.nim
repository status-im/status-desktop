type
  ContentType* {.pure.} = enum
    FetchMoreMessagesButton = -2
    ChatIdentifier = -1
    Unknown = 0
    Message = 1
    Sticker = 2
    Status = 3
    Emoji = 4
    Transaction = 5
    Group = 6
    Image = 7
    Audio = 8
    Community = 9
    Gap = 10
    Edit = 11

type StatusType* {.pure.} = enum
  Unknown = 0
  Automatic
  DoNotDisturb
  AlwaysOnline
  Inactive