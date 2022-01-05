{.used.}

import contacts

export contacts

type
  ContactDetails* = object
    displayName*: string
    icon*: string
    isIdenticon*: bool
    isCurrentUser*: bool
    details*: ContactsDto