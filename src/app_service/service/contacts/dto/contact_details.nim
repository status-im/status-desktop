{.used.}

import contacts

export contacts

type
  ContactDetails* = object
    displayName*: string
    icon*: string
    isCurrentUser*: bool
    colorId*: int
    details*: ContactsDto
