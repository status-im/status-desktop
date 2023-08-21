type
  DisplayInstructionsState* = ref object of State

proc newDisplayInstructionsState*(backState: State): DisplayInstructionsState =
  result = DisplayInstructionsState()
  result.setup(StateType.DisplayInstructions, backState)

proc delete*(self: DisplayInstructionsState) =
  self.State.delete
