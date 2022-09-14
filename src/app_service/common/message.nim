import sequtils, strutils, sugar, re
import ../service/contacts/dto/contacts

proc replaceMentionsWithPubKeys*(allKnownContacts: seq[ContactsDto], message: string): string =
  let aliasPattern = re(r"(@[A-z][a-z]+ [A-z][a-z]* [A-z][a-z]*)", flags = {reStudy, reIgnoreCase})
  let ensPattern = re(r"(@\w+((\.stateofus)?\.eth))", flags = {reStudy, reIgnoreCase})
  let namePattern = re(r"(@\w+)", flags = {reStudy, reIgnoreCase})

  let aliasMentions = findAll(message, aliasPattern)
  let ensMentions = findAll(message, ensPattern)
  let nameMentions = findAll(message, namePattern)
  var updatedMessage = message

  # In the following lines we're free to compare to `x.userDefaultDisplayName()` cause that's actually what we're displaying
  # in the mentions suggestion list.
  for mention in aliasMentions:
    let listOfMatched = allKnownContacts.filter(x => "@" & x.userDefaultDisplayName().toLowerAscii == mention.toLowerAscii)
    if(listOfMatched.len > 0):
      updatedMessage = updatedMessage.replaceWord(mention, '@' & listOfMatched[0].id)

  for mention in ensMentions:
    let listOfMatched = allKnownContacts.filter(x => "@" & x.name.toLowerAscii == mention.toLowerAscii)
    if(listOfMatched.len > 0):
      updatedMessage = updatedMessage.replaceWord(mention, '@' & listOfMatched[0].id)

  for mention in nameMentions:
    let listOfMatched = allKnownContacts.filter(x => x.userDefaultDisplayName().toLowerAscii == mention.toLowerAscii or
      "@" & x.userDefaultDisplayName().toLowerAscii == mention.toLowerAscii)
    if(listOfMatched.len > 0):
      updatedMessage = updatedMessage.replaceWord(mention, '@' & listOfMatched[0].id)
  return updatedMessage
