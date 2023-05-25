{.used.}

import contacts

export contacts

type
  ContactDetails* = object
    defaultDisplayName*: string
    optionalName*: string
    icon*: string
    isCurrentUser*: bool
    colorId*: int
    colorHash*: string
    dto*: ContactsDto
