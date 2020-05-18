import NimQml

QtObject:
  type ChatMessage* = ref object of QObject
    userName: string
    message: string
    timestamp: string
    isCurrentUser: bool

  proc delete*(self: ChatMessage) =
    self.QObject.delete

  proc setup(self: ChatMessage) =
    self.QObject.setup

  proc newChatMessage*(): ChatMessage =
    new(result)
    result.userName = ""
    result.message = ""
    result.timestamp = "0"
    result.isCurrentUser = false
    result.setup

  proc userName*(self: ChatMessage): string {.slot.} =
    result = self.userName

  proc userNameChanged*(self: ChatMessage, userName: string) {.signal.}

  proc setUserName(self: ChatMessage, userName: string) {.slot.} =
    if self.userName == userName: return
    self.userName = userName
    self.userNameChanged(userName)

  proc `userName=`*(self: ChatMessage, userName: string) = self.setUserName(userName)

  QtProperty[string] userName:
    read = userName
    write = setUserName
    notify = userNameChanged

  proc message*(self: ChatMessage): string {.slot.} =
    result = self.message

  proc messageChanged*(self: ChatMessage, message: string) {.signal.}

  proc setMessage(self: ChatMessage, message: string) {.slot.} =
    if self.message == message: return
    self.message = message
    self.messageChanged(message)

  proc `message=`*(self: ChatMessage, message: string) = self.setMessage(message)

  QtProperty[string] message:
    read = message
    write = setMessage
    notify = messageChanged

  proc timestamp*(self: ChatMessage): string {.slot.} =
    result = self.timestamp

  proc timestampChanged*(self: ChatMessage, timestamp: string) {.signal.}

  proc setTimestamp(self: ChatMessage, timestamp: string) {.slot.} =
    if self.timestamp == timestamp: return
    self.timestamp = timestamp
    self.timestampChanged(timestamp)

  proc `timestamp=`*(self: ChatMessage, timestamp: string) = self.setTimestamp(timestamp)

  QtProperty[string] timestamp:
    read = timestamp
    write = setTimestamp
    notify = timestampChanged

  proc isCurrentUser*(self: ChatMessage): bool {.slot.} =
    result = self.isCurrentUser

  proc isCurrentUserChanged*(self: ChatMessage, isCurrentUser: bool) {.signal.}

  proc setIsCurrentUser(self: ChatMessage, isCurrentUser: bool) {.slot.} =
    if self.isCurrentUser == isCurrentUser: return
    self.isCurrentUser = isCurrentUser
    self.isCurrentUserChanged(isCurrentUser)

  proc `isCurrentUser=`*(self: ChatMessage, isCurrentUser: bool) = self.setIsCurrentUser(isCurrentUser)

  QtProperty[bool] isCurrentUser:
    read = isCurrentUser
    write = setIsCurrentUser
    notify = isCurrentUserChanged
