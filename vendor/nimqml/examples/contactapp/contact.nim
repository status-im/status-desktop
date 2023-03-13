import NimQml

QtObject:
  type Contact* = ref object of QObject
    name: string
    surname: string

  proc delete*(self: Contact) =
    self.QObject.delete

  proc setup(self: Contact) =
    self.QObject.setup

  proc newContact*(): Contact =
    new(result)
    result.name = ""
    result.setup

  proc firstName*(self: Contact): string {.slot.} =
    result = self.name

  proc firstNameChanged*(self: Contact, firstName: string) {.signal.}

  proc setFirstName(self: Contact, name: string) {.slot.} =
    if self.name == name: return
    self.name = name
    self.firstNameChanged(name)

  proc `firstName=`*(self: Contact, name: string) = self.setFirstName(name)

  QtProperty[string] firstName:
    read = firstName
    write = setFirstName
    notify = firstNameChanged

  proc surname*(self: Contact): string {.slot.} =
    result = self.surname

  proc surnameChanged*(self: Contact, surname: string) {.signal.}

  proc setSurname(self: Contact, surname: string) {.slot.} =
    if self.surname == surname: return
    self.surname = surname
    self.surnameChanged(surname)

  proc `surname=`*(self: Contact, surname: string) = self.setSurname(surname)

  QtProperty[string] surname:
    read = surname
    write = setSurname
    notify = surnameChanged
