import strformat

type
  IdentityImage* = ref object
    thumbnail*: string
    large*: string

type 
  Item* = object
    id*, alias*, username*, identicon*, address*, ensName*, localNickname*: string
    ensVerified*: bool
    messagesFromContactsOnly*: bool
    sendUserStatus*: bool
    currentUserStatus*: int
    identityImage*: IdentityImage
    appearance*: int
    added*: bool
    blocked*: bool
    hasAddedUs*: bool

proc `$`*(self: Item): string =
  result = fmt"""ProfileDto(
    username: {self.username},
    identicon: {self.identicon},
    messagesFromContactsOnly: {self.messagesFromContactsOnly}
    )"""
