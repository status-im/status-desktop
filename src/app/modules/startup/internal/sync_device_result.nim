type
  SyncDeviceResultState* = ref object of State

proc newSyncDeviceResultState*(flowType: FlowType, backState: State): SyncDeviceResultState =
  result = SyncDeviceResultState()
  result.setup(flowType, StateType.SyncDeviceResult, backState)

proc delete*(self: SyncDeviceResultState) =
  self.State.delete

method executePrimaryCommand*(self: SyncDeviceResultState, controller: Controller) =
  controller.loginLocalPairingAccount()
