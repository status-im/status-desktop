import Tables, json, sequtils, strformat, chronicles

import service_interface, dto
import status/statusgo_backend_new/contacts as status_go

export service_interface

logScope:
  topics = "contacts-service"

type 
  Service* = ref object of ServiceInterface
    contacts: Table[string, ContactDto] # [contact_id, ContactDto]

method delete*(self: Service) =
  echo "ContactServiceDelete"

proc newService*(): Service =
  echo "ContactServiceCreate"
  result = Service()
  result.contacts = initTable[string, ContactDto]()

method init*(self: Service) =
  echo "ContactServiceInit"
  try:
    let response = status_go.getContacts()

    let contacts = map(response.result.getElems(), 
    proc(x: JsonNode): ContactDto = x.toContactDto())

    for contact in contacts:
      self.contacts[contact.id] = contact

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return