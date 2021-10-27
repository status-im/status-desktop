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
    error "trying to get community for an unexisting community id"
    return

  result = self.communities[communityId].categories
  if(order == SortOrder.Ascending):
    result.sort(sortAsc[Category])
  else:
    result.sort(sortDesc[Category])

method getChats*(self: Service, communityId: string, categoryId = "", order = SortOrder.Ascending): seq[Chat] =
  if(not self.communities.contains(communityId)):
    error "trying to get community for an unexisting community id"
    return

  for chat in self.communities[communityId].chats:
    if(chat.categoryId != categoryId):
      continue

    result.add(chat)

  if(order == SortOrder.Ascending):
    result.sort(sortAsc[Chat])
  else:
    result.sort(sortDesc[Chat])
