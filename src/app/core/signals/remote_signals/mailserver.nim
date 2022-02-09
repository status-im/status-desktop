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
  requestId*: string
  numBatches*: int

type HistoryRequestBatchProcessedSignal* = ref object of Signal
  requestId*: string
  batchIndex*: int
  numBatches*: int

type HistoryRequestCompletedSignal* = ref object of Signal
  requestId*: string

type HistoryRequestFailedSignal* = ref object of Signal
  requestId*: string
  errorMessage*: string
  error*: bool

type MailserverAvailableSignal* = ref object of Signal
  address*: string

type MailserverChangedSignal* = ref object of Signal
  address*: string

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
  result.requestId = jsonSignal["event"]{"requestId"}.getStr()
  result.numBatches = jsonSIgnal["event"]{"numBatches"}.getInt()

proc fromEvent*(T: type HistoryRequestBatchProcessedSignal, jsonSignal: JsonNode): HistoryRequestBatchProcessedSignal =
  result = HistoryRequestBatchProcessedSignal()
  result.signalType = SignalType.HistoryRequestBatchProcessed
  result.requestId = jsonSignal["event"]{"requestId"}.getStr()
  result.batchIndex = jsonSIgnal["event"]{"batchIndex"}.getInt()
  result.numBatches = jsonSIgnal["event"]{"numBatches"}.getInt()

proc fromEvent*(T: type HistoryRequestCompletedSignal, jsonSignal: JsonNode): HistoryRequestCompletedSignal =
  result = HistoryRequestCompletedSignal()
  result.signalType = SignalType.HistoryRequestCompleted
  result.requestId = jsonSignal["event"]{"requestId"}.getStr()

proc fromEvent*(T: type HistoryRequestFailedSignal, jsonSignal: JsonNode): HistoryRequestFailedSignal =
  result = HistoryRequestFailedSignal()
  result.signalType = SignalType.HistoryRequestStarted
  result.requestId = jsonSignal["event"]{"requestId"}.getStr()
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
