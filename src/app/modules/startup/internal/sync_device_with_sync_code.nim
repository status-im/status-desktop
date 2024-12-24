type
  SyncDeviceWithSyncCodeState* = ref object of State

proc newSyncDeviceWithSyncCodeState*(flowType: FlowType, backState: State): SyncDeviceWithSyncCodeState =
  result = SyncDeviceWithSyncCodeState()
  result.setup(flowType, StateType.SyncDeviceWithSyncCode, backState)

proc delete*(self: SyncDeviceWithSyncCodeState) =
  self.State.delete

method executePrimaryCommand*(self: SyncDeviceWithSyncCodeState, controller: Controller) =
  let connectionString = controller.getConnectionString()
  controller.inputConnectionStringForBootstrapping(connectionString)

method getNextPrimaryState*(self: SyncDeviceWithSyncCodeState, controller: Controller): State =
  return createState(StateType.SyncDeviceResult, self.flowType, self)