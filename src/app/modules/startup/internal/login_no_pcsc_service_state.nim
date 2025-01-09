type LoginNoPCSCServiceState* = ref object of State

proc newLoginNoPCSCServiceState*(
    flowType: FlowType, backState: State
): LoginNoPCSCServiceState =
  result = LoginNoPCSCServiceState()
  result.setup(flowType, StateType.LoginNoPCSCService, backState)

proc delete*(self: LoginNoPCSCServiceState) =
  self.State.delete

method executePrimaryCommand*(self: LoginNoPCSCServiceState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    controller.runLoadAccountFlow(
      seedPhraseLength = 0, seedPhrase = "", pin = "", puk = "", factoryReset = true
    )

method getNextTertiaryState*(
    self: LoginNoPCSCServiceState, controller: Controller
): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextQuaternaryState*(
    self: LoginNoPCSCServiceState, controller: Controller
): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method getNextQuinaryState*(
    self: LoginNoPCSCServiceState, controller: Controller
): State =
  if self.flowType == FlowType.AppLogin:
    controller.cancelCurrentFlow()
    return createState(StateType.LostKeycardOptions, self.flowType, self)

method resolveKeycardNextState*(
    self: LoginNoPCSCServiceState,
    keycardFlowType: string,
    keycardEvent: KeycardEvent,
    controller: Controller,
): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(
    self, keycardFlowType, keycardEvent, controller
  )
