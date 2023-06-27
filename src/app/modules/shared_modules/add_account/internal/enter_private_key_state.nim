type
  EnterPrivateKeyState* = ref object of State

proc newEnterPrivateKeyState*(backState: State): EnterPrivateKeyState =
  result = EnterPrivateKeyState()
  result.setup(StateType.EnterPrivateKey, backState)

proc delete*(self: EnterPrivateKeyState) =
  self.State.delete
  
method executePrePrimaryStateCommand*(self: EnterPrivateKeyState, controller: Controller) =
  controller.buildNewPrivateKeyKeypairAndAddItToOrigin()

method getNextPrimaryState*(self: EnterPrivateKeyState, controller: Controller): State =
  return createState(StateType.Main, nil)