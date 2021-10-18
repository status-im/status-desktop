import Tables, json, sequtils, strformat, chronicles

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