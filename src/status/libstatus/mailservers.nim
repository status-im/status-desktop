import json, times
import core, utils

type
  MailserverTopic* = ref object
    topic*: string
    discovery*: bool
    negotiated*: bool
    chatIds*: seq[string]
    lastRequest*: int64

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

proc requestMessages*(topics: seq[string], symKeyID: string, peer: string, numberOfMessages: int, fromTimestamp: int64 = 0, toTimestamp: int64 = 0, force: bool = false) =
  var toValue = times.toUnix(times.getTime())
  var fromValue = toValue - 86400
  if fromTimestamp != 0:
    fromValue = fromTimestamp
  if toTimestamp != 0:
    toValue = toTimestamp

  discard callPrivateRPC("requestMessages".prefix, %* [
    {
        "topics": topics,
        "mailServerPeer": peer,
        "symKeyID": symKeyID,
        "timeout": 30,
        "limit": numberOfMessages,
        "cursor": nil,
        "from": fromValue,
        "to": toValue,
        "force": force
    }
  ])

proc requestAllHistoricMessages*(): string =
  return callPrivateRPC("requestAllHistoricMessages".prefix, %*[])

proc fillGaps*(chatId: string, messageIds: seq[string]): string =
  return callPrivateRPC("fillGaps".prefix, %*[chatId, messageIds])

proc getMailserverTopics*(): string =
  return callPrivateRPC("mailservers_getMailserverTopics", %*[])

proc addMailserverTopic*(topic: MailserverTopic): string =
  return callPrivateRPC("mailservers_addMailserverTopic", %*[{
    "topic": topic.topic,
    "discovery?": topic.discovery,
    "negotiated?": topic.negotiated,
    "chat-ids": topic.chatIds,
    "last-request": topic.lastRequest
  }])

proc deleteMailserverTopic*(topic: string): string =
  return callPrivateRPC("mailservers_deleteMailserverTopic", %*[topic])
