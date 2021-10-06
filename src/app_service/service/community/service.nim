import Tables, json, sequtils, strformat, chronicles

import service_interface, dto
import status/statusgo_backend_new/communities as status_go

export service_interface

logScope:
  topics = "community-service"

type 
  Service* = ref object of ServiceInterface
    communities: Table[string, Dto] # [community_id, Dto]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.communities = initTable[string, Dto]()

method init*(self: Service) =
  try:
    let response = status_go.getJoinedComunities()

    let communities = map(response.result.getElems(), 
    proc(x: JsonNode): Dto = x.toDto())

    for community in communities:
        self.communities[community.id] = community

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

method getCommunities*(self: Service): seq[Dto] =
  return toSeq(self.communities.values)