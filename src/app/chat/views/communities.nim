import NimQml, json, sequtils, chronicles, strutils, strformat, tables
import ../../../status/status
import ../../../status/chat/chat
import ./community_list
import ./community_item
import ./community_membership_request_list
import ../../utils/image_utils
import ../../../status/signals/types as signal_types
import ../../../status/types

logScope:
  topics = "communities-view"

type
  CommunityImportState {.pure.} = enum
    Imported,
    InProgress,
    Error

proc mergeChat(community: var Community, chat: Chat): bool =
  var i = 0
  for c in community.chats:
    if (c.id == chat.id):
      chat.canPost = community.chats[i].canPost
      chat.categoryId = community.chats[i].categoryId
      chat.position = community.chats[i].position
      community.chats[i] = chat
      return true

    i = i + 1

  return false

QtObject:
  type CommunitiesView* = ref object of QObject
    status: Status
    activeCommunity*: CommunityItemView
    observedCommunity*: CommunityItemView
    communityList*: CommunityList
    joinedCommunityList*: CommunityList
    myCommunityRequests*: seq[CommunityMembershipRequest]
    importingCommunityState: CommunityImportState
    communityImportingProcessId: string

  proc setup(self: CommunitiesView) =
    self.QObject.setup

  proc delete*(self: CommunitiesView) =
    self.observedCommunity.delete
    self.activeCommunity.delete
    self.communityList.delete
    self.joinedCommunityList.delete
    self.QObject.delete

  proc newCommunitiesView*(status: Status): CommunitiesView =
    new(result, delete)
    result.importingCommunityState = CommunityImportState.Imported
    result.status = status
    result.activeCommunity = newCommunityItemView(status)
    result.observedCommunity = newCommunityItemView(status)
    result.communityList = newCommunityList(status)
    result.joinedCommunityList = newCommunityList(status)
    result.setup

  proc importingCommunityStateChanged*(self: CommunitiesView, state: int, communityImportingProcessId: string) {.signal.}

  proc setImportCommunityState(self: CommunitiesView, state: CommunityImportState, communityImportingProcessId: string) =
    if (self.importingCommunityState == state):
      return

    self.communityImportingProcessId = communityImportingProcessId
    self.importingCommunityState = state
    self.importingCommunityStateChanged(state.int, communityImportingProcessId)

  proc updateMemberVisibility*(self: CommunitiesView, statusUpdate: StatusUpdate) =
    self.joinedCommunityList.updateMemberVisibility(statusUpdate)
    self.activeCommunity.setCommunityItem(self.joinedCommunityList.getCommunityById(self.activeCommunity.communityItem.id))
    self.activeCommunity.triggerMembersUpdate()

  proc populateChats(self: CommunitiesView, communities: var seq[Community]): seq[Community] =
    result = @[]
    for community in communities.mitems():
      for chat in self.status.chat.channels.values:
        if chat.chatType != ChatType.CommunityChat:
          continue

        if chat.communityId != community.id:
          continue

        discard mergeChat(community, chat)

      result.add(community)

  proc updateCommunityChat*(self: CommunitiesView, newChat: Chat) =
    var community = self.joinedCommunityList.getCommunityById(newChat.communityId)
    if (community.id == ""):
      return

    let found = mergeChat(community, newChat)

    if (not found):
      community.chats.add(newChat)

    self.joinedCommunityList.replaceCommunity(community)
    if (self.activeCommunity.active and self.activeCommunity.communityItem.id == community.id):
      self.activeCommunity.changeChats(community.chats)
      

  proc pendingRequestsToJoinForCommunity*(self: CommunitiesView, communityId: string): seq[CommunityMembershipRequest] =
    result = self.status.chat.pendingRequestsToJoinForCommunity(communityId)

  proc membershipRequestPushed*(self: CommunitiesView, communityId: string, communityName: string, pubKey: string) {.signal.}

  proc addMembershipRequests*(self: CommunitiesView, membershipRequests: seq[CommunityMembershipRequest]) =
    var communityId: string
    var community: Community
    for request in membershipRequests:
      communityId = request.communityId
      community = self.joinedCommunityList.getCommunityById(communityId)
      if (community.id == ""):
        continue
      let alreadyPresentRequestIdx = community.membershipRequests.findIndexById(request.id)
      if (alreadyPresentRequestIdx == -1): 
        community.membershipRequests.add(request)
        self.membershipRequestPushed(community.id, community.name, request.publicKey)
      else:
        community.membershipRequests[alreadyPresentRequestIdx] = request
      self.joinedCommunityList.replaceCommunity(community)

      # Add to active community list
      if (communityId == self.activeCommunity.communityItem.id):
        self.activeCommunity.communityMembershipRequestList.addCommunityMembershipRequestItemToList(request)

  proc communitiesChanged*(self: CommunitiesView) {.signal.}

  proc getCommunitiesIfNotFetched*(self: CommunitiesView): CommunityList =
    if (not self.communityList.fetched):
      var communities = self.status.chat.getAllComunities()
      communities = self.populateChats(communities)
      self.communityList.setNewData(communities)
      self.communityList.fetched = true
    return self.communityList

  proc getComunities*(self: CommunitiesView): QVariant {.slot.} =
    return newQVariant(self.getCommunitiesIfNotFetched())

  QtProperty[QVariant] list:
    read = getComunities
    notify = communitiesChanged

  proc joinedCommunitiesChanged*(self: CommunitiesView) {.signal.}
    
  proc getJoinedComunities*(self: CommunitiesView): QVariant {.slot.} =
    if (not self.joinedCommunityList.fetched):
      var communities = self.status.chat.getJoinedComunities()
      communities = self.populateChats(communities)
      self.joinedCommunityList.setNewData(communities)
      for c in communities:
        self.addMembershipRequests(self.pendingRequestsToJoinForCommunity(c.id))
      self.joinedCommunityList.fetched = true

      # Also fetch requests
      self.myCommunityRequests = self.status.chat.myPendingRequestsToJoin()

    return newQVariant(self.joinedCommunityList)

  QtProperty[QVariant] joinedCommunities:
    read = getJoinedComunities
    notify = joinedCommunitiesChanged
  
  proc getCommunityNameById*(self: CommunitiesView, communityId: string): string {.slot.} =
    let communities = self.getCommunitiesIfNotFetched()
    for community in communities.communities:
      if community.id == communityId:
        return community.name
    return ""
  
  proc isUserMemberOfCommunity*(self: CommunitiesView, communityId: string): bool {.slot.} =
    let communities = self.getCommunitiesIfNotFetched()
    for community in communities.communities:
      if community.id == communityId:
        return community.joined and community.isMember
    return false
  
  proc userCanJoin*(self: CommunitiesView, communityId: string): bool {.slot.} =
    let communities = self.getCommunitiesIfNotFetched()
    for community in communities.communities:
      if community.id == communityId:
        return community.canJoin
    return false

  proc activeCommunityChanged*(self: CommunitiesView) {.signal.}

  proc setActiveCommunity*(self: CommunitiesView, communityId: string) {.slot.} =
    if(communityId == ""): return
    self.activeCommunity.setCommunityItem(self.joinedCommunityList.getCommunityById(communityId))
    self.activeCommunity.setActive(true)
    self.activeCommunityChanged()

  proc getActiveCommunity*(self: CommunitiesView): QVariant {.slot.} =
    newQVariant(self.activeCommunity)

  QtProperty[QVariant] activeCommunity:
    read = getActiveCommunity
    write = setActiveCommunity
    notify = activeCommunityChanged

  proc joinCommunity*(self: CommunitiesView, communityId: string, setActive: bool = true): string {.slot.} =
    result = ""
    try:
      if (not self.userCanJoin(communityId) or self.isUserMemberOfCommunity(communityId)):
        return
      self.status.chat.joinCommunity(communityId)
      var community = self.communityList.getCommunityById(communityId)
      self.joinedCommunityList.addCommunityItemToList(community)
      if (setActive):
        self.setActiveCommunity(communityId)
    except Exception as e:
      error "Error joining the community", msg = e.msg
      result = fmt"Error joining the community: {e.msg}"

  proc membershipRequestChanged*(self: CommunitiesView, communityId: string, communityName: string, accepted: bool) {.signal.}
  
  proc communityAdded*(self: CommunitiesView, communityId: string) {.signal.}

  proc observedCommunityChanged*(self: CommunitiesView) {.signal.}
  proc communityChanged*(self: CommunitiesView, communityId: string) {.signal.}

  proc addCommunityToList*(self: CommunitiesView, community: var Community) =
    var communities = @[community]
    community = self.populateChats(communities)[0]
    let communityCheck = self.communityList.getCommunityById(community.id)
    if (communityCheck.id == ""):
      self.communityList.addCommunityItemToList(community)
      self.communityAdded(community.id)
      self.communityChanged(community.id)
    else:
      self.communityList.replaceCommunity(community)
      self.communityChanged(community.id)

    if (self.activeCommunity.active and self.activeCommunity.communityItem.id == community.id):
      self.activeCommunity.setCommunityItem(community)

    if (self.observedCommunity.communityItem.id == community.id):
      self.observedCommunity.setCommunityItem(community)
      self.observedCommunityChanged()

    if (community.joined == true and community.isMember == true):
      let joinedCommunityCheck = self.joinedCommunityList.getCommunityById(community.id)
      if (joinedCommunityCheck.id == ""):
        self.joinedCommunityList.addCommunityItemToList(community)
      else:
        self.joinedCommunityList.replaceCommunity(community)
      self.joinedCommunitiesChanged()

    if (community.isMember == true):
      var i = 0
      for communityRequest in self.myCommunityRequests:
        if (communityRequest.communityId == community.id):
          self.membershipRequestChanged(community.id, community.name, true)
          self.myCommunityRequests.delete(i, i)
          break
        i = i + 1
    # TODO: handle membership request rejection
    # @cammellos mentioned this would likely changed in Communities Phase 3, so
    # no need to polish now.

    self.setImportCommunityState(CommunityImportState.Imported, self.communityImportingProcessId)

  proc isCommunityRequestPending*(self: CommunitiesView, communityId: string): bool {.slot.} =
    for communityRequest in self.myCommunityRequests:
      if (communityRequest.communityId == communityId):
        return true
    return false

  proc createCommunity*(self: CommunitiesView, name: string, description: string, access: int, ensOnly: bool, color: string, imagePath: string, aX: int, aY: int, bX: int, bY: int): string {.slot.} =
    result = ""
    try:
      var image = image_utils.formatImagePath(imagePath)
      var community = self.status.chat.createCommunity(name, description, access, ensOnly, color, image, aX, aY, bX, bY)
     
      if (community.id == ""):
        return "Community was not created. Please try again later"

      self.communityList.addCommunityItemToList(community)
      self.joinedCommunityList.addCommunityItemToList(community)
      self.setActiveCommunity(community.id)
      self.communitiesChanged()
    except RpcException as e:
      error "Error creating the community", msg = e.msg
      result = StatusGoError(error: e.msg).toJson

  proc editCommunity*(self: CommunitiesView, id: string, name: string, description: string, access: int, ensOnly: bool, color: string, imagePath: string, aX: int, aY: int, bX: int, bY: int): string {.slot.} =
    result = ""
    try:
      var image = image_utils.formatImagePath(imagePath)
      var community = self.status.chat.editCommunity(id, name, description, access, ensOnly, color, image, aX, aY, bX, bY)
     
      if (community.id == ""):
        return "Community was not edited. Please try again later"

      var communities = @[community]
      community = self.populateChats(communities)[0]
      self.communityList.replaceCommunity(community)
      self.joinedCommunityList.replaceCommunity(community)
      self.setActiveCommunity(community.id)
      self.communitiesChanged()
      self.activeCommunityChanged()
    except RpcException as e:
      error "Error editing the community", msg = e.msg
      result = StatusGoError(error: e.msg).toJson


  proc createCommunityCategory*(self: CommunitiesView, communityId: string, name: string, channels: string): string {.slot.} =
    result = ""
    try:
      let channelSeq = map(parseJson(channels).getElems(), proc(x:JsonNode):string = x.getStr().replace(communityId, ""))
      let category = self.status.chat.createCommunityCategory(communityId, name, channelSeq)
      self.joinedCommunityList.addCategoryToCommunity(communityId, category)
      self.activeCommunity.addCategoryToList(category)
    except Exception as e:
      error "Error creating the category", msg = e.msg
      result = fmt"Error creating the category: {e.msg}"


  proc editCommunityCategory*(self: CommunitiesView, communityId: string, categoryId: string, name: string, channels: string): string {.slot.} =
    result = ""
    try:
      let channelSeq = map(parseJson(channels).getElems(), proc(x:JsonNode):string = x.getStr().replace(communityId, ""))
      self.status.chat.editCommunityCategory(communityId, categoryId, name, channelSeq)
    except Exception as e:
      error "Error editing the category", msg = e.msg
      result = fmt"Error editing the category: {e.msg}"


  proc deleteCommunityCategory*(self: CommunitiesView, communityId: string, categoryId: string): string {.slot.} =
    result = ""
    try:
      self.status.chat.deleteCommunityCategory(communityId, categoryId)
      self.joinedCommunityList.removeCategoryFromCommunity(communityId, categoryId)
      self.activeCommunity.removeCategoryFromList(categoryId)
    except Exception as e:
      error "Error creating the category", msg = e.msg
      result = fmt"Error creating the category: {e.msg}"
  
  
  proc reorderCommunityCategories*(self: CommunitiesView, communityId: string, categoryId: string, position: int): string {.slot} =
    result = ""
    try:
      self.status.chat.reorderCommunityCategories(communityId, categoryId, position)
    except Exception as e:
      error "Error reorder the category", msg = e.msg
      result = fmt"Error reorder the category: {e.msg}"

  proc reorderCommunityChannel*(self: CommunitiesView, communityId: string, categoryId: string, chatId: string, position: int): string {.slot} =
    result = ""
    try:
      self.status.chat.reorderCommunityChannel(communityId, categoryId, chatId, position)
    except Exception as e:
      error "Error reorder the channel", msg = e.msg
      result = fmt"Error reorder the channel: {e.msg}"

       
  proc setObservedCommunity*(self: CommunitiesView, communityId: string) {.slot.} =
    if(communityId == ""): return
    var community = self.communityList.getCommunityById(communityId) 
    if (community.id == ""):
      discard self.getCommunitiesIfNotFetched()
      community = self.communityList.getCommunityById(communityId) 
    self.observedCommunity.setCommunityItem(community)
    self.observedCommunityChanged()

  proc getObservedCommunity*(self: CommunitiesView): QVariant {.slot.} =
    newQVariant(self.observedCommunity)

  QtProperty[QVariant] observedCommunity:
    read = getObservedCommunity
    write = setObservedCommunity
    notify = observedCommunityChanged

  proc leaveCommunity*(self: CommunitiesView, communityId: string): string {.slot.} =
    result = ""
    try:
      self.status.chat.leaveCommunity(communityId)
      if (communityId == self.activeCommunity.communityItem.id):
        self.activeCommunity.setActive(false)
      self.joinedCommunityList.removeCommunityItemFromList(communityId)
      self.joinedCommunitiesChanged()
      var updatedCommunity = self.communityList.getCommunityById(communityId)
      updatedCommunity.joined = false
      self.communityList.replaceCommunity(updatedCommunity)
      self.communitiesChanged()
      self.communityChanged(communityId)
    except Exception as e:
      error "Error leaving the community", msg = e.msg
      result = fmt"Error leaving the community: {e.msg}"

  proc leaveCurrentCommunity*(self: CommunitiesView): string {.slot.} =
    result = self.leaveCommunity(self.activeCommunity.communityItem.id)

  proc inviteUserToCommunity*(self: CommunitiesView, pubKey: string): string {.slot.} =
    try:
      self.status.chat.inviteUserToCommunity(self.activeCommunity.id(), pubKey)
    except Exception as e:
      error "Error inviting to the community", msg = e.msg
      result = fmt"Error inviting to the community: {e.msg}"

  proc inviteUsersToCommunityById*(self: CommunitiesView, communityId: string, pubKeysJSON: string): string {.slot.} =
    try:
      let pubKeysParsed = pubKeysJSON.parseJson
      var pubKeys: seq[string] = @[]
      for pubKey in pubKeysParsed:
        pubKeys.add(pubKey.getStr)

      self.status.chat.inviteUsersToCommunity(communityId, pubKeys)
    except Exception as e:
      error "Error inviting to the community", msg = e.msg
      result = fmt"Error inviting to the community: {e.msg}"

  proc inviteUsersToCommunity*(self: CommunitiesView, pubKeysJSON: string): string {.slot.} =
    result = self.inviteUsersToCommunityById(self.activeCommunity.id(), pubKeysJSON)
    self.status.chat.statusUpdates()

  proc exportCommunity*(self: CommunitiesView): string {.slot.} =
    try:
      result = self.status.chat.exportCommunity(self.activeCommunity.communityItem.id)
    except Exception as e:
      error "Error exporting the community", msg = e.msg
      result = fmt"Error exporting the community: {e.msg}"

  proc importCommunity*(self: CommunitiesView, communityKey: string, communityImportingProcessId: string): string {.slot.} =
    try:
      self.setImportCommunityState(CommunityImportState.InProgress, communityImportingProcessId)
      let response = self.status.chat.importCommunity(communityKey)

      let jsonNode = response.parseJSON()
      if (jsonNode.contains("error")):
        if (jsonNode["error"].contains("message")):
          let msg = jsonNode["error"]["message"].getStr()
          result = fmt"Error importing the community: {msg}"
        else:
          result = fmt"Error importing the community: unknown error"
        self.setImportCommunityState(CommunityImportState.Error, communityImportingProcessId)

    except Exception as e:
      self.setImportCommunityState(CommunityImportState.Error, communityImportingProcessId)
      error "Error importing the community", msg = e.msg
      result = fmt"Error importing the community: {e.msg}"

  proc removeUserFromCommunity*(self: CommunitiesView, pubKey: string) {.slot.} =
    try:
      self.status.chat.removeUserFromCommunity(self.activeCommunity.id(), pubKey)
      self.activeCommunity.removeMember(pubKey)
    except Exception as e:
      error "Error removing user from the community", msg = e.msg

  proc banUserFromCommunity*(self: CommunitiesView, pubKey: string, communityId: string) {.slot.} =
    discard self.status.chat.banUserFromCommunity(pubKey, communityId)

  proc requestToJoinCommunity*(self: CommunitiesView, communityId: string, ensName: string) {.slot.} =
    try:
      let requests = self.status.chat.requestToJoinCommunity(communityId, ensName)
      for request in requests:
        self.myCommunityRequests.add(request)
    except Exception as e:
      error "Error requesting to join the community", msg = e.msg

  proc removeMembershipRequest(self: CommunitiesView, requestId: string, accepted: bool) =
    var i = 0
    for request in self.myCommunityRequests:
      if (request.id == requestId):
        self.myCommunityRequests.delete(i, i)
        let name = self.getCommunityNameById(request.communityId)
        self.membershipRequestChanged(request.communityId, name, accepted)
        break
      i = i + 1
    self.activeCommunity.communityMembershipRequestList.removeCommunityMembershipRequestItemFromList(requestId)

  proc acceptRequestToJoinCommunity*(self: CommunitiesView, requestId: string): string {.slot.} =
    try:
      self.status.chat.acceptRequestToJoinCommunity(requestId)
      self.removeMembershipRequest(requestId, true)
      self.status.chat.statusUpdates()
    except Exception as e:
      error "Error accepting request to join the community", msg = e.msg
      return "Error accepting request to join the community"
    return ""

  proc declineRequestToJoinCommunity*(self: CommunitiesView, requestId: string): string {.slot.} =
    try:
      self.status.chat.declineRequestToJoinCommunity(requestId)
      self.removeMembershipRequest(requestId, false)
    except Exception as e:
      error "Error declining request to join the community", msg = e.msg
      return "Error declining request to join the community"
    return ""

  proc requestCommunityInfo*(self: CommunitiesView, communityId: string) {.slot.} =
    try:
      self.status.chat.requestCommunityInfo(communityId)
    except Exception as e:
      error "Error fetching community info", msg = e.msg

  proc getChannel*(self: CommunitiesView, channelId: string): Chat =
    for community in self.joinedCommunityList.communities:
      for chat in community.chats:
        if (chat.id == channelId):
          if community.muted:
            chat.muted = true
          return chat

  proc deleteCommunityChat*(self: CommunitiesView, communityId: string, channelId: string): string {.slot.} =
    try:
      self.status.chat.deleteCommunityChat(communityId, channelId)
      
      self.joinedCommunityList.removeChannelInCommunity(communityId, channelId)
    except RpcException as e:
      error "Error deleting channel", msg=e.msg, channelId
      result = StatusGoError(error: e.msg).toJson

  proc setCommunityMuted*(self: CommunitiesView, communityId: string, muted: bool) {.slot.} =
    self.status.chat.setCommunityMuted(communityId, muted)
    if (communityId == self.activeCommunity.communityItem.id):
      self.activeCommunity.setMuted(muted)

    var community = self.joinedCommunityList.getCommunityById(communityId)
    community.muted = muted
    self.joinedCommunityList.replaceCommunity(community)

  proc markNotificationsAsRead*(self: CommunitiesView, markAsReadProps: MarkAsReadNotificationProperties) =
    if(markAsReadProps.communityId.len == 0 and markAsReadProps.channelId.len == 0):
      # Remove all notifications from all communities and their channels for set types.

      for t in markAsReadProps.notificationTypes:
        case t:
          of ActivityCenterNotificationType.NewOneToOne:
            debug "Clear all one to one notifications"
          of ActivityCenterNotificationType.NewPrivateGroupChat:
            debug "Clear all private group chat notifications"
          of ActivityCenterNotificationType.Mention:
            self.activeCommunity.clearAllMentions()
  
            for c in self.joinedCommunityList.communities:
              # We don't need to update channels from the currently active community.
              let clearChannels = c.id != self.activeCommunity.communityItem.id
              self.joinedCommunityList.clearAllMentions(c.id, clearChannels)

          of ActivityCenterNotificationType.Reply:
            debug "Clear all reply notifications"
          else:
            debug "Unknown notifications"

    else:
      # Remove single notification from the channel (channelId) of community (communityId) for set types.
      for t in markAsReadProps.notificationTypes:
        case t:
          of ActivityCenterNotificationType.NewOneToOne:
            debug "Clear one to one notification"
          of ActivityCenterNotificationType.NewPrivateGroupChat:
            debug "Clear private group chat notification"
          of ActivityCenterNotificationType.Mention:
            if (markAsReadProps.communityId == self.activeCommunity.communityItem.id):
              self.activeCommunity.decrementMentions(markAsReadProps.channelId)
              self.joinedCommunityList.updateMentions(markAsReadProps.communityId)
            else:
              for c in self.joinedCommunityList.communities:
                # We don't need to update channels from the currently active community.
                if (c.id != self.activeCommunity.communityItem.id):
                  self.joinedCommunityList.decrementMentions(c.id, markAsReadProps.channelId)

          of ActivityCenterNotificationType.Reply:
            debug "Clear reply notification"
          else:
            debug "Unknown notification"
