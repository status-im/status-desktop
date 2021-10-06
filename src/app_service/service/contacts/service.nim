import Tables, json, sequtils, strformat, chronicles

import service_interface, dto
import status/statusgo_backend_new/contacts as status_go

export service_interface

logScope:
  topics = "contacts-service"

type 
  Service* = ref object of ServiceInterface
    contacts: Table[string, Dto] # [contact_id, Dto]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.contacts = initTable[string, Dto]()

method init*(self: Service) =
  try:
    let response = status_go.getContacts()

    let contacts = map(response.result.getElems(), 
    proc(x: JsonNode): Dto = x.toDto())

    for contact in contacts:
      self.contacts[contact.id] = contact

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return