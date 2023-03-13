import NimQml

QtObject:
  type Contact* = ref object of QObject
    firstName: string
    lastName: string

  proc delete*(self: Contact) =
    self.QObject.delete

  proc setup(self: Contact) =
    self.QObject.setup

  proc newContact*(): Contact =
    new(result)
    result.firstName = ""
    result.lastName = ""
    result.setup

  proc firstName*(self: Contact): string {.slot.} =
    result = self.firstName

  proc firstNameChanged*(self: Contact) {.signal.}

  proc setFirstName(self: Contact, firstName: string) {.slot.} =
    if self.firstName == firstName: return
    self.firstName = firstName
    self.firstNameChanged()

  proc `firstName=`*(self: Contact, firstName: string) = self.setFirstName(firstName)

  QtProperty[string] firstName:
    read = firstName
    write = setFirstName
    notify = firstNameChanged

  proc lastName*(self: Contact): string {.slot.} =
    result = self.lastName

  proc lastNameChanged*(self: Contact) {.signal.}

  proc setLastName(self: Contact, lastName: string) {.slot.} =
    if self.lastName == lastName: return
    self.lastName = lastName
    self.lastNameChanged()

  proc `lastName=`*(self: Contact, lastName: string) = self.setLastName(lastName)

  QtProperty[string] lastName:
    read = lastName
    write = setLastName
    notify = lastNameChanged
