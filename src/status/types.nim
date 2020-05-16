type SignalCallback* = proc(eventMessage: cstring): void {.cdecl.}

type SignalType* {.pure.} = enum
  Message = "messages.new"
  Wallet = "wallet"
  NodeStarted = "node.started"
  NodeLogin = "node.login"
  EnvelopeSent = "envelope.sent"
  EnvelopeExpired = "envelope.expired"
  MailserverRequestCompleted = "mailserver.request.completed"
  MailserverRequestExpired = "mailserver.request.expired"
  DiscoverSummary = "discover.summary"
  SubscriptionsData = "subscriptions.data"
  SubscriptionsError = "subscriptions.error"
  WhisperFilterAdded = "whisper.filter.added"
  Unknown
