import Tables, json, sequtils, std/algorithm, strformat, chronicles

import eventemitter
import service_interface, ./dto/community

import ../chat/service as chat_service

import status/statusgo_backend_new/communities as status_go

export service_interface

logScope:
  topics = "community-service"


type
  CommunityArgs* = ref object of Args
    community*: CommunityDto

# Signals which may be emitted by this service:
const SIGNAL_COMMUNITY_JOINED* = "SIGNAL_COMMUNITY_JOINED"

type 
  Service* = ref object of service_interface.ServiceInterface
    events: EventEmitter
    joinedCommunities: Table[string, CommunityDto] # [community_id, CommunityDto]
    allCommunities: Table[string, CommunityDto] # [community_id, CommunityDto]

# Forward declaration
method loadAllCommunities(self: Service): seq[CommunityDto]
method loadJoinedComunities(self: Service): seq[CommunityDto]

method delete*(self: Service) =
  discard

proc newService*(events: EventEmitter): Service =
  result = Service()
  result.events = events
  result.joinedCommunities = initTable[string, CommunityDto]()
  result.allCommunities = initTable[string, CommunityDto]()

method init*(self: Service) =
  try:
    let joinedCommunities = self.loadJoinedComunities()
    for community in joinedCommunities:
      self.joinedCommunities[community.id] = community

    let allCommunities = self.loadAllCommunities()
    for community in allCommunities:
      self.allCommunities[community.id] = community

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method loadAllCommunities(self: Service): seq[CommunityDto] =
  let response = status_go.getAllCommunities()
  return parseCommunities(response)

method loadJoinedComunities(self: Service): seq[CommunityDto] =
  let response = status_go.getJoinedComunities()
  return parseCommunities(response)

method getJoinedCommunities*(self: Service): seq[CommunityDto] =
  return toSeq(self.joinedCommunities.values)

method getAllCommunities*(self: Service): seq[CommunityDto] =
  return toSeq(self.allCommunities.values)

method getCommunityById*(self: Service, communityId: string): CommunityDto =
  if(not self.joinedCommunities.hasKey(communityId)):
    error "error: requested community doesn't exists"
    return

  return self.joinedCommunities[communityId]

method getCommunityIds*(self: Service): seq[string] =
  return toSeq(self.joinedCommunities.keys)

proc sortAsc[T](t1, t2: T): int =
  if(t1.position > t2.position):
    return 1
  elif (t1.position < t2.position):
    return -1
  else:
    return 0

proc sortDesc[T](t1, t2: T): int =
  if(t1.position < t2.position):
    return 1
  elif (t1.position > t2.position):
    return -1
  else:
    return 0

method getCategories*(self: Service, communityId: string, order: SortOrder = SortOrder.Ascending): seq[Category] =
  if(not self.joinedCommunities.contains(communityId)):
    error "trying to get community categories for an unexisting community id"
    return

  result = self.joinedCommunities[communityId].categories
  if(order == SortOrder.Ascending):
    result.sort(sortAsc[Category])
  else:
    result.sort(sortDesc[Category])

method getChats*(self: Service, communityId: string, categoryId = "", order = SortOrder.Ascending): seq[Chat] =
  ## By default returns chats which don't belong to any category, for passed `communityId`.
  ## If `categoryId` is set then only chats belonging to that category for passed `communityId` will be returned.
  ## Returned chats are sorted by position following set `order` parameter.
  if(not self.joinedCommunities.contains(communityId)):
    error "trying to get community chats for an unexisting community id"
    return

  for chat in self.joinedCommunities[communityId].chats:
    if(chat.categoryId != categoryId):
      continue

    result.add(chat)

  if(order == SortOrder.Ascending):
    result.sort(sortAsc[Chat])
  else:
    result.sort(sortDesc[Chat])

method getAllChats*(self: Service, communityId: string, order = SortOrder.Ascending): seq[Chat] =
  ## Returns all chats belonging to the community with passed `communityId`, sorted by position.
  ## Returned chats are sorted by position following set `order` parameter.
  if(not self.joinedCommunities.contains(communityId)):
    error "trying to get all community chats for an unexisting community id"
    return

  result = self.joinedCommunities[communityId].chats

  if(order == SortOrder.Ascending):
    result.sort(sortAsc[Chat])
  else:
    result.sort(sortDesc[Chat])

method isUserMemberOfCommunity*(self: Service, communityId: string): bool =
  if(not self.allCommunities.contains(communityId)):
    return false
  return self.allCommunities[communityId].joined and self.allCommunities[communityId].isMember

method userCanJoin*(self: Service, communityId: string): bool =
  if(not self.allCommunities.contains(communityId)):
    return false
  return self.allCommunities[communityId].canJoin

method joinCommunity*(self: Service, communityId: string): string =
  result = ""
  try:
    if (not self.userCanJoin(communityId) or self.isUserMemberOfCommunity(communityId)):
      return
    discard status_go.joinCommunity(communityId)
    var community = self.allCommunities[communityId]
    self.joinedCommunities[communityId] = community

    self.events.emit(SIGNAL_COMMUNITY_JOINED, CommunityArgs(community: community))
  except Exception as e:
    error "Error joining the community", msg = e.msg
    result = fmt"Error joining the community: {e.msg}"