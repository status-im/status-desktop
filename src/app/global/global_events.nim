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

  proc showTestNotification*(self: GlobalEvents, title: string, message: string) {.signal.}
  
  proc showMessageNotification*(self: GlobalEvents, title: string, message: string, sectionId: string, 
    isCommunitySection: bool, isSectionActive: bool, chatId: string, isChatActive: bool, messageId: string, 
    notificationType: int, isOneToOne: bool, isGroupChat: bool) {.signal.}
  
  proc showNewContactRequestNotification*(self: GlobalEvents, title: string, message: string, sectionId: string) 
    {.signal.}
  
  proc newCommunityMembershipRequestNotification*(self: GlobalEvents, title: string, message: string, 
    sectionId: string) {.signal.}
  
  proc myRequestToJoinCommunityAcccepted*(self: GlobalEvents, title: string, message: string, 
    sectionId: string) {.signal.}

  proc myRequestToJoinCommunityRejected*(self: GlobalEvents, title: string, message: string, 
    sectionId: string) {.signal.}

  proc showAcceptedContactRequest*(self: GlobalEvents, title: string, message: string, 
    sectionId: string) {.signal.}

  proc meMentionedIconBadgeNotification*(self: GlobalEvents, allMentions: int) {.signal.}