import NimQml

QtObject:
  type GlobalEvents* = ref object of QObject

  proc setup(self: GlobalEvents) =
    self.QObject.setup

  proc delete*(self: GlobalEvents) =
    self.QObject.delete

  proc newGlobalEvents*(): GlobalEvents =
    new(result, delete)
    result.setup

  proc showNormalMessageNotification*(self: GlobalEvents, title: string, message: string, sectionId: string, 
    chatId: string, messageId: string) {.signal.}
  proc showMentionMessageNotification*(self: GlobalEvents, title: string, message: string, sectionId: string, 
    chatId: string, messageId: string) {.signal.}
  proc showNewContactRequestNotification*(self: GlobalEvents, title: string, message: string, sectionId: string) 
    {.signal.}
  proc newCommunityMembershipRequestNotification*(self: GlobalEvents, title: string, message: string, 
    sectionId: string) {.signal.}
  proc myRequestToJoinCommunityHasBeenAcccepted*(self: GlobalEvents, title: string, message: string, 
    sectionId: string) {.signal.}
  proc myRequestToJoinCommunityHasBeenRejected*(self: GlobalEvents, title: string, message: string, 
    sectionId: string) {.signal.}
    