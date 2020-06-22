import strutils
import profile/profile

let domain* = ".stateofus.eth"

proc userName*(ensName: string, removeSuffix: bool = false): string =
  if ensName != "" and ensName.endsWith(domain):
    if removeSuffix: 
      result = ensName.split(".")[0]
    else:
      result = ensName
  else:
    result = ensName

proc userNameOrAlias*(contact: Profile): string =
  if(contact.ensName != "" and contact.ensVerified):
    result = "@" & userName(contact.ensName, true)
  else:
    result = contact.alias