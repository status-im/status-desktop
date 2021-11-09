import Tables, json, sequtils, std/algorithm, strformat, chronicles

import service_interface, ./dto/community

import ../chat/service as chat_service

import status/statusgo_backend_new/communities as status_go

export service_interface

logScope:
  topics = "community-service"

type 
  Service* = ref object of service_interface.ServiceInterface
    communities: Table[string, CommunityDto] # [community_id, CommunityDto]
    chatService: chat_service.Service

method delete*(self: Service) =
  discard

proc newService*(chatService: chat_service.Service): Service =
  result = Service()
  result.communities = initTable[string, CommunityDto]()
  result.chatService = chatService

method init*(self: Service) =
  try:
    let response = status_go.getJoinedComunities()

    let communities = map(response.result.getElems(), 
    proc(x: JsonNode): CommunityDto = x.toCommunityDto())

    for community in communities:
      self.communities[community.id] = community

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getCommunities*(self: Service): seq[CommunityDto] =
  return toSeq(self.communities.values)

method getCommunityById*(self: Service, communityId: string): CommunityDto =
  if(not self.communities.hasKey(communityId)):
    error "error: requested community doesn't exists"
    return

  return self.communities[communityId]

method getCommunityIds*(self: Service): seq[string] =
  return toSeq(self.communities.keys)

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
  if(not self.communities.contains(communityId)):
    error "trying to get community categories for an unexisting community id"
    return

  result = self.communities[communityId].categories
  if(order == SortOrder.Ascending):
    result.sort(sortAsc[Category])
  else:
    result.sort(sortDesc[Category])

method getChats*(self: Service, communityId: string, categoryId = "", order = SortOrder.Ascending): seq[Chat] =
  ## By default returns chats which don't belong to any category, for passed `communityId`.
  ## If `categoryId` is set then only chats belonging to that category for passed `communityId` will be returned.
  ## Returned chats are sorted by position following set `order` parameter.
  if(not self.communities.contains(communityId)):
    error "trying to get community chats for an unexisting community id"
    return

  for chat in self.communities[communityId].chats:
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
  if(not self.communities.contains(communityId)):
    error "trying to get all community chats for an unexisting community id"
    return

  result = self.communities[communityId].chats

  if(order == SortOrder.Ascending):
    result.sort(sortAsc[Chat])
  else:
    result.sort(sortDesc[Chat])