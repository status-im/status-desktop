import json, times
import core, utils

proc ping*(mailservers: seq[string], timeoutMs: int): string =
  var addresses: seq[string] = @[]
  for mailserver in mailservers:
    addresses.add(mailserver)
  result = callPrivateRPC("mailservers_ping", %* [
    { "addresses": addresses, "timeoutMs": timeoutMs }
  ])

proc update*(peer: string) =
  discard callPrivateRPC("updateMailservers".prefix, %* [[peer]])

proc delete*(peer: string) =
  discard callPrivateRPC("mailservers_deleteMailserver", %* [peer])

proc requestAllHistoricMessages*(): string =
  return callPrivateRPC("requestAllHistoricMessages".prefix, %*[])

proc syncChatFromSyncedFrom*(chatId: string): string =
  return callPrivateRPC("syncChatFromSyncedFrom".prefix, %*[chatId])

proc fillGaps*(chatId: string, messageIds: seq[string]): string =
  return callPrivateRPC("fillGaps".prefix, %*[chatId, messageIds])
