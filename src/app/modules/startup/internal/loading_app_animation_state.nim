import state

type
  LoadingAppAnimationState* = ref object of State

proc newLoadingAppAnimationState*(flowType: FlowType, backState: State): LoadingAppAnimationState =
  result = LoadingAppAnimationState()
  result.setup(flowType, StateType.LoadingAppAnimation, backState)

proc delete*(self: LoadingAppAnimationState) =
  self.State.delete
