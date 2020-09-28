import NimQml, os
import ../../status/status
import ../../status/libstatus/accounts/constants as accountConstants

QtObject:
  type UtilsView* = ref object of QObject
    status*: Status

  proc setup(self: UtilsView) =
    self.QObject.setup

  proc delete*(self: UtilsView) =
    self.QObject.delete

  proc newUtilsView*(status: Status): UtilsView =
    new(result, delete)
    result = UtilsView()
    result.status = status
    result.setup

  proc getDataDir*(self: UtilsView): string {.slot.} =
    result = accountConstants.DATADIR

  proc joinPath*(self: UtilsView, start: string, ending: string): string {.slot.} =
    result = os.joinPath(start, ending)

  proc join3Paths*(self: UtilsView, start: string, middle: string, ending: string): string {.slot.} =
    result = os.joinPath(start, middle, ending)

  proc urlFromUserInput*(self: UtilsView, input: string): string {.slot.} =
    result = url_fromUserInput(input)
