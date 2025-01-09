type SyncDeviceResultState* = ref object of State

proc newSyncDeviceResultState*(
    flowType: FlowType, backState: State
): SyncDeviceResultState =
  result = SyncDeviceResultState()
  result.setup(flowType, StateType.SyncDeviceResult, backState)

proc delete*(self: SyncDeviceResultState) =
  self.State.delete

method executePrimaryCommand*(self: SyncDeviceResultState, controller: Controller) =
  controller.loginLocalPairingAccount()

method getNextSecondaryState*(
    self: SyncDeviceResultState, controller: Controller
): State =
  return createState(
    StateType.UserProfileEnterSeedPhrase, FlowType.FirstRunOldUserImportSeedPhrase, self
  )

method getNextTertiaryState*(
    self: SyncDeviceResultState, controller: Controller
): State =
  return createState(
    StateType.SyncDeviceWithSyncCode, FlowType.FirstRunOldUserSyncCode, self
  )
