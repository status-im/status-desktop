import eventemitter
import json
import libstatus/contacts as status_contacts
import profile

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

proc getContacts*(self: ContactModel): JsonNode =
  status_contacts.getContacts()

proc addContact*(self: ContactModel, id: string): string =
  let contact = self.getContactByID(id)
  status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensVerifiedAt, contact.ensVerificationRetries, contact.alias, contact.identicon, contact.systemTags)
