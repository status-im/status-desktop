import io_interface

type Controller* = ref object of RootObj
  delegate: io_interface.AccessInterface

proc newController*(delegate: io_interface.AccessInterface): Controller =
  result = Controller()
  result.delegate = delegate

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard
