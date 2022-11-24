import json

import base
import signal_type

type MailserverRequestCompletedSignal* = ref object of Signal
  requestID*: string
  lastEnvelopeHash*: string
  cursor*: string
  errorMessage*: string
  error*: bool

type MailserverRequestExpiredSignal* = ref object of Signal
  # TODO

type HistoryRequestStartedSignal* = ref object of Signal
  numBatches*: int

type HistoryRequestSuccessSignal* = ref object of Signal
  requestId*: string
  peerId*: string

type HistoryRequestCompletedSignal* = ref object of Signal

type HistoryRequestFailedSignal* = ref object of Signal
  requestId*: string
  peerId*: string
  errorMessage*: string
  error*: bool

type MailserverAvailableSignal* = ref object of Signal
  address*: string

type MailserverChangedSignal* = ref object of Signal
  address*: string

type MailserverNotWorkingSignal* = ref object of Signal

proc fromEvent*(T: type MailserverRequestCompletedSignal, jsonSignal: JsonNode): MailserverRequestCompletedSignal =
  result = MailserverRequestCompletedSignal()
  result.signalType = SignalType.MailserverRequestCompleted
  if jsonSignal["event"].kind != JNull:
    result.requestID = jsonSignal["event"]{"requestID"}.getStr()
    result.lastEnvelopeHash = jsonSignal["event"]{"lastEnvelopeHash"}.getStr()
    result.cursor = jsonSignal["event"]{"cursor"}.getStr()
    result.errorMessage = jsonSignal["event"]{"errorMessage"}.getStr()
    result.error = result.errorMessage != ""

proc fromEvent*(T: type MailserverRequestExpiredSignal, jsonSignal: JsonNode): MailserverRequestExpiredSignal =
  # TODO: parse signal
  result = MailserverRequestExpiredSignal()
  result.signalType = SignalType.MailserverRequestExpired

proc fromEvent*(T: type HistoryRequestStartedSignal, jsonSignal: JsonNode): HistoryRequestStartedSignal =
  result = HistoryRequestStartedSignal()
  result.signalType = SignalType.HistoryRequestStarted
  result.numBatches = jsonSIgnal["event"]{"numBatches"}.getInt()

proc fromEvent*(T: type HistoryRequestSuccessSignal, jsonSignal: JsonNode): HistoryRequestSuccessSignal =
  result = HistoryRequestSuccessSignal()
  result.signalType = SignalType.HistoryRequestSuccess
  result.requestId = jsonSignal["event"]{"requestId"}.getStr()
  result.peerId = jsonSignal["event"]{"peerId"}.getStr()

proc fromEvent*(T: type HistoryRequestCompletedSignal, jsonSignal: JsonNode): HistoryRequestCompletedSignal =
  result = HistoryRequestCompletedSignal()
  result.signalType = SignalType.HistoryRequestCompleted

proc fromEvent*(T: type HistoryRequestFailedSignal, jsonSignal: JsonNode): HistoryRequestFailedSignal =
  result = HistoryRequestFailedSignal()
  result.signalType = SignalType.HistoryRequestFailed
  result.requestId = jsonSignal["event"]{"requestId"}.getStr()
  result.peerId = jsonSignal["event"]{"peerId"}.getStr()
  if jsonSignal["event"].kind != JNull:
    result.errorMessage = jsonSignal["event"]{"errorMessage"}.getStr()
    result.error = result.errorMessage != ""

proc fromEvent*(T: type MailserverAvailableSignal, jsonSignal: JsonNode): MailserverAvailableSignal =
  result = MailserverAvailableSignal()
  result.signalType = SignalType.MailserverAvailable
  result.address = jsonSignal["event"]{"address"}.getStr()

proc fromEvent*(T: type MailserverChangedSignal, jsonSignal: JsonNode): MailserverChangedSignal =
  result = MailserverChangedSignal()
  result.signalType = SignalType.MailserverChanged
  result.address = jsonSignal["event"]{"address"}.getStr()

proc fromEvent*(T: type MailserverNotWorkingSignal, jsonSignal: JsonNode): MailserverNotWorkingSignal =
  result = MailserverNotWorkingSignal()
  result.signalType = SignalType.MailseverNotWorking
