import eventemitter
import libstatus/types

type
  MailServer* = ref object
    name*, endpoint*: string

type
  Contact* = ref object
    name*, address*: string

type Profile* = ref object
    username*, identicon*: string

proc toProfileModel*(account: Account): Profile =
    result = Profile(username: account.name, identicon: account.photoPath)
