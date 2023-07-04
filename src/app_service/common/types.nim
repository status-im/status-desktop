type
  ContentType* {.pure.} = enum
    NewMessagesMarker = -3
    FetchMoreMessagesButton = -2
    ChatIdentifier = -1
    Unknown = 0
    Message = 1
    Sticker = 2
    Status = 3
    Emoji = 4
    Transaction = 5
    SystemMessageGroup = 6
    Image = 7
    Audio = 8
    Community = 9
    Gap = 10
    ContactRequest = 11
    DiscordMessage = 12
    ContactIdentityVerification = 13
    # Local only
    SystemMessagePinnedMessage = 14
    SystemMessageMutualEventSent = 15
    SystemMessageMutualEventAccepted = 16
    SystemMessageMutualEventRemoved = 17

proc toContentType*(value: int): ContentType =
  try:
    return ContentType(value)
  except RangeDefect:
    return ContentType.Unknown

type
  StatusType* {.pure.} = enum
    Unknown = 0
    Automatic
    DoNotDisturb
    AlwaysOnline
    Inactive

  OnlineStatus* {.pure.} = enum
    Inactive = 0
    Online

proc toOnlineStatus*(statusType: StatusType): OnlineStatus =
  if(statusType == StatusType.AlwaysOnline or statusType == StatusType.Automatic):
    return OnlineStatus.Online
  else:
    return OnlineStatus.Inactive

type MemberRole* {.pure} = enum
  None = 0
  Owner
  ManageUsers
  ModerateContent
  Admin

type
  ContractTransactionStatus* {.pure.} = enum
    Failed,
    InProgress,
    Completed