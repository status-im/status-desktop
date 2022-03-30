type
  ContactVerificationState* {.pure.} = enum
    NotMarked = 0
    Verified    
    Untrustworthy

type
  Item* = ref object
    pubKey: string
    name: string
    icon: string
    isBlocked: bool
    isMutualContact: bool
    verificationState: ContactVerificationState

proc initItem*(pubKey, name, icon: string, isMutualContact, isBlocked: bool, 
  isContactVerified, isContactUntrustworthy: bool): Item =
  result = Item()
  result.pubKey = pubKey
  result.name = name
  result.icon = icon
  result.isMutualContact = isMutualContact
  result.isBlocked = isBlocked
  if(isContactVerified):
    result.verificationState = ContactVerificationState.Verified
  elif(isContactUntrustworthy):
    result.verificationState = ContactVerificationState.Untrustworthy
  else:
    result.verificationState = ContactVerificationState.NotMarked

proc pubKey*(self: Item): string =
  self.pubKey

proc name*(self: Item): string =
  self.name

proc `name=`*(self: Item, value: string) =
  self.name = value

proc icon*(self: Item): string =
  self.icon

proc isMutualContact*(self: Item): bool =
  self.isMutualContact

proc isBlocked*(self: Item): bool =
  self.isBlocked

proc verificationState*(self: Item): ContactVerificationState =
  self.verificationState
