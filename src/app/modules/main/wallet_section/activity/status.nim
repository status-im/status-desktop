import NimQml, std/json, sequtils, strutils, times
import tables, stint, sets, atomics

import web3/conversions

import app/core/signals/types

import backend/activity as backend_activity

# Status's responsibility is to keep track and report the general state of the backend
QtObject:
  type
    Status* = ref object of QObject
      loadingData: Atomic[int]
      errorCode: backend_activity.ErrorCode

      loadingRecipients: Atomic[int]
      loadingStartTimestamp: Atomic[int]

      startTimestamp: int

      newDataAvailable: bool

  proc setup(self: Status) =
    self.QObject.setup

  proc delete*(self: Status) =
    self.QObject.delete

  proc loadingDataChanged*(self: Status) {.signal.}

  proc setLoadingData*(self: Status, loadingData: bool) =
    discard fetchAdd(self.loadingData, if loadingData: 1 else: -1)
    self.loadingDataChanged()

  proc loadingRecipientsChanged*(self: Status) {.signal.}

  proc setLoadingRecipients*(self: Status, loadingData: bool) =
    discard fetchAdd(self.loadingRecipients, if loadingData: 1 else: -1)
    self.loadingRecipientsChanged()

  proc loadingStartTimestampChanged*(self: Status) {.signal.}

  proc setLoadingStartTimestamp*(self: Status, loadingData: bool) =
    discard fetchAdd(self.loadingStartTimestamp, if loadingData: 1 else: -1)
    self.loadingStartTimestampChanged()

  proc errorCodeChanged*(self: Status) {.signal.}

  proc setErrorCode*(self: Status, errorCode: int) =
    self.errorCode = backend_activity.ErrorCode(errorCode)
    self.errorCodeChanged()

  proc newStatus*(): Status =
    new(result, delete)

    result.errorCode = backend_activity.ErrorCode.ErrorCodeSuccess

    result.setup()

  proc getLoadingData*(self: Status): bool {.slot.} =
    return load(self.loadingData) > 0

  QtProperty[bool] loadingData:
    read = getLoadingData
    notify = loadingDataChanged

  proc getErrorCode*(self: Status): int {.slot.} =
    return self.errorCode.int

  QtProperty[int] errorCode:
    read = getErrorCode
    notify = errorCodeChanged

  proc getLoadingRecipients*(self: Status): bool {.slot.} =
    return load(self.loadingRecipients) > 0

  QtProperty[bool] loadingRecipients:
    read = getLoadingRecipients
    notify = loadingRecipientsChanged

  proc getLoadingStartTimestamp*(self: Status): bool {.slot.} =
    return load(self.loadingStartTimestamp) > 0

  QtProperty[bool] loadingStartTimestamp:
    read = getLoadingStartTimestamp
    notify = loadingStartTimestampChanged

  proc startTimestampChanged*(self: Status) {.signal.}

  proc setStartTimestamp*(self: Status, startTimestamp: int) =
    self.startTimestamp = startTimestamp
    self.startTimestampChanged()

  proc getStartTimestamp*(self: Status): int {.slot.} =
    return if self.startTimestamp > 0: self.startTimestamp
           else: int(times.parse("2000-01-01", "yyyy-MM-dd").toTime().toUnix())

  QtProperty[int] startTimestamp:
    read = getStartTimestamp
    notify = startTimestampChanged

  proc newDataAvailableChanged*(self: Status) {.signal.}

  proc setNewDataAvailable*(self: Status, newDataAvailable: bool) =
    self.newDataAvailable = newDataAvailable
    self.newDataAvailableChanged()

  proc getNewDataAvailable*(self: Status): bool {.slot.} =
    return self.newDataAvailable

  QtProperty[bool] newDataAvailable:
    read = getNewDataAvailable
    notify = newDataAvailableChanged