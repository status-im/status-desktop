type
  ScanQrState* = ref object of State

proc newScanQrState*(backState: State): ScanQrState =
  result = ScanQrState()
  result.setup(StateType.ScanQr, backState)

proc delete*(self: ScanQrState) =
  self.State.delete

method getNextPrimaryState*(self: ScanQrState, controller: Controller): State =
  discard