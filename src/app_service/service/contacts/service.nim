import Tables, json, sequtils, strformat, chronicles

import service_interface, ./dto/contacts
import status/statusgo_backend_new/contacts as status_go

export service_interface

logScope:
  topics = "contacts-service"

type 
  Service* = ref object of ServiceInterface
    contacts: Table[string, ContactsDto] # [contact_id, ContactsDto]

method delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()
  result.contacts = initTable[string, ContactsDto]()

method init*(self: Service) =
  try:
    let response = status_go.getContacts()

    let contacts = map(response.result.getElems(), 
    proc(x: JsonNode): ContactsDto = x.toContactsDto())

    for contact in contacts:
      self.contacts[contact.id] = contact

  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return