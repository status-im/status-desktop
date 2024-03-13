import stew/shims/strformat

type
  PendingRequestItem* = ref object
    id: string
    publicKey: string
    chatId: string
    communityId: string
    state: int
    our: string

proc initItem*(
    id: string,
    publicKey: string,
    chatId: string,
    communityId: string,
    state: int,
    our: string
    ): PendingRequestItem =
  result = PendingRequestItem()
  result.id = id
  result.publicKey = publicKey
  result.chatId = chatId
  result.communityId = communityId
  result.state = state
  result.our = our

proc id*(self: PendingRequestItem): string =
  self.id

proc pubKey*(self: PendingRequestItem): string =
  self.publicKey

proc chatId*(self: PendingRequestItem): string =
  self.chatId

proc communityId*(self: PendingRequestItem): string =
  self.communityId

proc state*(self: PendingRequestItem): int =
  self.state

proc our*(self: PendingRequestItem): string =
  self.our

proc `$`*(self: PendingRequestItem): string =
  result = fmt"""PendingRequestItem(
    id: {self.id},
    publicKey: {$self.publicKey},
    chatId: {$self.chatId},
    communityId: {$self.communityId},
    state: {$self.state},
    our: {$self.our},
    ]"""