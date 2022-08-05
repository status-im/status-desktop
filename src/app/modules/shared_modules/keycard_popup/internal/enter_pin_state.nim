type
  EnterPinState* = ref object of State

proc newEnterPinState*(flowType: FlowType, backState: State): EnterPinState =
  result = EnterPinState()
  result.setup(flowType, StateType.EnterPin, backState)

proc delete*(self: EnterPinState) =
  self.State.delete
