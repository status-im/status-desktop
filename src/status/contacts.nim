import eventemitter
import json
import libstatus/contacts as status_contacts
import profile

type
  Contact* = ref object
    name*, address*: string

type
  ContactModel* = ref object
    events*: EventEmitter

proc newContactModel*(events: EventEmitter): ContactModel =
    result = ContactModel()
    result.events = events

proc getContactByID*(self: ContactModel, id: string): Profile =
  let response = status_contacts.getContactByID(id)
  toProfileModel(parseJSON($response)["result"])

proc blockContact*(self: ContactModel, id: string): string =
  var contact = self.getContactByID(id)
  contact.systemTags.add(":contact/blocked")
  status_contacts.blockContact(contact)
